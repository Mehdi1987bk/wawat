# i18n — hardcoded literals to migrate to a localized key (CODE changes)

521 bare AZ literals in 37 files. Each needs the literal wrapped in `_contentText(content,'key','AZ')` / `t('key')` / `S.of(context).x`, and the key added to CMS/ARB.

## lib/screens/home/tabs/listings/details/listing_details_screen.dart  (103)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 525 | Əməliyyat alınmadı. | `common.operation_failed` | Не удалось выполнить действие. | Action failed. |
| 539 | Elanı dayandır? | `listing.pause_confirm_title` | Приостановить объявление? | Pause listing? |
| 541 | Bu elan lentdən çıxacaq və istifadəçilər onu görməyəcək. Davam edək? | `listing.pause_confirm_message` | Объявление скроется из ленты и станет недоступно пользователям. Продолжить? | This listing will leave the feed and users won’t see it. Continue? |
| 543 | Dayandır | `common.pause` | Приостановить | Pause |
| 559 | Elanı aktivləşdir? | `listing.resume_confirm_title` | Активировать объявление? | Activate listing? |
| 561 | Elan yenidən lentdə görünəcək. Davam edək? | `listing.resume_confirm_message` | Объявление снова появится в ленте. Продолжить? | The listing will show in the feed again. Continue? |
| 562 | Aktiv et | `my_listings.resume` | Активировать | Activate |
| 625 | Profil məlumatı tapılmadı. | `profile.not_found` | Профиль не найден. | Profile not found. |
| 656 | Elanı sil? | `listing.delete_confirm_title` | Удалить объявление? | Delete listing? |
| 657 | Bu əməliyyat geri qaytarılmır. Davam etmək istəyirsən? | `listing.delete_confirm_message` | Это действие необратимо. Продолжить? | This can’t be undone. Continue? |
| 658 | Sil | `common.delete` | Удалить | Delete |
| 669 | Elanı sil | `listing.delete_sheet_title` | Удалить объявление | Delete listing |
| 670 | Silmə səbəbini seç. | `listing.delete_sheet_subtitle` | Выберите причину удаления. | Choose a reason for deleting. |
| 671 | Sil | `common.delete` | Удалить | Delete |
| 704 | Şikayət et | `listing.report_sheet_title` | Пожаловаться | Report |
| 705 | Səbəbi seç və ya qısa qeyd yaz. | `listing.report_sheet_subtitle` | Выберите причину или напишите короткую заметку. | Pick a reason or add a short note. |
| 706 | Göndər | `common.send` | Отправить | Send |
| 718 | Şikayət göndərildi. | `listing.report_sent` | Жалоба отправлена. | Report sent. |
| 874 | Ləğv et | `common.cancel` | Отмена | Cancel |
| 965 | Elanım | `listing.my_listing_title` | Моё объявление | My listing |
| 1537 | {count} çatdırılma | `listing.completed_deliveries` | {count} доставок | {count} deliveries |
| 1572 | Adətən ~{minutes} dəqiqəyə cavab verir | `listing.avg_response` | Обычно отвечает за ~{minutes} мин | Usually replies in ~{minutes} min |
| 1622 | Aktiv sövdələşmə olduğu üçün redaktə məhduddur. Silmək istəsəniz, əvvəl açıq sövdələşmələri həll edin. | `listing.edit_limited_active_deal` | Редактирование ограничено из-за активной сделки. Чтобы удалить, сначала завершите открытые сделки. | Editing is limited while there’s an active deal. To delete, resolve open deals first. |
| 1665 | Baxış | `listing.stat_views` | Просмотры | Views |
| 1673 | Seçilmiş | `listing.stat_favorited` | В избранном | Favorited |
| 1682 | Boş | `listing.stat_free` | Свободно | Free |
| 1682 | Çəki | `listing.stat_weight` | Вес | Weight |
| 1766 | Rezerv olunub | `listing.reserved` | Забронировано | Reserved |
| 1798 | {count} kq boş yer qalıb | `listing.free_space_left` | Осталось {count} кг свободного места | {count} kg of space left |
| 1830 | Detallar | `listing.details_label` | Детали | Details |
| 1852 | Qiymət | `listing.price_label` | Цена | Price |
| 1854 | Razılaşma | `listing.negotiable_short` | Договорная | Negotiable |
| 1859 | Reys | `listing.flight_label` | Рейс | Flight |
| 1865 | Bağlamalar | `listing.packages_label` | Посылки | Packages |
| 2009 | Boş yer | `listing.fact_free_space` | Свободно | Free space |
| 2015 | Qiymət | `listing.price_label` | Цена | Price |
| 2017 | Razılaşma | `listing.negotiable_short` | Договорная | Negotiable |
| 2023 | Reys | `listing.flight_label` | Рейс | Flight |
| 2030 | Dərc olunub | `listing.fact_published` | Опубликовано | Published |
| 2037 | Çəki | `listing.stat_weight` | Вес | Weight |
| 2042 | Təhvil | `listing.fact_delivery` | Доставка | Delivery |
| 2048 | Dərc olunub | `listing.fact_published` | Опубликовано | Published |
| 2164 | Qəbul olunan bağlamalar | `listing.accepted_packages` | Принимаемые посылки | Accepted packages |
| 2164 | Bağlama növü | `listing.package_type` | Тип посылки | Package type |
| 2209 | Təsvir | `listing.description_label` | Описание | Description |
| 2261 | Oxşar elanlar | `listing.similar` | Похожие объявления | Similar listings |
| 2276 | Hamısı | `common.all` | Все | All |
| 2352 | Oxşar elanlar | `listing.similar` | Похожие объявления | Similar listings |
| 2452 | {n} kq boş | `listing.kg_free` | {n} кг свободно | {n} kg free |
| 2473 | Razılaşma ilə | `listing.negotiable` | По договорённости | Negotiable |
| 2534 | Səfər | `listing.type_trip` | Поездка | Trip |
| 2534 | Göndəriş | `listing.type_shipment` | Отправление | Shipment |
| 2558 | {n} kq boş | `listing.kg_free` | {n} кг свободно | {n} kg free |
| 2573 | Razılaşma ilə | `listing.negotiable` | По договорённости | Negotiable |
| 2642 | Mesaj | `listing.message_cta` | Сообщение | Message |
| 2654 | Yer yoxdur | `listing.no_space` | Мест нет | No space |
| 2660 | Təklif göndər | `listing.send_offer` | Отправить предложение | Send offer |
| 2677 | Redaktə | `common.edit` | Изменить | Edit |
| 2687 | Yenidən aktivləşdir | `listing.reactivate` | Активировать снова | Reactivate |
| 2701 | Sil | `common.delete` | Удалить | Delete |
| 2711 | Yenidən paylaş | `listing.repost` | Опубликовать снова | Repost |
| 2725 | Sil | `common.delete` | Удалить | Delete |
| 2735 | Düzəlt | `listing.fix` | Исправить | Fix |
| 2748 | Redaktə | `common.edit` | Изменить | Edit |
| 2757 | Dayandır | `common.pause` | Приостановить | Pause |
| 2766 | Sil | `common.delete` | Удалить | Delete |
| 2930 | Təklif göndər | `listing.send_offer` | Отправить предложение | Send offer |
| 2951 | Bağlama növü | `listing.package_type` | Тип посылки | Package type |
| 2978 | Çəki | `listing.weight_label` | Вес | Weight |
| 2979 | Boş: {n} kq | `listing.free_weight_hint` | Свободно: {n} кг | Free: {n} kg |
| 2987 | Ümumi qiymət | `listing.total_price` | Общая цена | Total price |
| 2997 | Qeyd | `common.note` | Заметка | Note |
| 2998 | Qısa mesaj yaz... | `listing.note_hint` | Напишите короткое сообщение... | Write a short message... |
| 3006 | Təxmini qiyməti çəkiyə görə hesablaya bilərsən: {price} $/kq | `listing.estimate_price_hint` | Примерную цену можно рассчитать по весу: {price} $/кг | You can estimate the price by weight: {price} $/kg |
| 3027 | Təklif göndər | `listing.send_offer` | Отправить предложение | Send offer |
| 3089 | Təklif göndərilmədi. Məlumatları yoxla və yenidən cəhd et. | `listing.offer_failed` | Не удалось отправить предложение. Проверьте данные и попробуйте снова. | Offer wasn’t sent. Check the details and try again. |
| 3127 | Bu söhbətdə artıq aktiv sifariş var. Davam etmək üçün mövcud söhbətə keç. | `listing.active_order_exists` | В этом чате уже есть активный заказ. Перейдите в существующий чат, чтобы продолжить. | There’s already an active order in this chat. Open the existing chat to continue. |
| 3210 | Söhbətə keç | `chat.go_to_chat` | Перейти в чат | Go to chat |
| 3256 | İstifadəçi | `common.user` | Пользователь | User |
| 3279 | Təklif göndərildi | `listing.offer_sent` | Предложение отправлено | Offer sent |
| 3290 | {ownerName} təklifinizə baxıb cavab verəcək. Söhbətdən danışıqları davam etdirə bilərsiniz. | `listing.offer_sent_body` | {ownerName} рассмотрит ваше предложение и ответит. Продолжить переговоры можно в чате. | {ownerName} will review your offer and reply. You can continue the conversation in chat. |
| 3316 | Bağlama | `listing.package_label` | Посылка | Package |
| 3325 | Ümumi qiymət | `listing.total_price` | Общая цена | Total price |
| 3351 | Söhbətə keç | `chat.go_to_chat` | Перейти в чат | Go to chat |
| 3367 | Elana qayıt | `listing.back_to_listing` | Вернуться к объявлению | Back to listing |
| 3543 | Qeyd | `common.note` | Заметка | Note |
| 3544 | İstəyə bağlı | `common.optional` | Необязательно | Optional |
| 3580 | Əməliyyat alınmadı. | `common.operation_failed` | Не удалось выполнить действие. | Action failed. |
| 3963 | Elan tapılmadı | `listing.not_found_title` | Объявление не найдено | Listing not found |
| 3972 | Elan silinmiş, moderasiyada ola bilər və ya sənə açıq deyil. | `listing.not_found_body` | Объявление удалено, находится на модерации или недоступно вам. | The listing was deleted, may be under review, or isn’t available to you. |
| 3982 | Yenidən yoxla | `common.retry` | Проверить снова | Retry |
| 4124 | Moderasiyada | `listing.status_moderation_title` | На модерации | Under review |
| 4125 | Elanınız yoxlanılır. Təsdiqlənəndən sonra lentdə görünəcək. | `listing.status_moderation_message` | Ваше объявление проверяется. После одобрения появится в ленте. | Your listing is being reviewed. It’ll appear in the feed once approved. |
| 4134 | Rədd edildi | `listing.status_rejected_title` | Отклонено | Rejected |
| 4136 | Səbəb: elan qaydalara uyğun deyil. Düzəliş edib yenidən göndərə bilərsiniz. | `listing.status_rejected_message` | Причина: объявление не соответствует правилам. Исправьте и отправьте снова. | Reason: the listing doesn’t meet the rules. Fix it and resubmit. |
| 4145 | Dayandırılıb | `listing.status_paused_title` | Приостановлено | Paused |
| 4147 | Bu elan lentdə görünmür. İstənilən vaxt yenidən aktivləşdirə bilərsiniz. | `listing.status_paused_message` | Это объявление скрыто из ленты. Вы можете активировать его в любой момент. | This listing is hidden from the feed. You can reactivate it anytime. |
| 4156 | Vaxtı keçib | `listing.status_expired_title` | Истекло | Expired |
| 4158 | Uçuş tarixi keçdiyi üçün elan lentdən çıxıb. Yeni tarixlə yenidən paylaşa bilərsiniz. | `listing.status_expired_message` | Дата вылета прошла, поэтому объявление ушло из ленты. Опубликуйте его снова с новой датой. | The flight date has passed, so the listing left the feed. Repost it with a new date. |
| 4191 | Yan, Fev, Mar ... Dek | `(use intl DateFormat)` | — | — |
| 4237 | bugün | `time.today` | сегодня | today |
| 4238 | dünən | `time.yesterday` | вчера | yesterday |
| 4239 | {n} gün əvvəl | `time.days_ago` | {n} дн. назад | {n} days ago |

## lib/screens/home/tabs/profile_tab/new_profile/new_profile_screen.dart  (36)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 529 | Profil | `profile.title` | Профиль | Profile |
| 669 | Əməliyyat alınmadı. | `common.operation_failed` | Не удалось выполнить операцию. | Something went wrong. |
| 853 | Əməliyyat alınmadı. | `common.operation_failed` | Не удалось выполнить операцию. | Something went wrong. |
| 877 | Şikayət göndərildi. | `profile.report_sent` | Жалоба отправлена. | Report sent. |
| 1027 | {year}-dən üzv | `profile.member_since` | с нами с {year} | member since {year} |
| 1521 | Razılaşma | `listing.negotiable` | Договорная | Negotiable |
| 1523 | {kg} kq boş | `listing.free_weight_kg` | {kg} кг свободно | {kg} kg free |
| 2110 | İzlənilir | `profile.following_active` | Вы подписаны | Following |
| 2115 | İzlə | `profile.follow` | Подписаться | Follow |
| 2124 | Mesaj | `profile.message` | Сообщение | Message |
| 2370 | Ayarlar | `profile.settings_title` | Настройки | Settings |
| 2921 | Məxfilik yenilənmədi. | `profile.privacy_update_failed` | Не удалось обновить конфиденциальность. | Couldn't update privacy. |
| 3400 | Şikayəti göndər | `profile.report_submit` | Отправить жалобу | Send report |
| 3496 | Cavabınız | `review.reply_field_label` | Ваш ответ | Your reply |
| 3533 | İstifadəçini blokla | `profile.block_user` | Заблокировать пользователя | Block user |
| 3539 | Şikayət et | `profile.report_action` | Пожаловаться | Report |
| 3545 | Bağla | `common.close` | Закрыть | Close |
| 4140 | Güclü | `profile.password_strong` | Надёжный | Strong |
| 4140 | Zəif | `profile.password_weak` | Слабый | Weak |
| 4172 | Bildiyiniz dillər | `profile.languages_you_know` | Языки, которыми владеете | Languages you speak |
| 4665 | Profil | `profile.title` | Профиль | Profile |
| 4753 | Profil | `profile.title` | Профиль | Profile |
| 4778 | İstifadəçi tapılmadı | `profile.user_not_found` | Пользователь не найден | User not found |
| 4787 | Bu hesab mövcud deyil, dayandırılıb və ya silinib. | `profile.account_unavailable` | Этот аккаунт не существует, приостановлен или удалён. | This account doesn't exist, is suspended, or was deleted. |
| 4799 | Yenilə | `common.refresh` | Обновить | Refresh |
| 4883 | Profil | `profile.title` | Профиль | Profile |
| 4906 | Profil üçün daxil ol | `profile.auth_required_title` | Войдите, чтобы открыть профиль | Sign in to view your profile |
| 4916 | Elanlarını, rəylərini və ayarlarını idarə etmək üçün hesabına daxil ol. | `profile.auth_required_subtitle` | Войдите в аккаунт, чтобы управлять объявлениями, отзывами и настройками. | Sign in to manage your listings, reviews and settings. |
| 4927 | Daxil ol / Qeydiyyat | `profile.auth_login_register` | Вход / Регистрация | Sign in / Sign up |
| 4937 | Yenilə | `common.refresh` | Обновить | Refresh |
| 5005 | ['Yan','Fev','Mar','Apr','May','İyun','İyul','Avq','Sen','Okt','Noy','Dek'] | `common.month_abbr` | — | — |
| 5026 | {n} həftə | `common.time_weeks` | {n} нед. | {n}w |
| 5027 | {n} gün | `common.time_days` | {n} дн. | {n}d |
| 5028 | {n} saat | `common.time_hours` | {n} ч. | {n}h |
| 5029 | indi | `common.time_now` | сейчас | now |
| 5038 | Əməliyyat alınmadı. | `common.operation_failed` | Не удалось выполнить операцию. | Something went wrong. |

## lib/screens/chat/widgets/message_bubble.dart  (35)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 185 | redaktə edildi | `chat.message.edited` | изменено | edited |
| 402 | Yenidən cəhd | `chat.message.retry` | Повторить | Retry |
| 865 | Təklifin göndərildi | `chat.card.proposal_sent` | Предложение отправлено | Offer sent |
| 866 | Çatdırılma təklifi | `chat.card.proposal_received` | Предложение о доставке | Delivery offer |
| 890 | gözlənilir | `chat.card.pending_badge` | ожидается | pending |
| 940 | Rədd | `chat.card.action_decline` | Отклонить | Decline |
| 957 | Dəyiş | `chat.card.action_counter` | Изменить | Change |
| 970 | Qəbul | `chat.card.action_accept` | Принять | Accept |
| 1026 | Sövdələşmə tamamlandı | `chat.card.completed_title` | Сделка завершена | Deal completed |
| 1050 | Rəy | `chat.card.review_action` | Отзыв | Review |
| 1097 | Problem bildirildi | `chat.card.disputed_title` | Сообщено о проблеме | Problem reported |
| 1121 | Dəstək | `chat.card.support_action` | Поддержка | Support |
| 1182 | Sövdələşmə ləğv edildi | `chat.card.cancelled_title` | Сделка отменена | Deal cancelled |
| 1191 | Səbəb: $reasonLabel | `chat.card.cancel_reason` | Причина: {reason} | Reason: {reason} |
| 1234 | Planlar dəyişdi | `chat.cancel_reason.plans_changed` | Планы изменились | Plans changed |
| 1236 | Şərtlərlə razılaşmadıq | `chat.cancel_reason.terms_disagreement` | Не сошлись в условиях | Couldn't agree on terms |
| 1238 | Qarşı tərəf cavab vermir | `chat.cancel_reason.counterpart_unresponsive` | Другая сторона не отвечает | The other party isn't responding |
| 1240 | Başqa variant tapdım | `chat.cancel_reason.found_another` | Нашёл другой вариант | Found another option |
| 1242 | Digər | `chat.cancel_reason.other` | Другое | Other |
| 1455 | Təklif qəbul edildi | `chat.card_label.accepted` | Предложение принято | Offer accepted |
| 1456 | Təklif rədd edildi | `chat.card_label.declined` | Предложение отклонено | Offer declined |
| 1457 | Mal götürüldü | `chat.card_label.picked_up` | Товар забран | Picked up |
| 1458 | Çatdırıldı | `chat.card_label.delivered` | Доставлено | Delivered |
| 1459 | Sövdələşmə tamamlandı | `chat.card_label.completed` | Сделка завершена | Deal completed |
| 1460 | Avtomatik tamamlandı | `chat.card_label.auto_completed` | Завершено автоматически | Auto-completed |
| 1461 | Problem bildirildi | `chat.card_label.disputed` | Сообщено о проблеме | Problem reported |
| 1462 | Ləğv edildi | `chat.card_label.cancelled` | Отменено | Cancelled |
| 1463 | Vaxtı keçdi | `chat.card_label.expired` | Срок истёк | Expired |
| 1464 | Təklif | `chat.card_label.default` | Предложение | Offer |
| 1484 | Sənədlər | `chat.package.documents` | Документы | Documents |
| 1485 | Kiçik bağlama | `chat.package.small_parcel` | Небольшая посылка | Small parcel |
| 1486 | Elektronika | `chat.package.electronics` | Электроника | Electronics |
| 1487 | Geyim | `chat.package.clothing` | Одежда | Clothing |
| 1488 | Qida | `chat.package.food` | Еда | Food |
| 1489 | Digər | `chat.package.other` | Другое | Other |

## lib/screens/home/tabs/profile_tab/referral/referral_screen.dart  (32)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 124 |  Kod: {code}. | `referral.share_code_suffix` |  Код: {code}. |  Code: {code}. |
| 127 | Wawatair-ə qoşul, hər ikimiz {amount} {currency} qazanaq! | `referral.share_text` | Присоединяйся к Wawatair — заработаем оба по {amount} {currency}! | Join Wawatair — we both earn {amount} {currency}! |
| 148 | Kod kopyalandı | `referral.code_copied` | Код скопирован | Code copied |
| 158 | Dostunu dəvət et | `referral.title` | Пригласить друга | Invite a friend |
| 174 | Linki paylaş | `referral.step1_title` | Поделитесь ссылкой | Share the link |
| 174 | dostuna dəvət linkini göndər. | `referral.step1_body` | отправьте другу пригласительную ссылку. | send your friend the invite link. |
| 176 | Dostun qoşulur | `referral.step2_title` | Друг присоединяется | Your friend joins |
| 176 | link ilə qeydiyyatdan keçir. | `referral.step2_body` | регистрируется по ссылке. | signs up via the link. |
| 178 | İkiniz də qazanırsınız | `referral.step3_title` | Вы оба зарабатываете | You both earn |
| 179 | ilk sifarişdən sonra {amount} {currency} promokod. | `referral.step3_body` | промокод на {amount} {currency} после первого заказа. | a {amount} {currency} promo code after the first order. |
| 198 | Dəvət etdiklərim | `referral.my_invites` | Мои приглашения | People I invited |
| 252 | Dostunu dəvət et, hər ikiniz  | `referral.hero_title` | Пригласи друга, вы оба  | Invite a friend, you both  |
| 257 |  qazanın | `referral.hero_title_suffix` |  заработаете |  earn |
| 269 | Dostun ilk sifarişini tamamlayanda promokod hər ikinizə gedir. | `referral.hero_subtitle` | Когда друг завершит первый заказ, промокод получите вы оба. | When your friend completes their first order, you both get a promo code. |
| 333 | DƏVƏT KODUN | `referral.code_label` | ВАШ КОД ПРИГЛАШЕНИЯ | YOUR INVITE CODE |
| 391 | Kopyala | `referral.share_copy` | Копировать | Copy |
| 394 | Link kopyalandı | `referral.link_copied` | Ссылка скопирована | Link copied |
| 395 | Digər | `referral.share_more` | Ещё | More |
| 457 | Dəvət | `referral.stat_invited` | Приглашено | Invited |
| 459 | Qoşulan | `referral.stat_joined` | Присоединились | Joined |
| 462 | Qazanılan | `referral.stat_earned` | Заработано | Earned |
| 537 | Dəvət etdiklərim | `referral.invites_title` | Мои приглашения | People I invited |
| 587 | Dəvət olunub | `referral.invited_pending_name` | Приглашён | Invited |
| 594 | Qoşulub | `referral.joined` | Присоединился | Joined |
| 595 | İlk sifariş gözlənilir | `referral.awaiting_first_order` | Ожидается первый заказ | Awaiting first order |
| 614 | Gözləyir | `referral.status_pending` | Ожидает | Pending |
| 663 | Hələ heç kimi dəvət etməmisən | `referral.empty_title` | Вы ещё никого не пригласили | You haven't invited anyone yet |
| 670 | Linki paylaş — dostların burada görünəcək. | `referral.empty_subtitle` | Поделитесь ссылкой — ваши друзья появятся здесь. | Share the link — your friends will show up here. |
| 691 | Dəvət linkini paylaş | `referral.share_invite_link` | Поделиться ссылкой-приглашением | Share invite link |
| 735 | Bağlantı yoxdur | `referral.error_title` | Нет соединения | No connection |
| 741 | Məlumatı yükləyə bilmədik. İnternet bağlantını yoxla. | `referral.error_body` | Не удалось загрузить данные. Проверьте интернет-соединение. | We couldn't load the data. Check your internet connection. |
| 762 | Yenidən cəhd et | `referral.retry` | Повторить | Try again |

## lib/screens/home/tabs/profile_tab/settings/notification_settings/notification_settings_screen.dart  (27)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 104 | Kanallar | `notif_settings.group.channels` | Каналы | Channels |
| 109 | Push bildirişlər | `notif_settings.push.title` | Push-уведомления | Push notifications |
| 110 | Telefona anında bildiriş | `notif_settings.push.subtitle` | Мгновенные уведомления на телефон | Instant alerts on your phone |
| 117 | E-poçt | `notif_settings.email.title` | Эл. почта | Email |
| 118 | Vacib yeniliklər e-poçtla | `notif_settings.email.subtitle` | Важные новости по эл. почте | Important updates by email |
| 126 | Kateqoriyalar | `notif_settings.group.categories` | Категории | Categories |
| 131 | Sövdələşmə & təkliflər | `notif_settings.deals.title` | Сделки и предложения | Deals & offers |
| 132 | Təklif, çatdırılma, sifariş | `notif_settings.deals.subtitle` | Предложения, доставка, заказы | Offers, delivery, orders |
| 139 | Elanlar | `notif_settings.listings.title` | Объявления | Listings |
| 140 | Təsdiq, rədd, vaxt, uyğun elan | `notif_settings.listings.subtitle` | Подтверждения, отклонения, сроки, подходящие объявления | Approvals, rejections, deadlines, matching listings |
| 147 | Mesajlar | `notif_settings.messages.title` | Сообщения | Messages |
| 148 | Yeni və cavabsız mesajlar | `notif_settings.messages.subtitle` | Новые и неотвеченные сообщения | New and unanswered messages |
| 159 | Rəylər | `notif_settings.reviews.title` | Отзывы | Reviews |
| 160 | Yeni rəy və xatırlatma | `notif_settings.reviews.subtitle` | Новые отзывы и напоминания | New reviews and reminders |
| 167 | İzləmə | `notif_settings.follows.title` | Подписки | Following |
| 168 | Yeni izləyici və elanları | `notif_settings.follows.subtitle` | Новые подписчики и их объявления | New followers and their listings |
| 175 | Saxlanan axtarışlar | `notif_settings.saved_search.title` | Сохранённые поиски | Saved searches |
| 176 | Axtarışınıza uyğun yeni elan | `notif_settings.saved_search.subtitle` | Новые объявления по вашему запросу | New listings matching your search |
| 183 | Yeniliklər & təkliflər | `notif_settings.marketing.title` | Новости и акции | News & offers |
| 184 | Kampaniya və elanlar | `notif_settings.marketing.subtitle` | Акции и анонсы | Campaigns and announcements |
| 192 | Sakit saatlar | `notif_settings.group.quiet_hours` | Тихие часы | Quiet hours |
| 201 | Push-u sakitləşdir | `notif_settings.quiet.title` | Отключить push | Mute push |
| 202 | Seçilən saatlarda push gəlməz | `notif_settings.quiet.subtitle` | В выбранные часы push не приходит | No push during the selected hours |
| 331 | Ayarlar saxlandı. | `notif_settings.saved_toast` | Настройки сохранены. | Settings saved. |
| 373 | Bildiriş ayarları | `notif_settings.title` | Настройки уведомлений | Notification settings |
| 580 | Başlanğıc — son | `notif_settings.quiet.range_label` | Начало — конец | Start — end |
| 660 | Hesab və təhlükəsizlik bildirişləri (giriş, parol, təsdiq, xəbərdarlıq) həmişə göndərilir və söndürülə bilməz. | `notif_settings.critical_note` | Уведомления об аккаунте и безопасности (вход, пароль, подтверждение, предупреждение) отправляются всегда и не могут быть отключены. | Account and security alerts (sign-in, password, confirmation, warnings) are always sent and can't be turned off. |

## lib/screens/home/tabs/profile_tab/reports/reports_screen.dart  (27)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 51 | [Yanvar … Dekabr — AZ month-name array] | `(use intl DateFormat, not CMS)` | [Январь … Декабрь] | [January … December] |
| 116 | Həll olundu | `reports.status.resolved` | Решено | Resolved |
| 120 | Rədd edildi | `reports.status.rejected` | Отклонено | Rejected |
| 123 | Gözləyir | `reports.status.pending` | Ожидает | Pending |
| 126 | Baxılır | `reports.status.reviewing` | На рассмотрении | Under review |
| 213 | Şikayətlərim | `reports.title` | Мои жалобы | My reports |
| 347 | Şikayətin yoxdur | `reports.empty.title` | Жалоб нет | No reports |
| 354 | Elan, istifadəçi və ya mesaj barədə şikayət etsən, burada görünəcək. | `reports.empty.body` | Когда вы пожалуетесь на объявление, пользователя или сообщение, это появится здесь. | When you report a listing, user, or message, it'll appear here. |
| 372 | İstifadəçi barədə şikayət | `reports.title.user` | Жалоба на пользователя | Report about a user |
| 374 | Mesaj barədə şikayət | `reports.title.message` | Жалоба на сообщение | Report about a message |
| 376 | Elan barədə şikayət | `reports.title.listing` | Жалоба на объявление | Report about a listing |
| 401 | Şikayət #{id} | `reports.detail.title` | Жалоба #{id} | Report #{id} |
| 458 | Sübut əlavə edilib | `reports.evidence_attached` | Прикреплено доказательство | Evidence attached |
| 470 | Səbəb | `reports.label.reason` | Причина | Reason |
| 479 | İzah | `reports.label.note` | Пояснение | Explanation |
| 492 | Vəziyyət | `reports.label.status` | Статус | Status |
| 511 | Moderasiya cavabı | `reports.moderation_response` | Ответ модерации | Moderation response |
| 543 | Göndərildi | `reports.step.submitted` | Отправлено | Submitted |
| 546 | Baxılır | `reports.step.reviewing` | На рассмотрении | Under review |
| 546 | Moderasiya komandası yoxlayır | `reports.step.reviewing_sub` | Команда модерации проверяет | The moderation team is reviewing |
| 548 | Nəticə | `reports.step.result` | Результат | Result |
| 549 | Həll olundu | `reports.status.resolved` | Решено | Resolved |
| 549 | Rədd edildi | `reports.status.rejected` | Отклонено | Rejected |
| 549 | Gözlənilir | `reports.step.awaiting` | Ожидается | Awaiting |
| 735 | Bağlantı yoxdur | `reports.error.title` | Нет соединения | No connection |
| 741 | Məlumatı yükləyə bilmədik. İnternet bağlantını yoxla. | `reports.error.body` | Не удалось загрузить данные. Проверьте подключение к интернету. | We couldn't load the data. Check your internet connection. |
| 762 | Yenidən cəhd et | `reports.retry` | Повторить | Try again |

## lib/screens/auth/forgot_password/forgot_password_screen.dart  (25)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 97 | Email mütləqdir. | `auth.forgot.email_required` | Укажите email. | Email is required. |
| 122 | 6 rəqəmli kodu daxil edin. | `auth.forgot.otp_required` | Введите 6-значный код. | Enter the 6-digit code. |
| 148 | Minimum 8 simvol olmalıdır. | `auth.forgot.password_min` | Минимум 8 символов. | Must be at least 8 characters. |
| 153 | Şifrələr uyğun gəlmir. | `auth.forgot.password_mismatch` | Пароли не совпадают. | Passwords don't match. |
| 241 | Şifrəni bərpa et | `auth.forgot.title_email` | Восстановить пароль | Reset password |
| 243 | Kodu yaz | `auth.forgot.title_otp` | Введите код | Enter the code |
| 244 | Yeni şifrə | `auth.forgot.title_password` | Новый пароль | New password |
| 255 | Email-ini yaz - təsdiq kodu göndərək. | `auth.forgot.subtitle_email` | Введите email — отправим код подтверждения. | Enter your email — we'll send a verification code. |
| 257 | {email} ünvanına gələn 6 rəqəmli kod. | `auth.forgot.subtitle_otp` | 6-значный код, отправленный на {email}. | The 6-digit code sent to {email}. |
| 258 | Yeni şifrəni təyin et. | `auth.forgot.subtitle_password` | Задайте новый пароль. | Set your new password. |
| 286 | ad@nümunə.com | `auth.forgot.email_hint` | имя@пример.com | name@example.com |
| 294 | Kod göndər | `auth.forgot.send_code` | Отправить код | Send code |
| 346 | Yeni kod göndər | `auth.forgot.resend_code` | Отправить новый код | Send new code |
| 351 | Təsdiqlə | `auth.forgot.verify` | Подтвердить | Confirm |
| 356 | Kodun vaxtı bitib. | `auth.forgot.code_expired` | Срок действия кода истёк. | The code has expired. |
| 356 | Kodun vaxtı: {time} | `auth.forgot.code_timer` | Код истекает через: {time} | Code expires in: {time} |
| 371 | Kod gəlmədi? Yenidən göndər | `auth.forgot.code_not_received` | Код не пришёл? Отправить снова | Didn't get the code? Resend |
| 389 | Yeni şifrə | `auth.forgot.new_password_label` | Новый пароль | New password |
| 390 | Minimum 8 simvol | `auth.forgot.password_hint` | Минимум 8 символов | Minimum 8 characters |
| 409 | Təsdiqlə | `auth.forgot.confirm_label` | Подтвердите | Confirm |
| 410 | Təkrar yaz | `auth.forgot.confirm_hint` | Повторите ввод | Re-enter |
| 430 | Şifrəni yenilə | `auth.forgot.reset_password` | Обновить пароль | Update password |
| 460 | Şifrə yeniləndi | `auth.forgot.success_title` | Пароль обновлён | Password updated |
| 470 | Şifrəniz uğurla dəyişdirildi. Artıq yeni şifrəniz ilə daxil ola bilərsiniz. | `auth.forgot.success_body` | Пароль успешно изменён. Теперь можно войти с новым паролем. | Your password was changed successfully. You can now log in with your new password. |
| 480 | Daxil ol | `auth.login` | Войти | Log in |

## lib/screens/home/tabs/profile_tab/promo/rate_app_screen.dart  (21)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 125 | Tətbiqi qiymətləndir | `rate.title` | Оценить приложение | Rate the app |
| 142 | Wawatair-i bəyənirsən? | `rate.intro_title` | Нравится Wawatair? | Do you like Wawatair? |
| 150 | 1 dəqiqəni ayır, Store-da bizi qiymətləndir — və hədiyyə promokod qazan. | `rate.intro_subtitle` | Уделите минуту, оцените нас в Store — и получите промокод в подарок. | Take a minute to rate us on the Store — and get a gift promo code. |
| 165 | Store-da qiymətləndir | `rate.cta` | Оценить в Store | Rate on the Store |
| 172 | Bir dəqiqədən az çəkir | `rate.takes_a_minute` | Займёт меньше минуты | Takes less than a minute |
| 188 | Düyməyə bas — Store-un qiymətləndirmə pəncərəsi açılır | `rate.step1` | Нажмите кнопку — откроется окно оценки Store | Tap the button — the Store's rating window opens |
| 191 | {reward} promokod avtomatik hesabına gəlir | `rate.step2` | промокод на {reward} автоматически зачисляется на счёт | a {reward} promo code is added to your account automatically |
| 193 | Elanı VİP/önə çəkərkən tətbiq et | `rate.step3` | Примените при VIP/продвижении объявления | Apply it when making a listing VIP/promoting it |
| 212 | Hədiyyə promokodun hazırdır 🎁 | `rate.rated_title_coupon` | Ваш промокод-подарок готов 🎁 | Your gift promo code is ready 🎁 |
| 213 | Təşəkkür edirik! ⭐️ | `rate.rated_title_thanks` | Спасибо! ⭐️ | Thank you! ⭐️ |
| 222 | Rəyin üçün təşəkkür! Bu promokodu VİP/önə çəkərkən tətbiq et: | `rate.rated_body_coupon` | Спасибо за отзыв! Примените этот промокод при VIP/продвижении: | Thanks for your review! Apply this promo code when making a listing VIP/promoting: |
| 223 | Bu tətbiqi artıq qiymətləndirmisən. Dəstəyin bizə çox kömək edir. | `rate.rated_body_thanks` | Вы уже оценили это приложение. Ваша поддержка очень помогает нам. | You've already rated this app. Your support helps us a lot. |
| 242 | Promokodlarıma bax | `rate.view_my_codes` | Мои промокоды | View my promo codes |
| 267 | {reward} promokod hədiyyə | `rate.reward_chip` | {reward} промокод в подарок | {reward} promo code gift |
| 489 | Təşəkkür edirik! ⭐️ | `rate.toast_title` | Спасибо! ⭐️ | Thank you! ⭐️ |
| 495 | Rəyin bizə çox kömək edir. | `rate.toast_body` | Ваш отзыв очень помогает нам. | Your review helps us a lot. |
| 527 | Müddəti bitib | `rate.expired` | Срок истёк | Expired |
| 529 | Bu gün bitir · {date} | `rate.expires_today` | Истекает сегодня · {date} | Expires today · {date} |
| 530 | {days} gün qalıb · son tarix {date} | `rate.days_left` | осталось {days} дн. · до {date} | {days} days left · until {date} |
| 582 | Kod kopyalandı | `rate.code_copied` | Код скопирован | Code copied |
| 631 | {amount} endirim · VİP/önə çəkmə | `rate.coupon_footer` | {amount} скидка · VIP/продвижение | {amount} off · VIP/promotion |

## lib/screens/home/tabs/home_tab/search/user_search_tab.dart  (20)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 337 | Ad, soyad və ya @username | `search.user_search_hint` | Имя, фамилия или @username | Name, surname or @username |
| 400 | Son axtarışlar | `search.user_recent_title` | Недавние поиски | Recent searches |
| 407 | Təmizlə | `search.user_clear` | Очистить | Clear |
| 484 | Ad və ya @username ilə axtar | `search.user_prompt_title` | Поиск по имени или @username | Search by name or @username |
| 485 | İnsanları adı, soyadı və ya istifadəçi adı ilə tap. | `search.user_prompt_subtitle` | Ищите людей по имени, фамилии или нику. | Find people by name, surname or username. |
| 497 | Ən azı 2 simvol daxil edin | `search.user_min_chars` | Введите минимум 2 символа | Enter at least 2 characters |
| 553 | Daha çox yüklənir… | `search.user_loading_more` | Загрузка ещё… | Loading more… |
| 570 | Heç kim tapılmadı | `search.user_empty_title` | Никого не найдено | No one found |
| 571 | «{query}» üzrə nəticə yoxdur. Adı və ya @username-i yoxla. | `search.user_empty_subtitle` | Нет результатов по «{query}». Проверьте имя или @username. | No results for «{query}». Check the name or @username. |
| 591 | Çox tez-tez axtarış —  | `search.user_rate_limit_prefix` | Слишком частые запросы —  | Too many searches —  |
| 596 |  sonra yenidən cəhd et | `search.user_rate_limit_suffix` |  повторите попытку |  try again |
| 606 | Təkrar | `search.user_retry` | Повторить | Retry |
| 627 | Bağlantı yoxdur — nəticələr yüklənmədi | `search.user_network_error` | Нет соединения — результаты не загрузились | No connection — results didn't load |
| 634 | Təkrar | `search.user_retry` | Повторить | Retry |
| 727 | Marşrut | `search.segment_route` | Маршрут | Route |
| 728 | İstifadəçi | `search.segment_user` | Люди | People |
| 872 | Yeni istifadəçi · reytinq yoxdur | `search.user_new_no_rating` | Новый пользователь · нет рейтинга | New user · no rating |
| 890 | {count} çatdırılma | `search.user_deliveries_template` | {count} доставок | {count} deliveries |
| 910 | İzlənilir | `search.user_following` | Вы подписаны | Following |
| 931 | İzlə | `search.user_follow` | Подписаться | Follow |

## lib/screens/home/tabs/profile_tab/promo/promo_codes_screen.dart  (19)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 534 | ENDİRİM | `promo.discount_label` | СКИДКА | DISCOUNT |
| 617 | İstifadə et | `promo.use` | Использовать | Use |
| 642 | {days} gün qalıb | `promo.days_left` | осталось {days} дн. | {days} days left |
| 659 | Müddətsiz | `promo.no_expiry` | Бессрочно | No expiry |
| 660 | {date}-a qədər | `promo.until_date` | до {date} | until {date} |
| 750 | İŞLƏNİB | `promo.stamp_used` | ИСПОЛЬЗОВАН | USED |
| 750 | BİTİB | `promo.stamp_expired` | ИСТЁК | EXPIRED |
| 765 | İstifadə olunub | `promo.used_at` | Использован | Used |
| 769 | Vaxtı bitib | `promo.expired_at` | Истёк | Expired |
| 789 | Tətbiqi qiymətləndirdiyin üçün | `promo.source_rate_review` | За оценку приложения | For rating the app |
| 791 | Dostunu dəvət etdiyin üçün | `promo.source_referral` | За приглашение друга | For inviting a friend |
| 793 | Xoş gəlmisən bonusu | `promo.source_welcome` | Приветственный бонус | Welcome bonus |
| 795 | Promokod | `promo.source_default` | Промокод | Promo code |
| 1044 | Minimum ödəniş: {amount} | `promo.cond_min` | Минимальный заказ: {amount} | Minimum order: {amount} |
| 1046 | Bir dəfə istifadə olunur | `promo.cond_single_use` | Используется один раз | Single use |
| 1048 | VİP və önə çəkmə üçün keçərli | `promo.cond_scope` | Действует для VIP и продвижения | Valid for VIP and promotion |
| 1056 | Kodu köçür | `promo.copy_code` | Скопировать код | Copy code |
| 1067 | Elanı önə çıxar | `promo.promote_listing` | Продвинуть объявление | Promote listing |
| 1270 | Yenidən cəhd et | `promo.retry` | Повторить | Try again |

## lib/screens/home/tabs/listings/widgets/listing_card.dart  (19)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 494 | Razılaşma ilə | `listing.negotiable` | По договорённости | Negotiable |
| 547 | Çəki | `listing.weight_label` | Вес | Weight |
| 556 | Reys | `listing.flight_label` | Рейс | Flight |
| 565 | Qiymət razılaşma ilə | `listing.price_negotiable` | Цена договорная | Price negotiable |
| 611 | Boş yer | `listing.free_space` | Свободно | Free space |
| 798 | ~{minutes} dəq cavab | `listing.response_short` | ~{minutes} мин ответ | ~{minutes} min reply |
| 831 | Baxış | `listing.stat_views` | Просмотры | Views |
| 841 | Sevimli | `listing.stat_favorites` | В избранном | Favorite |
| 867 | Yer yoxdur | `listing.no_space` | Мест нет | No space |
| 869 | Təklif göndər | `listing.send_offer` | Отправить предложение | Send offer |
| 885 | Mesaj | `listing.message_cta` | Сообщение | Message |
| 904 | Aktiv et | `my_listings.resume` | Активировать | Activate |
| 904 | Dayandır | `common.pause` | Приостановить | Pause |
| 934 | Sil | `common.delete` | Удалить | Delete |
| 1163 | {days} gün {hours} saat | `promotion.remaining_days_hours` | {days} дн. {hours} ч | {days}d {hours}h |
| 1164 | {hours} saat | `promotion.remaining_hours` | {hours} ч | {hours}h |
| 1166 | {minutes} dəq | `promotion.remaining_minutes` | {minutes} мин | {minutes}m |
| 1198 | Yığ | `common.collapse` | Свернуть | Collapse |
| 1198 | Ətraflı | `common.more` | Подробнее | More |

## lib/screens/auth/registration/registration_screen.dart  (19)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 151 | Hesab yarat | `auth.register.title` | Создать аккаунт | Create account |
| 160 | Bir neçə addımda qoşul | `auth.register.subtitle` | Присоединяйтесь за пару шагов | Join in a few steps |
| 178 | Ad | `auth.register.first_name` | Имя | First name |
| 179 | Tahir | `auth.register.first_name_hint` | Иван | John |
| 189 | Soyad | `auth.register.last_name` | Фамилия | Last name |
| 190 | Quliyev | `auth.register.last_name_hint` | Иванов | Doe |
| 201 | ad@nümunə.com | `auth.register.email_hint` | имя@пример.com | name@example.com |
| 208 | Şifrə | `auth.register.password_label` | Пароль | Password |
| 209 | Minimum 8 simvol | `auth.register.password_hint` | Минимум 8 символов | Minimum 8 characters |
| 229 | Şifrəni təsdiqlə | `auth.register.confirm_password_label` | Подтвердите пароль | Confirm password |
| 231 | Təkrar yaz | `auth.register.confirm_password_hint` | Повторите ввод | Re-enter |
| 238 | Danışdığın dillər | `auth.register.languages_label` | Языки, на которых вы говорите | Languages you speak |
| 300 | İstifadə qaydaları və  | `auth.register.terms_prefix` | Условия использования и  | Terms of use and  |
| 302 | Məxfilik siyasəti | `auth.register.privacy_policy` | Политика конфиденциальности | Privacy policy |
| 316 |  ilə tanış oldum. | `auth.register.terms_suffix` |  — ознакомлен(а). |  — I have read and agree. |
| 339 | Qeydiyyatdan keç | `auth.register` | Зарегистрироваться | Sign up |
| 343 | və ya | `auth.or` | или | or |
| 372 | Hesabın var?  | `auth.register.have_account` | Уже есть аккаунт?  | Already have an account?  |
| 378 | Daxil ol | `auth.login` | Войти | Log in |

## lib/screens/home/tabs/profile_tab/promo/app_review.dart  (18)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 296 | Bir dəqiqədən az çəkir | `takes_a_minute` | Займёт меньше минуты | Takes less than a minute |
| 307 | Çox sağ ol! 🎉 | `high_title` | Большое спасибо! 🎉 | Thank you so much! 🎉 |
| 315 | Rəyini App Store-da paylaş — sənə  | `high_body_prefix` | Оставьте отзыв в App Store — мы отправим вам  | Share your review on the App Store — we'll send you  |
| 317 | {reward} promokod | `high_body_reward` | промокод на {reward} | a {reward} promo code |
| 320 |  göndərək. | `high_body_suffix` | . | . |
| 334 | App Store-da rəy yaz | `write_review_cta` | Написать отзыв в App Store | Write a review on the App Store |
| 358 | App Store açılır… | `opening_store_title` | Открываем App Store… | Opening the App Store… |
| 363 | Rəyini orada paylaş, sonra tətbiqə qayıt. | `opening_store_body` | Оставьте там отзыв, затем вернитесь в приложение. | Share your review there, then come back to the app. |
| 402 | Kodu köçür | `copy_code` | Скопировать код | Copy code |
| 411 | Bağla | `close` | Закрыть | Close |
| 443 | Bizə kömək et — nəyi dəyişək? | `low_title` | Помогите нам — что улучшить? | Help us — what should we change? |
| 448 | Fikrin birbaşa komandamıza gedir. Promokod yenə də səninlədir. | `low_body` | Ваш отзыв идёт напрямую нашей команде. Промокод всё равно ваш. | Your feedback goes straight to our team. The promo code is still yours. |
| 462 | Təcrübən barədə bir neçə söz yaz… | `feedback_hint` | Напишите пару слов о вашем опыте… | Write a few words about your experience… |
| 481 | Rəy göndər | `send_feedback` | Отправить отзыв | Send feedback |
| 486 | Keç | `skip` | Пропустить | Skip |
| 504 | {reward} promokod hədiyyə | `reward_chip` | {reward} промокод в подарок | {reward} promo code gift |
| 544 | PROMOKODUN | `promo_code_label` | ВАШ ПРОМОКОД | YOUR PROMO CODE |
| 586 | {reward} endirim · növbəti sifarişə | `reward_coupon_footer` | {reward} скидка · на следующий заказ | {reward} off · on your next order |

## lib/screens/auth/login/login_screen.dart  (13)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 119 | Xoş gəldin | `auth.login.welcome` | Добро пожаловать | Welcome |
| 128 | Hesabına daxil ol | `auth.login.subtitle` | Войдите в аккаунт | Log in to your account |
| 148 | ad@nümunə.com | `auth.login.email_hint` | имя@пример.com | name@example.com |
| 157 | Şifrə | `auth.login.password_label` | Пароль | Password |
| 189 | Məni xatırla | `auth.login.remember_me` | Запомнить меня | Remember me |
| 196 | Şifrənizi unutmusunuz? | `auth.login.forgot_password` | Забыли пароль? | Forgot your password? |
| 207 | Daxil ol | `auth.login` | Войти | Log in |
| 213 | Dəstək ilə əlaqə | `auth.login.contact_support` | Связаться с поддержкой | Contact support |
| 220 | və ya | `auth.or` | или | or |
| 223 | Google ilə davam et | `auth.continue_google` | Продолжить с Google | Continue with Google |
| 231 | Apple ilə davam et | `auth.continue_apple` | Продолжить с Apple | Continue with Apple |
| 241 | Hesabın yoxdur?  | `auth.login.no_account` | Нет аккаунта?  | Don't have an account?  |
| 247 | Qeydiyyatdan keç | `auth.register` | Зарегистрироваться | Sign up |

## lib/screens/home/tabs/profile_tab/new_profile/profile_api.dart  (12)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 138 | İzləməyə başladınız. | `profile.follow_started` | Вы подписались. | You're now following. |
| 144 | İzləmə dayandırıldı. | `profile.unfollow_done` | Вы отписались. | Unfollowed. |
| 150 | İstifadəçi bloklandı. | `profile.user_blocked` | Пользователь заблокирован. | User blocked. |
| 168 | Şikayət göndərildi. | `profile.report_sent` | Жалоба отправлена. | Report sent. |
| 185 | Məxfilik parametrləri yeniləndi. | `profile.privacy_updated` | Настройки конфиденциальности обновлены. | Privacy settings updated. |
| 199 | Parol dəyişdirildi. | `profile.password_changed` | Пароль изменён. | Password changed. |
| 205 | Hesabınız silindi. | `profile.account_deleted` | Ваш аккаунт удалён. | Your account was deleted. |
| 215 | Avatar yeniləndi. | `profile.avatar_updated` | Аватар обновлён. | Avatar updated. |
| 221 | Avatar silindi. | `profile.avatar_deleted` | Аватар удалён. | Avatar deleted. |
| 233 | Cavabınız moderasiyaya göndərildi. | `review.reply_submitted` | Ваш ответ отправлен на модерацию. | Your reply was sent for review. |
| 251 | Rəyiniz moderasiyaya göndərildi. | `review.submitted` | Ваш отзыв отправлен на модерацию. | Your review was sent for review. |
| 261 | Rəy istəyi göndərildi. | `review.request_sent` | Запрос на отзыв отправлен. | Review request sent. |

## lib/screens/home/tabs/home_tab/notification/notification_screen.dart  (10)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 1167 | Köhnə | `notifications.group.older` | Ранее | Earlier |
| 1172 | Bu gün | `notifications.group.today` | Сегодня | Today |
| 1173 | Dünən | `notifications.group.yesterday` | Вчера | Yesterday |
| 1174 | Bu həftə | `notifications.group.this_week` | На этой неделе | This week |
| 1175 | Köhnə | `notifications.group.older` | Ранее | Earlier |
| 1182 | indi | `notifications.time.now` | сейчас | now |
| 1183 | {minutes} dəqiqə əvvəl | `notifications.time.minutes_ago` | {minutes} мин. назад | {minutes} min ago |
| 1184 | {hours} saat əvvəl | `notifications.time.hours_ago` | {hours} ч. назад | {hours}h ago |
| 1185 | Dünən | `notifications.time.yesterday` | Вчера | Yesterday |
| 1186 | {days} gün əvvəl | `notifications.time.days_ago` | {days} дн. назад | {days}d ago |

## lib/screens/auth/forgot_password/forgot_password_bloc.dart  (10)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 31 | Təsdiq kodu email-inizə göndərildi. | `auth.forgot.code_sent` | Код подтверждения отправлен на вашу почту. | A verification code has been sent to your email. |
| 37 | Sorğu xətası | `common.request_error` | Ошибка запроса | Request error |
| 40 | Kod göndərmək mümkün olmadı. | `auth.forgot.send_code_failed` | Не удалось отправить код. | Couldn't send the code. |
| 50 | Bərpa tokeni yanlışdır. | `auth.forgot.invalid_token` | Токен восстановления недействителен. | The recovery token is invalid. |
| 67 | Sorğu xətası | `common.request_error` | Ошибка запроса | Request error |
| 71 | Kod yanlışdır. | `auth.forgot.invalid_code` | Неверный код. | The code is incorrect. |
| 81 | Bərpa tokeni yanlışdır. | `auth.forgot.invalid_token` | Токен восстановления недействителен. | The recovery token is invalid. |
| 99 | Sorğu xətası | `common.request_error` | Ошибка запроса | Request error |
| 102 | Şifrəni yeniləmək mümkün olmadı. | `auth.forgot.reset_failed` | Не удалось обновить пароль. | Couldn't update the password. |
| 137 | Sorğu xətası | `common.request_error` | Ошибка запроса | Request error |

## lib/screens/chat/widgets/deal_pin_bar.dart  (8)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 110 | Təklif gözləyir | `chat.pinbar.status.proposal_pending` | Ожидает предложения | Offer pending |
| 111 | Qəbul olundu | `chat.pinbar.status.accepted` | Принято | Accepted |
| 112 | Mal götürüldü | `chat.pinbar.status.picked_up` | Товар забран | Picked up |
| 113 | Çatdırıldı | `chat.pinbar.status.delivered` | Доставлено | Delivered |
| 114 | Mübahisəli | `chat.pinbar.status.disputed` | Спорная | Disputed |
| 115 | Tamamlandı | `chat.pinbar.status.completed` | Завершено | Completed |
| 116 | Avtomatik tamamlandı | `chat.pinbar.status.auto_completed` | Завершено автоматически | Auto-completed |
| 117 | Sövdələşmə | `chat.pinbar.status.default` | Сделка | Deal |

## lib/screens/auth/auth_modal/auth_welcome_screen.dart  (8)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 46 | Qonaq | `auth.guest` | Гость | Guest |
| 76 | Səyahət et, bağlama daşı, qazan. Etibarlı crowdshipping icması. | `auth.welcome.tagline` | Путешествуй, вози посылки, зарабатывай. Надёжное сообщество crowdshipping. | Travel, carry parcels, earn. A trusted crowdshipping community. |
| 89 | Qeydiyyatdan keç | `auth.register` | Зарегистрироваться | Sign up |
| 94 | Daxil ol | `auth.login` | Войти | Log in |
| 98 | və ya | `auth.or` | или | or |
| 101 | Google ilə davam et | `auth.continue_google` | Продолжить с Google | Continue with Google |
| 106 | Apple ilə davam et | `auth.continue_apple` | Продолжить с Apple | Continue with Apple |
| 114 | Qonaq kimi davam et | `auth.continue_as_guest` | Продолжить как гость | Continue as guest |

## lib/screens/home/tabs/profile_tab/deals/widgets/deal_status.dart  (7)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 125 | ['yanvar','fevral','mart','aprel','may','iyun','iyul','avqust','sentyabr','oktyabr','noyabr','dekabr'] | `(none — use intl DateFormat, not CMS)` | названия месяцев — использовать intl DateFormat | month-name array — should use intl DateFormat, not a CMS key |
| 150 | Sənədlər | `enum.package_type.documents` | Документы | Documents |
| 151 | Kiçik bağlama | `enum.package_type.small_parcel` | Маленькая посылка | Small parcel |
| 152 | Elektronika | `enum.package_type.electronics` | Электроника | Electronics |
| 153 | Geyim | `enum.package_type.clothing` | Одежда | Clothing |
| 154 | Qida | `enum.package_type.food` | Еда | Food |
| 155 | Digər | `enum.package_type.other` | Другое | Other |

## lib/screens/splesh/Intro_page.dart  (7)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 431 | Bakı | `onboarding.art.city_from` | Баку | Baku |
| 438 | İstanbul | `onboarding.art.city_to` | Стамбул | Istanbul |
| 447 | Bağlaman | `onboarding.art.parcel` | Твоя посылка | Your parcel |
| 515 | 1–2 gündə | `onboarding.art.eta` | за 1–2 дня | in 1–2 days |
| 559 | 4.9 reytinq | `onboarding.art.rating` | рейтинг 4.9 | 4.9 rating |
| 568 | Təhlükəsiz | `onboarding.art.secure` | Безопасно | Secure |
| 686 | 5 \$-dən | `onboarding.art.price_from` | от $5 | from $5 |

## lib/screens/home/tabs/profile_tab/deals/deal_detail_screen.dart  (6)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 313 | Profil məlumatı tapılmadı. | `deals.error.profile_not_found` | Данные профиля не найдены. | Profile not found. |
| 341 | Rəy göndərildi | `deals.review.sent` | Отзыв отправлен | Review submitted |
| 513 | Əməliyyat alınmadı. Yenidən cəhd edin. | `deals.error.action_failed` | Не удалось выполнить действие. Попробуйте ещё раз. | Action failed. Please try again. |
| 933 | Mal götürüldü | `deals.timeline.picked_up` | Товар забран | Item picked up |
| 941 | Çatdırıldı | `deals.timeline.delivered` | Доставлено | Delivered |
| 949 | Tamamlandı | `deals.timeline.completed` | Завершено | Completed |

## lib/screens/auth/email_verify/email_verify_screen.dart  (6)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 32 | Təsdiq linki email-inizə göndərildi. | `auth.verify.link_sent` | Ссылка для подтверждения отправлена на вашу почту. | A verification link has been sent to your email. |
| 83 | Email-ini təsdiqlə | `auth.verify.title` | Подтвердите email | Verify your email |
| 93 | {email} ünvanına təsdiq linki göndərdik. Linkə klikləyib hesabını aktivləşdir. | `auth.verify.body` | Мы отправили ссылку для подтверждения на {email}. Перейдите по ней, чтобы активировать аккаунт. | We sent a verification link to {email}. Tap the link to activate your account. |
| 103 | Linki yenidən göndər | `auth.verify.resend` | Отправить ссылку снова | Resend link |
| 115 | Davam et | `auth.continue` | Продолжить | Continue |
| 124 | Məktub gəlmədi? Spam qovluğunu yoxla. | `auth.verify.check_spam` | Письмо не пришло? Проверьте папку «Спам». | Didn't get the email? Check your spam folder. |

## lib/screens/home/tabs/profile_tab/profile_tab_screen.dart  (5)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 422 | İmtina et | `common.cancel` | Отмена | Cancel |
| 751 | Qaydalar & şərtlər | `menu.rules` | Правила и условия | Terms & conditions |
| 761 | Məxfilik siyasəti | `menu.privacy_policy` | Политика конфиденциальности | Privacy policy |
| 1541 | Menyu yüklənmədi. | `menu.load_failed` | Не удалось загрузить меню. | Couldn't load the menu. |
| 1559 | Yenidən yoxla | `menu.retry` | Повторить | Retry |

## lib/screens/home/tabs/profile_tab/legal/legal_doc_screen.dart  (5)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 38 | [Yanvar … Dekabr — AZ month-name array] | `(use intl DateFormat, not CMS)` | [Январь … Декабрь] | [January … December] |
| 176 | Yenilənib: {date} | `legal.updated` | Обновлено: {date} | Updated: {date} |
| 366 | Bağlantı yoxdur | `legal.error.title` | Нет соединения | No connection |
| 372 | Səhifəni yükləyə bilmədik. İnternet bağlantını yoxla. | `legal.error.body` | Не удалось загрузить страницу. Проверьте подключение к интернету. | We couldn't load the page. Check your internet connection. |
| 393 | Yenidən cəhd et | `legal.retry` | Повторить | Try again |

## lib/screens/home/tabs/home_tab/home_tab_screen.dart  (4)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 551 |  çatdırılma ·  | `home.stats_deliveries_suffix` |  доставок ·  |  deliveries ·  |
| 558 |  təsdiqlənmiş səyahətçi | `home.stats_travelers_suffix` |  проверенных путешественников |  verified travelers |
| 726 | {count} səyahətçi | `home.route_travelers_template` | {count} путешественников | {count} travelers |
| 735 | {price} $-dən | `home.route_price_from_template` | от {price} $ | from {price} $ |

## lib/screens/home/tabs/profile_tab/verification/verification_screen.dart  (3)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 815 | Sənəd növləri yüklənə bilmədi. Yenidən cəhd et. | `verification.doc_types_load_failed` | Не удалось загрузить типы документов. Попробуйте снова. | Couldn't load document types. Try again. |
| 839 | Göndərmək alınmadı. Yenidən cəhd et. | `verification.submit_failed` | Не удалось отправить. Попробуйте снова. | Submission failed. Try again. |
| 871 | Sənəd növləri yüklənmədi. Yenidən cəhd et. | `verification.doc_types_load_failed` | Не удалось загрузить типы документов. Попробуйте снова. | Document types didn't load. Try again. |

## lib/screens/home/tabs/create_post/create_post_screen.dart  (3)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 41 | Yanvar, Fevral ... Dekabr | `(use intl DateFormat)` | — | — |
| 61 | Siz | `common.you` | Вы | You |
| 70 | Siz | `common.you` | Вы | You |

## lib/screens/auth/email_verify/email_verify_bloc.dart  (3)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 21 | Təsdiq linkini göndərmək mümkün olmadı. | `auth.verify.send_failed` | Не удалось отправить ссылку для подтверждения. | Couldn't send the verification link. |
| 32 | Sorğu xətası | `common.request_error` | Ошибка запроса | Request error |
| 34 | Sorğu xətası | `common.request_error` | Ошибка запроса | Request error |

## lib/screens/home/tabs/create_post/listing_limit_gate_screen.dart  (2)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 282 | {active}/{limit} aktiv {noun} elanın var. | `limit.active_count_prefix` | У вас {active}/{limit} активных объявлений «{noun}». | You have {active}/{limit} active {noun} listings. |
| 626 | Yan, Fev, Mar ... Dek | `(use intl DateFormat)` | — | — |

## lib/screens/home/tabs/create_post/quota/listing_quota_screens.dart  (2)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 137 | səfər | `enum.listing_type_noun.trip` | поездка | trip |
| 137 | göndəriş | `enum.listing_type_noun.shipment` | отправление | shipment |

## lib/screens/home/bottom_bar.dart  (1)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 90 | Kəşf | `nav.explore` | Обзор | Explore |

## lib/screens/home/tabs/home_tab/search/search_offer_list_screen.dart  (1)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 2687 | kq | `common.unit_kg` | кг | kg |

## lib/screens/home/tabs/profile_tab/blocked_users/blocked_users_api.dart  (1)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 29 | Blok götürüldü. | `block.unblock_success` | Пользователь разблокирован. | User unblocked. |

## lib/screens/home/tabs/profile_tab/deals/deal_action_sheets.dart  (1)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 436 | Ətraflı izah edin… | `deals.dispute.detail_hint` | Опишите подробнее… | Explain in detail… |

## lib/screens/home/tabs/profile_tab/see_more_offers/delivery_full_list_screen.dart  (1)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 889 | Ləğv et | `common.cancel` | Отмена | Cancel |

## lib/screens/chat/widgets/chat_input.dart  (1)

| line | AZ | proposed key | RU | EN |
|---|---|---|---|---|
| 328 | ${reply.authorName}-ə cavab | `chat.reply.replying_to` | Ответ {name} | Reply to {name} |

