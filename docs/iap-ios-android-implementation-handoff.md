# Wawatair IAP: iOS и Android

Актуальный handoff по оплате VIP и продвижения объявлений через Apple App Store
и Google Play. Документ описывает состояние мобильного приложения на
2026-09-14, контракт с backend и оставшиеся действия перед production.

## 1. Текущий статус

| Часть | Статус |
| --- | --- |
| Общий Flutter IAP-сервис | Реализован |
| Каталог пакетов с backend | Реализован |
| Локализованные названия/описания с backend | Реализованы |
| Цена и доступность из App Store / Google Play | Реализованы |
| Создание pending-заказа до открытия магазина | Реализовано |
| Отправка Apple receipt / Google purchase token на backend | Реализована |
| Retry незавершённой покупки | Реализован |
| Защита от повторного начисления | Реализована на клиенте; backend сообщил об идемпотентности |
| Локальная StoreKit-конфигурация iOS | Обновлена |
| Android AAB `1.0.54 (55)` | Собран |
| Google Play Android Developer API | Выключен; это подтверждённый Android-блокер |
| Права Google service account в Play Console | Проверить после включения API |
| Загрузка AAB `1.0.54 (55)` в Internal testing | Не подтверждена |
| Production-товары App Store Connect | Требуют проверки в App Store Connect |

## 2. Идентификаторы приложения

```text
iOS Bundle ID:       wawat.app
Android package ID:  az.buking.buking
Flutter version:     1.0.54+55
```

IAP включён по умолчанию. Для аварийного отключения в отдельной сборке:

```bash
flutter build appbundle --dart-define=IAP_ENABLED=false
```

## 3. Канонический каталог товаров

Все товары являются consumable. `product_id` должен быть абсолютно одинаковым
в backend, App Store Connect, Google Play Console и мобильном приложении.

### VIP

| Срок | Product ID | Backend fallback |
| --- | --- | --- |
| 1 день | `wawat.app.vip.1d` | `$0.99` |
| 3 дня | `wawat.app.vip.3d` | `$1.99` |
| 5 дней | `wawat.app.vip.5d` | `$2.99` |

Старые `vip.7d` и `vip.30d` не используются. Нельзя преобразовывать один
купленный product ID в другой срок.

### Продвижение

| Пакет | Product ID | Backend package |
| --- | --- | --- |
| Малый | `wawat.app.boost.small` | `small` |
| Средний | `wawat.app.boost.medium` | `medium` |
| Большой | `wawat.app.boost.large` | `large` |

Диапазоны показов, например `352-588`, названия, описания и признак
`recommended` приходят с backend. Они не должны быть зашиты в production UI.
Окончательная локализованная цена всегда берётся из магазина.

## 4. Источники данных

| Данные | Источник истины |
| --- | --- |
| Product ID и тип пакета | Backend catalog |
| Название и описание пакета | Backend по `Accept-Language` |
| Срок VIP | Backend catalog |
| Диапазон показов boost | Backend catalog |
| Recommended и порядок | Backend catalog |
| Доступность товара | App Store / Google Play |
| Локальная цена и валюта | App Store / Google Play |
| Факт покупки | App Store / Google Play |
| Проверка и активация услуги | Только backend |

Мобильное приложение не активирует VIP или boost самостоятельно и не доверяет
цене, product ID или результату покупки, присланному самим клиентом.

## 5. Каталог backend

```http
GET /api/v1/purchases/catalog
Authorization: Bearer <user-token>
Accept: application/json
Accept-Language: az
```

Поддерживаемые языки: `az`, `en`, `ru`, `tr`, `ua`. Пример товара:

```json
{
  "package_id": "boost-medium",
  "product_id": "wawat.app.boost.medium",
  "kind": "featured",
  "package": "medium",
  "name": "Önə çıxarılan · Orta",
  "description": "Zəmanətli göstəriş paketi",
  "guaranteed_min": 352,
  "guaranteed_max": 588,
  "price": 7.99,
  "currency": "USD",
  "recommended": true,
  "sort_order": 20
}
```

`price/currency` здесь являются fallback. Если магазин вернул товар, UI
показывает `ProductDetails.price`, то есть реальную локальную цену магазина.

## 6. Общий процесс покупки

1. Приложение загружает каталог с backend.
2. По полученным product ID запрашивает товары в App Store или Google Play.
3. Пакет активен только при наличии совпадающего товара в магазине.
4. Пользователь выбирает VIP или boost.
5. Приложение создаёт pending promotion order на backend с уникальным
   `Idempotency-Key`.
6. После создания заказа открывается системное окно StoreKit / Google Play.
7. Магазин возвращает receipt или purchase token через purchase stream.
8. Приложение отправляет подтверждение на backend.
9. Только после HTTP 200 приложение завершает StoreKit transaction или
   consumes Google Play purchase.
10. Backend возвращает `activated=true` либо `pending_activation`, если
    объявление ещё проходит модерацию.

## 7. Создание promotion order

```http
POST /api/v1/listings/{listing_id}/promotions
Authorization: Bearer <user-token>
Idempotency-Key: <uuid>
Content-Type: application/json
```

VIP:

```json
{
  "type": "vip",
  "duration_days": 3
}
```

Boost:

```json
{
  "type": "featured",
  "package": "medium"
}
```

Для VIP нельзя отправлять `package`. Для boost нельзя отправлять
`duration_days` или `tier`.

Дополнительно реализованы:

```http
GET  /api/v1/promotions/pricing
POST /api/v1/promotions/{promotion_id}/quote
GET  /api/v1/me/promotions
GET  /api/v1/promotions/{promotion_id}
POST /api/v1/promotions/{promotion_id}/extend
```

## 8. Проверка оплаты backend

Android:

```http
POST /api/v1/promotions/{promotion_id}/pay
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "method": "google",
  "purchase_token": "<Google Play token>"
}
```

iOS:

```http
POST /api/v1/promotions/{promotion_id}/pay
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "method": "apple",
  "receipt": "<App Store receipt>"
}
```

Успешный ответ должен быть HTTP 200:

```json
{
  "data": {
    "activated": true,
    "promotion": {
      "status": "active"
    }
  }
}
```

Для объявления на модерации допустимы `activated=false` и
`status=pending_activation`, но покупка должна быть сохранена ровно один раз.

## 9. Retry и идемпотентность

- Pending promotion ID сохраняется отдельно для каждого product ID в
  `SharedPreferences`.
- Android-покупка намеренно не consumes, пока backend не вернул HTTP 200.
- При Retry приложение сначала ищет незавершённую покупку Google Play и повторно
  отправляет тот же token на backend без новой оплаты.
- Если сохранённый локальный заказ устарел, а незавершённой покупки в Play нет,
  marker очищается и новая покупка снова может открыть Google Play.
- StoreKit повторно отдаёт незавершённые iOS transactions через purchase stream.
- После успешной проверки Android purchase consumes, а iOS transaction
  завершается.
- Повторная отправка одного token/receipt должна возвращать тот же успешный
  результат и никогда не начислять услугу второй раз.

Fingerprint, Face ID и подтверждение паролем контролирует сам магазин и
настройки устройства. Приложение не может принудительно потребовать биометрию.

## 10. Android

Реализовано:

- `in_app_purchase` и Android billing adapter;
- запрос одноразовых товаров из Google Play;
- `autoConsume=false` на Android;
- ручной consume только после server verification;
- восстановление незавершённых покупок через `queryPastPurchases()`;
- обработка pending, canceled, error, purchased и restored;
- повторная серверная проверка уже купленного token.

Backend сообщил следующие production-настройки:

```text
enabled=true
google_live=true
android_package_id=az.buking.buking
package_env=az.buking.buking
credentials_exist=true
```

Используемый service account:

```text
firebase-adminsdk-fbsvc@wawatair-b212f.iam.gserviceaccount.com
Google Cloud project: wawatair-b212f
Project number: 774660161251
```

Прямая проверка Google Android Publisher API вернула HTTP 403 с точным
сообщением, что API выключен в project `774660161251`. OAuth token был получен
успешно, поэтому service account JSON и authentication исправны. До включения
API backend не сможет подтвердить реальную Google Play покупку. Публикация в
production сама по себе это не исправит.

В текущей Brave-сессии открыт `mehdi1987@bk.ru`; у него нет доступа к этому
Cloud project. API должен включить владелец/администратор `wawatair-b212f`.

Требуется в Google:

1. Включить `Google Play Android Developer API` в проекте `wawatair-b212f`.
2. Добавить service account в правильный Google Play Console developer account.
3. Выдать `View app information`.
4. Выдать `View financial data, orders, and cancellation survey responses`.
5. Создать и активировать все шесть product ID из раздела 3.
6. Загрузить AAB `1.0.54 (55)` в Internal testing и опубликовать изменения трека.

## 11. iOS

Реализовано:

- общий StoreKit purchase stream через `in_app_purchase`;
- отправка `serverVerificationData` как `receipt` на backend;
- завершение transaction только после HTTP 200;
- обработка восстановления и отмены пользователем;
- локальная конфигурация `ios/WawatProducts.storekit` с VIP 1/3/5 и тремя
  boost-пакетами;
- StoreKit-конфигурация подключена к Xcode scheme `Runner`.

Backend сообщил, что `apple_live=true`. Перед production всё равно необходимо
проверить:

1. Все шесть consumable products существуют и доступны в App Store Connect.
2. Product ID совпадают с разделом 3.
3. Paid Applications Agreement, banking и tax не находятся в pending-состоянии.
4. На backend настроен App Store Server API / In-App Purchase key: `.p8`,
   `Key ID`, `Issuer ID`.
5. Секрет `.p8` находится только в защищённом хранилище backend и не включён в
   приложение или git.

## 12. Локализация

- Названия и описания пакетов приходят в `/purchases/catalog` по
  `Accept-Language`.
- Диапазоны показов и recommended также управляются backend.
- Общие тексты экранов оплаты используют content keys приложения.
- Подготовленный набор новых ключей находится в
  `docs/i18n-promotion-iap-backend-handoff.json`.
- Store locale для украинского обычно имеет код `uk-UA`, а API приложения
  использует `ua`.

## 13. Основные файлы реализации

```text
lib/screens/payments/iap/iap_catalog.dart
lib/screens/payments/iap/iap_service.dart
lib/screens/home/tabs/listings/promotion/promotion_screens.dart
lib/data/network/api/promotion_api.dart
lib/data/network/request/promotion_request.dart
lib/data/network/response/promotion_response.dart
lib/main.dart
ios/WawatProducts.storekit
docs/i18n-promotion-iap-backend-handoff.json
test/screens/payments/iap/iap_catalog_test.dart
test/screens/payments/iap/iap_service_test.dart
```

В `main.dart` production-приложение подключает `BackendIapCatalogLoader` и
`BackendPurchaseValidator`, поэтому dev validator в обычном приложении не
используется.

## 14. Проверка и артефакт

Выполнено:

```text
fvm flutter test test/screens/payments/iap
Result: 5 tests passed

fvm flutter analyze <IAP files>
Result: No issues found
```

Android bundle:

```text
/Users/dart/Downloads/Wawat-1.0.54-55.aab
Size: 159 MB
SHA-256: c7fc473020fd1562583200bb627b4b3659a32e209dc26a0ab174c8dea6a4cf50
```

## 15. Проблемы из тестирования и их состояние

Ниже собраны проблемы, которые были показаны в переписке и на Android/iOS
скриншотах. Статус `исправлено в коде` означает, что изменение находится в
текущем проекте; оно появится у тестировщика только после установки новой
сборки.

### 15.1 На Android не загружаются пакеты

**Симптом:** после создания объявления вместо VIP и boost-пакетов отображалось
`Не удалось загрузить пакеты промоакции`, кнопки были заблокированы.

**Причины:** приложение должно получить одновременно каталог backend и товары
Google Play. Пакет нельзя купить, если product ID отсутствует, не активирован,
не доступен тестировщику либо отличается между API и Play Console.

**Что сделано:** реализован единый backend-каталог, точное сопоставление по
product ID и повторная загрузка каталога/магазина. **Что осталось:** создать и
активировать все шесть товаров в Play Console, опубликовать изменения и
проверить доступ тестового аккаунта.

### 15.2 Кнопки VIP и «Продвинуть» заблокированы

**Симптом:** карточки пакетов видны, но кнопки оплаты серые и не нажимаются.

**Причина:** backend знает пакет, но Google Play/App Store не вернул
соответствующий `ProductDetails`. Это защита от попытки купить неизвестный
магазину товар.

**Статус:** логика приложения корректна. Требуется синхронизация и активация
товаров в магазине. Снимать блокировку искусственно нельзя.

### 15.3 Несовпадали сроки VIP

**Симптом:** на одном экране были пакеты `3/7/30`, backend ожидал другие сроки,
появлялась ошибка `Выбранное значение для длительности некорректно`.

**Причина:** разные каталоги в mobile, backend и Play Console.

**Что сделано:** канонический набор приведён к `1/3/5` дням; удалено скрытое
преобразование `1d -> 3d`. Backend должен принимать и проверять ровно
`vip.1d`, `vip.3d`, `vip.5d`. Старые неоплаченные заказы `7d/30d` нужно
отменить или мигрировать на backend, не меняя уже оплаченные транзакции.

### 15.4 Google Play показал успех, а приложение показало ошибку

**Симптом:** системное окно Google сообщило, что покупка прошла, после чего
открылась страница `Сервер не подтвердил покупку в магазине`.

**Причина:** магазин принял покупку, но backend не смог проверить purchase
token через Google Play Android Developer API. Последняя прямая проверка
вернула HTTP 403.

**Статус:** это не ограничение Internal testing и публикация в production сама
по себе проблему не исправит. Нужно включить API и выдать service account права
из раздела 10. После этого уже купленный token можно проверить повторно.

### 15.5 Retry показывал loading и сразу останавливался

**Симптом:** кнопка `Попробовать снова` кратко показывала загрузку, но Google
Play не открывался и экран не менялся.

**Причины:** старый локальный pending marker мог блокировать новую попытку;
предыдущий error-result сохранялся; приложение не всегда сопоставляло
незавершённую покупку с promotion order.

**Что сделано:** перед Retry очищается старый UI-result, pending order хранится
по product ID, локальный marker сверяется с реально принадлежащими пользователю
покупками, а stale marker удаляется.

**Ожидаемое поведение:** если Google Play уже списал деньги и покупка ещё не
consumed, Retry **не должен открывать второе окно оплаты**. Он повторно отправляет
тот же token на backend. Новое окно Google Play открывается только тогда, когда
незавершённой покупки нет и начинается действительно новая покупка.

### 15.6 После одной ошибки любой пакет сразу показывал failure

**Симптом:** после неудачной оплаты пользователь возвращался, выбирал другой
пакет, но приложение сразу открывало старый экран ошибки, не пытаясь запустить
новую оплату.

**Причина:** прошлый terminal result и pending order переиспользовались новым
checkout.

**Что сделано:** результаты разделены по product ID, предыдущий результат
очищается перед запуском, stale pending order удаляется после сверки с
магазином. Ошибка одного товара больше не должна автоматически заражать другой.

### 15.7 Повторная попытка могла создать второй заказ

**Риск:** при каждом нажатии Retry можно было создать новый promotion order,
хотя в магазине уже существовала оплаченная незавершённая покупка.

**Что сделано:** product ID связан с pending promotion ID в локальном хранилище;
сначала восстанавливается существующая transaction. Backend обязан хранить
уникальную связь transaction/token с заказом и отвечать идемпотентно.

### 15.8 Покупка не должна теряться при ошибке backend

**Риск:** если consumable purchase завершить до серверной проверки, повторно
получить token может быть невозможно.

**Что сделано:** Android `autoConsume=false`; consume выполняется только после
HTTP 200. На iOS transaction завершается также только после HTTP 200. При
HTTP 403/422/503 transaction остаётся незавершённой для дальнейшего Retry.

### 15.9 Не запрашивается fingerprint или Face ID

**Симптом:** магазин иногда подтверждает тестовую покупку без биометрии.

**Причина:** способ подтверждения выбирает Google Play/App Store с учётом
настроек устройства, тестового аккаунта, суммы, предыдущей авторизации и правил
риска. Flutter-приложение не управляет этим окном.

**Статус:** это не ошибка приложения. Нельзя безопасно добавлять собственную
биометрию вместо подтверждения магазина.

### 15.10 Названия, описания и диапазоны были зашиты в mobile

**Требование:** названия пакетов, описания, `352-588`, recommended и порядок
должны управляться backend и локализоваться.

**Что сделано:** эти значения читаются из `/purchases/catalog`. Магазин хранит
техническое название товара и определяет фактическую цену. Если backend-текст
отсутствует, возможен fallback, но product ID не подменяется.

### 15.11 Цена backend могла отличаться от цены магазина

**Риск:** показывать пользователю цену API, а списывать другую цену StoreKit или
Google Play.

**Что сделано:** backend price используется только как fallback. При доступном
товаре UI и кнопка оплаты используют локализованную цену `ProductDetails.price`
из магазина. Backend при проверке обязан доверять данным Apple/Google, а не
сумме, присланной мобильным приложением.

### 15.12 Ошибку пытались связать с тестовым треком

**Вопрос:** заработает ли проверка автоматически после публикации приложения?

**Ответ:** нет. Internal testing поддерживает реальные тестовые Google Play
покупки и использует тот же Android Publisher API. Если service account получает
403, production будет получать ту же ошибку.

### 15.13 Кнопка Retry после backend-исправления

Backend сообщил, что live verification и идемпотентность включены. Однако до
выдачи Google-разрешений это не подтверждает полноценную проверку. После
настройки API правильный сценарий такой:

1. Тестировщик сохраняет текущую незавершённую покупку.
2. Устанавливает сборку с исправленным Retry.
3. Нажимает Retry один раз.
4. Приложение повторно отправляет старый token, не списывая деньги второй раз.
5. Backend возвращает HTTP 200.
6. Приложение consumes transaction и показывает success.

### 15.14 Состояние iOS отдельно от Android

Локальный StoreKit-каталог и клиентский receipt flow реализованы, однако успех
на iOS зависит от активных App Store Connect products и серверного Apple key.
То, что Android-конфигурация исправлена, не подтверждает iOS автоматически, и
наоборот. Оба магазина проверяются отдельными end-to-end покупками.

### 15.15 Удаление Apple Pay

Apple Pay не используется для цифровых VIP/boost-покупок. Оплата цифровой
услуги внутри приложения проходит через StoreKit на iOS и Google Play Billing
на Android. Старый отдельный provider checkout больше не является частью этого
IAP-потока.

## 16. Финальная end-to-end проверка

1. Проверить каталог API на всех языках и совпадение product ID.
2. Проверить, что каждый product ID найден App Store и Google Play.
3. Создать новое тестовое объявление и pending promotion order.
4. Купить один VIP-пакет через системное окно магазина.
5. Убедиться, что backend получил receipt/token и вернул HTTP 200.
6. Убедиться, что promotion стал `active` или `pending_activation`.
7. Повторно отправить тот же receipt/token и проверить отсутствие двойной
   активации.
8. Смоделировать временный HTTP 503, затем нажать Retry и проверить повторную
   валидацию без второго списания.
9. Проверить Cancel, Pending purchase и восстановление после перезапуска.
10. Повторить сценарии отдельно на TestFlight и Google Play Internal testing.

Backend-лог Android во время теста:

```bash
cd /var/www/api.wawatair.com
tail -f storage/logs/laravel.log | grep --line-buffered 'Google IAP'
```

Ожидаемый конечный результат: магазин подтверждает оплату, backend валидирует
её через Apple/Google, сохраняет транзакцию идемпотентно, активирует услугу, и
только после этого мобильное приложение завершает transaction.
