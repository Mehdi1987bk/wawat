# Backend: полная настройка IAP для Google Play и App Store

Дата актуализации: 2026-09-14.

Этот документ предназначен для backend-разработчика и администратора store-
аккаунтов Wawatair. Его цель: довести оплату VIP и продвижения до полностью
рабочего состояния на Android и iOS, включая server-side verification,
идемпотентность, повторную проверку незавершённых покупок и production readiness.

## 1. Критически важное требование Google Play

> **Service account должен получить доступ ИМЕННО В ТОМ GOOGLE PLAY CONSOLE
> DEVELOPER ACCOUNT, КОТОРОМУ ПРИНАДЛЕЖИТ ПРИЛОЖЕНИЕ WAWAT AIR С PACKAGE NAME
> `az.buking.buking`.**

Недостаточно выполнить только одно из следующих действий:

- создать service account в Google Cloud;
- положить service-account JSON на backend;
- использовать существующий Firebase service account;
- включить Google Play Android Developer API;
- войти в любой другой Play Console developer account.

Service account создаётся в Google Cloud, но затем его email нужно отдельно
пригласить в `Users and permissions` нужного Play Console developer account.
Это должен быть тот аккаунт разработчика, внутри которого видны:

```text
Application: Wawat Air
Package name: az.buking.buking
```

Если после входа в Play Console этого приложения нет, открыт неправильный
developer account. В таком аккаунте настраивать service account бессмысленно.

Официальная инструкция Google подтверждает, что для server-to-server доступа
нужны действия и в Google Cloud Console, и в Google Play Console:

- [Google Play Developer API: Getting Started](https://developers.google.com/android-publisher/getting_started)
- [Play Console: users and permissions](https://support.google.com/googleplay/android-developer/answer/9844686)

## 2. Известные идентификаторы проекта

```text
Android application name: Wawat Air
Android package name:     az.buking.buking
iOS bundle identifier:    wawat.app
Google Cloud project ID:  wawatair-b212f
Google Cloud project no.: 774660161251
Service account email:    firebase-adminsdk-fbsvc@wawatair-b212f.iam.gserviceaccount.com
Mobile build:             1.0.54 (55)
```

Не создавать второй service account без необходимости. Текущий Firebase
service account можно использовать для Google Play verification, если:

1. API включён в его Google Cloud project;
2. его email приглашён в правильный Play Console developer account;
3. ему выданы нужные Play Console permissions;
4. JSON-файл этого же service account установлен на production backend.

## 3. Канонические товары

Backend, mobile, Google Play и App Store должны использовать одинаковые и
неизменяемые product ID.

### VIP, consumable

| Срок | Product ID | Backend fallback price |
| --- | --- | --- |
| 1 день | `wawat.app.vip.1d` | `0.99 USD` |
| 3 дня | `wawat.app.vip.3d` | `1.99 USD` |
| 5 дней | `wawat.app.vip.5d` | `2.99 USD` |

Старые `wawat.app.vip.7d` и `wawat.app.vip.30d` больше не используются.
Нельзя принимать `vip.1d`, а активировать 3 дня, или делать другие скрытые
преобразования product ID.

### Продвижение, consumable

| Пакет | Product ID | Backend package code |
| --- | --- | --- |
| Малый | `wawat.app.boost.small` | `small` |
| Средний | `wawat.app.boost.medium` | `medium` |
| Большой | `wawat.app.boost.large` | `large` |

Названия, описания, порядок, recommended и диапазоны гарантированных показов
приходят с backend. Фактическая цена и валюта приходят из магазина.

## 4. Ответственность компонентов

| Компонент | Ответственность |
| --- | --- |
| Backend catalog | Product ID, пакет, срок, тексты, диапазоны, recommended |
| Google Play / App Store | Наличие товара, локальная цена, факт оплаты |
| Mobile | Открытие системной оплаты, передача receipt/token, UI результата |
| Backend verifier | Проверка покупки напрямую в Apple/Google |
| Backend database | Уникальность транзакции и выдача entitlement ровно один раз |

Backend не должен доверять следующим значениям от mobile:

- цене;
- валюте;
- статусу покупки;
- сроку VIP;
- диапазону показов;
- названию пакета;
- заявлению клиента, что платёж успешен.

Backend получает `purchase_token` или `receipt`, проверяет его у store и только
после этого активирует услугу.

# Часть A. Google Play

## 5. Шаг 1: открыть правильный Play Console developer account

Действие выполняет владелец или администратор аккаунта разработчика Google Play.

1. Открыть [Google Play Console](https://play.google.com/console/).
2. В переключателе developer accounts выбрать аккаунт, в котором создан Wawat
   Air.
3. Открыть `All apps`.
4. Убедиться, что в списке есть Wawat Air.
5. Открыть приложение и проверить package name `az.buking.buking`.
6. Только после этой проверки переходить в `Users and permissions`.

### Stop-condition

Если Wawat Air или package `az.buking.buking` не видны, остановиться. Это не тот
developer account. Нельзя добавлять service account в случайный Play Console
аккаунт: он всё равно не получит доступ к покупкам Wawat Air.

## 6. Шаг 2: включить Google Play Android Developer API

В Google Cloud Console выбрать именно проект:

```text
wawatair-b212f
```

Далее:

1. Открыть `APIs & Services` -> `Library`.
2. Найти `Google Play Android Developer API`.
3. Нажать `Enable`.
4. Открыть `APIs & Services` -> `Enabled APIs & services`.
5. Убедиться, что виден сервис `androidpublisher.googleapis.com`.

Команда для пользователя с правами `Service Usage Admin`:

```bash
gcloud config set project wawatair-b212f
gcloud services enable androidpublisher.googleapis.com \
  --project=wawatair-b212f
```

Проверка:

```bash
gcloud services list --enabled \
  --project=wawatair-b212f \
  --filter='config.name:androidpublisher.googleapis.com'
```

Если включение возвращает permission denied, выполнять команду должен владелец
Cloud project или пользователь с `roles/serviceusage.serviceUsageAdmin`.
Service account backend не обязан и обычно не должен иметь право самостоятельно
включать API.

Официальная инструкция:
[Enable and disable Google Cloud services](https://cloud.google.com/service-usage/docs/enable-disable).

## 7. Шаг 3: проверить service account в Google Cloud

В проекте `wawatair-b212f` открыть:

```text
IAM & Admin -> Service Accounts
```

Найти:

```text
firebase-adminsdk-fbsvc@wawatair-b212f.iam.gserviceaccount.com
```

Проверить:

- service account не disabled;
- JSON принадлежит именно этому email;
- JSON содержит `project_id: wawatair-b212f`;
- private key не отозван;
- backend использует текущий JSON, а не старую копию другого аккаунта.

Создавать новый JSON только если текущий ключ утрачен или отозван:

```text
Service account -> Keys -> Add key -> Create new key -> JSON
```

Файл скачивается как секрет. Его нельзя отправлять в публичный чат, добавлять в
репозиторий, Docker image или mobile application.

## 8. Шаг 4: пригласить service account в нужный Play Console account

Это ключевой шаг, который сейчас не подтверждён.

Находясь в **правильном developer account**, которому принадлежит Wawat Air:

1. Открыть `Users and permissions`.
2. Нажать `Invite new users`.
3. В поле email вставить service account email:

```text
firebase-adminsdk-fbsvc@wawatair-b212f.iam.gserviceaccount.com
```

4. Выбрать app-level access для Wawat Air / `az.buking.buking` либо account-level
   access, если ваша политика требует глобального доступа.
5. Выдать разрешения:

```text
View app information and download bulk reports (read only)
View financial data, orders, and cancellation survey responses
Manage orders and subscriptions
```

6. Нажать `Invite user`.
7. Вернуться в список пользователей.
8. Убедиться, что service account отображается как пользователь и имеет доступ
   к Wawat Air.

`Manage orders and subscriptions` требуется Google для полного использования
Play Billing API, включая управление/consume/acknowledge. Если backend только
читает покупку, права всё равно рекомендуется выдать согласно официальной
инструкции Google Billing API. Доступ лучше ограничить приложением Wawat Air,
если нет необходимости давать его всему developer account.

### Что означает «именно в аккаунте разработчика»

Service account не является обычным Gmail-пользователем и не создаётся «внутри»
личного Play-аккаунта. Правильная схема:

```text
Google Cloud project
  -> создаёт service account
  -> service account имеет email
  -> этот email приглашается в Play Console
  -> приглашение выполняется внутри developer account владельца Wawat Air
  -> service account получает permission на az.buking.buking
```

Google больше не требует обязательно связывать developer account с Cloud
project, но приглашение service account в Play Console остаётся обязательным.

## 9. Шаг 5: создать и активировать товары Google Play

В Wawat Air открыть раздел монетизации и создать one-time products. Все шесть
товаров должны иметь точные ID из раздела 3.

Для каждого товара проверить:

- тип: one-time product / in-app product;
- товар активен;
- имеется активная buy purchase option, если используется новый каталог;
- настроена цена;
- доступны нужные страны/регионы;
- tax/compliance заполнены;
- product ID без лишних пробелов и с правильным регистром;
- изменения опубликованы, а не остались draft.

Store title можно заполнить на одном основном языке. Названия и описания внутри
интерфейса Wawatair всё равно приходят с backend. Но обязательные поля Play
Console должны быть заполнены для публикации продукта.

Официальные материалы:

- [Create an in-app product](https://support.google.com/googleplay/android-developer/answer/1153481)
- [One-time products](https://developer.android.com/google/play/billing/one-time-products)

## 10. Шаг 6: настроить тестовые аккаунты

Для надёжного теста один и тот же Google account должен:

1. находиться в списке Internal testing;
2. открыть opt-in link и принять участие в тесте;
3. находиться в `Settings -> License testing`;
4. быть выбранным аккаунтом в Google Play на устройстве;
5. установить приложение через Google Play Internal testing;
6. видеть тестовый способ оплаты в системном окне Google.

Официально товары должны быть опубликованы, а приложение должно иметь релиз в
test или production track. Internal testing достаточно; выкладывать приложение
в production для проверки IAP не нужно.

Полезные инструкции:

- [License testing](https://support.google.com/googleplay/android-developer/answer/6062777)
- [Test Google Play Billing](https://developer.android.com/google/play/billing/test)

## 11. Шаг 7: установить JSON на production backend

Рекомендуемый путь вне git:

```text
/var/www/api.wawatair.com/storage/app/google-play/service-account.json
```

Пример прав:

```bash
sudo chown wawatair:wawatair \
  /var/www/api.wawatair.com/storage/app/google-play/service-account.json
sudo chmod 600 \
  /var/www/api.wawatair.com/storage/app/google-play/service-account.json
```

Production `.env`:

```dotenv
GOOGLE_PLAY_PACKAGE_NAME=az.buking.buking
GOOGLE_PLAY_SERVICE_ACCOUNT=/var/www/api.wawatair.com/storage/app/google-play/service-account.json
```

Нельзя помещать в `.env` само содержимое private key, если приложение ожидает
путь к файлу. Нельзя логировать JSON или access token.

После изменения:

```bash
cd /var/www/api.wawatair.com
/usr/bin/php8.4 artisan optimize:clear
/usr/bin/php8.4 artisan optimize
```

Проверка без вывода секрета:

```bash
/usr/bin/php8.4 artisan tinker --execute='
$s = app(\App\Settings\IapSettings::class);
dump([
  "enabled" => $s->enabled,
  "google_live" => $s->google_live,
  "android_package_id" => $s->android_package_id,
  "package_env" => config("services.google_play.package_name"),
  "credentials_exist" => is_file(config("services.google_play.service_account")),
]);'
```

Ожидается:

```text
enabled=true
google_live=true
android_package_id=az.buking.buking
package_env=az.buking.buking
credentials_exist=true
```

Эта проверка подтверждает только локальную конфигурацию backend. Она не
подтверждает, что API включён и Play Console permissions действительно выданы.

## 12. Backend catalog

Mobile использует backend как источник product ID и метаданных:

```http
GET /api/v1/purchases/catalog
Authorization: Bearer <user-token>
Accept: application/json
Accept-Language: ru
```

Поддерживаемые языки:

```text
az, en, ru, tr, ua
```

Формат:

```json
{
  "data": {
    "products": [
      {
        "package_id": "vip-3-days",
        "product_id": "wawat.app.vip.3d",
        "kind": "vip",
        "name": "VIP на 3 дня",
        "description": "Объявление будет показано в VIP-разделе",
        "duration_days": 3,
        "price": 1.99,
        "currency": "USD",
        "recommended": true,
        "sort_order": 20
      },
      {
        "package_id": "boost-medium",
        "product_id": "wawat.app.boost.medium",
        "kind": "featured",
        "package": "medium",
        "name": "Продвижение · Средний",
        "description": "Гарантированные показы",
        "guaranteed_min": 352,
        "guaranteed_max": 588,
        "price": 7.99,
        "currency": "USD",
        "recommended": true,
        "sort_order": 20
      }
    ]
  }
}
```

Backend должен:

- вернуть все активные товары;
- локализовать `name` и `description` по `Accept-Language`;
- кэшировать каталог отдельно по языку;
- не подменять product ID;
- считать `guaranteed_min/max` на backend;
- гарантировать `guaranteed_max >= guaranteed_min > 0`;
- хранить цену catalog только как fallback;
- не считать цену catalog доказательством суммы покупки.

## 13. Создание pending promotion order

До открытия Google Play mobile создаёт заказ:

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

Backend обязан:

1. проверить авторизацию;
2. проверить, что listing принадлежит пользователю;
3. проверить, что package/duration существует и активен;
4. вычислить ожидаемый product ID;
5. создать заказ `pending_payment`;
6. сохранить snapshot пакета, срока, диапазона, цены и валюты;
7. сохранить idempotency key;
8. при повторном запросе с тем же key вернуть тот же заказ;
9. не активировать услугу до store verification.

## 14. Android payment endpoint

Mobile отправляет реальный purchase token:

```http
POST /api/v1/promotions/{promotion_id}/pay
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "method": "google",
  "purchase_token": "<token from Google Play>"
}
```

Backend должен использовать OAuth scope:

```text
https://www.googleapis.com/auth/androidpublisher
```

Рекомендуемый актуальный endpoint проверки one-time purchase:

```http
GET https://androidpublisher.googleapis.com/androidpublisher/v3/
    applications/az.buking.buking/purchases/productsv2/tokens/{purchase_token}
```

Допустим legacy endpoint, если текущая библиотека backend использует его:

```http
GET https://androidpublisher.googleapis.com/androidpublisher/v3/
    applications/az.buking.buking/purchases/products/{product_id}/tokens/{purchase_token}
```

Официальные ссылки:

- [Google Play Android Developer API](https://developers.google.com/android-publisher/api-ref/rest)
- [One-time purchase lifecycle](https://developer.android.com/google/play/billing/lifecycle/one-time)
- [Fight fraud and abuse](https://developer.android.com/google/play/billing/security)

## 15. Что обязательно проверять в ответе Google

Backend должен проверить минимум:

1. Google запрос завершился успешно.
2. Purchase state равен `PURCHASED`, не `PENDING` и не `CANCELLED`.
3. Product line item содержит ожидаемый product ID.
4. Product ID совпадает с pending promotion order.
5. Package name равен `az.buking.buking`.
6. Token ещё не использован другим заказом.
7. Пользователь имеет право оплатить этот listing.
8. Заказ ещё не активирован либо это идемпотентный повтор.
9. Тестовая покупка допускается только в test environment/track согласно
   политике проекта.
10. Обязательные поля Google response сохранены для аудита без хранения лишних
    персональных данных.

Нельзя активировать entitlement, если состояние `PENDING`. Pending не является
ошибкой: backend должен вернуть понятный статус ожидания.

## 16. Идемпотентность и база данных

Purchase token глобально уникален и должен иметь UNIQUE constraint. Не следует
использовать только Google order ID как ключ дедупликации: Google указывает, что
не все покупки обязательно имеют order ID.

Минимально хранить:

```text
provider                    google | apple
provider_transaction_key    UNIQUE
product_id
promotion_id
user_id
listing_id
purchase_state
verification_status
store_order_id              nullable
store_payload_snapshot      encrypted/redacted JSON
verified_at
activated_at                nullable
created_at / updated_at
```

Критическая уникальность:

```sql
UNIQUE(provider, provider_transaction_key)
```

Обработка должна выполняться в database transaction:

```text
begin transaction
  lock promotion order
  find or insert store transaction by unique token/transaction id
  if token belongs to another promotion: reject conflict
  if already successfully processed: return previous successful result
  verify expected product
  persist verification result
  activate VIP/boost exactly once
  mark promotion active or pending_activation
commit
```

Повторный запрос с тем же token и тем же promotion должен вернуть HTTP 200 с
тем же итоговым состоянием. Он не должен повторно прибавлять дни, показы или
создавать второй платёж.

## 17. Кто выполняет consume

В текущей мобильной реализации Android purchase consumes на устройстве только
после HTTP 200 от backend.

Поэтому backend сейчас должен:

- проверить Google token;
- записать и активировать entitlement идемпотентно;
- вернуть HTTP 200;
- **не выполнять consume параллельно с mobile**.

Если backend начнёт вызывать `purchases.products.consume`, mobile также
попытается consume и может показать ошибку после уже успешной активации. Должен
быть выбран ровно один владелец consume.

Текущий контракт:

```text
Backend verifies and activates -> HTTP 200 -> Mobile consumes
```

Перенос consume на backend возможен позже, но только вместе с изменением mobile
и отдельным end-to-end тестом.

## 18. HTTP-ответы backend

### Успех

```http
HTTP 200
```

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

Если listing находится на модерации:

```json
{
  "data": {
    "activated": false,
    "promotion": {
      "status": "pending_activation"
    }
  }
}
```

Покупка при этом должна быть подтверждена и сохранена ровно один раз.

### Ошибки

| HTTP | Смысл | Поведение mobile |
| --- | --- | --- |
| 401 | Пользователь не авторизован | Попросить войти заново |
| 403 | Нет доступа к операции или Google API | Не consume; разрешить Retry |
| 409 | Token уже связан с другим заказом | Не активировать второй раз |
| 422 | Неверный product/order/state | Не consume; показать validation error |
| 503 | Google API, credentials или permissions недоступны | Не consume; разрешить Retry |

Внутренняя ошибка Google не должна превращаться в HTTP 200. Но повторяемые
ошибки не должны удалять pending order или считать token потраченным.

## 19. Логи без утечки секретов

Логировать:

```text
provider
promotion_id
product_id
user_id
Google HTTP status
purchase state
verification result
activated true/false
короткий hash token, не сам token
```

Не логировать:

```text
полный purchase_token
service account JSON
private_key
OAuth access token
Apple .p8
полный receipt
Authorization Bearer token пользователя
```

Команда наблюдения:

```bash
cd /var/www/api.wawatair.com
tail -f storage/logs/laravel.log | grep --line-buffered 'Google IAP'
```

## 20. Проверка доступа Google до мобильного теста

Backend-разработчик должен выполнить smoke test с реальным тестовым purchase
token. Результат должен различать:

| Результат | Значение |
| --- | --- |
| 200 от Android Publisher API | API и permissions работают |
| 401 | Неверный/отозванный service account key или OAuth |
| 403 | API выключен либо service account не приглашён/не имеет permissions |
| 404 | Неверный package, token или неправильный developer account |

Последняя известная проверка возвращала 403. Поэтому нельзя сообщать, что
Google backend integration готова, пока smoke test не вернул успешный Google
response.

## 21. Полный Android end-to-end тест

1. Опубликовать все товары.
2. Опубликовать Android bundle в Internal testing.
3. Добавить тестовый email в Internal testing.
4. Добавить тот же email в License testing.
5. Установить приложение из Google Play под этим аккаунтом.
6. Создать объявление.
7. Выбрать VIP на 1, 3 или 5 дней.
8. Убедиться, что системное окно Google показывает правильный product/price.
9. Завершить тестовую оплату.
10. Проверить входящий `/promotions/{id}/pay` на backend.
11. Проверить успешный ответ Android Publisher API.
12. Проверить UNIQUE store transaction в базе.
13. Проверить активированный promotion.
14. Проверить HTTP 200 mobile.
15. Проверить consume после HTTP 200.
16. Повторно купить этот consumable после consume.
17. Повторить тот же backend token и проверить отсутствие двойной активации.
18. Проверить pending payment.
19. Проверить canceled payment.
20. Временно смоделировать 503 и убедиться, что Retry использует старый token,
    а не запускает второе списание.

Для license tester неподтверждённая покупка может быть быстро возвращена Google,
поэтому проверку и consume нельзя откладывать.

# Часть B. Apple App Store

## 22. Создать consumable products в App Store Connect

В App Store Connect открыть Wawat Air с bundle ID `wawat.app`:

```text
Apps -> Wawat Air -> Monetization -> In-App Purchases
```

Создать те же шесть consumable product ID из раздела 3. Для каждого заполнить:

- Reference Name;
- Product ID;
- локализацию;
- цену;
- availability;
- tax category;
- review information, если требуется;
- состояние, допускающее Sandbox/TestFlight тест.

Paid Apps Agreement должен быть Active, а banking и tax заполнены. Изменения
метаданных могут появляться в Sandbox не мгновенно.

Официальные инструкции:

- [Configure In-App Purchases](https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/overview-for-configuring-in-app-purchases)
- [Create a consumable IAP](https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/create-consumable-or-non-consumable-in-app-purchases)
- [Submit an IAP for review](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-in-app-purchase)

## 23. Создать Apple In-App Purchase key

Это не APNs push key.

В App Store Connect:

```text
Users and Access -> Integrations -> In-App Purchase
```

Далее:

1. Нажать `Generate In-App Purchase Key`.
2. Дать понятное имя, например `wawat-iap-server`.
3. Скачать `.p8` один раз.
4. Сохранить `Key ID`.
5. Сохранить `Issuer ID`.
6. Передать backend по защищённому каналу.

Backend нужны:

```text
In-App Purchase .p8 file
Key ID
Issuer ID
Bundle ID: wawat.app
Environment: Sandbox and Production
```

Официальная инструкция:
[Creating API keys for App Store Server API](https://developer.apple.com/documentation/appstoreserverapi/creating-api-keys-to-authorize-api-requests).

## 24. Apple secrets на backend

Рекомендуемый путь вне git:

```text
/var/www/api.wawatair.com/storage/app/apple-iap/AuthKey_<KEY_ID>.p8
```

Пример `.env` без реальных значений:

```dotenv
APPLE_IAP_BUNDLE_ID=wawat.app
APPLE_IAP_KEY_ID=<key-id>
APPLE_IAP_ISSUER_ID=<issuer-id>
APPLE_IAP_PRIVATE_KEY_PATH=/var/www/api.wawatair.com/storage/app/apple-iap/AuthKey_<key-id>.p8
APPLE_IAP_LIVE=true
```

Права файла:

```bash
sudo chown wawatair:wawatair \
  /var/www/api.wawatair.com/storage/app/apple-iap/AuthKey_<key-id>.p8
sudo chmod 600 \
  /var/www/api.wawatair.com/storage/app/apple-iap/AuthKey_<key-id>.p8
```

## 25. Apple payment endpoint

Mobile отправляет:

```http
POST /api/v1/promotions/{promotion_id}/pay
Authorization: Bearer <user-token>
Content-Type: application/json

{
  "method": "apple",
  "receipt": "<StoreKit server verification data>"
}
```

Backend должен:

1. проверить receipt/transaction через Apple;
2. поддержать Sandbox и Production environment;
3. проверить bundle ID `wawat.app`;
4. проверить product ID;
5. сопоставить product ID с pending promotion;
6. проверить успешное состояние transaction;
7. использовать Apple transaction ID как уникальный provider key;
8. активировать entitlement ровно один раз;
9. вернуть идемпотентный HTTP 200 при повторной доставке transaction.

App Store Server API использует JWT, подписанный In-App Purchase `.p8` key:
[App Store Server API](https://developer.apple.com/documentation/appstoreserverapi).

## 26. Полный iOS end-to-end тест

1. Проверить товары и agreements в App Store Connect.
2. Проверить Apple server key на backend.
3. Установить сборку через TestFlight.
4. Создать pending promotion.
5. Выполнить Sandbox/TestFlight покупку.
6. Проверить Apple verification на backend.
7. Проверить product ID и bundle ID.
8. Проверить UNIQUE transaction ID.
9. Проверить активацию entitlement.
10. Проверить повторную доставку transaction без двойной активации.
11. Проверить user cancellation.
12. Проверить восстановление незавершённой transaction после перезапуска.

# Часть C. Критерии завершения

## 27. Backend считается готовым только когда выполнено всё

### Google configuration

- [ ] Открыт правильный Play Console developer account.
- [ ] В нём виден Wawat Air / `az.buking.buking`.
- [ ] `androidpublisher.googleapis.com` включён в `wawatair-b212f`.
- [ ] Service account существует и не disabled.
- [ ] Service account email приглашён в этот конкретный developer account.
- [ ] Service account имеет доступ к Wawat Air.
- [ ] Выданы app information, financial/orders и manage orders permissions.
- [ ] Все шесть товаров созданы, активны и опубликованы.
- [ ] Google API smoke test с реальным тестовым token возвращает success.

### Backend implementation

- [ ] Каталог отдаёт точные product ID и локализованные тексты.
- [ ] Pending order создаётся идемпотентно.
- [ ] Google token проверяется напрямую у Google.
- [ ] Apple receipt/transaction проверяется напрямую у Apple.
- [ ] Purchased проверяется отдельно от Pending/Canceled.
- [ ] Product ID сверяется с pending order.
- [ ] Transaction key имеет UNIQUE constraint.
- [ ] Повторный token возвращает прежний success без второго entitlement.
- [ ] Backend не consumes одновременно с текущим mobile.
- [ ] Ошибка store не уничтожает возможность Retry.
- [ ] Секреты и полные token/receipt не попадают в логи.

### End-to-end

- [ ] Android Internal testing purchase завершилась HTTP 200 и активацией.
- [ ] Android Retry старого token работает без второго списания.
- [ ] iOS TestFlight purchase завершилась HTTP 200 и активацией.
- [ ] Повторная доставка Apple/Google transaction не активирует услугу дважды.

## 28. Текущий известный блокер

Backend выполнил smoke test 2026-09-14:

```text
OAuth token: получен успешно
Service account JSON: исправен
Authentication: работает
Android Publisher API: HTTP 403
Google message: API has not been used in project 774660161251 before or is disabled
```

Следовательно, текущая подтверждённая причина 403: Google Play Android
Developer API выключен в `wawatair-b212f`. Ошибка 401 и проблема ключа service
account исключены.

Дополнительная проверка в Brave показала, что открытый Google-аккаунт
`mehdi1987@bk.ru` не имеет доступа к project `774660161251`, включая permission
`resourcemanager.projects.get`. Поэтому этот аккаунт не может включить API.

Сейчас требуется:

1. Войти в Google Cloud под владельцем/администратором проекта
   `wawatair-b212f` либо выдать нужному пользователю `Service Usage Admin`.
2. Включить `androidpublisher.googleapis.com`.
3. Подождать несколько минут.
4. Повторить backend smoke test.
5. Если результат станет 404 для заведомо фиктивного token, доступ к API
   работает; 404 в таком тесте ожидаем, потому что token не существует.
6. Если появится новый 403 `insufficient permissions`, выполнить раздел 8:
   пригласить service account в правильный Play Console developer account.

До успешного API smoke test нельзя считать Android IAP полностью готовым.
Публикация приложения в production не исправит 403. Сначала нужно исправить
доступ, успешно завершить покупку в Internal testing и только потом выпускать
production release.

Backend также сообщил текущий статус:

```text
Six Android product IDs active: yes (по отчёту backend)
Google live verification: enabled
Idempotency: implemented
Apple live verification/key: configured (по отчёту backend)
Real Android purchase verification: ещё не выполнена из-за выключенного API
Real TestFlight purchase verification: ещё не подтверждена end-to-end тестом
```

## 29. Что backend должен вернуть после выполнения

Backend-разработчик должен прислать результат без секретов:

```text
1. Google API enabled: yes/no
2. Correct Play developer account verified: yes/no
3. Service account invited to that account: yes/no
4. Wawat Air app permission granted: yes/no
5. Required billing permissions granted: yes/no
6. Six product IDs active: yes/no + missing IDs
7. Android Publisher smoke test HTTP status: <status>
8. Real test purchase verification: success/failure
9. Promotion activation: active/pending_activation/failure
10. Duplicate token test: idempotent/not idempotent
11. Apple products active: yes/no + missing IDs
12. Apple server key configured: yes/no
13. TestFlight purchase verification: success/failure
```

Не присылать `.p8`, service account JSON, private keys, receipts или purchase
tokens в обычном чате. Для секретов использовать защищённое хранилище или
приватный зашифрованный канал.
