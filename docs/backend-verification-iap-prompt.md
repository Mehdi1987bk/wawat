# Оплата верификации через магазин — задача бэкенду

> **Статус: бэкенд готов и в проде** (prod commit 5838441). Ниже — что сделано,
> оставлено для истории.

В App Store Connect создан продукт `wawat.app.verification`
(Consumable / расходуемая, 0.99 USD, все страны, статус «Подготовка к отправке»).
Клиент уже умеет открывать оплату через App Store / Google Play и слать чек на
`/verification/pay`.

## 1. Каталог покупок ✅

`GET /api/v1/purchases/catalog` отдаёт продукт (`kind: verification`):

```json
{
  "product_id": "wawat.app.verification",
  "kind": "verification"
}
```

> **Цену каталог НЕ отдаёт** — так же, как для VIP/boost/quota. По правилам IAP
> цену показывает магазин (App Store / Google Play), клиент читает её из
> `ProductDetails`, а не из каталога. Это правильно и уже так в коде.

## 2. Приём чека магазина

`POST /verification/pay` должен принимать чек и активировать бейдж
(активация — **идемпотентная**, повторный чек не должен списывать/ломать):

- iOS: `{ "method": "apple", "receipt": "<base64>" }`
- Android: `{ "method": "google", "purchase_token": "<token>" }`
- проверить чек у Apple / Google;
- вернуть `{ "activated": true }` (или `status: "paid"`).

Карта («Bank kartı») на этом экране (`{ "method": "card" }` → `checkout_url`)
работает уже сейчас — магазин опционален, но нужен для iOS по правилам Apple.

## 3. Google Play (Android)

Создать тот же продукт `wawat.app.verification` (0.99 USD) → **Activate**.

---

После пунктов 1–3 плитка «App Store / Google Play» в приложении загорится
**сама, без правок в коде**: клиент подхватит продукт из каталога и из магазина.
