# Платежи Wawat: аудит и что доделать на бэкенде (`api.wawatair.com`)

**Дата:** 2026-09-20
**Кому:** команда бэкенда (`kodo-az/api.wawatair.com`)
**От:** мобильный клиент (`mobile.wawatair.com`)

Клиент полностью переведён на правильную модель оплаты (см. раздел «Что уже
исправлено на клиенте»). Бэкенд-стек IAP по коду **корректен и готов** — проверка
Apple (SK1 base64 + SK2 JWS), Google Play, идемпотентный `redeem()`, каталог со
всеми продуктами. Проблемы, из-за которых «всё работает некорректно», — это
**конфигурация окружения бэкенда (env + каталог)**, а не логика. Настройку
продуктов в App Store Connect я проверил вручную — она **полная и верная** (см.
пункт 2). Ниже — точный чек-лист.

---

## 0. Главная причина «платёж не проходит» — пустой `APPLE_IAP_BUNDLE_ID`

`App\Support\Iap\AppleReceiptVerifier::verify()` первой строкой берёт
`config('services.apple_iap.bundle_id')`, а дефолт в `config/services.php` —
**пустая строка**. Если `APPLE_IAP_BUNDLE_ID` не задан в `.env` продакшена,
проверка **любого** чека Apple сразу падает в `serviceUnavailable` → клиент
видит «Ödəniş provayderi əlçatan deyil / платёж не прошёл». Это молчаливый
убийца: код правильный, но без env-переменной он не работает никогда.

**Сделать:**

```dotenv
# Apple — обязательно
APPLE_IAP_BUNDLE_ID=wawat.app

# Google — обязательно для Android IAP
GOOGLE_PLAY_PACKAGE_NAME=az.buking.buking
GOOGLE_PLAY_SERVICE_ACCOUNT=/абсолютный/путь/к/service-account.json

# Apple App Store Server API — НЕ обязательно, пока клиент шлёт SK1 base64.
# Нужно, только если захотите принимать и SK2 JWS (см. раздел 4).
APPLE_IAP_ISSUER_ID=
APPLE_IAP_KEY_ID=
APPLE_IAP_TEAM_ID=
APPLE_IAP_PRIVATE_KEY_PATH=storage/app/apple/iap-key.p8
```

**И добавьте эти ключи в `.env.example`** — их там сейчас нет, поэтому свежий
деплой молча уезжает с пустыми значениями.

Сервис-аккаунт Google должен иметь в Play Console право **«View financial data,
orders and cancellation survey responses»** (выдано 2026-09-19; распространение
до 24 ч). При 401/403 `GoogleReceiptVerifier` возвращает 503 и покупка не
списывается — то есть до появления права Android-проверка будет «temporarily
unavailable».

---

## 1. Каталог `GET /purchases/catalog` — почему на iOS пропадает плитка магазина

`ProductCatalog::quotaProducts()` добавляет quota-продукт **только если**
`quota->priceFor(ListingType::Trip, $extra) !== null`. Если для типа/размера цена
не настроена — продукт **не попадает** в каталог, клиент не может сопоставить его
со стором, и плитка «App Store / Google Play» исчезает (именно это на скриншоте
экрана увеличения лимита: пакет «+1», плитки магазина нет).

**Сделать:** в настройках ListingQuota задать цену для `extra = 1, 3, 5` (пакеты
small/medium/large). Проверить, что `GET /purchases/catalog` реально возвращает
`kind: "quota"` со всеми тремя `extra_listings` и `product_id`
`wawat.app.quota.{small,medium,large}`.

Product id в каталоге **обязан посимвольно совпадать** с id в App Store Connect и
Google Play:

| Фича | kind | product_id |
| --- | --- | --- |
| VİP 1/3/5 дней | `vip` | `wawat.app.vip.1d` / `.3d` / `.5d` |
| Boost | `featured` | `wawat.app.boost.small` / `.medium` / `.large` |
| Лимит объявлений | `quota` | `wawat.app.quota.small` / `.medium` / `.large` |
| Верификация | `verification` | `wawat.app.verification` |

---

## 2. App Store Connect — проверено вручную, правок НЕ требуется

Проверил 2026-09-20 в App Store Connect (аккаунт VAVATEX GROUP MMC, app id
6755226789):

- **Соглашение о платных приложениях — «Активно»**, банковский счёт (Expressbank,
  USD) — «Активно». То есть StoreKit продукты отдаёт, блокировки на уровне
  аккаунта нет.
- Все **9** продуктов (3 vip + 3 boost + 3 quota) — статус **«Готов к отправке»**,
  у каждого заполнены локализованное отображаемое имя, описание и цена (175
  стран). Проверил в том числе `wawat.app.quota.small`: имя «Listing limit +1»,
  описание «1 additional listing for your account», цена задана.

Раньше мы предполагали, что плитка «App Store» на экране лимита пропадает из-за
пустой локализации в ASC — **это оказалось не так, локализация на месте.** Значит
пропажа плитки — это **пункт 1** (каталог бэкенда не отдаёт `quota`, когда
`quota->priceFor(Trip, extra)` = null). Как только каталог вернёт
`wawat.app.quota.small`, плитка появится. **Это сейчас главный блокер оплаты
лимита на iOS.**

Два замечания по ASC — действия на стороне аккаунта (не бэкенда):

- Продукт `wawat.app.verification` в ASC **отсутствует** (заведено 9 из 10). Пока
  верификация — mock (пункт 5), это не мешает; но перед платной верификацией на
  iOS продукт нужно создать.
- Ни один IAP ещё **не отправлялся на ревью вместе с версией приложения** (ASC
  показывает баннер «первый расходуемый IAP должен быть отправлен с новой версией
  приложения»). В TestFlight (sandbox) продукты работают уже сейчас, но в
  **публичном App Store IAP не заработают**, пока первый расходуемый продукт не
  уйдёт на ревью вместе с ближайшей версией.

Google Play: те же product id — активные managed-продукты, сервис-аккаунт
привязан и авторизован (право «View financial data» выдано 2026-09-19).

---

## 3. Контракт `/pay` (уже верный — просто подтвердите, ничего не меняя)

Эндпоинты: `POST /promotions/{id}/pay`, `POST /listing-quota/orders/{id}/pay`,
`POST /verification/pay`.

- iOS: `{ "method": "apple", "receipt": "<base64 app receipt>" }`
  → `verifyReceipt`, при статусе `21007` авто-повтор на sandbox (TestFlight).
- Android: `{ "method": "google", "purchase_token": "<token>" }`
  → Play Developer API `purchases.products.get`.
- Успех строго: **HTTP 200 + `data.activated == true`** (quota также
  `status: "paid"`).
- `transaction_id` из чека — ключ идемпотентности: повтор того же чека → снова
  200 без второй активации.

---

## 4. StoreKit-версия (контекст, действий обычно не требуется)

Плагин `in_app_purchase` по умолчанию использует **StoreKit 2** на iOS 15+, где
`receipt` = JWS-транзакция. Ваш `AppleReceiptVerifier` это **умеет** (ветка
`substr_count('.') === 2` → App Store Server API), но для неё нужны
`APPLE_IAP_ISSUER_ID/KEY_ID/PRIVATE_KEY_PATH`. Пока они пустые, SK2-путь падает в
503.

Поэтому **клиент принудительно включает StoreKit 1** (`enableStoreKit1()`), и
`receipt` — классический **base64 app receipt** → ваша ветка `verifyReceipt`,
которой ключ App Store Server API не нужен. Итог: с заданным
`APPLE_IAP_BUNDLE_ID` этого достаточно. Если позже захотите вернуть клиент на SK2
— просто заполните три ключа выше, и `viaServerApi` заработает.

---

## 5. Верификация аккаунта `/verification/pay` — всё ещё mock

В коде помечено «mock for now», клиент показывает mock-подпись. На iOS реальная
оплата верификации **обязана** идти через IAP (`wawat.app.verification`) тем же
путём `redeemStorePurchase` → `IapService->redeem()`, что и promo/quota. Пока это
mock — **не списывать деньги на iOS**. Когда будете подключать: добавить продукт
в ASC/Play, отдавать его в каталоге (уже отдаётся) и провести оплату через
store-метод.

---

## 6. Карта (Kapital) теперь только для Android

Клиент **больше не показывает «Bank kartı» на iOS** — продажа цифровой услуги мимо
App Store нарушает Apple 3.1.1 (из-за этого и был риск отклонения ревью). Карта
остаётся способом оплаты **только на Android**. Для продакшена: `PaymentSettings::
$kapital_live = true` + боевые креды `KAPITAL_*`; mock-хук `mock_outcome`
отключить в проде.

---

## Что уже исправлено на клиенте (для контекста)

- **iOS = только IAP** для VİP/boost/quota. Плитка карты на iOS убрана.
- Плитка магазина переименована «Apple Pay» → **«App Store»** (это IAP, а не Apple
  Pay; из-за старого лейбла была путаница).
- Если store-продукт не разрешился, iOS показывает «магазин временно недоступен»,
  **а не** молчаливый откат на карту.
- StoreKit 1 форсирован (base64 receipt под ваш `verifyReceipt`).

## Как проверить после правок

TestFlight (iOS) или внутренний трек (Android) → купить любой пакет → в логах
бэкенда `grep -i 'Apple IAP'` / `grep -i 'Google IAP'`: должно быть
`verifyReceipt ok` / `server API ok` / `Play API ok` с `environment` и
`product`. Ответ клиенту — 200 + `activated: true`.
