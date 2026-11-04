# Тексты экрана «Обновление приложения» — для бэкенда

В приложении появился экран «Доступно обновление» с кнопкой «Обновить сейчас»:
приложение само скачивает новую версию и перезапускается. Тексты экрана
приходят из CMS (`/content`, группа **`update`**). Пока ключей на бэкенде нет,
приложение показывает азербайджанский вариант на всех языках.

## Что нужно сделать

1. Добавить **10 новых ключей** в группу `update` для всех 6 языков
   (`az`, `en`, `ru`, `tr`, `ua`, `es`) — список ниже.
2. Больше ничего: новых эндпоинтов, полей и миграций не требуется.
   Само обновление приходит не через наш сервер.

Уже существующие ключи, которые экран тоже использует, — **не трогать**:
`update.button`, `common.continue`, `common.retry`, `common.close`.

## Ключи

| Ключ | Где на экране |
| --- | --- |
| `update.ota_title` | Заголовок: есть обновление |
| `update.ota_body` | Текст под заголовком |
| `update.ota_downloading_body` | Текст во время скачивания |
| `update.ota_downloading_button` | Кнопка во время скачивания |
| `update.ota_done_title` | Заголовок после скачивания |
| `update.ota_restarting_body` | Текст перед перезапуском |
| `update.ota_restarting_button` | Кнопка перед перезапуском |
| `update.ota_next_launch_body` | Текст, если перезапуститься сразу нельзя |
| `update.ota_failed_title` | Заголовок ошибки |
| `update.ota_failed_body` | Текст ошибки |

### update.ota_title
- **az:** Yeniləmə mövcuddur
- **en:** Update available
- **ru:** Доступно обновление
- **tr:** Güncelleme mevcut
- **ua:** Доступне оновлення
- **es:** Actualización disponible

### update.ota_body
- **az:** Wawatair-in yeni versiyası hazırdır. Düyməyə basın — tətbiq onu yükləyib özü yenidən açılacaq.
- **en:** A new version of Wawatair is ready. Tap the button — the app will download it and restart on its own.
- **ru:** Новая версия Wawatair уже готова. Нажмите кнопку — приложение скачает её и перезапустится само.
- **tr:** Wawatair'in yeni sürümü hazır. Düğmeye dokunun — uygulama onu indirip kendiliğinden yeniden başlayacak.
- **ua:** Нова версія Wawatair вже готова. Натисніть кнопку — застосунок завантажить її та перезапуститься сам.
- **es:** La nueva versión de Wawatair está lista. Pulsa el botón: la app la descargará y se reiniciará sola.

### update.ota_downloading_body
- **az:** Yeni versiya yüklənir. Bu bir neçə saniyə çəkəcək.
- **en:** Downloading the new version. This will take a few seconds.
- **ru:** Загружается новая версия. Это займёт несколько секунд.
- **tr:** Yeni sürüm indiriliyor. Bu birkaç saniye sürecek.
- **ua:** Завантажується нова версія. Це займе кілька секунд.
- **es:** Descargando la nueva versión. Tardará unos segundos.

### update.ota_downloading_button
- **az:** Yüklənir…
- **en:** Downloading…
- **ru:** Загрузка…
- **tr:** İndiriliyor…
- **ua:** Завантаження…
- **es:** Descargando…

### update.ota_done_title
- **az:** Yeniləndi
- **en:** Updated
- **ru:** Обновлено
- **tr:** Güncellendi
- **ua:** Оновлено
- **es:** Actualizado

### update.ota_restarting_body
- **az:** Tətbiq indi özü yenidən açılacaq.
- **en:** The app will now restart on its own.
- **ru:** Приложение сейчас перезапустится само.
- **tr:** Uygulama şimdi kendiliğinden yeniden başlayacak.
- **ua:** Застосунок зараз перезапуститься сам.
- **es:** La app se reiniciará sola ahora.

### update.ota_restarting_button
- **az:** Yenidən açılır…
- **en:** Restarting…
- **ru:** Перезапуск…
- **tr:** Yeniden başlatılıyor…
- **ua:** Перезапуск…
- **es:** Reiniciando…

### update.ota_next_launch_body
- **az:** Yeni versiya yükləndi. Tətbiqi növbəti dəfə açanda işə düşəcək.
- **en:** The new version has been downloaded. It will turn on the next time you open the app.
- **ru:** Новая версия скачана. Она включится при следующем открытии приложения.
- **tr:** Yeni sürüm indirildi. Uygulamayı bir sonraki açtığınızda etkinleşecek.
- **ua:** Нову версію завантажено. Вона ввімкнеться під час наступного відкриття застосунку.
- **es:** La nueva versión se ha descargado. Se activará la próxima vez que abras la app.

### update.ota_failed_title
- **az:** Yeniləmək alınmadı
- **en:** Couldn't update
- **ru:** Не удалось обновить
- **tr:** Güncellenemedi
- **ua:** Не вдалося оновити
- **es:** No se pudo actualizar

### update.ota_failed_body
- **az:** İnterneti yoxlayın və yenidən cəhd edin.
- **en:** Check your internet connection and try again.
- **ru:** Проверьте интернет и попробуйте ещё раз.
- **tr:** İnternet bağlantınızı kontrol edip tekrar deneyin.
- **ua:** Перевірте інтернет і спробуйте ще раз.
- **es:** Comprueba tu conexión a internet e inténtalo de nuevo.

## То же самое для импорта (JSON)

```json
[
  {"key": "update.ota_title", "group": "update", "az": "Yeniləmə mövcuddur", "en": "Update available", "ru": "Доступно обновление", "tr": "Güncelleme mevcut", "ua": "Доступне оновлення", "es": "Actualización disponible"},
  {"key": "update.ota_body", "group": "update", "az": "Wawatair-in yeni versiyası hazırdır. Düyməyə basın — tətbiq onu yükləyib özü yenidən açılacaq.", "en": "A new version of Wawatair is ready. Tap the button — the app will download it and restart on its own.", "ru": "Новая версия Wawatair уже готова. Нажмите кнопку — приложение скачает её и перезапустится само.", "tr": "Wawatair'in yeni sürümü hazır. Düğmeye dokunun — uygulama onu indirip kendiliğinden yeniden başlayacak.", "ua": "Нова версія Wawatair вже готова. Натисніть кнопку — застосунок завантажить її та перезапуститься сам.", "es": "La nueva versión de Wawatair está lista. Pulsa el botón: la app la descargará y se reiniciará sola."},
  {"key": "update.ota_downloading_body", "group": "update", "az": "Yeni versiya yüklənir. Bu bir neçə saniyə çəkəcək.", "en": "Downloading the new version. This will take a few seconds.", "ru": "Загружается новая версия. Это займёт несколько секунд.", "tr": "Yeni sürüm indiriliyor. Bu birkaç saniye sürecek.", "ua": "Завантажується нова версія. Це займе кілька секунд.", "es": "Descargando la nueva versión. Tardará unos segundos."},
  {"key": "update.ota_downloading_button", "group": "update", "az": "Yüklənir…", "en": "Downloading…", "ru": "Загрузка…", "tr": "İndiriliyor…", "ua": "Завантаження…", "es": "Descargando…"},
  {"key": "update.ota_done_title", "group": "update", "az": "Yeniləndi", "en": "Updated", "ru": "Обновлено", "tr": "Güncellendi", "ua": "Оновлено", "es": "Actualizado"},
  {"key": "update.ota_restarting_body", "group": "update", "az": "Tətbiq indi özü yenidən açılacaq.", "en": "The app will now restart on its own.", "ru": "Приложение сейчас перезапустится само.", "tr": "Uygulama şimdi kendiliğinden yeniden başlayacak.", "ua": "Застосунок зараз перезапуститься сам.", "es": "La app se reiniciará sola ahora."},
  {"key": "update.ota_restarting_button", "group": "update", "az": "Yenidən açılır…", "en": "Restarting…", "ru": "Перезапуск…", "tr": "Yeniden başlatılıyor…", "ua": "Перезапуск…", "es": "Reiniciando…"},
  {"key": "update.ota_next_launch_body", "group": "update", "az": "Yeni versiya yükləndi. Tətbiqi növbəti dəfə açanda işə düşəcək.", "en": "The new version has been downloaded. It will turn on the next time you open the app.", "ru": "Новая версия скачана. Она включится при следующем открытии приложения.", "tr": "Yeni sürüm indirildi. Uygulamayı bir sonraki açtığınızda etkinleşecek.", "ua": "Нову версію завантажено. Вона ввімкнеться під час наступного відкриття застосунку.", "es": "La nueva versión se ha descargado. Se activará la próxima vez que abras la app."},
  {"key": "update.ota_failed_title", "group": "update", "az": "Yeniləmək alınmadı", "en": "Couldn't update", "ru": "Не удалось обновить", "tr": "Güncellenemedi", "ua": "Не вдалося оновити", "es": "No se pudo actualizar"},
  {"key": "update.ota_failed_body", "group": "update", "az": "İnterneti yoxlayın və yenidən cəhd edin.", "en": "Check your internet connection and try again.", "ru": "Проверьте интернет и попробуйте ещё раз.", "tr": "İnternet bağlantınızı kontrol edip tekrar deneyin.", "ua": "Перевірте інтернет і спробуйте ще раз.", "es": "Comprueba tu conexión a internet e inténtalo de nuevo."}
]
```
