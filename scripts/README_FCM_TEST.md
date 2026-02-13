# Тестовое FCM-уведомление (без gcloud)

Используется **Dart-скрипт** и JSON сервисного аккаунта из Firebase. Устанавливать gcloud не нужно.

## 1. Один раз: скачать JSON сервисного аккаунта

1. Откройте [Firebase Console](https://console.firebase.google.com/) → проект **wawatair**
2. **Project settings** (шестерёнка) → вкладка **Service accounts**
3. Нажмите **Generate new private key** → сохраните файл (например, как `service_account.json`) в папку `scripts/` проекта  
   Или в любое место — в команде ниже укажите полный путь к файлу.

Не коммитьте этот файл в git (он уже в `.gitignore`).

## 2. Одна консольная команда

Сначала установите зависимости (если ещё не ставили):

```bash
cd /Users/dart/StudioProjects/wawat && fvm dart pub get
```

Отправка тестового уведомления (подставьте путь к вашему `service_account.json` и при необходимости свой FCM-токен):

```bash
cd /Users/dart/StudioProjects/wawat && fvm dart run bin/send_fcm.dart scripts/service_account.json "fX8tdbEDRdWoEQhuEumRrk:APA91bEmw2l6J6gkttVZVWfvVc3rv5ws4u6tAIexamWtKvGKzYHzU5mfSNEcgSzO3o6ukAXfRkRY_hGlAeQ77vVatOQR5jFmbteZHDducmG5r7zJ4vXhja4"
```

Если JSON лежит в другом месте:

```bash
fvm dart run bin/send_fcm.dart /путь/к/service_account.json "ВАШ_FCM_ТОКЕН"
```

Успешный ответ — JSON с полем `"name": "projects/wawatair-b212f/messages/..."`.
