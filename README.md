# Wawat Air

Мобильное приложение сервиса [Wawatair](https://wawatair.com): путешественники
везут посылки попутно. Flutter, dart-пакет называется `buking`.

Описание экранов и структуры — в [WAWAT_README.md](WAWAT_README.md),
рабочие заметки по бэкенду, аналитике и локализации — в [`docs/`](docs).

## Требования

| Что | Версия | Почему именно она |
|-----|--------|-------------------|
| Flutter | **3.27.1** | пин в `.fvmrc`; с более новым `pub get` падает на решении версий |
| JDK | 17 | `sourceCompatibility` / `jvmTarget` в `android/app/build.gradle` |
| Android SDK | compileSdk 35, build-tools 35 | |
| Android NDK | 27.0.12077973 | |

Нужную версию Flutter ставит [FVM](https://fvm.app):

```bash
fvm install 3.27.1
fvm flutter pub get
```

Дальше все команды — через `fvm flutter`, не через глобальный `flutter`.
Глобальный новее, и проект с ним рассыпается на версиях пакетов: это выглядит
как «устаревшие зависимости», но дело только в версии SDK.

## Запуск

```bash
fvm flutter run              # на подключённом телефоне или эмуляторе
fvm flutter test             # 30 тестов
fvm flutter analyze
```

Web- и desktop-сборок нет: 22 файла в `lib/` завязаны на `dart:io`.

## Сборка APK для телефона

```bash
./scripts/build_apk.sh                          # универсальный APK, ~85 МБ
./scripts/build_apk.sh release --split-per-abi  # по одному на архитектуру, ~38 МБ
```

Скрипт проверяет версию Flutter, JDK, Android SDK и ключ подписи, потом собирает.
Результат — в `build/app/outputs/flutter-apk/`.

Для установки на свой телефон надёжнее универсальный APK. При `--split-per-abi`
Flutter сдвигает `versionCode` на номер архитектуры (arm64 → `2029` вместо `29`),
и после такой сборки обновление из Play выглядит для Android откатом версии —
приложение придётся сначала удалить.

Установка на телефон и заливка в сторы — в `.project-ai/DEPLOYMENT.md`.

Release-сборке нужны `android/key.properties` и keystore; в git они не лежат,
на новой машине их надо положить руками.

## Бэкенд

Приложение всегда работает с боевым API `https://api.wawatair.com/api/v1`
(`lib/main.dart`). Отдельного тестового контура нет.

Тексты интерфейса приходят из CMS (`GET /content`), а не из ARB-файлов.
