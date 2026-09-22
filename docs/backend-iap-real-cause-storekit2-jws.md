# IAP: настоящая причина отказа /pay — формат чека (SK2 JWS vs SK1 base64)

**Дата:** 2026-09-19
**Статус:** платёж всё ещё падает («Платёж не прошёл / serverdə təsdiqlənmədi»)
на VIP (`/promotions/{id}/pay`) в TestFlight, хотя бэкенд объявил Apple-фикс
задеплоенным.

## Прошлый диагноз был неверным

Ранее сообщалось: «Flutter шлёт **StoreKit 1 base64 app receipt**, сервер
понимал только StoreKit 2». На самом деле — **наоборот**.

Плагин `in_app_purchase_storekit` **0.4.4** с версии 0.4.0 по умолчанию использует
**StoreKit 2** на всех устройствах iOS 15+ (CHANGELOG: *«BREAKING CHANGE: StoreKit
2 is now the default for all devices that support it»*). В режиме StoreKit 2 поле
`serverVerificationData` (которое клиент кладёт в `receipt`) — это **JWS-
представление транзакции** (подтверждено в исходнике плагина:
`sk2_transaction_wrapper.dart` → *«receiptData is the JWS representation of the
transaction»*), а НЕ base64 app receipt.

Итог: клиент всё это время слал **SK2 JWS**, а не base64. Поэтому фикс под
«SK1 base64 + verifyReceipt + 21007» бил мимо реального формата.

## Что мы сделали на клиенте (быстрый путь)

Форсировали **StoreKit 1** на iOS:
`InAppPurchaseStoreKitPlatform.enableStoreKit1()` в старте `IapService`.
Теперь `receipt` = классический **base64 app receipt**, и его должен принять
ваш `verifyReceipt`-путь (с переходом на sandbox при 21007 — для TestFlight).

**Нужен новый TestFlight-билд** (изменение клиентское). После него VIP/quota
покупка в TestFlight должна доходить до «Təbriklər».

Контракт `/pay` НЕ менялся:
- iOS: `{ "method": "apple", "receipt": "<base64 app receipt>" }`
- Android: `{ "method": "google", "purchase_token": "<token>" }`
- Успех строго: HTTP 200 + `{ "data": { "activated": true } }`
  (quota также принимает `"status": "paid"`).

## Что проверить на бэкенде

1. **verifyReceipt действительно работает с реальным SK1 base64** (не только с
   ранее тестированным SK2). При status `21007` — повтор на
   `https://sandbox.itunes.apple.com/verifyReceipt`.
2. `bundle_id` в чеке = **`wawat.app`** (совпадает с проектом — проверено).
3. `product_id` из чека сверяется с product_id заказа
   (`wawat.app.vip.1d/3d/5d`, `wawat.app.boost.small/medium/large`,
   `wawat.app.quota.small/medium/large`).
4. `transaction_id` — уникальный ключ идемпотентности; повтор того же чека →
   снова 200 без второй активации/списания.
5. Оба эндпоинта: `/promotions/{id}/pay` И `/listing-quota/orders/{id}/pay`.

## На будущее (не срочно)

SK1 помечен Apple как deprecated. Правильное долгосрочное решение — научить
бэкенд принимать **SK2 JWS**: разобрать `receipt` как JWS (`header.payload.
signature`), проверить подпись по цепочке сертификатов `x5c` из заголовка против
корневого CA Apple, затем прочитать `environment` (Sandbox/Production — снимает
нужду в 21007), `bundleId`, `productId`, `transactionId` из payload. Тогда можно
будет вернуть клиент на SK2 и убрать `enableStoreKit1()`.
