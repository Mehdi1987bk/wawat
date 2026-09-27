# Верификация: плитка «App Store» серая на iOS — диагностика

**Дата:** 2026-09-27 (исправлено после ответа бэкенда)
**Кому:** мобильный клиент (себе) + бэкенд для сверки
**Экран:** профиль → Верификация → «Оплата» → лист «Способ оплаты» (TestFlight, iOS)

## Что подтвердил бэкенд (прежняя версия этого дока была НЕВЕРНА)
- Товар верификации **есть** и в App Store Connect, и в `GET /purchases/catalog`.
- Правильный `product_id` — **`wawat.app.verification`** (НЕ `.badge`). Создавать
  `wawat.app.verification.badge` НЕ надо — это сломает рабочий поток.
- В ASC статус «Ready to review», `POST /verification/pay` по чеку Apple уже
  работает (проведены 2 sandbox-покупки).

То есть серверная часть в порядке. Прежний диагноз «товара нет в ASC/каталоге»
оказался ошибочным.

## Что исправлено в клиенте
- `ios/WawatProducts.storekit`: id товара исправлен на `wawat.app.verification`
  (влияет только на локальные StoreKit-прогоны в Xcode; в TestFlight/проде
  `.storekit` игнорируется — там каталог берётся с бэкенда).
- Из `kDevIapProducts` запись верификации убрана (dev-каталог, только для
  `lib/dev_iap.dart`).
- Добавлен диагностический лог в `_loadVerificationStoreProduct`
  ([verification_screen.dart](../lib/screens/home/tabs/profile_tab/verification/verification_screen.dart)):
  `[IAP][verify] catalogId=… storeResolved=… queried=[…] notFound=[…]`.

## Почему плитка всё ещё могла быть серой на TestFlight
Плитка «App Store» включается только когда товар резолвится с двух сторон
([verification_screen.dart:690](../lib/screens/home/tabs/profile_tab/verification/verification_screen.dart)):
```
storeEnabled = kIapEnabled
  && _verificationCatalog != null       // пришёл в GET /purchases/catalog (kind=verification)
  && _verificationStoreProduct != null  // нашёлся в App Store Connect (queryProductDetails)
```
Раз сервер отдаёт товар, серым он остаётся, если у пользователя `queryProductDetails`
не вернул `wawat.app.verification` (id попал в `notFoundIDs`). Типичные причины на
устройстве, не в коде:
- сборка ещё без обновлённого каталога / старый кэш каталога (нужен перезаход на экран);
- ASC-товар ещё не распространился на sandbox для конкретного аккаунта;
- `kIapEnabled=false` в этой сборке.

## Как подтвердить причину (ждём лог с устройства)
Открыть на TestFlight-устройстве экран верификации → «Оплата» и снять лог
`[IAP][verify] …`:
- `notFound` содержит `wawat.app.verification` → товар не доехал до этого устройства/аккаунта в ASC (sandbox-распространение).
- `catalogId` пустой / нет строки `catalogId=…` → бэкенд не вернул `verification`-продукт этому пользователю (проверить ответ `GET /purchases/catalog`).
- `storeResolved=true`, но плитка серая → смотреть `kIapEnabled` в сборке.

## Apple 3.1.1
Как только плитка «App Store» стабильно активна на iOS — **скрыть банковскую карту
для верификации на iOS** (как уже сделано для лимита: `_showCard = !Platform.isIOS`).
Пока оставляем карту, чтобы на iOS был хоть один рабочий способ.
