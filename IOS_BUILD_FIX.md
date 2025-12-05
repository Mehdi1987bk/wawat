# iOS Build Error Fix - PusherSwift/TweetNacl Module Dependency

## Проблема / Problem

При сборке iOS приложения возникает ошибка:
```
error: Unable to find module dependency: 'CTweetNacl' (in target 'PusherSwift' from project 'Pods')
note: A dependency of Swift module 'TweetNacl'
note: A dependency of main module 'PusherSwift'
```

Также есть предупреждения в:
- `url_launcher_ios` - keyWindow deprecation (iOS 13.0)
- `flutter_local_notifications` - UNNotificationPresentationOptionAlert deprecation
- `flutter_downloader` - UILocalNotification deprecation
- `TweetNacl` - multiple withUnsafeMutableBytes deprecations
- `NWWebSocket` - class shadows module warning

## Причина / Root Cause

Ошибка появилась после добавления WebSocket/Pusher зависимостей. Проблема в том, что:

1. **Кэш iOS сборки содержит старые зависимости** - PusherSwift, TweetNacl, NWWebSocket остались в кэше после удаления пакета
2. **Модуль CTweetNacl не может быть найден** - это проблема линковки модулей в Swift
3. **Несовместимость между модулями** - PusherSwift пытается использовать TweetNacl, который зависит от CTweetNacl, но модуль не экспортирован правильно

## Решение / Solution

Нужно **полностью очистить iOS build кэш и переустановить Pods**:

### Шаг 1: Очистить iOS кэш
```bash
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf ~/Library/Developer/Xcode/DerivedData/*
cd ..
```

### Шаг 2: Очистить Flutter кэш
```bash
flutter clean
flutter pub get
```

### Шаг 3: Переустановить Pods
```bash
cd ios
pod deintegrate  # Если установлен cocoapods-deintegrate
pod install --repo-update
cd ..
```

### Шаг 4: Пересобрать проект
```bash
flutter build ios --release
```

## Альтернативное решение / Alternative Solution

Если проблема сохраняется, попробуйте:

### 1. Обновить CocoaPods
```bash
sudo gem install cocoapods
pod --version  # Должна быть версия 1.16+
```

### 2. Очистить весь Xcode кэш
```bash
rm -rf ~/Library/Caches/CocoaPods
rm -rf ~/Library/Developer/Xcode/DerivedData
cd ios
pod cache clean --all
pod install --repo-update
cd ..
```

### 3. Проверить Podfile минимальную версию iOS
В `ios/Podfile` должно быть:
```ruby
platform :ios, '14.0'  # ✓ Уже установлено
```

### 4. Если использовали Pusher - убедитесь что он удален
Если вы добавляли какой-то Pusher пакет (pusher_websocket_flutter, pusher_client и т.д.), убедитесь что:
- Он удален из `pubspec.yaml`
- Запущен `flutter pub get`
- Выполнены шаги очистки выше

## Предупреждения (Warnings) - Опционально

Предупреждения не блокируют сборку, но для их исправления:

### url_launcher deprecation
В `pubspec.yaml` уже обновлено до последней версии:
```yaml
url_launcher: ^6.3.2
```

### flutter_local_notifications deprecation
Можно обновить до последней версии (если нужно):
```bash
flutter pub upgrade flutter_local_notifications
```

### flutter_downloader deprecation
Можно обновить до последней версии (если нужно):
```bash
flutter pub upgrade flutter_downloader
```

## Проверка исправления / Verification

После выполнения шагов:

1. Ошибка **"Unable to find module dependency: 'CTweetNacl'"** должна исчезнуть
2. PusherSwift, TweetNacl, NWWebSocket не должны появляться в Podfile.lock (если вы их удалили)
3. Сборка должна пройти успешно

## Дополнительная информация / Additional Info

- **Текущая версия iOS**: 14.0 (minimum deployment target)
- **CocoaPods версия**: 1.16.2
- **Flutter версия**: 3.27.1 (из .fvmrc)

## Если проблема не решена / If Problem Persists

Откройте проект в Xcode и проверьте:

```bash
cd ios
open Runner.xcworkspace
```

В Xcode:
1. Product → Clean Build Folder (Cmd+Shift+K)
2. File → Workspace Settings → Build System → Legacy Build System (попробуйте)
3. Проверьте Build Phases → Link Binary With Libraries - убедитесь что TweetNacl и PusherSwift там нет (если вы их удалили)

## Команды для быстрого исправления / Quick Fix Commands

Скопируйте и выполните все команды сразу:

```bash
# Полная очистка и переустановка
cd ios && rm -rf Pods Podfile.lock .symlinks && cd ..
flutter clean
flutter pub get
cd ios && pod install --repo-update && cd ..
flutter build ios --release --no-codesign
```

---

**Примечание**: Эта проблема возникла после добавления и последующего удаления WebSocket/Pusher библиотек. iOS Pods кэш сохранил старые зависимости, которые нужно полностью очистить.
