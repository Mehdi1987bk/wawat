# Настройка Firebase Push Notifications

В проект добавлены пакеты и код для Firebase Cloud Messaging (FCM). Чтобы пуши работали, выполните шаги ниже.

## 1. Проект в Firebase Console

1. Откройте [Firebase Console](https://console.firebase.google.com/).
2. Создайте проект или выберите существующий.
3. Добавьте приложение **Android**: укажите package name `az.buking.buking`.
4. Добавьте приложение **iOS**: укажите bundle id (как в Xcode у Runner).

## 2. Файлы конфигурации

- **Android:** скачайте `google-services.json` и положите в каталог `android/app/`.
- **iOS:** скачайте `GoogleService-Info.plist` и добавьте в Xcode в target Runner (корень проекта Runner).

## 3. Генерация firebase_options.dart (FlutterFire CLI)

Установите CLI глобально (не в проекте — иначе конфликт с intl):

```bash
fvm dart pub global activate flutterfire_cli
export PATH="$PATH:$HOME/.pub-cache/bin"
```

**Если используете FVM:** скрипт `flutterfire` вызывает `dart`, поэтому в PATH должен быть `dart` из FVM. В корне проекта выполните:

```bash
# Подставить в PATH каталог с dart из FVM (тот же, что использует fvm flutter)
export PATH="$(pwd)/.fvm/flutter_sdk/bin:$PATH"
flutterfire configure
```

Либо одной строкой:

```bash
PATH="$(pwd)/.fvm/flutter_sdk/bin:$PATH" flutterfire configure
```

Будет создан/обновлён `lib/firebase_options.dart` с ключами для Android и iOS. Без этого шага приложение при запуске выдаст ошибку о ненастроенных опциях.

## 4. iOS: Push Notifications и права

- В Xcode: target **Runner** → **Signing & Capabilities** → добавьте **Push Notifications** (и при необходимости **Background Modes** с **Remote notifications**).
- В `Info.plist` уже добавлен режим `remote-notification` в `UIBackgroundModes`.

## 5. Android: ничего дополнительно

- В `AndroidManifest.xml` уже добавлено разрешение `POST_NOTIFICATIONS` и канал по умолчанию для FCM.
- Плагин `com.google.gms.google-services` подключён в `android/app/build.gradle`.

## 6. Использование FCM токена на бэкенде

После инициализации токен доступен так:

```dart
final token = await PushNotificationService().refreshToken();
// или
final token = PushNotificationService().fcmToken;
```

Чтобы отправлять токен на ваш API при логине или при обновлении:

```dart
PushNotificationService().setOnTokenUpdated((token) {
  // Отправить token на ваш backend (например, после логина).
});
```

Инициализация и запрос разрешений выполняются в `main()` при старте приложения.

## Проверка

- **Foreground:** уведомления показываются через `flutter_local_notifications`.
- **Background / Terminated:** системные уведомления от FCM; по тапу вызывается `onMessageOpenedApp` / `getInitialMessage` (логика в `PushNotificationService._handleMessageOpened`).
- Токен можно проверить в логах после запуска или через `PushNotificationService().fcmToken` / `refreshToken()`.
