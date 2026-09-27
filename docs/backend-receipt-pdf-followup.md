# Чек PDF: что приложение уже делает и что нужно от бэкенда

Приложение больше не генерирует PDF само — кнопка «PDF yüklə» скачивает
`receipt.pdf_url` (Bearer, `responseType bytes`) и:

- Android 10+ — кладёт файл в «Загрузки» (MediaStore) и открывает его в
  PDF-просмотрщике; Android 8–9 — открывает шторку «Поделиться»;
- iOS — кладёт файл в Documents приложения и открывает системный просмотр
  (QuickLook), откуда пользователь сохраняет его в «Файлы».

Кнопка видна только при `is_paid = true` и `pdf_url != null`. Рядом отдельная
иконка «Paylaş» (шторка «Поделиться»).

## 1. Новые ключи CMS (группа `receipt`)

| ключ | az | en | ru | tr | ua | es |
| --- | --- | --- | --- | --- | --- | --- |
| `receipt.share` | Paylaş | Share | Поделиться | Paylaş | Поділитися | Compartir |
| `receipt.pdf_saved_downloads` | Qəbz «Yükləmələr» qovluğunda saxlanıldı. | Receipt saved to Downloads. | Чек сохранён в «Загрузки». | Makbuz «İndirilenler» klasörüne kaydedildi. | Чек збережено в «Завантаження». | Recibo guardado en «Descargas». |
| `receipt.pdf_saved_no_viewer` | Qəbz saxlanıldı, amma telefonda PDF açan proqram tapılmadı. | Receipt saved, but no app to open PDFs was found on this phone. | Чек сохранён, но на телефоне нет приложения для открытия PDF. | Makbuz kaydedildi ancak telefonda PDF açacak uygulama bulunamadı. | Чек збережено, але на телефоні немає застосунку для відкриття PDF. | Recibo guardado, pero no hay ninguna app para abrir PDF en este teléfono. |
| `receipt.pdf_error_network` | İnternet bağlantısı yoxdur. Bağlantını yoxlayıb yenidən cəhd edin. | No internet connection. Check it and try again. | Нет подключения к интернету. Проверьте связь и попробуйте снова. | İnternet bağlantısı yok. Bağlantını kontrol edip tekrar dene. | Немає підключення до інтернету. Перевірте зв'язок і спробуйте ще раз. | Sin conexión a internet. Compruébala e inténtalo de nuevo. |
| `receipt.pdf_error_server` | Server qəbzi göndərə bilmədi. Bir az sonra yenidən cəhd edin. | The server couldn't send the receipt. Please try again a bit later. | Сервер не смог отдать чек. Попробуйте чуть позже. | Sunucu makbuzu gönderemedi. Biraz sonra tekrar dene. | Сервер не зміг надіслати чек. Спробуйте трохи пізніше. | El servidor no pudo enviar el recibo. Inténtalo de nuevo más tarde. |
| `receipt.pdf_error_save` | Qəbzi telefonda saxlamaq alınmadı. | Couldn't save the receipt on this phone. | Не удалось сохранить чек на телефоне. | Makbuz telefona kaydedilemedi. | Не вдалося зберегти чек на телефоні. | No se pudo guardar el recibo en el teléfono. |

Старый ключ `receipt.pdf_error` («PDF yaradıla bilmədi.») больше не
используется — можно удалить.

## 2. Вопросы / проверки

1. **Верификация.** Где лежит `receipt` — в `data.receipt` или в корне ответа?
   Приложение принимает оба варианта. Главное — чтобы он был в
   **`GET /verification`**, а не только в ответе `POST /verification/pay`:
   иначе после перезапуска приложения кнопки «Qəbz» на экране «Вы
   верифицированы» не будет.
2. **Заголовок `Accept`.** Приложение на все запросы шлёт
   `Accept: application/json` (общий перехватчик). `/receipts/{kind}/{id}/pdf`
   должен отдавать PDF независимо от него. Ошибки (404/429/5xx) — JSON с
   локализованным `message`: приложение показывает этот текст пользователю.
3. **Шрифт в PDF.** Мы не смогли проверить серверный PDF вживую (нужен
   оплаченный заказ под реальным аккаунтом). Пришлите, пожалуйста, два примера
   (az и ru) или проверьте сами: «ə ş ğ ı ö ü ç İ», кириллица и символ «→»
   (в NotoSans его нет — он печатался квадратом, лучше «–»).
