# Оплата банковской картой — что нужно от бэкенда

**Задача:** во всех платных местах, где есть Apple Pay / Google Play, теперь показывается
и «Bank kartı» (Kapital, hosted 3-D Secure). **Клиент полностью готов** — он сам открывает
WebView Kapital, как только сервер вернёт `checkout_url`, и подтверждает результат по
`GET`-статусу. Ничего на клиенте менять больше не нужно. Ниже — что должен сделать бэкенд,
чтобы карта реально списывала деньги, а не отрабатывала в мок-режиме.

Приложение ходит на прод: `https://api.wawatair.com/api/v1`.

---

## 0. Общий принцип (уже работает для продвижения)

Для карты клиент делает `POST …/pay` с телом `{ "method": "card" }` и заголовком
`Idempotency-Key`. Ожидаемый ответ:

- **реальная оплата:** в ответе есть `payment.checkout_url` (hosted-страница Kapital) →
  клиент открывает её в WebView, пользователь вводит карту, после редиректа на
  `wawatair://payment/result?status=…` клиент перечитывает статус заказа с сервера
  (редиректу не доверяем — источник истины сервер, активация идемпотентна);
- **мок:** `checkout_url` нет, заказ уже помечен оплаченным → клиент показывает успех.

Kapital-гейт в `PromotionService::pay` уже устроен так:
`if (method === card && payment.card_enabled && !mock_payments) → initCardCheckout()`.
Нужно, чтобы **то же самое** работало для лимита объявлений и верификации.

Тестовый терминал Kapital (безопасно, без реальных денег) уже в `config/services.php`:
`TerminalSys/kapital` / `kapital123`, `test_url = https://txpgtst.kapitalbank.az/api`.
Тестовая карта: `4169 7413 3015 1778`, exp `06/27`, CVV `591`.

---

## 1. Продвижение (VIP / Boost) — **включить карту**

Код готов, но на проде стоит мок. Нужно в настройках:

| Настройка | Сейчас | Поставить |
| --- | --- | --- |
| `promotion.mock_payments` | `true` | **`false`** |
| `payment.card_enabled` | `true` | оставить `true` |
| `payment.kapital_live` | `false` | `false` для теста / `true` для реальных денег |

- `mock_payments` переключается в админке: **Parametrlər → Promotion**.
- `payment.*` (`PaymentSettings`) в админке **нет** — правится в БД/сидом
  (`database/settings`) или отдельным экраном. Их надо вынести в админку либо выставить руками.
- Для реальных денег в `kapital_live=true` в `.env` сервера должны лежать **боевые**
  merchant-креды Kapital (не тестовые из `config/services.php`).

Проверка: `POST /promotions/{id}/pay {method:card}` должен вернуть `payment.checkout_url`.

---

## 2. Лимит объявлений («Limiti artır») — **включить карту так же**

Клиент уже шлёт `POST /listing-quota/orders/{id}/pay {method:"card"}` и ждёт
`payment.checkout_url` (эндпоинт и разбор ответа уже есть). На iOS плитка карты раньше была
скрыта — **сняли, теперь карта показывается на всех платформах.**

Нужно на бэкенде для quota-оплаты повторить логику продвижения:

1. в методе оплаты quota-заказа добавить ветку `method === card`:
   `if (card_enabled && !mock_payments) → initCardCheckout(...)` через тот же `KapitalGateway`
   (`typeRid: Order_SMS`, сумма/валюта из заказа, `hppRedirectUrl` → колбэк);
2. отдавать `payment.checkout_url` в ответе `…/orders/{id}/pay`;
3. колбэк Kapital для quota (по аналогии с
   `PaymentCallbackController` для продвижения) — пометить заказ оплаченным и
   редиректить на `wawatair://payment/result?status=success&order={id}`;
4. включить `mock_payments=false` для quota (если у quota свой флаг — выключить и его).

Пока этого нет, карта в quota отрабатывает как мок (заказ помечается оплаченным без ввода
карты) — не сломано, но и не реально.

> ⚠️ Проверьте, что `POST …/orders/{id}/pay {method:card}` не отвечает `422` — сейчас
> в клиенте есть заметка, что раньше он мог 422-ить. Card должен быть валидным методом для quota.

---

## 3. Верификация (платный KYC) — **добавить card-ветку (её сейчас нет)**

Сейчас `VerificationController::pay` принимает `method`, но и `card`, и `balance` уходят в
`VerificationService::pay()` — это **чистый мок**: сразу ставит `paid_at` + `is_verified`,
`checkout_url` не возвращает (реальный путь есть только для `apple`/`google` через
`redeemStorePurchase`).

Клиент уже шлёт `POST /verification/pay {method:"card"}` + `Idempotency-Key` и умеет открыть
WebView, если придёт `checkout_url` (ищет его в `data.payment.checkout_url` или на верхнем
уровне ответа). Нужно на бэкенде:

1. в `pay()` для `method === card` (при `card_enabled && !mock_payments`) — вместо
   мгновенной активации создать заказ Kapital через `KapitalGateway` и вернуть
   `checkout_url` (в `data.payment.checkout_url`);
2. колбэк Kapital для верификации → активировать (`paid_at`, `is_verified`, пересчёт tier)
   и редиректить на `wawatair://payment/result?status=success`;
3. фиксировать `charged_amount` из фактически списанного, как в мок-ветке.

Пока card-ветки нет — верификация активируется по-старому (мок). Как только сервер начнёт
отдавать `checkout_url`, реальный WebView откроется **без единой правки в приложении.**

---

## Итог: что нажать/сделать

- [ ] **Продвижение:** `promotion.mock_payments = false` (+ `payment.card_enabled=true`,
      `kapital_live` по ситуации). Это уже полностью рабочий путь.
- [ ] **Quota:** добавить card-ветку + колбэк, выключить мок, проверить что card не 422.
- [ ] **Верификация:** добавить card-ветку + колбэк (сейчас её нет вообще).
- [ ] Для реальных денег на всех трёх: `payment.kapital_live=true` + боевые merchant-креды
      Kapital в `.env` (тестовые из `config/services.php` — только для txpgtst).

Все новые тексты кнопок/плиток («Bank kartı», «Kart ilə ödəniş» и т.д.) уже отданы в
`docs/i18n-verification-quota-promo-handoff.json` для CMS-локализации.
