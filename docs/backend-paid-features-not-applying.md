# Оплата проходит, но VIP / Boost / Лимит не применяются — общая причина

**Дата:** 2026-09-21
**Кому:** команда бэкенда (`kodo-az/api.wawatair.com`)
**От:** мобильный клиент
**Приоритет:** блокер продаж (все три платные фичи не работают)

Симптом с телефона: пользователь платит за **VIP**, за **Boost (продвижение)** и
за **увеличение лимита объявлений** — оплата в сторе проходит (Apple/Google
показывает «куплено»), но на бэкенде **ничего не происходит**: объявление не
становится VIP, не становится продвинутым, лимит не растёт. Все три фичи ведут
себя одинаково.

Разбор клиента и бэкенда (по коду) показал **одну общую причину** и несколько
вторичных. Причина №1 — на бэкенде, в один переключатель.

---

## ГЛАВНАЯ ПРИЧИНА: `iap.apple_live` / `iap.google_live` = false → работает SandboxVerifier

Все три фичи (VIP, Boost, Лимит) при оплате через App Store / Google Play идут
через один и тот же шов:

```
POST /promotions/{id}/pay           (VIP, Boost)
POST /listing-quota/orders/{id}/pay (Лимит)
  → RedeemsStorePurchase::redeemStorePurchase
  → IapService::redeem()
  → VerifierFactory::for($platform)->verify($platform, $token, $expected)
```

`VerifierFactory` выбирает верификатор **по настройке из БД**:

```php
// app/Support/Iap/VerifierFactory.php:15-23
PurchasePlatform::Ios => $this->settings->apple_live
    ? app(AppleReceiptVerifier::class)
    : app(SandboxVerifier::class),
PurchasePlatform::Android => $this->settings->google_live
    ? app(GoogleReceiptVerifier::class)
    : app(SandboxVerifier::class),
```

Дефолт этих настроек — **false**:

```php
// database/settings/2026_09_09_140000_iap_per_platform_mode.php
$this->migrator->add('iap.apple_live', false);
$this->migrator->add('iap.google_live', false);
```

Пока `apple_live=false`, iOS-покупки проверяет **`SandboxVerifier`**, а он
принимает ТОЛЬКО синтетический тестовый токен и отклоняет любой реальный чек:

```php
// app/Support/Iap/SandboxVerifier.php:27-29
if (($parts[0] ?? '') !== 'sandbox') {
    return new VerifiedPurchase(valid: false, ...);   // реальный чек StoreKit сюда и попадает
}
```

Приложение шлёт **настоящий чек StoreKit** (`receipt =
purchase.verificationData.serverVerificationData`), который начинается не с
`sandbox|`, а с `MII...`. Дальше:

```php
// app/Services/IapService.php:48-49
if (! $verified->valid) {
    throw DomainException::unprocessable(cms('purchase.invalid', default: 'Alış təsdiqlənmədi.')); // HTTP 422
}
```

→ `/pay` отвечает **422 `purchase.invalid`**, `activate()` не вызывается,
`markPaidVia()` не вызывается. **Ни VIP, ни Boost, ни Лимит не активируются.**

**Почему выглядит как «оплата прошла».** На 422 клиент оставляет транзакцию
StoreKit **незавершённой** (завершает только на 404), поэтому стор
переотправляет покупку при каждом запуске приложения, и Apple продолжает
показывать «куплено», хотя бэкенд каждый раз отклоняет чек.

### Что сделать (причина №1)

1. В настройках (Spatie settings, group `iap`) выставить:
   - **`iap.apple_live = true`**
   - **`iap.google_live = true`**

   Через админку (`AdminV2\SettingsController`, `IapSettings::class`) или tinker
   **на вашем сервере `api.wawatair.com`**:
   ```php
   $s = app(App\Settings\IapSettings::class);
   $s->apple_live = true;
   $s->google_live = true;
   $s->save();
   ```

> Прошлый хендофф (`backend-iap-payment-audit-fix.md`, 20 сент.) назвал причиной
> пустой `APPLE_IAP_BUNDLE_ID` и **пропустил этот переключатель**. Даже с
> заданным `bundle_id`, пока `apple_live=false`, `AppleReceiptVerifier`
> **не создаётся вообще** — реальные чеки продолжают отклоняться. Начинать надо
> именно с `apple_live/google_live`.

---

## Причина №2: после `apple_live=true` верификатору нужны реквизиты

Когда `apple_live=true`, iOS-чек проверяет `AppleReceiptVerifier`. Клиент
принудительно включает **StoreKit 1** (base64 app receipt), поэтому чек идёт по
пути `viaVerifyReceipt` — а ему нужен **только** bundle id (никакие `.p8`-ключи
для этого пути НЕ требуются):

```php
// app/Support/Iap/AppleReceiptVerifier.php:34-38
$bundleId = (string) config('services.apple_iap.bundle_id', '');
if ($bundleId === '') { throw $this->unavailable(); }   // иначе 503
```

`config/services.php:56` → `env('APPLE_IAP_BUNDLE_ID', '')` (по умолчанию пусто,
в `.env.example` ключа нет).

### Что сделать (причина №2)

В прод `.env` и в `.env.example`:
```dotenv
# Apple (для SK1 verifyReceipt достаточно ТОЛЬКО bundle_id)
APPLE_IAP_BUNDLE_ID=wawat.app

# Android (для GoogleReceiptVerifier)
GOOGLE_PLAY_PACKAGE_NAME=az.buking.buking
GOOGLE_PLAY_SERVICE_ACCOUNT=/абсолютный/путь/service-account.json
```

`.p8`-ключи (`APPLE_IAP_KEY_ID/ISSUER_ID/TEAM_ID/PRIVATE_KEY_PATH`) нужны только
если позже вернёте клиент на StoreKit 2 (JWS). Сейчас — не нужны.

---

## Причина №3 (важно для теста): не тестировать локальным `.storekit`

Чеки, выданные локальным файлом `ios/WawatProducts.storekit` (запуск из Xcode со
StoreKit Configuration), подписаны **локальным тестовым CA** и НЕ проходят
проверку на реальных эндпоинтах Apple (`verifyReceipt` / App Store Server API) —
даже при корректных `apple_live` и `bundle_id`.

**Тестировать только через настоящий Apple Sandbox-аккаунт или TestFlight.**
Тогда чек настоящий, `verifyReceipt` вернёт status 0 (в TestFlight — через
sandbox после 21007, это уже обработано в коде).

---

## Карта (Kapital) — только если пользователь платит картой, не через стор

Для VIP/Boost картой активация происходит **не сразу**, а когда браузер дойдёт до
`GET /api/v1/payments/kapital/callback/{promotion.public_id}` →
`PaymentCallbackController::kapital` → `confirmCardPayment()`. URL строится из
`config('services.kapital.return_url_base')`, который завязан на `APP_URL`. В
`.env.example` `APP_URL=http://localhost:8080` — с таким значением Kapital
редиректит браузер на недоступный адрес, callback не срабатывает, промо навсегда
остаётся `pending_payment`.

- Если карта в игре: `APP_URL` / `KAPITAL_RETURN_URL_BASE` — публичный https-хост;
  `PaymentSettings::card_enabled=true`, `mock_payments=false`.
- **Для лимита картой callback-а нет вообще**: `ListingQuotaPurchaseService::pay()`
  для метода `card` при `mock_payments=false` кидает `provider_unavailable`. Лимит
  можно оплатить **только через стор** (или mock). Клиент на iOS всё равно
  показывает плитку карты для лимита — это отдельный клиентский недочёт (ниже).

Поскольку **все три** фичи падают одинаково, а лимит картой на бэкенде не
поддерживается, живой способ оплаты — это **стор (IAP)**, то есть причина №1.

---

## Вторичное: промо на объявлении «на модерации» паркуется (не баг, но объясняет часть кейсов)

Если объявление **не в discoverable-статусе** (`active` / `partially_booked` /
`fully_booked`), `ActivatePromotionAction::execute` (строки 26-30) ставит промо в
`pending_activation`, деньги уже списаны, `listing.promotion_type` не трогается:

```php
if (! $this->listingIsDiscoverable($listing)) {
    $promotion->update(['status' => PromotionStatus::PendingActivation]);
    return $promotion;   // activated = false
}
```

Это by design (промо стартует, когда объявление одобрят). **Проверьте, что есть
триггер, который применяет `pending_activation`-промо в момент, когда объявление
становится discoverable** — иначе оплаченное промо так и не запустится.

---

## Живая диагностика (на вашей стороне, `api.wawatair.com`)

1. Проверить настройки: в tinker вывести `app(App\Settings\IapSettings::class)` —
   если `apple_live=false`, причина №1 подтверждена.
2. Смотреть ответ `/pay` при тестовой покупке: должен быть **HTTP 200 + `data.activated`**.
   Если **422 `purchase.invalid`** (`Alış təsdiqlənmədi`) — чек отклонён верификатором.
3. Логи: `POST /promotions/{id}/pay` и `/listing-quota/orders/{id}/pay` с 422; в логах
   Apple — `verifyReceipt rejected` / `verifyReceipt ok`.
4. После покупки: `GET /api/v1/me` → `listing_quota[type].{limit,remaining}`;
   `GET /api/v1/promotions/{id}` → `status` (`active` vs `pending_activation` vs
   `pending_payment`); у объявления — `promotion_type`. Так `422/никогда не Paid`
   отделяется от `Paid, но pending_activation`.
5. Уточнить метод: в теле iOS-запроса `{"method":"apple","receipt":...}`. Если там
   `method:"card"` — диагноз смещается на Kapital-callback (раздел про карту).

## Порядок действий

1. `iap.apple_live=true`, `iap.google_live=true` (причина №1 — главный блокер).
2. `APPLE_IAP_BUNDLE_ID=wawat.app`, `GOOGLE_PLAY_PACKAGE_NAME` + service-account (причина №2).
3. Тест через реальный Sandbox/TestFlight, не через локальный `.storekit` (причина №3).
4. Убедиться, что применяется `pending_activation` при одобрении объявления.
5. Если используется карта — публичный `APP_URL`/`KAPITAL_RETURN_URL_BASE`.

После п.1–3 незавершённые (застрявшие) транзакции StoreKit сами переотправятся при
следующем запуске приложения и активируют ранее оплаченные заказы —
дополнительных действий на клиенте не требуется.
