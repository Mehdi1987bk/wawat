#!/bin/bash
# Сборка APK для установки на телефон.
#
# Использование:
#   ./scripts/build_apk.sh              # release, один APK на все телефоны
#   ./scripts/build_apk.sh debug        # debug-сборка (крупнее и медленнее)
#   ./scripts/build_apk.sh release --split-per-abi   # отдельный APK на архитектуру
#
# Проект закреплён на Flutter 3.27.1 через FVM (.fvmrc). Глобальный flutter
# новее — с ним падает `pub get` («version solving failed»). Скрипт сам находит
# нужный SDK и не даёт собрать не той версией.

set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$PWD"

MODE="${1:-release}"
shift || true
case "$MODE" in
  release|debug|profile) ;;
  *) echo "Неизвестный режим: $MODE (ожидается release, debug или profile)"; exit 1 ;;
esac

# ── Flutter нужной версии ────────────────────────────────────────────────────
PINNED="$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .fvmrc 2>/dev/null || true)"

if command -v fvm &>/dev/null && fvm flutter --version &>/dev/null; then
  FLUTTER=(fvm flutter)
elif [ -x ".fvm/flutter_sdk/bin/flutter" ]; then
  FLUTTER=(".fvm/flutter_sdk/bin/flutter")
else
  echo "Не найден Flutter $PINNED, закреплённый в .fvmrc."
  echo "Поставьте FVM (https://fvm.app) и выполните: fvm install $PINNED"
  echo "Глобальным flutter собирать нельзя — проект рассыплется на версиях пакетов."
  exit 1
fi

ACTUAL="$("${FLUTTER[@]}" --version 2>/dev/null | sed -n '1s/^Flutter \([^ ]*\).*/\1/p')"
if [ -n "$PINNED" ] && [ "$ACTUAL" != "$PINNED" ]; then
  echo "Flutter $ACTUAL, а .fvmrc требует $PINNED. Выполните: fvm install $PINNED"
  exit 1
fi
echo "Flutter $ACTUAL"

# ── Android SDK и JDK ────────────────────────────────────────────────────────
if [ -z "${ANDROID_SDK_ROOT:-}${ANDROID_HOME:-}" ] &&
   ! grep -q '^sdk.dir=' android/local.properties 2>/dev/null; then
  echo "Не найден Android SDK: задайте ANDROID_SDK_ROOT или sdk.dir в android/local.properties."
  exit 1
fi

# Gradle-конфиг проекта требует Java 17 (sourceCompatibility/jvmTarget).
JAVA_BIN="${JAVA_HOME:+$JAVA_HOME/bin/java}"
JAVA_BIN="${JAVA_BIN:-$(command -v java || true)}"
if [ -z "$JAVA_BIN" ] || [ ! -x "$JAVA_BIN" ]; then
  echo "Не найдена Java. Нужен JDK 17: задайте JAVA_HOME."
  exit 1
fi
JAVA_MAJOR="$("$JAVA_BIN" -version 2>&1 | sed -n '1s/.*version "\([0-9]*\).*/\1/p')"
if [ "${JAVA_MAJOR:-0}" -lt 17 ]; then
  echo "Java $JAVA_MAJOR, а сборка требует 17+. Задайте JAVA_HOME на JDK 17."
  exit 1
fi

# ── Подпись релиза ───────────────────────────────────────────────────────────
# Без keystore release-сборка падает на подписи. Ключ в репозиторий не
# коммитится, поэтому на новой машине его надо положить руками.
if [ "$MODE" = "release" ]; then
  if [ ! -f android/key.properties ]; then
    echo "Нет android/key.properties — release-сборку нечем подписать."
    echo "Положите ключ и key.properties (storePassword/keyPassword/keyAlias/storeFile)."
    exit 1
  fi
  STORE="$(sed -n 's/^storeFile=//p' android/key.properties)"
  # storeFile в key.properties разрешается относительно android/app/.
  if [ -n "$STORE" ] && [ ! -f "$STORE" ] && [ ! -f "android/app/$STORE" ]; then
    echo "Не найден keystore '$STORE' (ожидается android/app/$STORE)."
    exit 1
  fi
fi

# ── Сборка ───────────────────────────────────────────────────────────────────
"${FLUTTER[@]}" pub get
"${FLUTTER[@]}" build apk "--$MODE" "$@"

echo
echo "Готово. APK:"
find build/app/outputs/flutter-apk -name "*.apk" -newermt '-10 minutes' \
  -exec ls -lh {} \; | awk '{print "  " $NF "  " $5}'
echo
echo "Установить на телефон, подключённый по USB (нужен adb):"
echo "  adb install -r build/app/outputs/flutter-apk/app-$MODE.apk"
