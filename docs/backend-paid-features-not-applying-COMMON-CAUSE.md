# Оплата проходит, но VIP / буст / лимит не применяются — общая причина

**Дата:** 2026-09-21
**Симптом:** в приложении оплата «проходит», но объявление не становится VIP,
не становится продвинутым (буст), и лимит на добавление объявлений не растёт —
**все три функции ведут себя одинаково.**

Одинаковый отказ у всех трёх = **одна общая причина в общем звене**, а не три
разных бага. Общее звено — проверка чека Apple/Google (`IapService::redeem` →
`VerifierFactory`). VIP, буст и лимит все проходят через него.

---

## Главная причина (config на проде, не код)

`iap.apple_live = false` в настройках прода (это **дефолт миграции**:
`database/settings/2026_09_09_140000_iap_per_platform_mode.php:11`).

Что происходит при `apple_live=false`:

1. `VerifierFactory::for(Ios)` возвращает **`SandboxVerifier`**
   (`app/Support/Iap/VerifierFactory.php:17-19`).
2. `SandboxVerifier` **не ходит в Apple** и принимает только тестовый токен вида
   `sandbox|<productId>|<transactionId>`; любой другой токен →
   `valid: false` (`app/Support/Iap/SandboxVerifier.php:27-29`).
3. Клиент шлёт **настоящий чек StoreKit** (`receipt = serverVerificationData`,
   `lib/screens/payments/iap/iap_service.dart:117,131`), а не `sandbox|...`.
4. `IapService::redeem` получает `valid=false` → бросает `purchase.invalid`
   (HTTP 422) (`app/Services/IapService.php:48-49`). **Ничего не активируется —
   ни промо, ни лимит.**

Это бьёт по VIP, бусту и лимиту **одинаково**, потому что все три проходят через
этот один seam.

### Почему это выглядит как «оплата прошла»
На 422 клиент оставляет транзакцию **незавершённой** (не 404 —
`iap_service.dart:666-668`), поэтому StoreKit **передаёт её заново при каждом
запуске**. Пользователь снова видит нативный экран Apple «покупка совершена», а
бэкенд снова отвечает 422 → «платёж приходит, но ничего не происходит».

---

## Вторая причина (даже если включить `apple_live=true`)

- `APPLE_IAP_*` пустые по умолчанию (`config/services.php:56-58`) и **их нет в
  `.env.example`**. `AppleReceiptVerifier` бросает `unavailable`, если
  `key_id`/`issuer_id`/`private_key_path` пусты или файла нет
  (`app/Support/Iap/AppleReceiptVerifier.php:66-70`).
- Если тест идёт против локального файла **`ios/WawatProducts.storekit`**
  (он есть в проекте), его чеки подписаны локальным тест-CA и **никогда не
  пройдут** проверку у Apple — ни `verifyReceipt`, ни App Store Server API.

---

## Что сделать на бэкенде / проде (обязательно)

1. **Включить реальную верификацию:** `iap.apple_live = true` (и `google_live =
   true` для Android) в настройках прода.
2. **Заполнить креды Apple:** `APPLE_IAP_BUNDLE_ID`, `APPLE_IAP_KEY_ID`,
   `APPLE_IAP_ISSUER_ID`, `APPLE_IAP_TEAM_ID` и `.p8` по
   `APPLE_IAP_PRIVATE_KEY_PATH`; для Android — `GOOGLE_PLAY_*`. Добавить их все в
   `.env.example` (сейчас там нет ни одного платёжного ключа).
3. **Тестировать только с реальным Apple Sandbox-аккаунтом**, а НЕ с локальным
   `WawatProducts.storekit`. Пока `apple_live=false`, единственный принимаемый
   токен — буквально `sandbox|<productId>|<transactionId>`.

## Дополнительно (карта Kapital, если её используют)

- `KAPITAL_RETURN_URL_BASE` / `APP_URL` должны указывать на публичный https-хост
  (`https://api.wawatair.com`), иначе редирект Kapital не дойдёт до
  `GET /api/v1/payments/kapital/callback/{public_id}` и `confirmCardPayment`
  не выполнится (`config/services.php:78`, `PaymentCallbackController`).
- `card_enabled=true`, `mock_payments=false` — осознанно.
- **У лимита карты нет вообще:** `ListingQuotaPurchaseService::pay` бросает
  `provider_unavailable` для карты, если `mock_payments` выключен. Лимит по карте
  работает только через IAP или mock.

## Нюанс про PendingActivation (промо)
Если объявление на модерации/не в статусе discoverable, `ActivatePromotionAction`
паркует промо как `PendingActivation` (деньги списаны, бейджа нет —
`app/Actions/Promotion/ActivatePromotionAction.php:26-30`). Убедитесь, что при
переходе объявления в активный статус запаркованное промо доигрывается.

---

## Живая диагностика (чтобы подтвердить причину)

```bash
# 1. Значения настроек IAP на проде
php artisan tinker --execute="dump(app(App\Settings\IapSettings::class));"

# 2. Логи API: ищем 422/purchase.invalid на /pay
grep -E "promotions/.*/pay|listing-quota/orders/.*/pay" storage/logs/laravel.log | grep -Ei "422|purchase.invalid"

# 3. Что реально отвечает /pay (должно быть 200 + data.activated:true)
#    Если 422 — это верификатор чека (главная причина).

# 4. После тестовой покупки — проверить применение:
#    GET /api/v1/me           -> listing_quota[...].{limit,remaining}
#    GET /api/v1/promotions/{id} -> status (active / pending_activation / pending_payment)
#    у объявления promotion_type должен стать vip/featured
```

Если `/pay` отвечает 422 — причина подтверждена: включайте `apple_live` и
заполняйте `APPLE_IAP_*`.
