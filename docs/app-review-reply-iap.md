# Ответ Apple по IAP (Guideline 2.1(b)), сборка 2.0.2 (59)

## Сначала проверить (иначе ответ не поможет)

Все 10 покупок в приложении спрятаны за состоянием аккаунта — на пустом
аккаунте их не видно вообще. Ревьюеру нужен **готовый демо-аккаунт**:

1. **Есть одно своё объявление** в статусе «активно» или «на модерации» —
   тогда на карточке есть кнопки «Make VIP» и «Boost».
2. **Лимит объявлений исчерпан** — нажать «+» внизу, выбрать тип: должен
   открыться экран «limit is full» с кнопкой «Increase limit».
3. **Документы верификации одобрены в админке, оплата ещё не сделана** —
   в «Verify account» должна быть кнопка «Pay · …».
4. На этом аккаунте открыть все три окна оплаты и убедиться, что плитка
   **App Store активна и с ценой** (в верификации не должно быть «Available soon»).
5. Логин и пароль демо-аккаунта вписать в App Store Connect → версия →
   **App Review Information → Sign-In Information** (не в текст ответа).
6. Business → Agreements: **Paid Apps Agreement = Active**.

## Текст ответа (вставить в App Store Connect как есть)

Hello,

Thank you for the review. All In-App Purchases are available to signed-in
users, and each one appears at a specific point in the app. We have prepared
a demo account that is already in the required state for every purchase.
The sign-in credentials are provided in App Review Information.

There are no storefront or device restrictions. All ten products are
consumables and are purchased through the App Store payment sheet. The Paid
Apps Agreement is active. The app follows the device language; the button
names below are for English.

1) VIP — "vip 1", "VIP · 3 days", "VIP · 5 days"
- Sign in with the demo account.
- Tap the "Account" tab (bottom right).
- Tap "My listings".
- On the listing card tap the yellow "Make VIP" button.
- Choose a duration (1, 3 or 5 days) and tap "Continue to payment".
- On "Order summary" tap "Continue to payment".
- In the "Payment method" sheet choose "App Store".

2) Featured listing — "Önə çıxarılan · Kiçik / Orta / Böyük" (Small / Medium / Large)
- Account → "My listings".
- On the listing card tap the blue "Boost" button.
- Choose a package (Small, Medium or Large) and tap "Continue to payment".
- On "Order summary" tap "Continue to payment".
- In the "Payment method" sheet choose "App Store".

3) Listing limit — "Listing limit +1", "+3", "+5"
- Tap the "+" button in the centre of the bottom bar.
- Choose a listing type.
- The demo account has reached its free listing limit, so the screen
  "Your active listing limit is full" opens. Tap "Increase limit".
- Choose a plan (+1, +3 or +5) and tap the pay button at the bottom.
- In the "Confirm payment" sheet choose "App Store".

4) Verification badge — "Verification badge"
- Account → "Verify account".
- The demo account's documents are already approved, so the screen shows
  "Your documents are approved. Pay to activate."
- Tap "Pay".
- In the "Payment method" sheet choose "App Store".

Please let us know if any step does not match what you see, and we will
respond right away.

Best regards,
Wawat Air team
