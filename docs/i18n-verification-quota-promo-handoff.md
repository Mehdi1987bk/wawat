# Локализация: verification + limit + promotion (передача для CMS)

**Дата:** 2026-09-22  
**Кому:** команда бэкенда / CMS (`kodo-az`)  
**От:** мобильный клиент (Wawat, сборка 37)

Ниже — **51 новый ключ** локализации с экранов, которые мы доделали в этой
серии работ (верификация аккаунта, увеличение лимита объявлений, выбор способа
оплаты для VIP/Boost, плюс несколько мелочей). Сейчас эти строки зашиты в
клиенте как запасной AZ-текст — их нужно завести в CMS, чтобы приложение
тянуло переводы с бэкенда, как и остальные ключи.

**Как это устроено в клиенте:** `tr('ключ', 'AZ-текст')` — если CMS отдаёт
значение по ключу, показывается оно; иначе — зашитый AZ. Поэтому **AZ здесь —
источник истины** (ровно то, что видит пользователь без CMS). Языки: `az`, `en`,
`ru`, `tr`, `ua`, `es` — тот же набор, что в прошлых передачах.

- Машинная выгрузка ключей + все переводы: **`docs/i18n-verification-quota-promo-handoff.json`**
  (массив `{key, group, az, en, ru, tr, ua, es}` — импортируйте как обычно).
- `az` снят прямо из кода; `en`/`ru` вычитаны; **`tr`/`ua`/`es` — предложены**
  клиентом, стоит пробежать носителем перед публикацией.
- Ключи, уже отданные в прошлых файлах (`i18n-*`), сюда **не попали** — это только новое.
- `error.forbidden`: в коде по ошибке лежал русский запасной текст; здесь AZ исправлен на `Giriş qadağandır`.

## Hesab doğrulaması / KYC — экран верификации (профиль → «Doğrulama»)
*группа `verification` — 25 кл.*

| Ключ | AZ (источник) | RU | EN |
|---|---|---|---|
| `verification.awaiting_payment` | Sənədlər təsdiqləndi. Nişanı aktivləşdirmək üçün ödə. | Документы одобрены. Оплатите, чтобы активировать значок. | Documents approved. Pay to activate the badge. |
| `verification.intro.cta` | Sənədləri göndər | Отправить документы | Submit documents |
| `verification.intro.headline` | Hesabını doğrula | Подтвердите аккаунт | Verify your account |
| `verification.intro.paid_hint` | Nişan yalnız ödənişdən sonra aktivləşir. | Значок активируется только после оплаты. | The badge activates only after payment. |
| `verification.intro.paid_label` | Ödənişli xidmət | Платная услуга | Paid service |
| `verification.intro.step1_hint` | Pasport və selfi yüklə, yoxlamaya göndər. | Загрузите паспорт и селфи, отправьте на проверку. | Upload your passport and a selfie, then submit for review. |
| `verification.intro.step1_title` | Sənədləri göndər | Отправить документы | Submit documents |
| `verification.intro.step2_hint` | Sənədlər təsdiqləndikdən sonra ödə — nişan aktiv olur. | После одобрения документов оплатите — значок станет активным. | After the documents are approved, pay — and the badge goes active. |
| `verification.intro.step2_title` | Ödə və aktivləşdir | Оплатить и активировать | Pay and activate |
| `verification.intro.subtitle` | Profilinə etibar nişanı əlavə et. Sənədlərini təsdiqlət və aktivləşdir. | Добавьте в профиль значок доверия. Подтвердите документы и активируйте его. | Add a trust badge to your profile. Get your documents approved and activate it. |
| `verification.intro.title` | Hesab doğrulaması | Верификация аккаунта | Account verification |
| `verification.pay_failed` | Ödəniş alınmadı. Yenidən cəhd et. | Оплата не прошла. Повторите попытку. | Payment failed. Please try again. |
| `verification.payment.activates_note` | Ödəniş doğrulama nişanını dərhal aktivləşdirir. | Оплата сразу активирует значок верификации. | Payment activates the verification badge immediately. |
| `verification.payment.amount_label` | Ödəniləcək məbləğ | Сумма к оплате | Amount to pay |
| `verification.payment.approved_title` | Sənədlər təsdiqləndi | Документы одобрены | Documents approved |
| `verification.payment.cta` | Ödə | Оплатить | Pay |
| `verification.payment.mock_note` | Ödəniş provayderi tezliklə qoşulacaq — hazırda sınaq (mock) rejimidir. | Платёжный провайдер скоро подключится — сейчас это тестовый (mock) режим. | A payment provider is coming soon — this is currently test (mock) mode. |
| `verification.payment.title` | Ödəniş | Оплата | Payment |
| `verification.rejected.cta` | Yenidən göndər | Отправить повторно | Resubmit |
| `verification.rejected.free_note` | Yenidən göndərmək pulsuzdur. | Повторная отправка бесплатна. | Resubmitting is free. |
| `verification.rejected.headline` | Doğrulama rədd edildi | Верификация отклонена | Verification rejected |
| `verification.rejected.no_reason` | Səbəb göstərilməyib. | Причина не указана. | No reason provided. |
| `verification.rejected.reason_label` | Səbəb | Причина | Reason |
| `verification.rejected.subtitle` | Sənədlər təsdiqlənmədi. Səbəbə bax və yenidən göndər. | Документы не одобрены. Посмотрите причину и отправьте повторно. | The documents weren't approved. Check the reason and resubmit. |
| `verification.rejected.title` | Doğrulama | Верификация | Verification |

## Увеличение лимита объявлений («Limiti artır»)
*группа `listing_quota` — 12 кл.*

| Ключ | AZ (источник) | RU | EN |
|---|---|---|---|
| `listing_quota.awaiting_store` | Mağaza ödənişi gözlənilir… | Ожидание оплаты в магазине… | Waiting for store payment… |
| `listing_quota.creating_order` | Sifariş hazırlanır… | Подготовка заказа… | Preparing order… |
| `listing_quota.iap.pending` | Əvvəlki ödəniş hələ tamamlanır. Bir azdan yenidən cəhd et. | Предыдущий платёж ещё завершается. Повторите попытку чуть позже. | A previous payment is still completing. Please try again shortly. |
| `listing_quota.pay.card` | Bank kartı | Банковская карта | Bank card |
| `listing_quota.pay.card_sub` | AZN ilə ödəniş | Оплата в AZN | Payment in AZN |
| `listing_quota.pay.card_title` | Kart ilə ödəniş | Оплата картой | Card payment |
| `listing_quota.pay.method_title` | Ödəniş üsulu | Способ оплаты | Payment method |
| `listing_quota.pay.store_apple` | App Store | App Store | App Store |
| `listing_quota.pay.store_google` | Google Play | Google Play | Google Play |
| `listing_quota.pay.store_sub` | Mağaza vasitəsilə | Через магазин | Via the store |
| `listing_quota.pay.store_unavailable` | Ödəniş üsulu hazırda əlçatan deyil. Bir azdan yenidən cəhd et. | Этот способ оплаты сейчас недоступен. Повторите попытку чуть позже. | This payment method isn't available right now. Please try again shortly. |
| `listing_quota.payment_canceled` | Ödəniş ləğv edildi. Yenidən cəhd edə bilərsən. | Платёж отменён. Можно попробовать снова. | Payment canceled. You can try again. |

## Тарификация VIP/Boost — выбор способа оплаты
*группа `promotion` — 7 кл.*

| Ключ | AZ (источник) | RU | EN |
|---|---|---|---|
| `promotion.pay.card` | Bank kartı | Банковская карта | Bank card |
| `promotion.pay.card_sub` | AZN ilə ödəniş | Оплата в AZN | Payment in AZN |
| `promotion.pay.method_title` | Ödəniş üsulu | Способ оплаты | Payment method |
| `promotion.pay.store_apple` | App Store | App Store | App Store |
| `promotion.pay.store_google` | Google Play | Google Play | Google Play |
| `promotion.pay.store_sub` | Mağaza vasitəsilə | Через магазин | Via the store |
| `promotion.store_unavailable` | Mağaza ödənişi müvəqqəti olaraq əlçatan deyil. | Оплата через магазин временно недоступна. | Store payment is temporarily unavailable. |

## Оценка приложения / промокод за отзыв
*группа `app_review` — 2 кл.*

| Ключ | AZ (источник) | RU | EN |
|---|---|---|---|
| `app_review.subtitle` | 1 dəqiqəni ayır, Store-da bizi qiymətləndir — və hədiyyə promokod qazan. | Уделите минуту, оцените нас в Store — и получите промокод в подарок. | Take a minute, rate us on the Store — and get a gift promo code. |
| `app_review.thanks_title` | Təşəkkür edirik! ⭐️ | Спасибо! ⭐️ | Thank you! ⭐️ |

## Чат — удалённое сообщение
*группа `chat` — 2 кл.*

| Ключ | AZ (источник) | RU | EN |
|---|---|---|---|
| `chat.message.deleted` | Mesaj silindi | Сообщение удалено | Message deleted |
| `chat.message.deleted_by_you` | Bu mesajı sildiniz | Вы удалили это сообщение | You deleted this message |

## Жалобы — статус результата
*группа `reports` — 1 кл.*

| Ключ | AZ (источник) | RU | EN |
|---|---|---|---|
| `reports.result_pending` | Gözlənilir | Ожидается | Pending |

## Общие
*группа `common` — 1 кл.*

| Ключ | AZ (источник) | RU | EN |
|---|---|---|---|
| `common.clear` | Təmizlə | Очистить | Clear |

## Тексты ошибок
*группа `error` — 1 кл.*

| Ключ | AZ (источник) | RU | EN |
|---|---|---|---|
| `error.forbidden` | Giriş qadağandır | Доступ запрещён | Access denied |

---

Всего: **51 ключей**. Полная таблица со всеми шестью языками — в JSON рядом.
