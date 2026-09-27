# Активировать оплату верификации через магазин (App Store / Google Play)

Сейчас в приложении на экране «Подтвердите аккаунт → Оплатить» плитка **App Store /
Google Play неактивна** («Tezliklə əlçatan olacaq»). Причина: у бейджа верификации
нет продукта в магазине, поэтому приложению нечего открыть. Плитка загорится
**сама, без изменений в приложении**, как только выполнить 3 шага ниже.

Идентификатор продукта (одинаковый в обеих системах):

```
wawat.app.verification
```

Цена — как у остальных: показывается 0.99 USD.

---

## 1. App Store Connect (iOS)

1. **My Apps → Wawat → Monetization → In-App Purchases → (+)**
2. Тип: **Consumable** (расходуемый).
3. **Product ID:** `wawat.app.verification`
4. **Reference Name:** `Verification badge`
5. **Price:** тир, соответствующий ~0.99 USD.
6. Локализация (хотя бы en + az): Display Name «Doğrulama nişanı» / «Verification badge»,
   Description — короткое описание.
7. Приложить review-скриншот и **Submit for Review** (можно вместе со сборкой).

## 2. Google Play Console (Android)

1. **Monetize → Products → In-app products → Create product**
2. **Product ID:** `wawat.app.verification`
3. Название/описание + цена ~0.99 USD → **Activate**.

## 3. Бэкенд (уже наш API)

1. Добавить продукт в `GET /api/v1/purchases/catalog` (**без цены** — как VIP/quota;
   цену даёт магазин, клиент читает её из `ProductDetails`):
   ```json
   {
     "product_id": "wawat.app.verification",
     "kind": "verification"
   }
   ```
2. Убедиться, что `POST /verification/pay` принимает чек магазина и активирует бейдж:
   - iOS: `{ "method": "apple", "receipt": "<base64>" }`
   - Android: `{ "method": "google", "purchase_token": "<token>" }`
   - Проверить чек у Apple/Google, сделать активацию идемпотентной, вернуть
     `{ "activated": true }` (или `status: "paid"`).

> Приложение уже отправляет чек именно на `POST /verification/pay` (маршрут
> `wawat.app.verification*` в клиенте зашит). Как только продукт есть в магазине
> **и** в каталоге — клиент подхватит цену и плитка станет активной автоматически.

Карта («Bank kartı») на этом экране **работает уже сейчас**, магазин — опционально.
