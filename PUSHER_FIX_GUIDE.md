# Pusher Channels Flutter - iOS Xcode 26.0 Fix

## 🔴 Проблема

При сборке iOS приложения с `pusher_channels_flutter` на **Xcode 26.0** возникает ошибка:

```
error: Unable to find module dependency: 'CTweetNacl' (in target 'PusherSwift' from project 'Pods')
```

## 🎯 Причина

Apple включила **"Explicit Module Builds"** по умолчанию в **Xcode 26.0**. Это требует явного объявления всех Swift/Clang модулей.

**TweetNacl** (используется Pusher для шифрования) не был создан с учетом этого требования → модуль **CTweetNacl** не найден.

---

## ✅ Решение

### Шаг 1: Обновить `ios/Podfile`

Замените блок `post_install` на этот код:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    target.build_configurations.each do |config|
      # Минимальная версия iOS
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'

      # ✅ FIX для CTweetNacl ошибки с Pusher на Xcode 26.0
      if ['PusherSwift', 'PusherSwiftWithEncryption', 'TweetNacl'].include?(target.name)
        config.build_settings['SWIFT_ENABLE_EXPLICIT_MODULES'] = 'NO'
        config.build_settings['SWIFT_ENABLE_INCREMENTAL_COMPILATION'] = 'NO'
        config.build_settings['SWIFT_COMPILATION_MODE'] = 'wholemodule'
      end
    end
  end

  # ✅ Отключить explicit modules глобально для Pods
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['SWIFT_ENABLE_EXPLICIT_MODULES'] = 'NO'
  end
end
```

### Шаг 2: Очистить кэш и пересобрать

```bash
# 1. Очистить Flutter
flutter clean
flutter pub get

# 2. Очистить iOS кэш
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks

# 3. Очистить Xcode DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 4. Переустановить Pods
pod install --repo-update
cd ..

# 5. Пересобрать проект
flutter build ios --release
```

---

## 📝 Полный пример Podfile

Смотрите файл `ios/Podfile.EXAMPLE` для полного примера.

---

## 🔍 Что делает этот фикс?

1. **Отключает Explicit Modules** для `PusherSwift`, `PusherSwiftWithEncryption`, `TweetNacl`
2. **Отключает инкрементальную компиляцию** для этих модулей
3. **Использует whole-module optimization** для корректной сборки
4. **Глобально отключает explicit modules** для всех Pods проекта

---

## ⚠️ Альтернативные решения

### Вариант 1: Использовать другой Pusher клиент

Если проблема сохраняется, попробуйте альтернативы:

- **WebSocket** напрямую через `web_socket_channel`
- **Socket.IO** через `socket_io_client`
- **Собственный REST polling** вместо real-time

### Вариант 2: Откатить Xcode

Временно использовать **Xcode 25.x** до исправления в pusher_channels_flutter:

```bash
# Скачать Xcode 25.4
# https://developer.apple.com/download/all/

# Переключить активную версию
sudo xcode-select -s /Applications/Xcode-25.4.app
```

### Вариант 3: Ждать обновления

Следить за обновлением **pusher_channels_flutter**:
- GitHub: https://github.com/pusher/pusher-channels-flutter/issues

---

## 📚 Источники

- [Medium: Fixing CTweetNacl Error](https://medium.com/@frankperez87/fixing-the-unable-to-find-module-dependency-ctweetnacl-error-in-flutter-ios-with-pusher-1ae161266dd2)
- [Stack Overflow: Flutter iOS Build Fails After Xcode 26](https://stackoverflow.com/questions/79769313/flutter-ios-build-fails-after-xcode-26-update-unable-to-find-module-dependency)
- [GitHub Issue: Expensify App](https://github.com/Expensify/App/issues/70800)
- [GitHub: pusher-websocket-swift Issue #371](https://github.com/pusher/pusher-websocket-swift/issues/371)

---

## 🎯 Проверка

После выполнения исправления:

✅ Ошибка **"Unable to find module dependency: 'CTweetNacl'"** исчезнет
✅ PusherSwift соберется корректно
✅ Приложение можно загрузить в App Store

---

## 💡 Рекомендация

Если вы **НЕ используете** encryption в Pusher, можно попробовать использовать прямой **WebSocket** вместо `pusher_channels_flutter` для избежания этой проблемы полностью.
