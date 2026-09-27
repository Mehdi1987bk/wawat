# Локализация: ключи для CMS (верификация, лимит объявлений, продвижение)

> **Что нужно сделать:** добавить перечисленные ниже ключи в CMS локализации
> (тот же словарь, что отдаётся приложению через `GET` контента). Приложение
> **уже** запрашивает эти ключи — сейчас, пока ключа нет в CMS, показывается
> запасной азербайджанский текст (колонка **az**, зашит в коде). Как только ключ
> появится в CMS — текст начнёт «приходить с бэкенда», без правок в приложении.
>
> Правила:
> - **az — эталон.** Это ровно то, что пользователь видит сейчас. Ключ + az
>   должны совпасть с таблицей, иначе экран визуально не изменится.
> - **ru / en** — перевод для остальных языков CMS (можно поправить редактурой).
> - `{...}` (например `{days}`, `{amount}`, `{count}`) — **плейсхолдеры, не
>   переводить и не удалять**, приложение подставляет в них значения.
> - Ключи, которые уже есть в CMS, можно пропустить — список полный по экранам,
>   часть общих (`common.*`, `enum.*`, `receipt.*`) могла быть добавлена раньше.

Всего ключей: **191**. Экраны: подтверждение аккаунта (verification), увеличение
лимита объявлений (listing_quota), продвижение/VİP/буст (promotion) и общие.

---

## 1. Verification — подтверждение аккаунта (36)

| key | az (эталон) | ru | en |
| --- | --- | --- | --- |
| verification.intro.title | Hesab doğrulaması | Подтверждение аккаунта | Account verification |
| verification.intro.headline | Hesabını doğrula | Подтвердите аккаунт | Verify your account |
| verification.intro.subtitle | Profilinə etibar nişanı əlavə et. Sənədlərini təsdiqlət və aktivləşdir. | Добавьте в профиль значок доверия. Подтвердите документы и активируйте. | Add a trust badge to your profile. Verify your documents and activate it. |
| verification.intro.cta | Sənədləri göndər | Отправить документы | Submit documents |
| verification.intro.paid_label | Ödənişli xidmət | Платная услуга | Paid service |
| verification.intro.paid_hint | Nişan yalnız ödənişdən sonra aktivləşir. | Значок активируется только после оплаты. | The badge activates only after payment. |
| verification.intro.step1_title | Sənədləri göndər | Отправьте документы | Submit documents |
| verification.intro.step1_hint | Pasport və selfi yüklə, yoxlamaya göndər. | Загрузите паспорт и селфи, отправьте на проверку. | Upload your passport and a selfie, send for review. |
| verification.intro.step2_title | Ödə və aktivləşdir | Оплатите и активируйте | Pay and activate |
| verification.intro.step2_hint | Sənədlər təsdiqləndikdən sonra ödə — nişan aktiv olur. | После одобрения документов оплатите — значок активируется. | After the documents are approved, pay — the badge activates. |
| verification.payment.title | Ödəniş | Оплата | Payment |
| verification.payment.approved_title | Sənədlər təsdiqləndi | Документы одобрены | Documents approved |
| verification.payment.amount_label | Ödəniləcək məbləğ | Сумма к оплате | Amount due |
| verification.payment.cta | Ödə | Оплатить | Pay |
| verification.payment.activates_note | Ödəniş doğrulama nişanını dərhal aktivləşdirir. | Оплата сразу активирует значок подтверждения. | Payment activates the verification badge immediately. |
| verification.payment.mock_note | Ödəniş provayderi tezliklə qoşulacaq — hazırda sınaq (mock) rejimidir. | Платёжный провайдер скоро подключится — сейчас тестовый (mock) режим. | The payment provider will be connected soon — this is currently a test (mock) mode. |
| verification.awaiting_payment | Sənədlər təsdiqləndi. Nişanı aktivləşdirmək üçün ödə. | Документы одобрены. Оплатите, чтобы активировать значок. | Documents approved. Pay to activate the badge. |
| verification.pay.method_title | Ödəniş üsulu | Способ оплаты | Payment method |
| verification.pay.store_apple | App Store | App Store | App Store |
| verification.pay.store_google | Google Play | Google Play | Google Play |
| verification.pay.store_sub | Mağaza vasitəsilə | Через магазин | Via the store |
| verification.pay.store_soon | Tezliklə əlçatan olacaq | Скоро будет доступно | Available soon |
| verification.pay.card | Bank kartı | Банковская карта | Bank card |
| verification.pay.card_sub | AZN ilə ödəniş | Оплата в AZN | Payment in AZN |
| verification.pay.card_title | Kart ilə ödəniş | Оплата картой | Card payment |
| verification.pay_failed | Ödəniş alınmadı. Yenidən cəhd et. | Оплата не прошла. Попробуйте ещё раз. | Payment failed. Please try again. |
| verification.rejected.title | Doğrulama | Проверка | Verification |
| verification.rejected.headline | Doğrulama rədd edildi | Проверка отклонена | Verification rejected |
| verification.rejected.subtitle | Sənədlər təsdiqlənmədi. Səbəbə bax və yenidən göndər. | Документы не одобрены. Посмотрите причину и отправьте снова. | Documents were not approved. Check the reason and resubmit. |
| verification.rejected.reason_label | Səbəb | Причина | Reason |
| verification.rejected.no_reason | Səbəb göstərilməyib. | Причина не указана. | No reason provided. |
| verification.rejected.free_note | Yenidən göndərmək pulsuzdur. | Повторная отправка бесплатна. | Resubmitting is free. |
| verification.rejected.cta | Yenidən göndər | Отправить снова | Resubmit |
| verification.doc_types_load_failed | Sənəd növləri yüklənə bilmədi. Yenidən cəhd et. | Не удалось загрузить типы документов. Попробуйте ещё раз. | Failed to load document types. Please try again. |
| verification.doc_types_load_failed_retry | Sənəd növləri yüklənmədi. Yenidən cəhd et. | Типы документов не загрузились. Попробуйте ещё раз. | Document types did not load. Please try again. |
| verification.submit_failed | Göndərmək alınmadı. Yenidən cəhd et. | Не удалось отправить. Попробуйте ещё раз. | Submission failed. Please try again. |

---

## 2. Listing quota — увеличение лимита объявлений (43)

| key | az (эталон) | ru | en |
| --- | --- | --- | --- |
| listing_quota.title | Limiti artır | Увеличить лимит | Increase limit |
| listing_quota.plans_header | Limiti artır | Увеличить лимит | Increase limit |
| listing_quota.limit_full_subtitle | Limiti artır və dərhal yenisini yarat. | Увеличьте лимит и сразу создайте новое. | Increase the limit and create a new one right away. |
| listing_quota.pause_instead | və ya bir elanı dayandır | или приостановите одно объявление | or pause one listing |
| listing_quota.permanent_increase | Daimi limit artımı | Постоянное увеличение лимита | Permanent limit increase |
| listing_quota.one_time | bir dəfəlik · daimi limit | разово · постоянный лимит | one-time · permanent limit |
| listing_quota.new_limit | Yeni limit | Новый лимит | New limit |
| listing_quota.per_listing_prefix | elan başına | за объявление | per listing |
| listing_quota.badge.best_value | Ən sərfəli | Выгоднее всего | Best value |
| listing_quota.secure_note | Ödəniş təhlükəsiz provayder səhifəsində aparılır | Оплата проходит на защищённой странице провайдера | Payment is processed on the provider's secure page |
| listing_quota.pay_cta | ödə və limiti artır | оплатить и увеличить лимит | pay and increase the limit |
| listing_quota.pay_cta_empty | Plan seç | Выберите план | Choose a plan |
| listing_quota.load_error | Planlar yüklənmədi. Yenidən cəhd et. | Планы не загрузились. Попробуйте ещё раз. | Plans did not load. Please try again. |
| listing_quota.retry | Yenidən cəhd et | Попробовать снова | Try again |
| listing_quota.confirm_title | Ödənişi təsdiqlə | Подтвердите оплату | Confirm payment |
| listing_quota.total | Ümumi | Итого | Total |
| listing_quota.create_listing | Elan yarat | Создать объявление | Create a listing |
| listing_quota.pay.method_title | Ödəniş üsulu | Способ оплаты | Payment method |
| listing_quota.pay.store_apple | App Store | App Store | App Store |
| listing_quota.pay.store_google | Google Play | Google Play | Google Play |
| listing_quota.pay.store_sub | Mağaza vasitəsilə | Через магазин | Via the store |
| listing_quota.pay.card | Bank kartı | Банковская карта | Bank card |
| listing_quota.pay.card_sub | AZN ilə ödəniş | Оплата в AZN | Payment in AZN |
| listing_quota.pay.card_title | Kart ilə ödəniş | Оплата картой | Card payment |
| listing_quota.pay.store_unavailable | Ödəniş üsulu hazırda əlçatan deyil. Bir azdan yenidən cəhd et. | Способ оплаты сейчас недоступен. Попробуйте чуть позже. | This payment method is currently unavailable. Please try again shortly. |
| listing_quota.iap.pending | Əvvəlki ödəniş hələ tamamlanır. Bir azdan yenidən cəhd et. | Предыдущая оплата ещё завершается. Попробуйте чуть позже. | The previous payment is still completing. Please try again shortly. |
| listing_quota.awaiting_store | Mağaza ödənişi gözlənilir… | Ожидается оплата в магазине… | Waiting for the store payment… |
| listing_quota.creating_order | Sifariş hazırlanır… | Готовим заказ… | Preparing the order… |
| listing_quota.payment_pending | Ödəniş gözlənilir… | Ожидается оплата… | Payment pending… |
| listing_quota.payment_pending_sub | Ödəniş səhifəsində əməliyyatı tamamla. Bitən kimi nəticəni avtomatik göstərəcəyik. | Завершите операцию на странице оплаты. Как только она закончится, мы покажем результат автоматически. | Complete the operation on the payment page. We'll show the result automatically once it's done. |
| listing_quota.payment_failed | Ödəniş keçmədi | Оплата не прошла | Payment failed |
| listing_quota.payment_failed_sub | Məbləğ tutulmadı və limit dəyişmədi. Yenidən cəhd et. | Сумма не списана, лимит не изменился. Попробуйте ещё раз. | No amount was charged and the limit didn't change. Please try again. |
| listing_quota.payment_canceled | Ödəniş ləğv edildi. Yenidən cəhd edə bilərsən. | Оплата отменена. Можно попробовать снова. | Payment canceled. You can try again. |
| listing_quota.refresh_status | Statusu yenilə | Обновить статус | Refresh status |
| listing_quota.cancel_payment | Ödənişi ləğv et | Отменить оплату | Cancel payment |
| listing_quota.success_title | Limitin artdı! | Лимит увеличен! | Limit increased! |
| listing_quota.success_sub_prefix | İndi daha | Теперь ещё | Now you can |
| listing_quota.success_sub_suffix | aktiv elan yarada bilərsən. | активных объявлений можно создать. | create more active listings. |
| listing_quota.view_receipt | Qəbzə bax | Посмотреть чек | View receipt |
| listing_quota.receipt.package | Paket | Пакет | Package |
| listing_quota.receipt.type | Növ | Тип | Type |
| listing_quota.type_trip | səfər | поездка | trip |
| listing_quota.type_shipment | göndəriş | отправление | shipment |

---

## 3. Promotion — продвижение / VİP / буст (96)

| key | az (эталон) | ru | en |
| --- | --- | --- | --- |
| promotion.created_title | Elanın yoxlamaya göndərildi | Объявление отправлено на проверку | Your listing was sent for review |
| promotion.created_subtitle | Adətən 1–2 saat ərzində təsdiqlənir. Təsdiqdən sonra lentdə görünəcək. | Обычно одобряется за 1–2 часа. После одобрения появится в ленте. | Usually approved within 1–2 hours. It will appear in the feed after approval. |
| promotion.upsell_title | Elanını daha çox insana çatdır | Покажите объявление большему числу людей | Reach more people with your listing |
| promotion.pricing_unavailable | Promosyon paketlərini yükləmək alınmadı. | Не удалось загрузить пакеты продвижения. | Failed to load promotion packages. |
| promotion.skip | İndi yox, elanlarıma keç | Не сейчас, к моим объявлениям | Not now, go to my listings |
| promotion.cta.vip | VİP et | Сделать VİP | Make it VİP |
| promotion.cta.boost | Önə çək | Продвинуть | Boost |
| promotion.cta.checkout | Ödənişə keç | Перейти к оплате | Proceed to payment |
| promotion.cta.extend | Uzat | Продлить | Extend |
| promotion.vip_short | Ən yuxarıda, ayrıca bölmədə | В самом верху, в отдельном разделе | At the top, in a separate section |
| promotion.boost_short | Zəmanətli göstərişlər | Гарантированные показы | Guaranteed impressions |
| promotion.vip_description | Elanın lentin ən yuxarısında, ayrıca «VİP elanlar» bölməsində görünəcək. | Ваше объявление будет вверху ленты, в отдельном разделе «VİP объявления». | Your listing will show at the top of the feed, in a separate "VİP listings" section. |
| promotion.boost_description | Elanın seçdiyin mövqe zolağında görünəcək. | Ваше объявление будет показано в выбранной позиции. | Your listing will appear in the position band you choose. |
| promotion.vip_benefits_title | VİP nə qazandırır? | Что даёт VİP? | What does VİP give you? |
| promotion.vip_benefit.section | Ayrıca «VİP elanlar» bölməsində üst sıra | Верхняя строка в отдельном разделе «VİP объявления» | Top row in a separate "VİP listings" section |
| promotion.vip_benefit.badge | Tac nişanı və qızılı çərçivə | Значок короны и золотая рамка | Crown badge and a golden frame |
| promotion.vip_benefit.views | Orta hesabla daha çox baxış | В среднем больше просмотров | More views on average |
| promotion.step.duration | Müddət seç | Выберите срок | Choose duration |
| promotion.step.extend_duration | Müddəti artır | Увеличьте срок | Extend the duration |
| promotion.boost.packages_description | Elanına zəmanətli göstəriş sayı al. Hədəf yığılana qədər önə çəkilir — gün limiti yoxdur. | Получите для объявления гарантированное число показов. Продвигается, пока не наберётся цель — без ограничения по дням. | Get a guaranteed number of impressions for your listing. It stays boosted until the target is reached — no day limit. |
| promotion.boost.choose_package | Paket seç | Выберите пакет | Choose a package |
| promotion.boost.guaranteed_label | Zəmanətli göstərişlər | Гарантированные показы | Guaranteed impressions |
| promotion.boost.guaranteed_hint | Elanın hədəf göstəriş sayına çatana qədər önə çəkilir. | Продвигается, пока не достигнет целевого числа показов. | Stays boosted until it reaches the target impression count. |
| promotion.boost.recommended | Tövsiyə | Рекомендуем | Recommended |
| promotion.boost.no_refund_note | Ödəniş geri qaytarılmır. Zəmanət yerinə yetməzsə, dəstək vasitəsilə həll olunur. | Оплата не возвращается. Если гарантия не выполнена — решается через поддержку. | The payment is non-refundable. If the guarantee isn't met, it's resolved via support. |
| promotion.boost.progress_label | Göstərilib | Показано | Shown |
| promotion.preview_title | Lentdə belə görünəcək | Так это будет выглядеть в ленте | This is how it will look in the feed |
| promotion.preview_full_title | Elanın lentdə görünüşü | Вид объявления в ленте | Your listing in the feed |
| promotion.checkout_title | Sifariş yekunu | Итог заказа | Order summary |
| promotion.checkout.vip_title | VİP promosyon | VİP-продвижение | VİP promotion |
| promotion.checkout.boost_title_template | Önə çək · {tier} | Продвижение · {tier} | Boost · {tier} |
| promotion.checkout.duration | Müddət | Срок | Duration |
| promotion.checkout.package | Paket | Пакет | Package |
| promotion.checkout.start | Başlama | Начало | Start |
| promotion.checkout.end | Bitmə | Окончание | End |
| promotion.checkout.starts_after_approval | Təsdiqdən dərhal sonra | Сразу после одобрения | Right after approval |
| promotion.promo_code | Promokod (varsa) | Промокод (если есть) | Promo code (if any) |
| promotion.apply | Tətbiq et | Применить | Apply |
| promotion.choose_from_wallet | Promokodlarımdan seç | Выбрать из моих промокодов | Choose from my promo codes |
| promotion.promo_applied | Promokod tətbiq olundu · −{amount} AZN | Промокод применён · −{amount} AZN | Promo code applied · −{amount} AZN |
| promotion.total | Yekun | Итого | Total |
| promotion.starting_from | başlanğıc | от | from |
| promotion.pay.method_title | Ödəniş üsulu | Способ оплаты | Payment method |
| promotion.pay.store_apple | App Store | App Store | App Store |
| promotion.pay.store_google | Google Play | Google Play | Google Play |
| promotion.pay.store_sub | Mağaza vasitəsilə | Через магазин | Via the store |
| promotion.pay.card | Bank kartı | Банковская карта | Bank card |
| promotion.pay.card_sub | AZN ilə ödəniş | Оплата в AZN | Payment in AZN |
| promotion.pay.card_title | Kart ilə ödəniş | Оплата картой | Card payment |
| promotion.pay.verifying | Ödəniş yoxlanılır… | Проверяем оплату… | Verifying payment… |
| promotion.store_unavailable | Mağaza ödənişi müvəqqəti olaraq əlçatan deyil. | Оплата через магазин временно недоступна. | Store payment is temporarily unavailable. |
| promotion.iap.not_ready | Mağaza ödənişi müvəqqəti olaraq əlçatan deyil. | Оплата через магазин временно недоступна. | Store payment is temporarily unavailable. |
| promotion.iap.previous_pending | Əvvəlki ödəniş hələ tamamlanmayıb. Bir az sonra yenidən cəhd et. | Предыдущая оплата ещё не завершена. Попробуйте немного позже. | The previous payment isn't finished yet. Please try again a bit later. |
| promotion.iap.purchase_failed | Ödəniş alınmadı. Yenidən cəhd et. | Оплата не прошла. Попробуйте ещё раз. | Payment failed. Please try again. |
| promotion.iap.server_validation_failed | Mağaza əməliyyatı serverdə təsdiqlənmədi. Yenidən cəhd et. | Операция магазина не подтверждена на сервере. Попробуйте ещё раз. | The store transaction wasn't confirmed on the server. Please try again. |
| promotion.activated | Təbriklər! | Поздравляем! | Congratulations! |
| promotion.payment_failed | Ödəniş alınmadı | Оплата не прошла | Payment failed |
| promotion.refunded_title | Məbləğ balansa qaytarıldı | Сумма возвращена на баланс | Amount refunded to balance |
| promotion.refunded_to_balance | Məbləğ Wawatair balansına qaytarıldı. | Сумма возвращена на баланс Wawatair. | The amount was refunded to your Wawatair balance. |
| promotion.payment_pending | Təsdiq gözlənilir | Ожидается подтверждение | Awaiting confirmation |
| promotion.pending_activation_title | Ödəniş alındı | Оплата получена | Payment received |
| promotion.pending_activation_note | Elan təsdiqlənən kimi promosyon avtomatik aktivləşəcək. | Как только объявление одобрят, продвижение активируется автоматически. | The promotion will activate automatically once the listing is approved. |
| promotion.status.active_vip | Elanın indi VİP-dir və lentin ən yuxarısında görünəcək. | Ваше объявление теперь VİP и будет вверху ленты. | Your listing is now VİP and will appear at the top of the feed. |
| promotion.status.active_boost | Elanın indi önə çəkilir və zəmanətli göstərişlər toplayır. | Ваше объявление сейчас продвигается и набирает гарантированные показы. | Your listing is now boosted and collecting guaranteed impressions. |
| promotion.status.amount | Məbləğ | Сумма | Amount |
| promotion.status.impressions | Hədəf göstərişlər | Целевые показы | Target impressions |
| promotion.status.package | Paket | Пакет | Package |
| promotion.status.end | Bitmə | Окончание | End |
| promotion.status.status | Status | Статус | Status |
| promotion.status.done | Bitdi | Готово | Done |
| promotion.status.failed | Kartından məbləğ tutulmadı. Yenidən cəhd edə bilərsən. | С карты ничего не списано. Можно попробовать снова. | No amount was charged to your card. You can try again. |
| promotion.status.pending | Bankın və ya ödəniş provayderinin təsdiqini gözləyirik. Nəticə hazır olanda bildiriş alacaqsan. | Ждём подтверждения банка или платёжного провайдера. Когда результат будет готов, вы получите уведомление. | We're waiting for confirmation from the bank or payment provider. You'll get a notification when the result is ready. |
| promotion.status.check_later | Sonra profildən yoxla | Проверьте позже в профиле | Check later in your profile |
| promotion.status.refresh | Statusu yenilə | Обновить статус | Refresh status |
| promotion.status.refreshing | Yenilənir... | Обновляется... | Refreshing... |
| promotion.status.view_listing | Elanıma bax | Посмотреть моё объявление | View my listing |
| promotion.my_title | Promosyonlarım | Мои продвижения | My promotions |
| promotion.tabs.active_template | Aktiv ({count}) | Активные ({count}) | Active ({count}) |
| promotion.tabs.expired_template | Bitmiş ({count}) | Завершённые ({count}) | Expired ({count}) |
| promotion.empty | Bu bölmədə promosyon yoxdur. | В этом разделе нет продвижений. | No promotions in this section. |
| promotion.listing_template | Elan #{id} | Объявление #{id} | Listing #{id} |
| promotion.active_template | {type} artıq aktivdir | {type} уже активно | {type} is already active |
| promotion.action.renew | Yenilə | Обновить | Renew |
| promotion.action.extend | Uzat | Продлить | Extend |
| promotion.duration_template | {days} gün | {days} дн. | {days} days |
| promotion.summary.vip_template | {days} gün VİP | VİP на {days} дн. | VİP for {days} days |
| promotion.summary.boost_template | {tier} · {days} gün | {tier} · {days} дн. | {tier} · {days} days |
| promotion.remaining.days_template | {days} gün {hours} saat qalıb | Осталось {days} дн. {hours} ч. | {days}d {hours}h left |
| promotion.remaining.hours_template | {hours} saat qalıb | Осталось {hours} ч. | {hours}h left |
| promotion.remaining.expired | Müddəti bitib | Срок истёк | Expired |
| promotion.tier.top10 | İlk 10 | Топ-10 | Top 10 |
| promotion.tier.top50 | İlk 50 | Топ-50 | Top 50 |
| promotion.tier.top100 | İlk 100 | Топ-100 | Top 100 |
| promotion.wallet_title | Promokodlarım | Мои промокоды | My promo codes |
| promotion.wallet_empty | Aktiv promokodun yoxdur. | Активных промокодов нет. | You have no active promo codes. |
| promotion.wallet_days_left | {days} gün qalıb | Осталось {days} дн. | {days} days left |

---

## 4. Общие ключи (promo-причины, enum, общее) (16)

| key | az (эталон) | ru | en |
| --- | --- | --- | --- |
| common.cancel | İmtina et | Отмена | Cancel |
| common.close | Bağla | Закрыть | Close |
| common.retry | Yenidən | Повторить | Retry |
| common.error | Xəta baş verdi. Yenidən cəhd edin. | Произошла ошибка. Попробуйте ещё раз. | Something went wrong. Please try again. |
| receipt.view | Qəbz | Чек | Receipt |
| enum.listing_type.trip | Səfər | Поездка | Trip |
| enum.listing_type.shipment_post | Göndəriş | Отправление | Shipment |
| enum.promotion_type.vip | VİP | VİP | VİP |
| enum.promotion_type.featured | Önə çıxarılan | Продвигаемое | Featured |
| promo.reason.no_promo_code | Promokod daxil edin. | Введите промокод. | Enter a promo code. |
| promo.reason.invalid | Promokod yanlışdır, artıq istifadə olunub və ya vaxtı keçib. | Промокод неверный, уже использован или просрочен. | The promo code is invalid, already used, or expired. |
| promo.reason.below_min_order | Sifariş məbləği bu promokod üçün minimuma çatmır. | Сумма заказа не достигает минимума для этого промокода. | The order amount is below the minimum for this promo code. |
| promo.reason.currency_mismatch | Promokod başqa valyutadadır. | Промокод в другой валюте. | The promo code is in a different currency. |
| promo.reason.feature_disabled | Promokodlar müvəqqəti olaraq deaktivdir. | Промокоды временно отключены. | Promo codes are temporarily disabled. |
| promo.reason.listing_not_active | Elan aktiv olmadığı üçün promokod tətbiq olunmur. | Промокод не применяется: объявление неактивно. | The promo code doesn't apply because the listing isn't active. |
| promo.reason.generic | Promokod tətbiq olunmadı. | Промокод не применён. | The promo code wasn't applied. |

---

> После добавления ключей в CMS ничего пересобирать в приложении **не нужно** —
> приложение начнёт брать тексты из CMS при следующем обновлении контента.
