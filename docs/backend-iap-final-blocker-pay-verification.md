# IAP: последний блокер — сервер не подтверждает покупку

**Дата:** 2026-09-19
**Статус стора:** ГОТОВ. Все товары в App Store Connect и Google Play активны,
у всех есть локализованные названия, приложение их подтягивает, цена и лист
оплаты открываются.

**Что не работает:** покупка проходит в сторе, но приложение получает отказ на
последнем шаге — при верификации чека на сервере. Пользователь видит:

> Mağaza əməliyyatı serverdə təsdiqlənmədi. Yenidən cəhd et.
> (Платёж не прошёл. Попробуйте снова.)

Это значит: `POST /pay` вернул НЕ HTTP 200 (или вернул `activated:false`).
Проблема целиком на бэкенде — клиент чек шлёт корректно.

---

## Что именно шлёт приложение

iOS (продвижение — VIP/boost):
```http
POST /api/v1/promotions/{promotion_id}/pay
Authorization: Bearer <user-token>
Content-Type: application/json

{ "method": "apple", "receipt": "<StoreKit serverVerificationData>" }
```

iOS (лимит объявлений — quota):
```http
POST /api/v1/listing-quota/orders/{order_id}/pay
{ "method": "apple", "receipt": "<...>" }
```

Android — то же самое, но `{ "method": "google", "purchase_token": "<...>" }`.

Приложение считает покупку успешной ТОЛЬКО если ответ = HTTP 200 и
`data.activated == true` (для quota также подходит `data.status == "paid"`).
Любой другой ответ или исключение (403/422/503) = «серверdə təsdiqlənmədi».

---

## Самая вероятная причина (проверить первым делом)

**TestFlight и тестовые покупки идут через Apple SANDBOX, а не Production.**
Если App Store Server API / verifyReceipt настроен только на Production, каждый
чек из TestFlight будет отклонён (`verifyReceipt` вернёт status **21007** =
«это sandbox-чек, повтори на sandbox endpoint»).

Требуется:
1. При проверке Apple-чека поддержать ОБА окружения — Sandbox и Production.
   - Старый `verifyReceipt`: при status `21007` повторить запрос на
     `https://sandbox.itunes.apple.com/verifyReceipt`.
   - App Store Server API: запрашивать и `Sandbox`, и `Production` environment.
2. Bundle ID: `wawat.app`.
3. Вернуть идемпотентный HTTP 200 при повторной доставке той же транзакции
   (Apple/StoreKit переотправляет незакрытые транзакции — клиент это ждёт).

## Чек-лист для бэкенда, чтобы закрыть раз и навсегда

- [ ] Apple: чек проверяется и в Sandbox, и в Production (обработан 21007).
- [ ] Google: `purchase_token` проверяется напрямую у Google (нужен включённый
      `androidpublisher.googleapis.com` — по прошлому отчёту он был 403/выключен).
- [ ] product ID из чека сверяется с product ID pending-заказа.
- [ ] transaction ID у Apple / order ID у Google = UNIQUE provider key.
- [ ] Успешный ответ строго `HTTP 200` + `{ "data": { "activated": true } }`
      (quota: допустимо `"status": "paid"`).
- [ ] Повторный тот же чек → снова 200, без второй активации и второго списания.

## Как проверить, что починилось

TestFlight-покупка любого товара (например VIP·1 день, 0,99 $) должна дойти до
экрана «Təbriklər / Поздравляем», а не «серверdə təsdiqlənmədi». После этого —
повторить покупку тем же товаром: должна активироваться без второго списания.

---

Полный контекст и настройка ключей — в
`backend-iap-production-complete-guide.md` (разделы 23–28).
Не присылать в обычном чате `.p8`, service-account JSON, receipts и tokens.
