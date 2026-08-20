# i18n — полный набор ключей приложения для CMS (UPSERT)

**1255** уникальных ключей, которые приложение запрашивает через `t()` / `WawatContent.text()`. Источник AZ — карта `WawatContent.fallbacks` в коде (авторитетная) + аудит хардкод-строк. RU/EN сгенерированы.

**Инструкция бэкенду:** сделайте **UPSERT** в CMS — добавьте ключи, которых у вас ещё нет (со всеми языками az/ru/en/tr/uk/es — здесь даны az/ru/en, остальные по аналогии). Существующие ключи и их переводы **не трогайте**. После добавления недостающих ключей локализация начнёт работать **без обновления приложения** (клиент уже обёрнут в `t()` для этих ключей).

Формат: `key | AZ | RU | EN`.

## about  (7)

| key | AZ | RU | EN |
|---|---|---|---|
| `about.copyright` | © 2026 Wawatair · Bütün hüquqlar qorunur | © 2026 Wawatair · Все права защищены | © 2026 Wawatair · All rights reserved |
| `about.follow_us` | Bizi izlə | Мы в соцсетях | Follow us |
| `about.licenses` | Lisenziyalar | Лицензии | Licenses |
| `about.terms` | İstifadə şərtləri | Условия использования | Terms of use |
| `about.up_to_date` | Ən son versiyadasan | У вас последняя версия | You're up to date |
| `about.version` | Versiya {version} | Версия {version} | Version {version} |
| `about.website` | Veb sayt | Веб-сайт | Website |

## auth  (68)

| key | AZ | RU | EN |
|---|---|---|---|
| `auth.continue` | Davam et | Продолжить | Continue |
| `auth.continue_apple` | Apple ilə davam et | Продолжить с Apple | Continue with Apple |
| `auth.continue_as_guest` | Qonaq kimi davam et | Продолжить как гость | Continue as guest |
| `auth.continue_google` | Google ilə davam et | Продолжить с Google | Continue with Google |
| `auth.forgot.code_expired` | Kodun vaxtı bitib. | Срок действия кода истёк. | The code has expired. |
| `auth.forgot.code_not_received` | Kod gəlmədi? Yenidən göndər | Код не пришёл? Отправить снова | Didn't get the code? Resend |
| `auth.forgot.code_sent` | Təsdiq kodu email-inizə göndərildi. | Код подтверждения отправлен на вашу почту. | A verification code has been sent to your email. |
| `auth.forgot.code_timer` | Kodun vaxtı: {time} | Код истекает через: {time} | Code expires in: {time} |
| `auth.forgot.confirm_hint` | Təkrar yaz | Повторите ввод | Re-enter |
| `auth.forgot.confirm_label` | Təsdiqlə | Подтвердите | Confirm |
| `auth.forgot.email_hint` | ad@nümunə.com | имя@пример.com | name@example.com |
| `auth.forgot.email_required` | Email mütləqdir. | Укажите email. | Email is required. |
| `auth.forgot.invalid_code` | Kod yanlışdır. | Неверный код. | The code is incorrect. |
| `auth.forgot.invalid_token` | Bərpa tokeni yanlışdır. | Токен восстановления недействителен. | The recovery token is invalid. |
| `auth.forgot.new_password_label` | Yeni şifrə | Новый пароль | New password |
| `auth.forgot.otp_required` | 6 rəqəmli kodu daxil edin. | Введите 6-значный код. | Enter the 6-digit code. |
| `auth.forgot.password_hint` | Minimum 8 simvol | Минимум 8 символов | Minimum 8 characters |
| `auth.forgot.password_min` | Minimum 8 simvol olmalıdır. | Минимум 8 символов. | Must be at least 8 characters. |
| `auth.forgot.password_mismatch` | Şifrələr uyğun gəlmir. | Пароли не совпадают. | Passwords don't match. |
| `auth.forgot.resend_code` | Yeni kod göndər | Отправить новый код | Send new code |
| `auth.forgot.reset_failed` | Şifrəni yeniləmək mümkün olmadı. | Не удалось обновить пароль. | Couldn't update the password. |
| `auth.forgot.reset_password` | Şifrəni yenilə | Обновить пароль | Update password |
| `auth.forgot.send_code` | Kod göndər | Отправить код | Send code |
| `auth.forgot.send_code_failed` | Kod göndərmək mümkün olmadı. | Не удалось отправить код. | Couldn't send the code. |
| `auth.forgot.subtitle_email` | Email-ini yaz - təsdiq kodu göndərək. | Введите email — отправим код подтверждения. | Enter your email — we'll send a verification code. |
| `auth.forgot.subtitle_otp` | {email} ünvanına gələn 6 rəqəmli kod. | 6-значный код, отправленный на {email}. | The 6-digit code sent to {email}. |
| `auth.forgot.subtitle_password` | Yeni şifrəni təyin et. | Задайте новый пароль. | Set your new password. |
| `auth.forgot.success_body` | Şifrəniz uğurla dəyişdirildi. Artıq yeni şifrəniz ilə daxil ola bilərsiniz. | Пароль успешно изменён. Теперь можно войти с новым паролем. | Your password was changed successfully. You can now log in with your new password. |
| `auth.forgot.success_title` | Şifrə yeniləndi | Пароль обновлён | Password updated |
| `auth.forgot.title_email` | Şifrəni bərpa et | Восстановить пароль | Reset password |
| `auth.forgot.title_otp` | Kodu yaz | Введите код | Enter the code |
| `auth.forgot.title_password` | Yeni şifrə | Новый пароль | New password |
| `auth.forgot.verify` | Təsdiqlə | Подтвердить | Confirm |
| `auth.guest` | Qonaq | Гость | Guest |
| `auth.login` | Daxil ol | Войти | Log in |
| `auth.login.contact_support` | Dəstək ilə əlaqə | Связаться с поддержкой | Contact support |
| `auth.login.email_hint` | ad@nümunə.com | имя@пример.com | name@example.com |
| `auth.login.forgot_password` | Şifrənizi unutmusunuz? | Забыли пароль? | Forgot your password? |
| `auth.login.no_account` | Hesabın yoxdur?  | Нет аккаунта?  | Don't have an account?  |
| `auth.login.password_label` | Şifrə | Пароль | Password |
| `auth.login.remember_me` | Məni xatırla | Запомнить меня | Remember me |
| `auth.login.subtitle` | Hesabına daxil ol | Войдите в аккаунт | Log in to your account |
| `auth.login.welcome` | Xoş gəldin | Добро пожаловать | Welcome |
| `auth.or` | və ya | или | or |
| `auth.register` | Qeydiyyatdan keç | Зарегистрироваться | Sign up |
| `auth.register.confirm_password_hint` | Təkrar yaz | Повторите ввод | Re-enter |
| `auth.register.confirm_password_label` | Şifrəni təsdiqlə | Подтвердите пароль | Confirm password |
| `auth.register.email_hint` | ad@nümunə.com | имя@пример.com | name@example.com |
| `auth.register.first_name` | Ad | Имя | First name |
| `auth.register.first_name_hint` | Tahir | Иван | John |
| `auth.register.have_account` | Hesabın var?  | Уже есть аккаунт?  | Already have an account?  |
| `auth.register.languages_label` | Danışdığın dillər | Языки, на которых вы говорите | Languages you speak |
| `auth.register.last_name` | Soyad | Фамилия | Last name |
| `auth.register.last_name_hint` | Quliyev | Иванов | Doe |
| `auth.register.password_hint` | Minimum 8 simvol | Минимум 8 символов | Minimum 8 characters |
| `auth.register.password_label` | Şifrə | Пароль | Password |
| `auth.register.privacy_policy` | Məxfilik siyasəti | Политика конфиденциальности | Privacy policy |
| `auth.register.subtitle` | Bir neçə addımda qoşul | Присоединяйтесь за пару шагов | Join in a few steps |
| `auth.register.terms_prefix` | İstifadə qaydaları və  | Условия использования и  | Terms of use and  |
| `auth.register.terms_suffix` |  ilə tanış oldum. |  — ознакомлен(а). |  — I have read and agree. |
| `auth.register.title` | Hesab yarat | Создать аккаунт | Create account |
| `auth.verify.body` | {email} ünvanına təsdiq linki göndərdik. Linkə klikləyib hesabını aktivləşdir. | Мы отправили ссылку для подтверждения на {email}. Перейдите по ней, чтобы активировать аккаунт. | We sent a verification link to {email}. Tap the link to activate your account. |
| `auth.verify.check_spam` | Məktub gəlmədi? Spam qovluğunu yoxla. | Письмо не пришло? Проверьте папку «Спам». | Didn't get the email? Check your spam folder. |
| `auth.verify.link_sent` | Təsdiq linki email-inizə göndərildi. | Ссылка для подтверждения отправлена на вашу почту. | A verification link has been sent to your email. |
| `auth.verify.resend` | Linki yenidən göndər | Отправить ссылку снова | Resend link |
| `auth.verify.send_failed` | Təsdiq linkini göndərmək mümkün olmadı. | Не удалось отправить ссылку для подтверждения. | Couldn't send the verification link. |
| `auth.verify.title` | Email-ini təsdiqlə | Подтвердите email | Verify your email |
| `auth.welcome.tagline` | Səyahət et, bağlama daşı, qazan. Etibarlı crowdshipping icması. | Путешествуй, вози посылки, зарабатывай. Надёжное сообщество crowdshipping. | Travel, carry parcels, earn. A trusted crowdshipping community. |

## block  (16)

| key | AZ | RU | EN |
|---|---|---|---|
| `block.cancel` | İmtina et | Отмена | Cancel |
| `block.confirm.action` | Bloku aç | Разблокировать | Unblock |
| `block.confirm.body` | :name yenidən sizə mesaj yaza və elanlarınıza baxa biləcək. | :name снова сможет писать вам и просматривать ваши объявления. | :name will be able to message you and view your listings again. |
| `block.confirm.title` | Bloku açmaq? | Разблокировать? | Unblock? |
| `block.count` | Cəmi :count istifadəçi | Всего :count пользователей | :count users total |
| `block.empty.body` | Kimisə bloklasanız, burada görünəcək. Söhbətdə və ya profildə «Blokla» ilə bloklaya bilərsiniz. | Когда вы кого-то заблокируете, он появится здесь. Заблокировать можно из чата или профиля через «Заблокировать». | When you block someone, they'll appear here. You can block from a chat or profile using «Block». |
| `block.empty.title` | Bloklanmış istifadəçi yoxdur | Нет заблокированных пользователей | No blocked users |
| `block.error.body` | İnternet bağlantısını yoxlayıb yenidən cəhd edin. | Проверьте подключение к интернету и повторите попытку. | Check your internet connection and try again. |
| `block.error.title` | Yüklənmədi | Не удалось загрузить | Couldn't load |
| `block.loading_more` | Yüklənir… | Загрузка… | Loading… |
| `block.retry` | Yenidən cəhd et | Повторить | Try again |
| `block.subtitle` | Blokladığınız istifadəçilər sizə mesaj yaza və elanlarınıza baxa bilməz. | Заблокированные вами пользователи не могут писать вам и просматривать ваши объявления. | Users you've blocked can't message you or view your listings. |
| `block.title` | Bloklanmış istifadəçilər | Заблокированные пользователи | Blocked users |
| `block.unblock` | Blokdan çıxar | Разблокировать | Unblock |
| `block.unblock_success` | Blok götürüldü. | Пользователь разблокирован. | User unblocked. |
| `block.unblocking` | Açılır… | Разблокировка… | Unblocking… |

## chat  (116)

| key | AZ | RU | EN |
|---|---|---|---|
| `chat.action.archive` | Arxivlə | В архив | Archive |
| `chat.action.block` | Blokla | Заблокировать | Block |
| `chat.action.delete` | Söhbəti sil | Удалить чат | Delete chat |
| `chat.action.pin` | Söhbəti sabitlə | Закрепить чат | Pin chat |
| `chat.action.profile` | Profilə bax | Смотреть профиль | View profile |
| `chat.action.unarchive` | Arxivdən çıxar | Из архива | Unarchive |
| `chat.action.unblock` | Bloku aç | Разблокировать | Unblock |
| `chat.action.unpin` | Sabitdən çıxar | Открепить | Unpin |
| `chat.attach.image` | Şəkil | Фото | Photo |
| `chat.cancel_reason.counterpart_unresponsive` | Qarşı tərəf cavab vermir | Другая сторона не отвечает | The other party isn't responding |
| `chat.cancel_reason.found_another` | Başqa variant tapdım | Нашёл другой вариант | Found another option |
| `chat.cancel_reason.other` | Digər | Другое | Other |
| `chat.cancel_reason.plans_changed` | Planlar dəyişdi | Планы изменились | Plans changed |
| `chat.cancel_reason.terms_disagreement` | Şərtlərlə razılaşmadıq | Не сошлись в условиях | Couldn't agree on terms |
| `chat.card.action_accept` | Qəbul | Принять | Accept |
| `chat.card.action_counter` | Dəyiş | Изменить | Change |
| `chat.card.action_decline` | Rədd | Отклонить | Decline |
| `chat.card.cancel_reason` | Səbəb: {reason} | Причина: {reason} | Reason: {reason} |
| `chat.card.cancelled` | Sövdələşmə ləğv edildi | Сделка отменена | Deal cancelled |
| `chat.card.cancelled_title` | Sövdələşmə ləğv edildi | Сделка отменена | Deal cancelled |
| `chat.card.completed` | Sövdələşmə tamamlandı | Сделка завершена | Deal completed |
| `chat.card.completed_title` | Sövdələşmə tamamlandı | Сделка завершена | Deal completed |
| `chat.card.disputed_title` | Problem bildirildi | Сообщено о проблеме | Problem reported |
| `chat.card.pending_badge` | gözlənilir | ожидается | pending |
| `chat.card.proposal_incoming` | Çatdırılma təklifi | Предложение о доставке | Delivery offer |
| `chat.card.proposal_received` | Çatdırılma təklifi | Предложение о доставке | Delivery offer |
| `chat.card.proposal_sent` | Təklifin göndərildi | Предложение отправлено | Offer sent |
| `chat.card.reason_prefix` | Səbəb | Причина | Reason |
| `chat.card.review` | Rəy | Отзыв | Review |
| `chat.card.review_action` | Rəy | Отзыв | Review |
| `chat.card.support` | Dəstək | Поддержка | Support |
| `chat.card.support_action` | Dəstək | Поддержка | Support |
| `chat.card.waiting_badge` | gözlənilir | ожидание | pending |
| `chat.card_label.accepted` | Təklif qəbul edildi | Предложение принято | Offer accepted |
| `chat.card_label.auto_completed` | Avtomatik tamamlandı | Завершено автоматически | Auto-completed |
| `chat.card_label.cancelled` | Ləğv edildi | Отменено | Cancelled |
| `chat.card_label.completed` | Sövdələşmə tamamlandı | Сделка завершена | Deal completed |
| `chat.card_label.declined` | Təklif rədd edildi | Предложение отклонено | Offer declined |
| `chat.card_label.default` | Təklif | Предложение | Offer |
| `chat.card_label.delivered` | Çatdırıldı | Доставлено | Delivered |
| `chat.card_label.disputed` | Problem bildirildi | Сообщено о проблеме | Problem reported |
| `chat.card_label.expired` | Vaxtı keçdi | Срок истёк | Expired |
| `chat.card_label.picked_up` | Mal götürüldü | Товар забран | Picked up |
| `chat.counter.note` | Qeyd | Заметка | Note |
| `chat.counter.note_hint` | Şərti izah et... | Опишите условия... | Explain the terms... |
| `chat.counter.note_optional` | istəyə bağlı | необязательно | optional |
| `chat.counter.price` | Ümumi qiymət | Общая цена | Total price |
| `chat.counter.submit` | Yeni təklif göndər | Отправить новое предложение | Send new offer |
| `chat.counter.title` | Təklifi dəyiş | Изменить предложение | Change offer |
| `chat.counter.weight` | Çəki | Вес | Weight |
| `chat.empty_archive_subtitle` | Arxivləşmiş söhbətlər burada görünəcək. | Архивированные чаты появятся здесь. | Archived chats will appear here. |
| `chat.empty_archive_title` | Arxiv boşdur | Архив пуст | Archive is empty |
| `chat.empty_subtitle` | Elan sahibinə Mesaj və ya Təklif göndər yazanda söhbət burada görünəcək. | Когда вы отправите владельцу объявления «Сообщение» или «Предложение», чат появится здесь. | When you send a Message or Offer to a listing owner, the chat will appear here. |
| `chat.empty_title` | Hələ söhbətin yoxdur | У вас пока нет чатов | You don't have any chats yet |
| `chat.go_to_chat` | Söhbətə keç | Перейти в чат | Go to chat |
| `chat.image.too_large` | Şəklin ölçüsü 30 MB-dan çox ola bilməz. | Размер изображения не может превышать 30 МБ. | Image size can't exceed 30 MB. |
| `chat.image.unsupported` | Yalnız JPG, PNG və WEBP şəkilləri dəstəklənir. | Поддерживаются только изображения JPG, PNG и WEBP. | Only JPG, PNG and WEBP images are supported. |
| `chat.input.blocked` | Bu istifadəçiyə mesaj göndərə bilməzsən | Вы не можете писать этому пользователю | You can't message this user |
| `chat.input.blocked_by_me` | Bu istifadəçini blokladın. Mesaj göndərə bilməzsən. | Вы заблокировали этого пользователя. Отправка сообщений недоступна. | You've blocked this user. You can't send messages. |
| `chat.input.placeholder` | Mesaj yaz... | Напишите сообщение... | Write a message... |
| `chat.list.title` | Söhbətlər | Чаты | Chats |
| `chat.message.copy` | Kopyala | Копировать | Copy |
| `chat.message.delete` | Sil | Удалить | Delete |
| `chat.message.edit` | Redaktə et | Изменить | Edit |
| `chat.message.edited` | redaktə edildi | изменено | edited |
| `chat.message.reply` | Cavabla | Ответить | Reply |
| `chat.message.retry` | Yenidən cəhd | Повторить | Retry |
| `chat.open_error` | Söhbəti açmaq alınmadı. | Не удалось открыть чат. | Couldn't open the chat. |
| `chat.package.clothing` | Geyim | Одежда | Clothing |
| `chat.package.documents` | Sənədlər | Документы | Documents |
| `chat.package.electronics` | Elektronika | Электроника | Electronics |
| `chat.package.food` | Qida | Еда | Food |
| `chat.package.other` | Digər | Другое | Other |
| `chat.package.small_parcel` | Kiçik bağlama | Небольшая посылка | Small parcel |
| `chat.pinbar.accepted_carrier` | Malı göndərəndən götürün | Заберите товар у отправителя | Pick up the item from the sender |
| `chat.pinbar.accepted_sender` | Daşıyıcı malı götürəcək | Курьер заберёт товар | The carrier will pick up the item |
| `chat.pinbar.awaiting_reply` | Cavab gözlənilir | Ожидается ответ | Awaiting reply |
| `chat.pinbar.completed` | Rəy yazın — təcrübəni bölüşün | Оставьте отзыв — поделитесь опытом | Leave a review — share your experience |
| `chat.pinbar.delivered` | Malı aldınızsa təsdiqləyin | Подтвердите, если получили товар | Confirm if you received the item |
| `chat.pinbar.disputed` | Araşdırılır | На рассмотрении | Under review |
| `chat.pinbar.picked_up` | Yolda | В пути | On the way |
| `chat.pinbar.status.accepted` | Qəbul olundu | Принято | Accepted |
| `chat.pinbar.status.auto_completed` | Avtomatik tamamlandı | Завершено автоматически | Auto-completed |
| `chat.pinbar.status.completed` | Tamamlandı | Завершено | Completed |
| `chat.pinbar.status.default` | Sövdələşmə | Сделка | Deal |
| `chat.pinbar.status.delivered` | Çatdırıldı | Доставлено | Delivered |
| `chat.pinbar.status.disputed` | Mübahisəli | Спорная | Disputed |
| `chat.pinbar.status.picked_up` | Mal götürüldü | Товар забран | Picked up |
| `chat.pinbar.status.proposal_pending` | Təklif gözləyir | Ожидает предложения | Offer pending |
| `chat.pinbar.your_turn` | Sizin növbəniz — cavab verin | Ваш ход — ответьте | Your turn — respond |
| `chat.profile.unavailable` | Profil məlumatı tapılmadı. | Данные профиля не найдены. | Profile not found. |
| `chat.proposal.counter` | Dəyiş | Изменить | Counter |
| `chat.proposal.decline` | Rədd | Отклонить | Decline |
| `chat.reply.replying_to` | ${reply.authorName}-ə cavab | Ответ {name} | Reply to {name} |
| `chat.review.comment` | Şərhinizi yazın | Напишите комментарий | Write your comment |
| `chat.review.comment_label` | Şərhiniz | Ваш комментарий | Your comment |
| `chat.review.r1` | Çox pis | Очень плохо | Very bad |
| `chat.review.r2` | Pis | Плохо | Bad |
| `chat.review.r3` | Normal | Нормально | Okay |
| `chat.review.r4` | Yaxşı | Хорошо | Good |
| `chat.review.r5` | Əla | Отлично | Excellent |
| `chat.review.subtitle` | Təcrübəni qiymətləndir | Оцените опыт | Rate your experience |
| `chat.review.title` | Rəy yaz | Оставить отзыв | Write a review |
| `chat.search.empty` | Heç nə tapılmadı | Ничего не найдено | Nothing found |
| `chat.search.hint` | Axtar... | Поиск... | Search... |
| `chat.shipment.cancel` | Sövdələşməni ləğv et | Отменить сделку | Cancel the deal |
| `chat.shipment.cancel_hint` | Ləğv səbəbini yazın | Укажите причину отмены | Enter the cancellation reason |
| `chat.shipment.dispute` | Problem bildir | Сообщить о проблеме | Report a problem |
| `chat.shipment.dispute_hint` | Nə baş verdiyini yazın | Опишите, что произошло | Describe what happened |
| `chat.shipment.reason` | Səbəbi yaz | Укажите причину | Describe the reason |
| `chat.tab.all` | Hamısı | Все | All |
| `chat.tab.archive` | Arxiv | Архив | Archive |
| `chat.thread.empty_subtitle` | {name} ilə hələ yazışmamısan. Salamla və detalları soruş. | Вы ещё не переписывались с {name}. Поздоровайтесь и уточните детали. | You haven't messaged {name} yet. Say hi and ask for details. |
| `chat.thread.empty_title` | Söhbətə başla | Начните переписку | Start the conversation |
| `chat.typing` | yazır... | печатает... | typing... |
| `chat.user_not_found` | İstifadəçi məlumatı tapılmadı. | Данные пользователя не найдены. | User details not found. |

## common  (37)

| key | AZ | RU | EN |
|---|---|---|---|
| `common.all` | Hamısı | Все | All |
| `common.back` | Geri | Назад | Back |
| `common.cancel` | İmtina et | Отмена | Cancel |
| `common.close` | Bağla | Закрыть | Close |
| `common.collapse` | Yığ | Свернуть | Collapse |
| `common.coming_soon` | {label} tezliklə aktiv olacaq. | {label} скоро станет доступно. | {label} will be available soon. |
| `common.confirm` | Təsdiq et | Подтвердить | Confirm |
| `common.continue` | Davam et | Продолжить | Continue |
| `common.delete` | Sil | Удалить | Delete |
| `common.edit` | Düzəliş | Изменить | Edit |
| `common.error` | Xəta baş verdi. Yenidən cəhd edin. | Произошла ошибка. Попробуйте снова. | Something went wrong. Please try again. |
| `common.load_failed_generic` | Məlumatı yükləyə bilmədik. İnternet bağlantını yoxla. | Не удалось загрузить данные. Проверьте подключение к интернету. | Couldn't load data. Check your internet connection. |
| `common.month_abbr` | ['Yan','Fev','Mar','Apr','May','İyun','İyul','Avq','Sen','Okt','Noy','Dek'] | — | — |
| `common.more` | Ətraflı | Подробнее | More |
| `common.no_connection` | Bağlantı yoxdur | Нет подключения | No connection |
| `common.note` | Qeyd | Заметка | Note |
| `common.operation_completed` | Əməliyyat tamamlandı | Операция завершена | Operation completed |
| `common.operation_failed` | Əməliyyat alınmadı. | Не удалось выполнить операцию. | Something went wrong. |
| `common.optional` | İstəyə bağlı | Необязательно | Optional |
| `common.pause` | Dayandır | Приостановить | Pause |
| `common.refresh` | Yenilə | Обновить | Refresh |
| `common.request_error` | Sorğu xətası | Ошибка запроса | Request error |
| `common.reset` | Sıfırla | Сбросить | Reset |
| `common.retry` | Yenidən cəhd et | Повторить попытку | Try again |
| `common.save` | Yadda saxla | Сохранить | Save |
| `common.send` | Göndər | Отправить | Send |
| `common.something_went_wrong` | Xəta baş verdi. Yenidən cəhd edin. | Произошла ошибка. Повторите попытку. | Something went wrong. Try again. |
| `common.time_days` | {n} gün | {n} дн. | {n}d |
| `common.time_hours` | {n} saat | {n} ч. | {n}h |
| `common.time_now` | indi | сейчас | now |
| `common.time_weeks` | {n} həftə | {n} нед. | {n}w |
| `common.today` | Bu gün | Сегодня | Today |
| `common.unit_kg` | kq | кг | kg |
| `common.user` | İstifadəçi | Пользователь | User |
| `common.wait` | Gözləyin... | Подождите... | Please wait... |
| `common.yesterday` | Dünən | Вчера | Yesterday |
| `common.you` | Siz | Вы | You |

## create  (57)

| key | AZ | RU | EN |
|---|---|---|---|
| `create.chip.delivery_range` | Çatdırılma aralığı | Срок доставки | Delivery window |
| `create.chip.empty_weight` | Boş çəki | Свободный вес | Free weight |
| `create.chip.flight_date` | Uçuş tarixi | Дата вылета | Flight date |
| `create.chip.package_type` | Bağlama növü | Тип посылки | Package type |
| `create.chip.price_per_kg` | 1 kq qiyməti | Цена за 1 кг | Price per kg |
| `create.chip.weight` | Çəki | Вес | Weight |
| `create.delivery_range` | Çatdırılma aralığı | Срок доставки | Delivery window |
| `create.empty_weight` | Boş çəki | Свободный вес | Free weight |
| `create.empty_weight_helper` | Aparacağın maksimum çəki — limit 32 kq. | Максимальный вес, который повезёшь — лимит 32 кг. | Maximum weight you can carry — limit 32 kg. |
| `create.flight_date` | Uçuş tarixi | Дата вылета | Flight date |
| `create.flight_number` | Reys nömrəsi | Номер рейса | Flight number |
| `create.flight_number_helper` | Sərnişinlərə etibar üçün — maks 8 simvol. | Для доверия пассажиров — макс. 8 символов. | For passenger trust — max 8 characters. |
| `create.flight_number_hint` | məs. J2 5432 | напр. J2 5432 | e.g. J2 5432 |
| `create.flight_time` | Saat | Время | Time |
| `create.free_after_review` | Pulsuz · yoxlanışdan sonra dərc olunur | Бесплатно · публикуется после проверки | Free · published after review |
| `create.go_preview` | Önizləməyə keç | К предпросмотру | Go to preview |
| `create.negotiable` | Qiymətdə danışıq olar | Цена договорная | Price negotiable |
| `create.note_hint` | Nə götürə bilərsən, şərtlər, əlaqə vaxtı... | Что можешь взять, условия, время связи... | What you can take, terms, contact time... |
| `create.note_label` | Qeyd · istəyə bağlı | Заметка · необязательно | Note · optional |
| `create.package_min_one` | Ən azı 1 | Минимум 1 | At least 1 |
| `create.package_select` | Bağlama növü | Тип посылки | Package type |
| `create.package_selected_count` | {count} seçildi | Выбрано: {count} | {count} selected |
| `create.package_type_title` | Hansı bağlamaları götürürsən? | Какие посылки берёшь? | Which packages will you take? |
| `create.package_weight` | Bağlamanın çəkisi | Вес посылки | Package weight |
| `create.preview_section` | Elanın belə görünəcək | Так будет выглядеть твоё объявление | Here's how your listing will look |
| `create.preview_title` | Önizləmə | Предпросмотр | Preview |
| `create.price_helper` | Maksimum 99 $/kq. | Максимум 99 $/кг. | Maximum $99/kg. |
| `create.price_per_kg` | Qiymət (1 kq üçün) | Цена (за 1 кг) | Price (per kg) |
| `create.publish` | Dərc et | Опубликовать | Publish |
| `create.publishing` | Dərc olunur... | Публикуется... | Publishing... |
| `create.quick_select` | Tez seçim | Быстрый выбор | Quick select |
| `create.route_shipment_title` | Haradan hara göndərirsən? | Откуда и куда отправляешь? | Where are you sending from and to? |
| `create.route_subtitle` | Şəhərləri seç — sistem uyğun göndərişləri tapacaq. | Выбери города — система найдёт подходящие отправления. | Pick the cities — the system will find matching shipments. |
| `create.route_trip_title` | Haradan hara uçursan? | Откуда и куда летишь? | Where are you flying from and to? |
| `create.shipment_description` | Bağlamam var, aparacaq səyahətçi axtarıram — çatdırılma aralığı seçirəm. | У меня есть посылка, ищу путешественника — выбираю срок доставки. | I have a parcel and I'm looking for a traveler — I pick a delivery window. |
| `create.shipment_details_title` | Göndəriş detalları | Детали отправки | Shipment details |
| `create.shipment_title` | Göndəriş elanı | Объявление об отправке | Shipment listing |
| `create.step_details` | Detallar | Детали | Details |
| `create.step_preview` | Önizləmə | Предпросмотр | Preview |
| `create.step_route` | Marşrut | Маршрут | Route |
| `create.step_template` | Addım {step}/{total} | Шаг {step}/{total} | Step {step}/{total} |
| `create.success_matches_shipments` | {count} göndəriş səni gözləyir | {count} посылок ждут вас | {count} shipments are waiting for you |
| `create.success_matches_travelers` | {count} səyahətçi səni gözləyir | {count} путешественников ждут вас | {count} travelers are waiting for you |
| `create.success_my_listings` | Elanlarım | Мои объявления | My listings |
| `create.success_new_listing` | Yeni elan | Новое объявление | New listing |
| `create.success_quota_shipment` | 3 aktiv göndəriş elanı limitindən {used}-i istifadədə | Использовано {used} из 3 активных объявлений о посылке | {used} of 3 active shipment listings in use |
| `create.success_quota_trip` | 3 aktiv səfər elanı limitindən {used}-i istifadədə | Использовано {used} из 3 активных объявлений о поездке | {used} of 3 active trip listings in use |
| `create.success_remaining_shipment` | Daha {count} göndəriş elanı yarada bilərsən | Можно создать ещё {count} объявлений о посылке | You can create {count} more shipment listings |
| `create.success_remaining_trip` | Daha {count} səfər elanı yarada bilərsən | Можно создать ещё {count} объявлений о поездке | You can create {count} more trip listings |
| `create.success_subtitle` | Moderasiyadan keçdikdən sonra Kəşf lentində görünəcək — adətən bir neçə dəqiqə çəkir. | После модерации оно появится в ленте «Обзор» — обычно это занимает несколько минут. | Once it passes moderation, it will appear in the Discover feed — usually within a few minutes. |
| `create.success_title` | Elan yoxlanışa göndərildi | Объявление отправлено на проверку | Listing sent for review |
| `create.success_view_shipments` | Uyğun göndərişlərə bax | Смотреть подходящие посылки | View matching shipments |
| `create.success_view_travelers` | Uyğun səyahətçilərə bax | Смотреть подходящих путешественников | View matching travelers |
| `create.title` | Yeni elan | Новое объявление | New listing |
| `create.trip_description` | Səyahət edirəm, çantamda yer var — çəki və qiymət təyin edirəm. | Я путешествую, в багаже есть место — указываю вес и цену. | I'm traveling and have space in my bag — I set the weight and price. |
| `create.trip_details_title` | Səfər detalları | Детали поездки | Trip details |
| `create.trip_title` | Səfər elanı | Объявление о поездке | Trip listing |

## deals  (102)

| key | AZ | RU | EN |
|---|---|---|---|
| `deals.action.accept` | Qəbul et | Принять | Accept |
| `deals.action.browse` | Digər daşıyıcılara bax | Другие перевозчики | Browse other couriers |
| `deals.action.cancel` | Ləğv et | Отменить | Cancel |
| `deals.action.chat` | Söhbətə keç | Перейти в чат | Open chat |
| `deals.action.complete` | Malı aldım, təsdiqlə | Получил товар, подтвердить | Received, confirm |
| `deals.action.counter` | Qarşı təklif | Встречное предложение | Counter-offer |
| `deals.action.decline` | Rədd et | Отклонить | Decline |
| `deals.action.delivered` | Çatdırdım | Доставлено | Delivered |
| `deals.action.dispute` | Problem bildir | Сообщить о проблеме | Report a problem |
| `deals.action.picked_up` | Malı götürdüm | Забрал товар | Picked up |
| `deals.action.repropose` | Yenidən təklif et | Предложить снова | Propose again |
| `deals.action.review` | Rəy yaz | Оставить отзыв | Write a review |
| `deals.action.withdraw` | Təklifi geri götür | Отозвать предложение | Withdraw offer |
| `deals.active_badge_template` | {count} aktiv | {count} активн. | {count} active |
| `deals.auto_complete_hint` | 3 gün ərzində təsdiq etməsəniz, sövdələşmə avtomatik tamamlanacaq. | Если не подтвердите в течение 3 дней, сделка завершится автоматически. | If you don’t confirm within 3 days, the deal will complete automatically. |
| `deals.auto_completed_note` | Mal çatdırıldıqdan 3 gün sonra göndərən təsdiq etmədiyi üçün sövdələşmə avtomatik tamamlandı. Rəy yaza bilərsiniz. | Отправитель не подтвердил в течение 3 дней после доставки, поэтому сделка завершилась автоматически. Вы можете оставить отзыв. | The sender didn’t confirm within 3 days of delivery, so the deal completed automatically. You can leave a review. |
| `deals.awaiting_reply` | Cavab gözlənilir | Ожидается ответ | Awaiting reply |
| `deals.cancel.hint` | Səbəbi seçin — qarşı tərəfə bildiriləcək. | Выберите причину — другая сторона получит уведомление. | Choose a reason — the other side will be notified. |
| `deals.cancel.reason_label` | Ləğv səbəbi | Причина отмены | Cancellation reason |
| `deals.cancel.title` | Sövdələşməni ləğv et | Отменить сделку | Cancel deal |
| `deals.coming_soon` | Tezliklə aktiv olacaq. | Скоро будет доступно. | Coming soon. |
| `deals.confirm.complete.title` | Malı aldığınızı təsdiqləyirsiniz? | Подтверждаете, что получили товар? | Confirm that you received the item? |
| `deals.confirm.delivered.title` | Çatdırdığınızı təsdiqləyirsiniz? | Подтверждаете доставку? | Confirm delivery? |
| `deals.confirm.irreversible_body` | Bu əməldən sonra sövdələşmə tamamlanmış sayılacaq və geri qaytarıla bilməz. | После этого действия сделка будет считаться завершённой и её нельзя отменить. | After this action the deal is considered complete and can’t be undone. |
| `deals.confirm.no` | İmtina | Отмена | Cancel |
| `deals.confirm.picked_up.title` | Malı götürdüyünüzü təsdiqləyirsiniz? | Подтверждаете, что забрали товар? | Confirm that you picked up the item? |
| `deals.confirm.yes` | Bəli, təsdiqlə | Да, подтвердить | Yes, confirm |
| `deals.confirm_receipt_hint` | Malı aldınız? Təsdiqləyin | Получили товар? Подтвердите | Received the item? Confirm |
| `deals.counter.hint` | Şərtləri dəyişib göndər — qarşı tərəf təsdiqləyəcək. | Измените условия и отправьте — другая сторона подтвердит. | Change the terms and send — the other side will confirm. |
| `deals.counter.submit` | Qarşı təklifi göndər | Отправить встречное предложение | Send counter-offer |
| `deals.counter.title` | Qarşı təklif | Встречное предложение | Counter-offer |
| `deals.detail_title.picked_up` | Mal yoldadır | Товар в пути | Item on the way |
| `deals.dispute.admin_note` | Komandamız hər iki tərəflə əlaqə saxlayacaq. Söhbətdə əlavə məlumat verə bilərsiniz. | Наша команда свяжется с обеими сторонами. Вы можете добавить детали в чате. | Our team will contact both sides. You can add more details in the chat. |
| `deals.dispute.detail_hint` | Ətraflı izah edin… | Опишите подробнее… | Explain in detail… |
| `deals.dispute.hint` | Nə baş verdiyini yazın — admin araşdıracaq. Sövdələşmə «Mübahisəli» statusuna keçəcək. | Опишите, что произошло — админ разберётся. Сделка перейдёт в статус «Спорная». | Describe what happened — an admin will review it. The deal will move to "Disputed" status. |
| `deals.dispute.submit` | Problemi göndər | Отправить жалобу | Submit problem |
| `deals.dispute.title` | Problem bildir | Сообщить о проблеме | Report a problem |
| `deals.dispute_reason.damaged` | Mal zədəli / əskik | Товар повреждён / неполный | Item damaged / incomplete |
| `deals.dispute_reason.lost_contact` | Əlaqə kəsildi | Связь потеряна | Lost contact |
| `deals.dispute_reason.not_arrived` | Mal çatmadı | Товар не доставлен | Item not delivered |
| `deals.dispute_reason.other` | Digər | Другое | Other |
| `deals.empty.body` | Bir elana təklif göndərin və ya birbaşa söhbətdə razılaşın — sövdələşmələr burada görünəcək. | Отправьте предложение по объявлению или договоритесь прямо в чате — сделки появятся здесь. | Send an offer on a listing or agree directly in chat — your deals will appear here. |
| `deals.empty.cta` | Elanlara bax | Смотреть объявления | Browse listings |
| `deals.empty.title` | Hələ sövdələşməniz yoxdur | У вас пока нет сделок | You don’t have any deals yet |
| `deals.error.action_failed` | Əməliyyat alınmadı. Yenidən cəhd edin. | Не удалось выполнить действие. Попробуйте ещё раз. | Action failed. Please try again. |
| `deals.error.load` | Yüklənmədi. İnternet bağlantısını yoxlayın. | Не удалось загрузить. Проверьте интернет-соединение. | Failed to load. Check your internet connection. |
| `deals.error.profile_not_found` | Profil məlumatı tapılmadı. | Данные профиля не найдены. | Profile not found. |
| `deals.expired_note` | Təklifin cavab müddəti bitdi. Yenidən təklif göndərə bilərsiniz. | Срок ответа на предложение истёк. Вы можете отправить предложение снова. | The offer response window has expired. You can send a new offer. |
| `deals.expired_unanswered` | Cavabsız qaldı | Осталось без ответа | No response |
| `deals.filter.all` | Hamısı | Все | All |
| `deals.filter.carrier` | Daşıyıcı kimi | Как курьер | As carrier |
| `deals.filter.sender` | Göndərən kimi | Как отправитель | As sender |
| `deals.how_it_works` | Necə işləyir? | Как это работает? | How it works? |
| `deals.note_optional` | Qeyd (istəyə bağlı) | Заметка (необязательно) | Note (optional) |
| `deals.operation_failed` | Əməliyyat alınmadı. Yenidən cəhd edin. | Не удалось выполнить операцию. Попробуйте снова. | Operation failed. Please try again. |
| `deals.pending_expires_template` | Təklifin vaxtı: {date}-a qədər | Срок предложения: до {date} | Offer valid until {date} |
| `deals.reason_prefix` | Səbəb | Причина | Reason |
| `deals.retry` | Yenidən | Повторить | Retry |
| `deals.review.prompt` | Təcrübəni bir neçə sözlə yaz… | Опишите впечатление парой слов… | Describe your experience in a few words… |
| `deals.review.question_template` | {name} ilə təcrübən necə idi? | Как прошёл ваш опыт с {name}? | How was your experience with {name}? |
| `deals.review.sent` | Rəy göndərildi | Отзыв отправлен | Review submitted |
| `deals.review.submit` | Rəyi göndər | Отправить отзыв | Submit review |
| `deals.review.trait.careful` | Diqqətli | Внимательный | Careful |
| `deals.review.trait.on_time` | Vaxtında | Вовремя | On time |
| `deals.review.trait.polite` | Nəzakətli | Вежливый | Polite |
| `deals.review_sent` | Rəy göndərildi | Отзыв отправлен | Review sent |
| `deals.role.carrier` | Daşıyıcı | Курьер | Carrier |
| `deals.role.sender` | Göndərən | Отправитель | Sender |
| `deals.section.history` | Tarixçə | История | History |
| `deals.section.terms` | Şərtlər | Условия | Terms |
| `deals.step.accepted` | Qəbul | Принято | Accepted |
| `deals.step.delivered` | Çatdı | Доставлено | Delivered |
| `deals.step.done` | Bitdi | Готово | Done |
| `deals.step.picked_up` | Götürüldü | Забрано | Picked up |
| `deals.step.proposal` | Təklif | Предложение | Offer |
| `deals.sub.accepted_carrier` | Razılaşma bağlandı · malı göndərəndən götürün | Договорённость достигнута · заберите товар у отправителя | Deal agreed · pick up the item from the sender |
| `deals.sub.accepted_sender` | Razılaşma bağlandı · daşıyıcı malı götürəcək | Договорённость достигнута · курьер заберёт товар | Deal agreed · the carrier will pick up the item |
| `deals.sub.auto_completed` | Təsdiq müddəti bitdiyi üçün sistem bağladı | Закрыто системой по истечении срока подтверждения | Closed by the system after the confirmation window expired |
| `deals.sub.cancelled` | Sövdələşmə dayandırıldı | Сделка отменена | Deal cancelled |
| `deals.sub.completed` | Sövdələşmə uğurla bağlandı | Сделка успешно завершена | Deal closed successfully |
| `deals.sub.declined` | Təklif qəbul edilmədi | Предложение не принято | Offer wasn't accepted |
| `deals.sub.delivered_carrier` | Çatdırıldı · göndərənin təsdiqini gözləyin | Доставлено · дождитесь подтверждения отправителя | Delivered · wait for the sender’s confirmation |
| `deals.sub.delivered_sender` | Malı aldınızsa təsdiqləyin — sövdələşmə tamamlanacaq | Если получили товар, подтвердите — сделка завершится | If you’ve received the item, confirm — the deal will complete |
| `deals.sub.disputed` | Problem bildirildi · admin araşdırır | Проблема отправлена · рассматривает администратор | Issue reported · admin reviewing |
| `deals.sub.expired` | Təklif vaxtında cavablandırılmadı | Ответ на предложение не получен вовремя | Offer not answered in time |
| `deals.sub.pending_me` | Sizə yeni təklif gəlib — cavab verin | Вам поступило новое предложение — ответьте | You have a new offer — respond |
| `deals.sub.pending_them` | Təklifiniz göndərildi · qarşı tərəf cavab verməlidir | Ваше предложение отправлено · другая сторона должна ответить | Your offer was sent · the other side needs to respond |
| `deals.sub.picked_up_carrier` | Təyinat şəhərinə çatanda «Çatdırdım» seçin | По прибытии в город назначения нажмите «Доставлено» | On arrival in the destination city, tap "Delivered" |
| `deals.sub.picked_up_sender` | Mal yoldadır · daşıyıcı çatdırana qədər gözləyin | Товар в пути · дождитесь доставки курьером | Item on the way · wait for the carrier to deliver |
| `deals.tab.active` | Aktiv | Активные | Active |
| `deals.tab.history` | Tarixçə | История | History |
| `deals.terms.note` | Qeyd | Заметка | Note |
| `deals.terms.package` | Bağlama | Посылка | Package |
| `deals.terms.price` | Qiymət | Цена | Price |
| `deals.terms.trip_date` | Səfər | Поездка | Trip |
| `deals.terms.weight` | Çəki | Вес | Weight |
| `deals.timeline.completed` | Tamamlandı | Завершено | Completed |
| `deals.timeline.delivered` | Çatdırıldı | Доставлено | Delivered |
| `deals.timeline.picked_up` | Mal götürüldü | Товар забран | Item picked up |
| `deals.title` | Sövdələşmələrim | Мои сделки | My deals |
| `deals.title_short` | Sövdələşmə | Сделка | Deal |
| `deals.your_turn` | Sizin növbəniz — cavab verin | Ваш ход — ответьте | Your turn — respond |

## enum  (47)

| key | AZ | RU | EN |
|---|---|---|---|
| `enum.listing_delete_reason.created_by_mistake` | Səhvən yaratdım | Создал по ошибке | Created by mistake |
| `enum.listing_delete_reason.found_another` | Başqa variant tapdım | Нашёл другой вариант | Found another option |
| `enum.listing_delete_reason.no_longer_needed` | Artıq lazım deyil | Больше не нужно | No longer needed |
| `enum.listing_delete_reason.other` | Digər | Другое | Other |
| `enum.listing_delete_reason.plans_changed` | Planlarım dəyişdi | Планы изменились | My plans changed |
| `enum.listing_status.active` | Aktiv | Активно | Active |
| `enum.listing_type.shipment_post` | GÖNDƏRİŞ | Посылка | Shipment |
| `enum.listing_type.trip` | SƏFƏR | Поездка | Trip |
| `enum.listing_type_noun.shipment` | göndəriş | отправление | shipment |
| `enum.listing_type_noun.trip` | səfər | поездка | trip |
| `enum.package_type.clothing` | Geyim | Одежда | Clothing |
| `enum.package_type.documents` | Sənədlər | Документы | Documents |
| `enum.package_type.electronics` | Elektronika | Электроника | Electronics |
| `enum.package_type.food` | Qida | Еда | Food |
| `enum.package_type.other` | Digər | Другое | Other |
| `enum.package_type.small_parcel` | Kiçik bağlama | Маленькая посылка | Small parcel |
| `enum.payment_method.balance` | Wawatair balans | Баланс Wawatair | Wawatair balance |
| `enum.payment_method.card` | Bank kartı | Банковская карта | Bank card |
| `enum.promotion_type.featured` | Önə çıxarılan | Продвигаемое | Featured |
| `enum.promotion_type.vip` | VİP | VIP | VIP |
| `enum.report_reason_code.abuse` | Təhqir | Оскорбление | Abuse |
| `enum.report_reason_code.fake` | Saxta | Подделка | Fake |
| `enum.report_reason_code.fraud` | Fırıldaq | Мошенничество | Fraud |
| `enum.report_reason_code.inappropriate` | Uyğunsuz | Неприемлемо | Inappropriate |
| `enum.report_reason_code.other` | Digər | Другое | Other |
| `enum.report_reason_code.spam` | Spam | Спам | Spam |
| `enum.shipment_cancel_reason.counterpart_unresponsive` | Qarşı tərəf cavab vermir | Другая сторона не отвечает | The other party isn't responding |
| `enum.shipment_cancel_reason.found_another` | Başqa variant tapdım | Нашёл другой вариант | Found another option |
| `enum.shipment_cancel_reason.other` | Digər | Другое | Other |
| `enum.shipment_cancel_reason.plans_changed` | Planlar dəyişdi | Планы изменились | Plans changed |
| `enum.shipment_cancel_reason.terms_disagreement` | Şərtlərlə razılaşmadıq | Не договорились об условиях | Couldn't agree on terms |
| `enum.shipment_status.accepted` | Qəbul olundu | Принято | Accepted |
| `enum.shipment_status.auto_completed` | Avtomatik tamamlandı | Завершено автоматически | Auto-completed |
| `enum.shipment_status.cancelled` | Ləğv edildi | Отменено | Cancelled |
| `enum.shipment_status.completed` | Tamamlandı | Завершено | Completed |
| `enum.shipment_status.declined` | Rədd edildi | Отклонено | Declined |
| `enum.shipment_status.delivered` | Çatdırıldı | Доставлено | Delivered |
| `enum.shipment_status.disputed` | Mübahisəli | Спор | Disputed |
| `enum.shipment_status.expired` | Vaxtı keçdi | Истекло | Expired |
| `enum.shipment_status.picked_up` | Mal götürüldü | Груз забран | Picked up |
| `enum.shipment_status.proposal_pending` | Təklif gözləyir | Предложение на рассмотрении | Offer pending |
| `enum.user_tier.bronze` | Bürünc | Бронза | Bronze |
| `enum.user_tier.gold` | Qızıl | Золото | Gold |
| `enum.user_tier.new` | Yeni | Новичок | New |
| `enum.user_tier.platinum` | Platin | Платина | Platinum |
| `enum.user_tier.silver` | Gümüş | Серебро | Silver |
| `enum.user_tier.standard` | Standart | Стандарт | Standard |

## faq  (8)

| key | AZ | RU | EN |
|---|---|---|---|
| `faq.contact_subtitle` | Komandamız kömək etməyə hazırdır. | Наша команда готова помочь. | Our team is ready to help. |
| `faq.contact_title` | Cavab tapmadın? | Не нашли ответ? | Didn't find an answer? |
| `faq.empty` | Hələ sual yoxdur | Пока нет вопросов | No questions yet |
| `faq.load_failed` | FAQ yüklənmədi | Не удалось загрузить FAQ | Couldn't load FAQ |
| `faq.no_results` | «{query}» üzrə nəticə yoxdur | Нет результатов по «{query}» | No results for "{query}" |
| `faq.no_results_hint` | Başqa açar sözlə yoxla və ya dəstəyə yaz. | Попробуйте другое ключевое слово или напишите в поддержку. | Try another keyword or contact support. |
| `faq.search_hint` | Sualını axtar… | Поиск вопроса… | Search your question… |
| `faq.subtitle` | Suallarına cavab tap | Найдите ответы на свои вопросы | Find answers to your questions |

## favorites  (4)

| key | AZ | RU | EN |
|---|---|---|---|
| `favorites.empty_subtitle` | Bəyəndiyin elanları ürək işarəsi ilə burada saxla. | Отмечайте понравившиеся объявления сердечком, и они появятся здесь. | Tap the heart on listings you like to save them here. |
| `favorites.empty_title` | Hələ sevimli elan yoxdur | Пока нет избранных объявлений | No favorites yet |
| `favorites.subtitle` | Yadda saxladığın elanlar | Сохранённые объявления | Your saved listings |
| `favorites.title` | Sevimlilər | Избранное | Favorites |

## feed  (1)

| key | AZ | RU | EN |
|---|---|---|---|
| `feed.end` | Hamısı bu qədər | Это всё | That's everything |

## home  (7)

| key | AZ | RU | EN |
|---|---|---|---|
| `home.hero_subtitle` | Səyahət edənlərlə göndərənləri birləşdiririk | Соединяем путешественников и отправителей | Connecting travelers with senders |
| `home.hero_title` | Bağlamanı kim aparsın? | Кто доставит вашу посылку? | Who'll carry your parcel? |
| `home.route_price_from_template` | {price} $-dən | от {price} $ | from {price} $ |
| `home.route_travelers_template` | {count} səyahətçi | {count} путешественников | {count} travelers |
| `home.stats_deliveries_suffix` |  çatdırılma ·  |  доставок ·  |  deliveries ·  |
| `home.stats_prefix` | Bu ay | В этом месяце | This month |
| `home.stats_travelers_suffix` |  təsdiqlənmiş səyahətçi |  проверенных путешественников |  verified travelers |

## legal  (4)

| key | AZ | RU | EN |
|---|---|---|---|
| `legal.error.body` | Səhifəni yükləyə bilmədik. İnternet bağlantını yoxla. | Не удалось загрузить страницу. Проверьте подключение к интернету. | We couldn't load the page. Check your internet connection. |
| `legal.error.title` | Bağlantı yoxdur | Нет соединения | No connection |
| `legal.retry` | Yenidən cəhd et | Повторить | Try again |
| `legal.updated` | Yenilənib: {date} | Обновлено: {date} | Updated: {date} |

## limit  (2)

| key | AZ | RU | EN |
|---|---|---|---|
| `limit.active_count_prefix` | {active}/{limit} aktiv {noun} elanın var. | У вас {active}/{limit} активных объявлений «{noun}». | You have {active}/{limit} active {noun} listings. |
| `limit.increase_cta` | Limiti artır | Увеличить лимит | Increase limit |

## listing  (79)

| key | AZ | RU | EN |
|---|---|---|---|
| `listing.accepted_packages` | Qəbul olunan bağlamalar | Принимаемые посылки | Accepted packages |
| `listing.active_order_exists` | Bu söhbətdə artıq aktiv sifariş var. Davam etmək üçün mövcud söhbətə keç. | В этом чате уже есть активный заказ. Перейдите в существующий чат, чтобы продолжить. | There’s already an active order in this chat. Open the existing chat to continue. |
| `listing.avg_response` | Adətən ~{minutes} dəqiqəyə cavab verir | Обычно отвечает за ~{minutes} мин | Usually replies in ~{minutes} min |
| `listing.back_to_listing` | Elana qayıt | Вернуться к объявлению | Back to listing |
| `listing.completed_deliveries` | {count} çatdırılma | {count} доставок | {count} deliveries |
| `listing.delete_confirm_message` | Bu əməliyyat geri qaytarılmır. Davam etmək istəyirsən? | Это действие необратимо. Продолжить? | This can’t be undone. Continue? |
| `listing.delete_confirm_title` | Elanı sil? | Удалить объявление? | Delete listing? |
| `listing.delete_sheet_subtitle` | Silmə səbəbini seç. | Выберите причину удаления. | Choose a reason for deleting. |
| `listing.delete_sheet_title` | Elanı sil | Удалить объявление | Delete listing |
| `listing.deleted` | Elan silindi. | Объявление удалено. | Listing deleted. |
| `listing.description_label` | Təsvir | Описание | Description |
| `listing.detail_title` | Elan | Объявление | Listing |
| `listing.details_label` | Detallar | Детали | Details |
| `listing.edit_limited_active_deal` | Aktiv sövdələşmə olduğu üçün redaktə məhduddur. Silmək istəsəniz, əvvəl açıq sövdələşmələri həll edin. | Редактирование ограничено из-за активной сделки. Чтобы удалить, сначала завершите открытые сделки. | Editing is limited while there’s an active deal. To delete, resolve open deals first. |
| `listing.estimate_price_hint` | Təxmini qiyməti çəkiyə görə hesablaya bilərsən: {price} $/kq | Примерную цену можно рассчитать по весу: {price} $/кг | You can estimate the price by weight: {price} $/kg |
| `listing.fact_delivery` | Təhvil | Доставка | Delivery |
| `listing.fact_free_space` | Boş yer | Свободно | Free space |
| `listing.fact_published` | Dərc olunub | Опубликовано | Published |
| `listing.favorited` | Elan seçilmişlərə əlavə edildi. | Объявление добавлено в избранное. | Listing added to favorites. |
| `listing.fix` | Düzəlt | Исправить | Fix |
| `listing.flight_label` | Reys | Рейс | Flight |
| `listing.free_space` | Boş yer | Свободно | Free space |
| `listing.free_space_left` | {count} kq boş yer qalıb | Осталось {count} кг свободного места | {count} kg of space left |
| `listing.free_weight_hint` | Boş: {n} kq | Свободно: {n} кг | Free: {n} kg |
| `listing.free_weight_kg` | {kg} kq boş | {kg} кг свободно | {kg} kg free |
| `listing.fully_booked` | Yer yoxdur. | Мест нет. | No space left. |
| `listing.kg_free` | {n} kq boş | {n} кг свободно | {n} kg free |
| `listing.limit_reached_short` | Limit dolub | Лимит исчерпан | Limit reached |
| `listing.message_cta` | Mesaj | Сообщение | Message |
| `listing.my_listing_title` | Elanım | Моё объявление | My listing |
| `listing.negotiable` | Razılaşma | Договорная | Negotiable |
| `listing.negotiable_short` | Razılaşma | Договорная | Negotiable |
| `listing.no_space` | Yer yoxdur | Мест нет | No space |
| `listing.not_found_body` | Elan silinmiş, moderasiyada ola bilər və ya sənə açıq deyil. | Объявление удалено, находится на модерации или недоступно вам. | The listing was deleted, may be under review, or isn’t available to you. |
| `listing.not_found_title` | Elan tapılmadı | Объявление не найдено | Listing not found |
| `listing.note_hint` | Qısa mesaj yaz... | Напишите короткое сообщение... | Write a short message... |
| `listing.offer_failed` | Təklif göndərilmədi. Məlumatları yoxla və yenidən cəhd et. | Не удалось отправить предложение. Проверьте данные и попробуйте снова. | Offer wasn’t sent. Check the details and try again. |
| `listing.offer_sent` | Təklif göndərildi | Предложение отправлено | Offer sent |
| `listing.offer_sent_body` | {ownerName} təklifinizə baxıb cavab verəcək. Söhbətdən danışıqları davam etdirə bilərsiniz. | {ownerName} рассмотрит ваше предложение и ответит. Продолжить переговоры можно в чате. | {ownerName} will review your offer and reply. You can continue the conversation in chat. |
| `listing.package_label` | Bağlama | Посылка | Package |
| `listing.package_type` | Bağlama növü | Тип посылки | Package type |
| `listing.packages_label` | Bağlamalar | Посылки | Packages |
| `listing.pause_confirm_message` | Bu elan lentdən çıxacaq və istifadəçilər onu görməyəcək. Davam edək? | Объявление скроется из ленты и станет недоступно пользователям. Продолжить? | This listing will leave the feed and users won’t see it. Continue? |
| `listing.pause_confirm_title` | Elanı dayandır? | Приостановить объявление? | Pause listing? |
| `listing.paused` | Elan dayandırıldı. | Объявление приостановлено. | Listing paused. |
| `listing.price_label` | Qiymət | Цена | Price |
| `listing.price_negotiable` | Qiymət razılaşma ilə | Цена договорная | Price negotiable |
| `listing.reactivate` | Yenidən aktivləşdir | Активировать снова | Reactivate |
| `listing.remaining_template` | {count} qalıb | Осталось {count} | {count} left |
| `listing.report_sent` | Şikayət göndərildi. | Жалоба отправлена. | Report sent. |
| `listing.report_sheet_subtitle` | Səbəbi seç və ya qısa qeyd yaz. | Выберите причину или напишите короткую заметку. | Pick a reason or add a short note. |
| `listing.report_sheet_title` | Şikayət et | Пожаловаться | Report |
| `listing.repost` | Yenidən paylaş | Опубликовать снова | Repost |
| `listing.reserved` | Rezerv olunub | Забронировано | Reserved |
| `listing.response_short` | ~{minutes} dəq cavab | ~{minutes} мин ответ | ~{minutes} min reply |
| `listing.resume_confirm_message` | Elan yenidən lentdə görünəcək. Davam edək? | Объявление снова появится в ленте. Продолжить? | The listing will show in the feed again. Continue? |
| `listing.resume_confirm_title` | Elanı aktivləşdir? | Активировать объявление? | Activate listing? |
| `listing.resumed` | Elan yenidən aktivləşdirildi. | Объявление снова активно. | Listing reactivated. |
| `listing.send_offer` | Təklif göndər | Отправить предложение | Send offer |
| `listing.similar` | Oxşar elanlar | Похожие объявления | Similar listings |
| `listing.stat_favorited` | Seçilmiş | В избранном | Favorited |
| `listing.stat_favorites` | Sevimli | В избранном | Favorite |
| `listing.stat_free` | Boş | Свободно | Free |
| `listing.stat_views` | Baxış | Просмотры | Views |
| `listing.stat_weight` | Çəki | Вес | Weight |
| `listing.status_expired_message` | Uçuş tarixi keçdiyi üçün elan lentdən çıxıb. Yeni tarixlə yenidən paylaşa bilərsiniz. | Дата вылета прошла, поэтому объявление ушло из ленты. Опубликуйте его снова с новой датой. | The flight date has passed, so the listing left the feed. Repost it with a new date. |
| `listing.status_expired_title` | Vaxtı keçib | Истекло | Expired |
| `listing.status_moderation_message` | Elanınız yoxlanılır. Təsdiqlənəndən sonra lentdə görünəcək. | Ваше объявление проверяется. После одобрения появится в ленте. | Your listing is being reviewed. It’ll appear in the feed once approved. |
| `listing.status_moderation_title` | Moderasiyada | На модерации | Under review |
| `listing.status_paused_message` | Bu elan lentdə görünmür. İstənilən vaxt yenidən aktivləşdirə bilərsiniz. | Это объявление скрыто из ленты. Вы можете активировать его в любой момент. | This listing is hidden from the feed. You can reactivate it anytime. |
| `listing.status_paused_title` | Dayandırılıb | Приостановлено | Paused |
| `listing.status_rejected_message` | Səbəb: elan qaydalara uyğun deyil. Düzəliş edib yenidən göndərə bilərsiniz. | Причина: объявление не соответствует правилам. Исправьте и отправьте снова. | Reason: the listing doesn’t meet the rules. Fix it and resubmit. |
| `listing.status_rejected_title` | Rədd edildi | Отклонено | Rejected |
| `listing.total_price` | Ümumi qiymət | Общая цена | Total price |
| `listing.type_shipment` | Göndəriş | Отправление | Shipment |
| `listing.type_trip` | Səfər | Поездка | Trip |
| `listing.unfavorited` | Elan seçilmişlərdən çıxarıldı. | Объявление удалено из избранного. | Listing removed from favorites. |
| `listing.updated_moderation` | Elan yeniləndi və yenidən moderasiyaya göndərildi. | Объявление обновлено и отправлено на повторную модерацию. | Listing updated and sent back for review. |
| `listing.weight_label` | Çəki | Вес | Weight |

## listing_quota  (33)

| key | AZ | RU | EN |
|---|---|---|---|
| `listing_quota.badge.best_value` | Ən sərfəli | Выгодно | Best value |
| `listing_quota.cancel_payment` | Ödənişi ləğv et | Отменить оплату | Cancel payment |
| `listing_quota.confirm_title` | Ödənişi təsdiqlə | Подтвердите оплату | Confirm payment |
| `listing_quota.create_listing` | Elan yarat | Создать объявление | Create listing |
| `listing_quota.go_to_payment` | ödənişə keç | перейти к оплате | go to payment |
| `listing_quota.limit_full_subtitle` | Limiti artır və dərhal yenisini yarat. | Увеличьте лимит и сразу создайте новое. | Increase the limit and create a new one right away. |
| `listing_quota.limit_full_title.trip` | Aktiv {typeLabel} limitin dolub | Лимит активных «{typeLabel}» исчерпан | Your active {typeLabel} limit is full |
| `listing_quota.load_error` | Planlar yüklənmədi. Yenidən cəhd et. | Не удалось загрузить планы. Попробуйте снова. | Couldn’t load plans. Try again. |
| `listing_quota.new_limit` | Yeni limit | Новый лимит | New limit |
| `listing_quota.one_time` | bir dəfəlik · daimi limit | разово · постоянный лимит | one-time · permanent limit |
| `listing_quota.pause_instead` | və ya bir elanı dayandır | или приостановите одно объявление | or pause a listing instead |
| `listing_quota.pay_cta` | ödə və limiti artır | оплатить и увеличить лимит | pay and increase the limit |
| `listing_quota.pay_cta_empty` | Plan seç | Выберите план | Choose a plan |
| `listing_quota.payment_failed` | Ödəniş keçmədi | Оплата не прошла | Payment failed |
| `listing_quota.payment_failed_sub` | Məbləğ tutulmadı və limit dəyişmədi. Yenidən cəhd et. | Средства не списаны, лимит не изменён. Попробуйте снова. | No amount was charged and the limit didn’t change. Try again. |
| `listing_quota.payment_pending` | Ödəniş gözlənilir… | Ожидание оплаты… | Waiting for payment… |
| `listing_quota.payment_pending_sub` | Ödəniş səhifəsində əməliyyatı tamamla. Bitən kimi nəticəni avtomatik göstərəcəyik. | Завершите операцию на странице оплаты. Как только всё будет готово, мы автоматически покажем результат. | Complete the transaction on the payment page. We’ll show the result automatically once it’s done. |
| `listing_quota.per_listing_prefix` | elan başına | за объявление | per listing |
| `listing_quota.permanent_increase` | Daimi limit artımı | Постоянное увеличение лимита | Permanent limit increase |
| `listing_quota.plans_header` | Limiti artır | Увеличить лимит | Increase limit |
| `listing_quota.receipt.package` | Paket | Пакет | Package |
| `listing_quota.receipt.type` | Növ | Тип | Type |
| `listing_quota.refresh_status` | Statusu yenilə | Обновить статус | Refresh status |
| `listing_quota.retry` | Yenidən cəhd et | Попробовать снова | Try again |
| `listing_quota.secure_note` | Ödəniş təhlükəsiz provayder səhifəsində aparılır | Оплата проходит на защищённой странице провайдера | Payment is made on the provider’s secure page |
| `listing_quota.secure_redirect` | Növbəti addımda təhlükəsiz ödəniş səhifəsinə yönləndiriləcəksən. Ödənişi orada tamamla — nəticəni avtomatik alacağıq. | На следующем шаге вы перейдёте на защищённую страницу оплаты. Завершите оплату там — результат получим автоматически. | Next, you’ll be redirected to a secure payment page. Complete the payment there — we’ll get the result automatically. |
| `listing_quota.success_sub_prefix` | İndi daha | Теперь ещё | Now |
| `listing_quota.success_sub_suffix` | aktiv elan yarada bilərsən. | активных объявлений можно создать. | more active listings you can create. |
| `listing_quota.success_title` | Limitin artdı! | Лимит увеличен! | Your limit increased! |
| `listing_quota.test_mode` | Test rejimi — real məbləğ tutulmur (mock) | Тестовый режим — реальная сумма не списывается (mock) | Test mode — no real amount charged (mock) |
| `listing_quota.title` | Limiti artır | Увеличить лимит | Increase limit |
| `listing_quota.total` | Ümumi | Итого | Total |
| `listing_quota.view_receipt` | Qəbzə bax | Посмотреть чек | View receipt |

## menu  (44)

| key | AZ | RU | EN |
|---|---|---|---|
| `menu.about` | Tətbiq haqqında | О приложении | About the app |
| `menu.appearance` | Görünüş | Оформление | Appearance |
| `menu.blocked_users` | Bloklanmış istifadəçilər | Заблокированные пользователи | Blocked users |
| `menu.change_password` | Parolu dəyiş | Сменить пароль | Change password |
| `menu.connections` | İzləyicilər və izlədiklərim | Подписчики и подписки | Followers & following |
| `menu.contact_support` | Dəstəyə yaz | Написать в поддержку | Contact support |
| `menu.deals` | Sövdələşmələrim | Мои сделки | My deals |
| `menu.delete_account` | Hesabı sil | Удалить аккаунт | Delete account |
| `menu.edit_profile` | Profili redaktə et | Редактировать профиль | Edit profile |
| `menu.favorites` | Seçilmişlər | Избранное | Favorites |
| `menu.followers` | İzləyicilər | Подписчики | Followers |
| `menu.following` | İzlədiklərim | Подписки | Following |
| `menu.help` | Kömək & FAQ | Помощь и FAQ | Help & FAQ |
| `menu.invite` | Dostunu dəvət et | Пригласить друга | Invite a friend |
| `menu.language` | Dil | Язык | Language |
| `menu.language_subtitle` | Tətbiq dilini seçin. | Выберите язык приложения. | Choose the app language. |
| `menu.load_failed` | Menyu yüklənmədi. | Не удалось загрузить меню. | Couldn't load the menu. |
| `menu.logout` | Çıxış | Выйти | Log out |
| `menu.logout_confirm_message` | Yenidən daxil olmaq üçün e-poçt və parolunuz lazım olacaq. | Чтобы войти снова, понадобятся e-mail и пароль. | You'll need your email and password to sign in again. |
| `menu.logout_confirm_title` | Çıxış etmək? | Выйти из аккаунта? | Log out? |
| `menu.my_listings` | Elanlarım | Мои объявления | My listings |
| `menu.my_reports` | Şikayətlərim | Мои жалобы | My reports |
| `menu.not_verified_badge` | Təsdiqlənməyib | Не подтверждён | Not verified |
| `menu.notifications` | Bildiriş ayarları | Настройки уведомлений | Notification settings |
| `menu.privacy` | Məxfilik | Конфиденциальность | Privacy |
| `menu.privacy_policy` | Məxfilik siyasəti | Политика конфиденциальности | Privacy policy |
| `menu.promo_codes` | Promokodlarım | Мои промокоды | My promo codes |
| `menu.promotions` | Promosyonlarım | Мои промоакции | My promotions |
| `menu.rate_app` | Tətbiqi qiymətləndir | Оценить приложение | Rate the app |
| `menu.retry` | Yenidən yoxla | Повторить | Retry |
| `menu.reviews` | Rəylərim | Мои отзывы | My reviews |
| `menu.reviews_left` | Yazdığım rəylər | Оставленные отзывы | Reviews I left |
| `menu.reviews_received` | Aldığım rəylər | Полученные отзывы | Reviews received |
| `menu.rules` | Qaydalar & şərtlər | Правила и условия | Terms & conditions |
| `menu.saved_searches` | Saxlanan axtarışlar | Сохранённые поиски | Saved searches |
| `menu.section_account` | Hesab | Аккаунт | Account |
| `menu.section_activity` | Fəaliyyətim | Моя активность | My activity |
| `menu.section_preferences` | Tərcihlər | Настройки | Preferences |
| `menu.section_reviews` | Rəylər | Отзывы | Reviews |
| `menu.section_support` | Dəstək & haqqında | Поддержка и о приложении | Support & about |
| `menu.tier_status` | Statusum | Мой статус | My status |
| `menu.title` | Menyu | Меню | Menu |
| `menu.verify_account` | Hesabı təsdiqlə | Подтвердить аккаунт | Verify account |
| `menu.view_profile` | Profilə bax | Открыть профиль | View profile |

## my_listings  (4)

| key | AZ | RU | EN |
|---|---|---|---|
| `my_listings.filter_empty_subtitle` | Bu filter üzrə elan tapılmadı. | По этому фильтру объявлений не найдено. | No listings match this filter. |
| `my_listings.filter_empty_title` | Elan yoxdur | Объявлений нет | No listings |
| `my_listings.filter_title` | Filtr | Фильтр | Filter |
| `my_listings.resume` | Aktiv et | Активировать | Activate |

## nav  (1)

| key | AZ | RU | EN |
|---|---|---|---|
| `nav.explore` | Kəşf | Обзор | Explore |

## notif_settings  (27)

| key | AZ | RU | EN |
|---|---|---|---|
| `notif_settings.critical_note` | Hesab və təhlükəsizlik bildirişləri (giriş, parol, təsdiq, xəbərdarlıq) həmişə göndərilir və söndürülə bilməz. | Уведомления об аккаунте и безопасности (вход, пароль, подтверждение, предупреждение) отправляются всегда и не могут быть отключены. | Account and security alerts (sign-in, password, confirmation, warnings) are always sent and can't be turned off. |
| `notif_settings.deals.subtitle` | Təklif, çatdırılma, sifariş | Предложения, доставка, заказы | Offers, delivery, orders |
| `notif_settings.deals.title` | Sövdələşmə & təkliflər | Сделки и предложения | Deals & offers |
| `notif_settings.email.subtitle` | Vacib yeniliklər e-poçtla | Важные новости по эл. почте | Important updates by email |
| `notif_settings.email.title` | E-poçt | Эл. почта | Email |
| `notif_settings.follows.subtitle` | Yeni izləyici və elanları | Новые подписчики и их объявления | New followers and their listings |
| `notif_settings.follows.title` | İzləmə | Подписки | Following |
| `notif_settings.group.categories` | Kateqoriyalar | Категории | Categories |
| `notif_settings.group.channels` | Kanallar | Каналы | Channels |
| `notif_settings.group.quiet_hours` | Sakit saatlar | Тихие часы | Quiet hours |
| `notif_settings.listings.subtitle` | Təsdiq, rədd, vaxt, uyğun elan | Подтверждения, отклонения, сроки, подходящие объявления | Approvals, rejections, deadlines, matching listings |
| `notif_settings.listings.title` | Elanlar | Объявления | Listings |
| `notif_settings.marketing.subtitle` | Kampaniya və elanlar | Акции и анонсы | Campaigns and announcements |
| `notif_settings.marketing.title` | Yeniliklər & təkliflər | Новости и акции | News & offers |
| `notif_settings.messages.subtitle` | Yeni və cavabsız mesajlar | Новые и неотвеченные сообщения | New and unanswered messages |
| `notif_settings.messages.title` | Mesajlar | Сообщения | Messages |
| `notif_settings.push.subtitle` | Telefona anında bildiriş | Мгновенные уведомления на телефон | Instant alerts on your phone |
| `notif_settings.push.title` | Push bildirişlər | Push-уведомления | Push notifications |
| `notif_settings.quiet.range_label` | Başlanğıc — son | Начало — конец | Start — end |
| `notif_settings.quiet.subtitle` | Seçilən saatlarda push gəlməz | В выбранные часы push не приходит | No push during the selected hours |
| `notif_settings.quiet.title` | Push-u sakitləşdir | Отключить push | Mute push |
| `notif_settings.reviews.subtitle` | Yeni rəy və xatırlatma | Новые отзывы и напоминания | New reviews and reminders |
| `notif_settings.reviews.title` | Rəylər | Отзывы | Reviews |
| `notif_settings.saved_search.subtitle` | Axtarışınıza uyğun yeni elan | Новые объявления по вашему запросу | New listings matching your search |
| `notif_settings.saved_search.title` | Saxlanan axtarışlar | Сохранённые поиски | Saved searches |
| `notif_settings.saved_toast` | Ayarlar saxlandı. | Настройки сохранены. | Settings saved. |
| `notif_settings.title` | Bildiriş ayarları | Настройки уведомлений | Notification settings |

## notification  (6)

| key | AZ | RU | EN |
|---|---|---|---|
| `notification.group_old` | Köhnə | Ранее | Earlier |
| `notification.group_this_week` | Bu həftə | На этой неделе | This week |
| `notification.time_days_ago` | {count} gün əvvəl | {count} дн. назад | {count} days ago |
| `notification.time_hours_ago` | {count} saat əvvəl | {count} ч. назад | {count} hours ago |
| `notification.time_minutes_ago` | {count} dəqiqə əvvəl | {count} мин. назад | {count} minutes ago |
| `notification.time_now` | indi | только что | just now |

## notifications  (9)

| key | AZ | RU | EN |
|---|---|---|---|
| `notifications.group.older` | Köhnə | Ранее | Earlier |
| `notifications.group.this_week` | Bu həftə | На этой неделе | This week |
| `notifications.group.today` | Bu gün | Сегодня | Today |
| `notifications.group.yesterday` | Dünən | Вчера | Yesterday |
| `notifications.time.days_ago` | {days} gün əvvəl | {days} дн. назад | {days}d ago |
| `notifications.time.hours_ago` | {hours} saat əvvəl | {hours} ч. назад | {hours}h ago |
| `notifications.time.minutes_ago` | {minutes} dəqiqə əvvəl | {minutes} мин. назад | {minutes} min ago |
| `notifications.time.now` | indi | сейчас | now |
| `notifications.time.yesterday` | Dünən | Вчера | Yesterday |

## onboarding  (18)

| key | AZ | RU | EN |
|---|---|---|---|
| `onboarding.art.city_from` | Bakı | Баку | Baku |
| `onboarding.art.city_to` | İstanbul | Стамбул | Istanbul |
| `onboarding.art.eta` | 1–2 gündə | за 1–2 дня | in 1–2 days |
| `onboarding.art.parcel` | Bağlaman | Твоя посылка | Your parcel |
| `onboarding.art.price_from` | 5 \$-dən | от $5 | from $5 |
| `onboarding.art.rating` | 4.9 reytinq | рейтинг 4.9 | 4.9 rating |
| `onboarding.art.secure` | Təhlükəsiz | Безопасно | Secure |
| `onboarding.cta.next` | Növbəti | Далее | Next |
| `onboarding.cta.skip` | Keç | Пропустить | Skip |
| `onboarding.cta.start` | Başla | Начать | Get started |
| `onboarding.have_account` | Hesabın var? | Уже есть аккаунт? | Have an account? |
| `onboarding.login` | Daxil ol | Войти | Log in |
| `onboarding.slide1.body` | Uçan minlərlə insanın çantasında boş yer var. Wawatair onları bağlama göndərənlərlə birləşdirir. | У тысяч летящих людей есть свободное место в багаже. Wawatair соединяет их с теми, кто отправляет посылки. | Thousands of travelers have free space in their bags. Wawatair connects them with people sending parcels. |
| `onboarding.slide1.title` | Səyahət edəni göndərənlə birləşdir | Соедини путешественника с отправителем | Connect travelers with senders |
| `onboarding.slide2.body` | Qiyməti birbaşa çatda danış, bağlamanı əl-ələ, tez və sərfəli çatdır. | Обсуди цену прямо в чате и передай посылку из рук в руки — быстро и выгодно. | Agree on the price right in chat and hand off your parcel in person — fast and affordable. |
| `onboarding.slide2.title` | Kargodan ucuz, poçtdan sürətli | Дешевле карго, быстрее почты | Cheaper than cargo, faster than mail |
| `onboarding.slide3.body` | Mavi nişan, reytinq və rəylər — kiminlə iş gördüyünü əvvəlcədən bil. | Синяя галочка, рейтинг и отзывы — знай заранее, с кем имеешь дело. | Blue badge, ratings and reviews — know who you're dealing with in advance. |
| `onboarding.slide3.title` | Təsdiqlənmiş, etibarlı icma | Проверенное, надёжное сообщество | A verified, trusted community |

## picker  (2)

| key | AZ | RU | EN |
|---|---|---|---|
| `picker.date_help` | Tarix seç | Выберите дату | Select date |
| `picker.time_help` | Saat seç | Выберите время | Select time |

## privacy_policy  (2)

| key | AZ | RU | EN |
|---|---|---|---|
| `privacy_policy.empty` | Məzmun yoxdur | Нет содержимого | No content |
| `privacy_policy.load_error` | Məxfilik siyasətini yükləmək olmadı | Не удалось загрузить политику конфиденциальности | Couldn't load the privacy policy |

## profile  (94)

| key | AZ | RU | EN |
|---|---|---|---|
| `profile.account_deleted` | Hesabınız silindi. | Ваш аккаунт удалён. | Your account was deleted. |
| `profile.account_unavailable` | Bu hesab mövcud deyil, dayandırılıb və ya silinib. | Этот аккаунт не существует, приостановлен или удалён. | This account doesn't exist, is suspended, or was deleted. |
| `profile.auth_login_register` | Daxil ol / Qeydiyyat | Вход / Регистрация | Sign in / Sign up |
| `profile.auth_required_subtitle` | Elanlarını, rəylərini və ayarlarını idarə etmək üçün hesabına daxil ol. | Войдите в аккаунт, чтобы управлять объявлениями, отзывами и настройками. | Sign in to manage your listings, reviews and settings. |
| `profile.auth_required_title` | Profil üçün daxil ol | Войдите, чтобы открыть профиль | Sign in to view your profile |
| `profile.avatar_camera` | Kameradan çək | Снять на камеру | Take a photo |
| `profile.avatar_delete` | Şəkli sil | Удалить фото | Delete photo |
| `profile.avatar_delete_failed` | Avatar silinmədi. | Не удалось удалить аватар. | Couldn't delete the avatar. |
| `profile.avatar_deleted` | Avatar silindi. | Аватар удалён. | Avatar deleted. |
| `profile.avatar_gallery` | Qalereyadan seç | Выбрать из галереи | Choose from gallery |
| `profile.avatar_hint` | JPG/PNG/WEBP · maks 10 MB | JPG/PNG/WEBP · макс. 10 МБ | JPG/PNG/WEBP · max 10 MB |
| `profile.avatar_title` | Profil şəkli | Фото профиля | Profile photo |
| `profile.avatar_update_failed` | Avatar yenilənmədi. | Не удалось обновить аватар. | Couldn't update the avatar. |
| `profile.avatar_updated` | Avatar yeniləndi. | Аватар обновлён. | Avatar updated. |
| `profile.block_user` | İstifadəçini blokla | Заблокировать пользователя | Block user |
| `profile.change_password` | Parolu dəyiş | Сменить пароль | Change password |
| `profile.change_photo` | Şəkli dəyiş | Изменить фото | Change photo |
| `profile.current_password` | Cari parol | Текущий пароль | Current password |
| `profile.delete_account` | Hesabı sil | Удалить аккаунт | Delete account |
| `profile.delete_confirm_understand` | Nəticələri başa düşürəm | Я понимаю последствия | I understand the consequences |
| `profile.delete_subtitle` | Elanlarınız, söhbətləriniz və rəyləriniz gizlədiləcək. Bu əməli geri qaytarmaq mümkün deyil. | Ваши объявления, чаты и отзывы будут скрыты. Отменить это действие нельзя. | Your listings, chats and reviews will be hidden. This can't be undone. |
| `profile.delete_title` | Hesabı silmək? | Удалить аккаунт? | Delete account? |
| `profile.deliveries` | Çatdırılma | Доставки | Deliveries |
| `profile.edit` | Profili redaktə et | Редактировать профиль | Edit profile |
| `profile.empty_listings_subtitle` | Yeni elan yaratdıqdan sonra burada görünəcək. | После создания объявления появятся здесь. | Once you create a listing, it'll show up here. |
| `profile.empty_listings_title` | Hələ elan yoxdur | Пока нет объявлений | No listings yet |
| `profile.first_name` | Ad | Имя | First name |
| `profile.follow` | İzlə | Подписаться | Follow |
| `profile.follow_started` | İzləməyə başladınız. | Вы подписались. | You're now following. |
| `profile.followers` | İzləyici | Подписчики | Followers |
| `profile.following` | İzləyir | Подписки | Following |
| `profile.following_active` | İzlənilir | Вы подписаны | Following |
| `profile.help_faq` | Kömək & FAQ | Помощь и FAQ | Help & FAQ |
| `profile.language` | Dil | Язык | Language |
| `profile.languages_you_know` | Bildiyiniz dillər | Языки, которыми владеете | Languages you speak |
| `profile.last_name` | Soyad | Фамилия | Last name |
| `profile.list_empty` | Siyahı boşdur | Список пуст | The list is empty |
| `profile.listings` | Elanlar | Объявления | Listings |
| `profile.load_failed` | Məlumat yüklənmədi. | Не удалось загрузить данные. | Couldn't load the data. |
| `profile.logout` | Çıxış | Выйти | Log out |
| `profile.member_since` | {year}-dən üzv | с нами с {year} | member since {year} |
| `profile.message` | Mesaj | Сообщение | Message |
| `profile.my_listings` | Elanlarım | Мои объявления | My listings |
| `profile.new_password` | Yeni parol | Новый пароль | New password |
| `profile.not_found` | Profil məlumatı tapılmadı. | Профиль не найден. | Profile not found. |
| `profile.not_verified` | Təsdiqlənməyib | Не подтверждён | Not verified |
| `profile.notification_settings` | Bildiriş ayarları | Настройки уведомлений | Notification settings |
| `profile.password_changed` | Parol dəyişdirildi. | Пароль изменён. | Password changed. |
| `profile.password_hint` | Ən az 8 simvol, cari paroldan fərqli | Минимум 8 символов, отличается от текущего | At least 8 characters, different from the current one |
| `profile.password_min` | Ən az 8 simvol olmalıdır. | Минимум 8 символов. | Must be at least 8 characters. |
| `profile.password_strong` | Güclü | Надёжный | Strong |
| `profile.password_update` | Parolu yenilə | Обновить пароль | Update password |
| `profile.password_weak` | Zəif | Слабый | Weak |
| `profile.privacy` | Məxfilik | Конфиденциальность | Privacy |
| `profile.privacy_activity` | Aktivlik vaxtı | Время активности | Activity time |
| `profile.privacy_activity_hint` | Son giriş görünsün | Показывать последний вход | Show last seen |
| `profile.privacy_email` | E-poçt | Эл. почта | Email |
| `profile.privacy_languages` | Bildiyim dillər | Языки, которыми владею | Languages I speak |
| `profile.privacy_note` | Əlaqə həmişə söhbət (chat) vasitəsilə mümkündür — nömrənizi gizli saxlasanız belə. | Связаться всегда можно через чат — даже если номер скрыт. | You can always be reached via chat — even if your number is hidden. |
| `profile.privacy_phone` | Telefon nömrəsi | Номер телефона | Phone number |
| `profile.privacy_profile_visible` | Profildə görünsün | Показывать в профиле | Show on profile |
| `profile.privacy_show` | Profildə göstər | Показывать в профиле | Show on profile |
| `profile.privacy_update_failed` | Məxfilik yenilənmədi. | Не удалось обновить конфиденциальность. | Couldn't update privacy. |
| `profile.privacy_updated` | Məxfilik parametrləri yeniləndi. | Настройки конфиденциальности обновлены. | Privacy settings updated. |
| `profile.privacy_visible_to_others` | Başqaları görə bilsin | Виден другим | Visible to others |
| `profile.rating` | Reytinq | Рейтинг | Rating |
| `profile.report_abuse` | Təhqir | Оскорбление | Abuse |
| `profile.report_action` | Şikayət et | Пожаловаться | Report |
| `profile.report_details` | Ətraflı | Подробнее | Details |
| `profile.report_fake` | Saxta | Фейк | Fake |
| `profile.report_fraud` | Fırıldaq | Мошенничество | Fraud |
| `profile.report_inappropriate` | Uyğunsuz | Неприемлемо | Inappropriate |
| `profile.report_other` | Digər | Другое | Other |
| `profile.report_sent` | Şikayət göndərildi. | Жалоба отправлена. | Report sent. |
| `profile.report_submit` | Şikayəti göndər | Отправить жалобу | Send report |
| `profile.report_user_subtitle` | Səbəbi seçin. Şikayət anonimdir. | Выберите причину. Жалоба анонимна. | Pick a reason. Reports are anonymous. |
| `profile.report_user_title` | İstifadəçini şikayət et | Пожаловаться на пользователя | Report user |
| `profile.response` | Cavab | Ответ | Response |
| `profile.settings.account` | Hesab | Аккаунт | Account |
| `profile.settings.preferences` | Tərcihlər | Настройки | Preferences |
| `profile.settings.support` | Dəstək | Поддержка | Support |
| `profile.settings_title` | Ayarlar | Настройки | Settings |
| `profile.support` | Dəstək | Поддержка | Support |
| `profile.terms_privacy` | Qaydalar & məxfilik siyasəti | Правила и политика конфиденциальности | Terms & privacy policy |
| `profile.title` | Profil | Профиль | Profile |
| `profile.unfollow_done` | İzləmə dayandırıldı. | Вы отписались. | Unfollowed. |
| `profile.update_failed` | Profil yenilənmədi. | Не удалось обновить профиль. | Couldn't update the profile. |
| `profile.updated` | Profil yeniləndi. | Профиль обновлён. | Profile updated. |
| `profile.user_blocked` | İstifadəçi bloklandı. | Пользователь заблокирован. | User blocked. |
| `profile.user_not_found` | İstifadəçi tapılmadı | Пользователь не найден | User not found |
| `profile.users_will_appear` | Burada istifadəçilər görünəcək. | Здесь появятся пользователи. | Users will appear here. |
| `profile.verification_unavailable` | Təsdiqləmə məlumatı yüklənmədi. | Не удалось загрузить данные подтверждения. | Couldn't load verification details. |
| `profile.verified` | Təsdiqlənib | Подтверждён | Verified |
| `profile.verify_account` | Hesabınızı təsdiqləyin | Подтвердите аккаунт | Verify your account |

## promo  (34)

| key | AZ | RU | EN |
|---|---|---|---|
| `promo.cond_min` | Minimum ödəniş: {amount} | Минимальный заказ: {amount} | Minimum order: {amount} |
| `promo.cond_scope` | VİP və önə çəkmə üçün keçərli | Действует для VIP и продвижения | Valid for VIP and promotion |
| `promo.cond_single_use` | Bir dəfə istifadə olunur | Используется один раз | Single use |
| `promo.copied` | Kod kopyalandı | Код скопирован | Code copied |
| `promo.copy_code` | Kodu köçür | Скопировать код | Copy code |
| `promo.days_left` | {days} gün qalıb | осталось {days} дн. | {days} days left |
| `promo.discount_label` | ENDİRİM | СКИДКА | DISCOUNT |
| `promo.earn_invite` | Dostunu dəvət et | Пригласите друга | Invite a friend |
| `promo.earn_invite_sub` | Hər qeydiyyatdan olan dost üçün | За каждого зарегистрировавшегося друга | For each friend who signs up |
| `promo.earn_rate` | Tətbiqi qiymətləndir | Оцените приложение | Rate the app |
| `promo.earn_rate_sub` | Store-da ulduz ver | Поставьте звезду в Store | Give a star on the Store |
| `promo.empty_subtitle` | Promokod qazan və sifarişlərində endirim əldə et. | Зарабатывайте промокоды и получайте скидки на заказы. | Earn promo codes and get discounts on your orders. |
| `promo.empty_title` | Hələ promokodun yoxdur | У вас пока нет промокодов | You have no promo codes yet |
| `promo.error_body` | Promokodları yükləyə bilmədik. İnternet bağlantını yoxla. | Не удалось загрузить промокоды. Проверьте интернет-соединение. | We couldn't load your promo codes. Check your internet connection. |
| `promo.error_title` | Bağlantı yoxdur | Нет соединения | No connection |
| `promo.expired_at` | Vaxtı bitib | Истёк | Expired |
| `promo.hint` | Kodu elanı VİP edərkən və ya önə çəkərkən ödənişdə tətbiq et. | Применяйте код при оплате, делая объявление VIP или продвигая его. | Apply the code at checkout when making a listing VIP or promoting it. |
| `promo.no_expiry` | Müddətsiz | Бессрочно | No expiry |
| `promo.promote_listing` | Elanı önə çıxar | Продвинуть объявление | Promote listing |
| `promo.retry` | Yenidən cəhd et | Повторить | Try again |
| `promo.source_default` | Promokod | Промокод | Promo code |
| `promo.source_rate_review` | Tətbiqi qiymətləndirdiyin üçün | За оценку приложения | For rating the app |
| `promo.source_referral` | Dostunu dəvət etdiyin üçün | За приглашение друга | For inviting a friend |
| `promo.source_welcome` | Xoş gəlmisən bonusu | Приветственный бонус | Welcome bonus |
| `promo.stamp_expired` | BİTİB | ИСТЁК | EXPIRED |
| `promo.stamp_used` | İŞLƏNİB | ИСПОЛЬЗОВАН | USED |
| `promo.tab_active` | Aktiv | Активные | Active |
| `promo.tab_empty` | Bu bölmədə promokod yoxdur. | В этом разделе нет промокодов. | No promo codes in this section. |
| `promo.tab_expired` | Vaxtı keçmiş | Истёкшие | Expired |
| `promo.tab_used` | İstifadə olunmuş | Использованные | Used |
| `promo.title` | Promokodlarım | Мои промокоды | My promo codes |
| `promo.until_date` | {date}-a qədər | до {date} | until {date} |
| `promo.use` | İstifadə et | Использовать | Use |
| `promo.used_at` | İstifadə olunub | Использован | Used |

## promotion  (110)

| key | AZ | RU | EN |
|---|---|---|---|
| `promotion.action.extend` | Uzat | Продлить | Extend |
| `promotion.action.renew` | Yenilə | Возобновить | Renew |
| `promotion.activated` | Təbriklər! | Поздравляем! | Congratulations! |
| `promotion.active_template` | {type} artıq aktivdir | {type} уже активно | {type} is already active |
| `promotion.apply` | Tətbiq et | Применить | Apply |
| `promotion.boost_description` | Elanın axtarış və lentdə seçdiyin mövqe zolağında görünəcək. | Объявление появится в выбранной позиционной полосе в поиске и ленте. | Your listing appears in the position band you choose, in search and the feed. |
| `promotion.boost_short` | İlk 10 / 50 / 100 mövqe | Топ 10 / 50 / 100 позиций | Top 10 / 50 / 100 positions |
| `promotion.checkout.boost_title_template` | Önə çək · {tier} | Продвинуть · {tier} | Boost · {tier} |
| `promotion.checkout.discount` | Endirim | Скидка | Discount |
| `promotion.checkout.duration` | Müddət | Срок | Duration |
| `promotion.checkout.end` | Bitmə | Окончание | Ends |
| `promotion.checkout.package` | Paket | Пакет | Package |
| `promotion.checkout.start` | Başlama | Начало | Start |
| `promotion.checkout.starts_after_approval` | Təsdiqdən dərhal sonra | Сразу после одобрения | Right after approval |
| `promotion.checkout.vip_title` | VİP promosyon | VIP-продвижение | VIP promotion |
| `promotion.checkout_open_failed` | Ödəniş səhifəsini açmaq alınmadı. | Не удалось открыть страницу оплаты. | Couldn't open the payment page. |
| `promotion.checkout_title` | Sifariş yekunu | Итог заказа | Order summary |
| `promotion.created_subtitle` | Adətən 1–2 saat ərzində təsdiqlənir. Təsdiqdən sonra lentdə görünəcək. | Обычно проверка занимает 1–2 часа. После одобрения объявление появится в ленте. | Usually approved within 1–2 hours. Once approved it appears in the feed. |
| `promotion.created_title` | Elanın yoxlamaya göndərildi | Объявление отправлено на проверку | Listing sent for review |
| `promotion.cta.boost` | Önə çək | Продвинуть | Boost |
| `promotion.cta.boost_too` | Önə də çək | Ещё и продвинуть | Boost too |
| `promotion.cta.checkout` | Ödənişə keç | Перейти к оплате | Proceed to payment |
| `promotion.cta.continue_duration` | Davam et — müddət seç | Продолжить — выбрать срок | Continue — choose duration |
| `promotion.cta.extend` | Uzat | Продлить | Extend |
| `promotion.cta.upgrade_tier` | Zolağı yüksəlt | Повысить уровень | Upgrade tier |
| `promotion.cta.vip` | VİP et | Сделать VIP | Make VIP |
| `promotion.duration.best_value` | Ən sərfəli paket | Самый выгодный пакет | Best value |
| `promotion.duration.popular` | Populyar seçim | Популярный выбор | Popular choice |
| `promotion.duration.short_trial` | Qısa sınaq | Короткий тест | Quick trial |
| `promotion.duration_template` | {days} gün | {days} дн. | {days} days |
| `promotion.empty` | Bu bölmədə promosyon yoxdur. | В этом разделе нет продвижений. | No promotions in this section. |
| `promotion.error.generic` | Əməliyyat alınmadı. Yenidən cəhd et. | Операция не выполнена. Повторите попытку. | The operation failed. Try again. |
| `promotion.error.load` | Məlumatları yükləmək alınmadı. | Не удалось загрузить данные. | Couldn't load the data. |
| `promotion.failed_title` | Ödəniş alınmadı | Оплата не прошла | Payment failed |
| `promotion.listing_template` | Elan #{id} | Объявление №{id} | Listing #{id} |
| `promotion.my_title` | Promosyonlarım | Мои продвижения | My promotions |
| `promotion.pay.processing` | Ödəniş emal olunur… | Обработка платежа… | Processing payment… |
| `promotion.pay.processing_hint` | Zəhmət olmasa gözlə. Bu ekranı bağlama. | Пожалуйста, подождите. Не закрывайте этот экран. | Please wait. Don't close this screen. |
| `promotion.pay.retry` | Yenidən cəhd et | Повторить | Try again |
| `promotion.pay.secure_note` | Ödənişlər şifrələnir · kart məlumatı serverdə saxlanmır | Платежи шифруются · данные карты не хранятся на сервере | Payments are encrypted · card data isn't stored on the server |
| `promotion.pay.title` | Ödəniş | Оплата | Payment |
| `promotion.payment.balance` | Wawatair balans | Баланс Wawatair | Wawatair balance |
| `promotion.payment.balance_subtitle` | Mock ödəniş · real balans inteqrasiyada | Тестовая оплата · реальный баланс в интеграции | Mock payment · real balance in integration |
| `promotion.payment.balance_unavailable` | Balans: 0.00 $ — kifayət etmir | Баланс: 0.00 $ — недостаточно | Balance: $0.00 — insufficient |
| `promotion.payment.card` | Bank kartı | Банковская карта | Bank card |
| `promotion.payment.card_subtitle` | Visa · Mastercard | Visa · Mastercard | Visa · Mastercard |
| `promotion.payment.change_method` | Ödəniş üsulunu dəyiş | Изменить способ оплаты | Change payment method |
| `promotion.payment.pay_template` | Ödə · {amount} $ | Оплатить · {amount} $ | Pay · {amount} $ |
| `promotion.payment.safety` | Ödənişlər şifrələnir · kart məlumatı serverdə saxlanmır | Платежи шифруются · данные карты не хранятся на сервере | Payments are encrypted · card details aren't stored on the server |
| `promotion.payment_failed` | Ödəniş alınmadı | Оплата не прошла | Payment failed |
| `promotion.payment_integration_note` | Ödəniş sistemi inteqrasiya mərhələsindədir — provayder qoşulan kimi işləyəcək. | Платёжная система на этапе интеграции — экран готов и заработает, как только подключится провайдер. | The payment system is being integrated — this screen is ready and will work once the provider is connected. |
| `promotion.payment_method` | Ödəniş üsulu | Способ оплаты | Payment method |
| `promotion.payment_pending` | Təsdiq gözlənilir | Ожидается подтверждение | Awaiting confirmation |
| `promotion.payment_title` | Ödəniş | Оплата | Payment |
| `promotion.pending_activation_note` | Elan təsdiqlənən kimi promosyon avtomatik aktivləşəcək. | Продвижение можно оплатить сейчас — оно активируется автоматически после одобрения объявления. | You can buy promotion now — it activates automatically once the listing is approved. |
| `promotion.pending_title` | Təsdiq gözlənilir | Ожидание подтверждения | Awaiting confirmation |
| `promotion.position_description_template` | Nəticələrin ilk {count}-liyində daha çox baxış | Больше просмотров в топ-{count} результатов | More views in the top {count} results |
| `promotion.preview_full_title` | Elanın lentdə görünüşü | Вид объявления в ленте | Listing preview in feed |
| `promotion.preview_title` | Lentdə belə görünəcək | Так это выглядит в ленте | How it looks in the feed |
| `promotion.pricing_unavailable` | Promosyon paketlərini yükləmək alınmadı. | Не удалось загрузить пакеты продвижения. | Couldn't load promotion packages. |
| `promotion.processing_subtitle` | Zəhmət olmasa gözlə. Bu ekranı bağlama. | Пожалуйста, подождите. Не закрывайте этот экран. | Please wait. Don't close this screen. |
| `promotion.processing_title` | Ödəniş emal olunur… | Обработка платежа… | Processing payment… |
| `promotion.promo_code` | Promokod (varsa) | Промокод (если есть) | Promo code (if any) |
| `promotion.provider_unavailable` | Ödəniş səhifəsini açmaq alınmadı. | Не удалось открыть страницу оплаты. | Couldn't open the payment page. |
| `promotion.refunded_title` | Məbləğ balansa qaytarıldı | Сумма возвращена на баланс | Amount refunded to balance |
| `promotion.refunded_to_balance` | Məbləğ Wawatair balansına qaytarıldı. | Сумма возвращена на баланс Wawatair. | The amount was refunded to your Wawatair balance. |
| `promotion.remaining.days_template` | {days} gün {hours} saat qalıb | Осталось {days} дн. {hours} ч. | {days}d {hours}h left |
| `promotion.remaining.expired` | Müddəti bitib | Срок истёк | Expired |
| `promotion.remaining.hours_template` | {hours} saat qalıb | Осталось {hours} ч. | {hours}h left |
| `promotion.remaining_days_hours` | {days} gün {hours} saat | {days} дн. {hours} ч | {days}d {hours}h |
| `promotion.remaining_hours` | {hours} saat | {hours} ч | {hours}h |
| `promotion.remaining_minutes` | {minutes} dəq | {minutes} мин | {minutes}m |
| `promotion.section.all` | Bütün elanlar | Все объявления | All listings |
| `promotion.section.vip` | VİP elanlar | VIP-объявления | VIP listings |
| `promotion.skip` | İndi yox, elanlarıma keç | Не сейчас, к моим объявлениям | Not now, go to my listings |
| `promotion.starting_from` | başlanğıc | от | from |
| `promotion.status.active_boost` | Elanın indi seçilmiş mövqe zolağında önə çıxarılır. | Ваше объявление продвигается в выбранной позиционной полосе. | Your listing is now boosted in the selected position band. |
| `promotion.status.active_vip` | Elanın indi VİP-dir və lentin ən yuxarısında görünəcək. | Теперь ваше объявление VIP и показывается в самом верху ленты. | Your listing is now VIP and shows at the top of the feed. |
| `promotion.status.amount` | Məbləğ | Сумма | Amount |
| `promotion.status.check_later` | Sonra profildən yoxla | Проверить позже в профиле | Check later in profile |
| `promotion.status.done` | Bitdi | Готово | Done |
| `promotion.status.end` | Bitmə | Окончание | Ends |
| `promotion.status.failed` | Kartından məbləğ tutulmadı. Yenidən cəhd edə bilərsən. | Средства с карты не списаны. Можно повторить попытку. | No money was charged. You can try again. |
| `promotion.status.package` | Paket | Пакет | Package |
| `promotion.status.pending` | Bankın və ya ödəniş provayderinin təsdiqini gözləyirik. Nəticə hazır olanda bildiriş alacaqsan. | Ждём подтверждения от банка или платёжного провайдера. Вы получите уведомление, когда результат будет готов. | Waiting for the bank or payment provider to confirm. You'll get a notification once the result is ready. |
| `promotion.status.refresh` | Statusu yenilə | Обновить статус | Refresh status |
| `promotion.status.refreshing` | Yenilənir... | Обновление... | Refreshing... |
| `promotion.status.status` | Status | Статус | Status |
| `promotion.status.view_listing` | Elanıma bax | Открыть объявление | View listing |
| `promotion.step.duration` | Müddət seç | Выберите срок | Choose duration |
| `promotion.step.extend_duration` | Müddəti artır | Продлить срок | Extend duration |
| `promotion.step.position` | Mövqe zolağını seç | Выберите позиционную полосу | Choose a position band |
| `promotion.success_title` | Təbriklər! | Поздравляем! | Congratulations! |
| `promotion.summary.boost_template` | {tier} · {days} gün | {tier} · {days} дн. | {tier} · {days} days |
| `promotion.summary.vip_template` | {days} gün VİP | {days} дн. VIP | {days}d VIP |
| `promotion.tabs.active_template` | Aktiv ({count}) | Активные ({count}) | Active ({count}) |
| `promotion.tabs.expired_template` | Bitmiş ({count}) | Завершённые ({count}) | Expired ({count}) |
| `promotion.tier.top10` | İlk 10 | Топ 10 | Top 10 |
| `promotion.tier.top100` | İlk 100 | Топ 100 | Top 100 |
| `promotion.tier.top50` | İlk 50 | Топ 50 | Top 50 |
| `promotion.tier_note` | VİP elanlar həmişə önə çəkilmiş elanların da üstündədir. | VIP-объявления всегда выше продвинутых. | VIP listings always rank above boosted ones. |
| `promotion.total` | Yekun | Итого | Total |
| `promotion.upsell_title` | Elanını daha çox insana çatdır | Покажите объявление большему числу людей | Reach more people with your listing |
| `promotion.vip_active` | VİP aktiv | VIP активен | VIP active |
| `promotion.vip_benefit.badge` | Tac nişanı və qızılı çərçivə | Значок короны и золотая рамка | Crown badge and gold frame |
| `promotion.vip_benefit.section` | Ayrıca «VİP elanlar» bölməsində üst sıra | Верхняя строка в отдельном разделе «VIP-объявления» | Top spot in a separate "VIP listings" section |
| `promotion.vip_benefit.views` | Orta hesabla daha çox baxış | В среднем больше просмотров | More views on average |
| `promotion.vip_benefits_title` | VİP nə qazandırır? | Что даёт VIP? | What does VIP give you? |
| `promotion.vip_description` | Elanın lentin ən yuxarısında, ayrıca «VİP elanlar» bölməsində görünəcək. | Объявление появится в самом верху ленты и в отдельном разделе «VIP-объявления». | Your listing appears at the top of the feed and in a separate "VIP listings" section. |
| `promotion.vip_short` | Ən yuxarıda, ayrıca bölmədə | В самом верху, в отдельном разделе | At the very top, in a separate section |

## rate  (21)

| key | AZ | RU | EN |
|---|---|---|---|
| `rate.code_copied` | Kod kopyalandı | Код скопирован | Code copied |
| `rate.coupon_footer` | {amount} endirim · VİP/önə çəkmə | {amount} скидка · VIP/продвижение | {amount} off · VIP/promotion |
| `rate.cta` | Store-da qiymətləndir | Оценить в Store | Rate on the Store |
| `rate.days_left` | {days} gün qalıb · son tarix {date} | осталось {days} дн. · до {date} | {days} days left · until {date} |
| `rate.expired` | Müddəti bitib | Срок истёк | Expired |
| `rate.expires_today` | Bu gün bitir · {date} | Истекает сегодня · {date} | Expires today · {date} |
| `rate.intro_subtitle` | 1 dəqiqəni ayır, Store-da bizi qiymətləndir — və hədiyyə promokod qazan. | Уделите минуту, оцените нас в Store — и получите промокод в подарок. | Take a minute to rate us on the Store — and get a gift promo code. |
| `rate.intro_title` | Wawatair-i bəyənirsən? | Нравится Wawatair? | Do you like Wawatair? |
| `rate.rated_body_coupon` | Rəyin üçün təşəkkür! Bu promokodu VİP/önə çəkərkən tətbiq et: | Спасибо за отзыв! Примените этот промокод при VIP/продвижении: | Thanks for your review! Apply this promo code when making a listing VIP/promoting: |
| `rate.rated_body_thanks` | Bu tətbiqi artıq qiymətləndirmisən. Dəstəyin bizə çox kömək edir. | Вы уже оценили это приложение. Ваша поддержка очень помогает нам. | You've already rated this app. Your support helps us a lot. |
| `rate.rated_title_coupon` | Hədiyyə promokodun hazırdır 🎁 | Ваш промокод-подарок готов 🎁 | Your gift promo code is ready 🎁 |
| `rate.rated_title_thanks` | Təşəkkür edirik! ⭐️ | Спасибо! ⭐️ | Thank you! ⭐️ |
| `rate.reward_chip` | {reward} promokod hədiyyə | {reward} промокод в подарок | {reward} promo code gift |
| `rate.step1` | Düyməyə bas — Store-un qiymətləndirmə pəncərəsi açılır | Нажмите кнопку — откроется окно оценки Store | Tap the button — the Store's rating window opens |
| `rate.step2` | {reward} promokod avtomatik hesabına gəlir | промокод на {reward} автоматически зачисляется на счёт | a {reward} promo code is added to your account automatically |
| `rate.step3` | Elanı VİP/önə çəkərkən tətbiq et | Примените при VIP/продвижении объявления | Apply it when making a listing VIP/promoting it |
| `rate.takes_a_minute` | Bir dəqiqədən az çəkir | Займёт меньше минуты | Takes less than a minute |
| `rate.title` | Tətbiqi qiymətləndir | Оценить приложение | Rate the app |
| `rate.toast_body` | Rəyin bizə çox kömək edir. | Ваш отзыв очень помогает нам. | Your review helps us a lot. |
| `rate.toast_title` | Təşəkkür edirik! ⭐️ | Спасибо! ⭐️ | Thank you! ⭐️ |
| `rate.view_my_codes` | Promokodlarıma bax | Мои промокоды | View my promo codes |

## receipt  (9)

| key | AZ | RU | EN |
|---|---|---|---|
| `receipt.download_pdf` | PDF yüklə | Скачать PDF | Download PDF |
| `receipt.footer` | Bu qəbz avtomatik yaradılıb · dəstək: {email} | Этот чек создан автоматически · поддержка: {email} | This receipt was generated automatically · support: {email} |
| `receipt.pdf_error` | PDF yaradıla bilmədi. | Не удалось создать PDF. | Couldn't generate the PDF. |
| `receipt.status.awaiting_provider` | Gözləyir | Ожидает | Pending |
| `receipt.status.failed` | Uğursuz | Не удалось | Failed |
| `receipt.status.paid` | Ödənildi | Оплачено | Paid |
| `receipt.status.refunded` | Geri qaytarıldı | Возвращено | Refunded |
| `receipt.title` | Qəbz | Чек | Receipt |
| `receipt.view` | Qəbz | Чек | Receipt |

## referral  (43)

| key | AZ | RU | EN |
|---|---|---|---|
| `referral.awaiting_first_order` | İlk sifariş gözlənilir | Ожидается первый заказ | Awaiting first order |
| `referral.both_earn` | İkiniz də qazanırsınız | Вы оба получаете бонус | You both earn |
| `referral.both_earn_hint` | ilk sifarişdən sonra {amount} promokod. | промокод на {amount} после первого заказа. | a {amount} promo code after the first order. |
| `referral.code_copied` | Kod kopyalandı | Код скопирован | Code copied |
| `referral.code_label` | DƏVƏT KODUN | ВАШ КОД ПРИГЛАШЕНИЯ | YOUR INVITE CODE |
| `referral.empty_subtitle` | Linki paylaş — dostların burada görünəcək. | Поделитесь ссылкой — ваши друзья появятся здесь. | Share the link — your friends will show up here. |
| `referral.empty_title` | Hələ heç kimi dəvət etməmisən | Вы ещё никого не пригласили | You haven't invited anyone yet |
| `referral.error_body` | Məlumatı yükləyə bilmədik. İnternet bağlantını yoxla. | Не удалось загрузить данные. Проверьте интернет-соединение. | We couldn't load the data. Check your internet connection. |
| `referral.error_title` | Bağlantı yoxdur | Нет соединения | No connection |
| `referral.friend_joins` | Dostun qoşulur | Друг присоединяется | Your friend joins |
| `referral.friend_joins_hint` | link ilə qeydiyyatdan keçir. | регистрируется по вашей ссылке. | signs up with your link. |
| `referral.hero_note` | Dostun ilk sifarişini tamamlayanda promokod hər ikinizə gedir. | Когда друг завершит первый заказ, промокод получите вы оба. | When your friend completes their first order, you both get a promo code. |
| `referral.hero_prefix` | Dostunu dəvət et, hər ikiniz | Пригласите друга — вы оба | Invite a friend and you both |
| `referral.hero_subtitle` | Dostun ilk sifarişini tamamlayanda promokod hər ikinizə gedir. | Когда друг завершит первый заказ, промокод получите вы оба. | When your friend completes their first order, you both get a promo code. |
| `referral.hero_suffix` | qazanın | получите бонус | earn |
| `referral.hero_title` | Dostunu dəvət et, hər ikiniz  | Пригласи друга, вы оба  | Invite a friend, you both  |
| `referral.hero_title_suffix` |  qazanın |  заработаете |  earn |
| `referral.invited_pending_name` | Dəvət olunub | Приглашён | Invited |
| `referral.invites_title` | Dəvət etdiklərim | Мои приглашения | People I invited |
| `referral.item_invited` | Dəvət olunub | Приглашён | Invited |
| `referral.item_waiting_first_order` | İlk sifariş gözlənilir | Ожидается первый заказ | Awaiting first order |
| `referral.joined` | Qoşulub | Присоединился | Joined |
| `referral.link_copied` | Link kopyalandı | Ссылка скопирована | Link copied |
| `referral.my_invites` | Dəvət etdiklərim | Мои приглашения | People I invited |
| `referral.retry` | Yenidən cəhd et | Повторить | Try again |
| `referral.share_code_suffix` |  Kod: {code}. |  Код: {code}. |  Code: {code}. |
| `referral.share_copy` | Kopyala | Копировать | Copy |
| `referral.share_invite_link` | Dəvət linkini paylaş | Поделиться ссылкой-приглашением | Share invite link |
| `referral.share_link` | Linki paylaş | Поделиться ссылкой | Share link |
| `referral.share_link_hint` | dostuna dəvət linkini göndər. | отправьте другу пригласительную ссылку. | send your friend the invite link. |
| `referral.share_more` | Digər | Ещё | More |
| `referral.share_text` | Wawatair-ə qoşul, hər ikimiz {amount} qazanaq! Kod: {code}. {link} | Присоединяйся к Wawatair — заработаем оба по {amount} {currency}! | Join Wawatair — we both earn {amount} {currency}! |
| `referral.stat_earned` | Qazanılan | Заработано | Earned |
| `referral.stat_invited` | Dəvət | Приглашено | Invited |
| `referral.stat_joined` | Qoşulan | Присоединились | Joined |
| `referral.status_pending` | Gözləyir | Ожидает | Pending |
| `referral.step1_body` | dostuna dəvət linkini göndər. | отправьте другу пригласительную ссылку. | send your friend the invite link. |
| `referral.step1_title` | Linki paylaş | Поделитесь ссылкой | Share the link |
| `referral.step2_body` | link ilə qeydiyyatdan keçir. | регистрируется по ссылке. | signs up via the link. |
| `referral.step2_title` | Dostun qoşulur | Друг присоединяется | Your friend joins |
| `referral.step3_body` | ilk sifarişdən sonra {amount} {currency} promokod. | промокод на {amount} {currency} после первого заказа. | a {amount} {currency} promo code after the first order. |
| `referral.step3_title` | İkiniz də qazanırsınız | Вы оба зарабатываете | You both earn |
| `referral.title` | Dostunu dəvət et | Пригласить друга | Invite a friend |

## reports  (37)

| key | AZ | RU | EN |
|---|---|---|---|
| `reports.detail.title` | Şikayət #{id} | Жалоба #{id} | Report #{id} |
| `reports.empty.body` | Elan, istifadəçi və ya mesaj barədə şikayət etsən, burada görünəcək. | Когда вы пожалуетесь на объявление, пользователя или сообщение, это появится здесь. | When you report a listing, user, or message, it'll appear here. |
| `reports.empty.title` | Şikayətin yoxdur | Жалоб нет | No reports |
| `reports.empty_subtitle` | Elan, istifadəçi və ya mesaj barədə şikayət etsən, burada görünəcək. | Если вы пожалуетесь на объявление, пользователя или сообщение, жалоба появится здесь. | If you report a listing, user, or message, it'll show up here. |
| `reports.empty_title` | Şikayətin yoxdur | У вас нет жалоб | No reports yet |
| `reports.error.body` | Məlumatı yükləyə bilmədik. İnternet bağlantını yoxla. | Не удалось загрузить данные. Проверьте подключение к интернету. | We couldn't load the data. Check your internet connection. |
| `reports.error.title` | Bağlantı yoxdur | Нет соединения | No connection |
| `reports.evidence_attached` | Sübut əlavə edilib | Прикреплено доказательство | Evidence attached |
| `reports.explanation_label` | İzah | Пояснение | Explanation |
| `reports.id_template` | Şikayət #{id} | Жалоба #{id} | Report #{id} |
| `reports.label.note` | İzah | Пояснение | Explanation |
| `reports.label.reason` | Səbəb | Причина | Reason |
| `reports.label.status` | Vəziyyət | Статус | Status |
| `reports.moderation_response` | Moderasiya cavabı | Ответ модерации | Moderation response |
| `reports.result_resolved` | Həll olundu | Решено | Resolved |
| `reports.retry` | Yenidən cəhd et | Повторить | Try again |
| `reports.status.pending` | Gözləyir | Ожидает | Pending |
| `reports.status.rejected` | Rədd edildi | Отклонено | Rejected |
| `reports.status.resolved` | Həll olundu | Решено | Resolved |
| `reports.status.reviewing` | Baxılır | На рассмотрении | Under review |
| `reports.status_label` | Vəziyyət | Статус | Status |
| `reports.status_resolved` | Həll olundu | Решено | Resolved |
| `reports.step.awaiting` | Gözlənilir | Ожидается | Awaiting |
| `reports.step.result` | Nəticə | Результат | Result |
| `reports.step.reviewing` | Baxılır | На рассмотрении | Under review |
| `reports.step.reviewing_sub` | Moderasiya komandası yoxlayır | Команда модерации проверяет | The moderation team is reviewing |
| `reports.step.submitted` | Göndərildi | Отправлено | Submitted |
| `reports.step_result` | Nəticə | Результат | Result |
| `reports.step_reviewing_hint` | Moderasiya komandası yoxlayır | Команда модерации проверяет | The moderation team is reviewing |
| `reports.step_sent` | Göndərildi | Отправлено | Sent |
| `reports.subject_listing` | Elan barədə şikayət | Жалоба на объявление | Report listing |
| `reports.subject_message` | Mesaj barədə şikayət | Жалоба на сообщение | Report message |
| `reports.subject_user` | İstifadəçi barədə şikayət | Жалоба на пользователя | Report user |
| `reports.title` | Şikayətlərim | Мои жалобы | My reports |
| `reports.title.listing` | Elan barədə şikayət | Жалоба на объявление | Report about a listing |
| `reports.title.message` | Mesaj barədə şikayət | Жалоба на сообщение | Report about a message |
| `reports.title.user` | İstifadəçi barədə şikayət | Жалоба на пользователя | Report about a user |

## review  (17)

| key | AZ | RU | EN |
|---|---|---|---|
| `review.count` | {count} rəy | {count} отз. | {count} reviews |
| `review.empty_subtitle` | Tamamlanmış sifarişlərdən sonra rəylər burada görünəcək. | Отзывы появятся здесь после завершённых заказов. | Reviews show up here after completed orders. |
| `review.empty_title` | Hələ rəy yoxdur | Пока нет отзывов | No reviews yet |
| `review.moderation_note` | Rəylər dərc olunmadan öncə yoxlanılır. | Отзывы проверяются перед публикацией. | Reviews are checked before they're published. |
| `review.reply_button` | Cavab yaz | Ответить | Reply |
| `review.reply_field_label` | Cavabınız | Ваш ответ | Your reply |
| `review.reply_hint` | Cavabını yaz… | Напишите ответ… | Write your reply… |
| `review.reply_pending` | Cavabınız yoxlanılır | Ваш ответ проверяется | Your reply is under review |
| `review.reply_sent` | Cavab göndərildi. | Ответ отправлен. | Reply sent. |
| `review.reply_submit` | Cavabı göndər | Отправить ответ | Send reply |
| `review.reply_submitted` | Cavabınız moderasiyaya göndərildi. | Ваш ответ отправлен на модерацию. | Your reply was sent for review. |
| `review.reply_title` | Cavab yaz | Ответить | Write a reply |
| `review.request_sent` | Rəy istəyi göndərildi. | Запрос на отзыв отправлен. | Review request sent. |
| `review.submitted` | Rəyiniz moderasiyaya göndərildi. | Ваш отзыв отправлен на модерацию. | Your review was sent for review. |
| `review.tab` | Rəylər | Отзывы | Reviews |
| `review.verified_shipment` | Təsdiqlənmiş sifariş | Подтверждённый заказ | Verified order |
| `review.your_reply` | Sizin cavabınız | Ваш ответ | Your reply |

## search  (71)

| key | AZ | RU | EN |
|---|---|---|---|
| `search.advanced` | Ətraflı axtarış | Расширенный поиск | Advanced search |
| `search.alert_active` | Bildiriş aktiv | Уведомление активно | Alert on |
| `search.applied_hint` | Filtrlər tətbiq olunur · «Ətraflı»-ya yenidən basıb yığmaq olar | Фильтры применены · нажмите «Подробнее» ещё раз, чтобы свернуть | Filters applied · tap «More» again to collapse |
| `search.date_from` | Başlanğıc | Начало | Start |
| `search.date_to` | Son | Конец | End |
| `search.end_subtitle` | Başqa marşrutu yoxla | Попробуйте другой маршрут | Try another route |
| `search.end_title` | Nəticələrin sonu | Конец результатов | End of results |
| `search.filter` | Filtrlə | Фильтр | Filter |
| `search.filter_any` | Fərqi yoxdur | Не важно | Any |
| `search.filter_date` | Tarix aralığı | Диапазон дат | Date range |
| `search.filter_package_type` | Bağlama növləri | Типы посылок | Package types |
| `search.filter_price` | Qiymət aralığı | Диапазон цены | Price range |
| `search.filter_rating` | Reytinq | Рейтинг | Rating |
| `search.filter_tier` | İstifadəçi səviyyəsi | Уровень пользователя | User level |
| `search.filter_type` | Elan tipi | Тип объявления | Listing type |
| `search.filter_weight` | Çəki aralığı | Диапазон веса | Weight range |
| `search.filter_weight_price` | Çəki və qiymət | Вес и цена | Weight and price |
| `search.filters_title` | Ətraflı axtarış | Расширенный поиск | Advanced search |
| `search.following` | İzləyirsiniz | Вы подписаны | Following |
| `search.following_only` | Yalnız izlədiyim istifadəçilər | Только те, на кого я подписан | Only users I follow |
| `search.from_placeholder` | Haradan | Откуда | From |
| `search.hero_subtitle` | Haradan hara göndərmək istəyirsən? | Откуда и куда отправляете? | Where are you sending from and to? |
| `search.hero_title` | Marşrutu axtar | Поиск маршрута | Find a route |
| `search.last_check_template` | Son yoxlama: {time} | Последняя проверка: {time} | Last checked: {time} |
| `search.network_error_subtitle` | İnternet bağlantını yoxla | Проверьте подключение к интернету | Check your internet connection |
| `search.network_error_title` | Bağlantı yoxdur | Нет соединения | No connection |
| `search.price_max` | Maks $ | Макс $ | Max $ |
| `search.price_min` | Min $ | Мин $ | Min $ |
| `search.recent_title` | Son axtarışlar | Недавние поиски | Recent searches |
| `search.results_count_template` | {count} nəticə | Результатов: {count} | {count} results |
| `search.save_current` | Axtarışı saxla | Сохранить поиск | Save search |
| `search.save_error` | Axtarışı saxlamaq alınmadı. Yenidən cəhd edin. | Не удалось сохранить поиск. Попробуйте ещё раз. | Couldn't save search. Please try again. |
| `search.save_name_hint` | Şablonun adı | Название шаблона | Template name |
| `search.save_notify` | Yeni uyğun elanlar barədə bildiriş al | Получать уведомления о новых подходящих объявлениях | Get notified about new matching listings |
| `search.save_subtitle` | Bu filtrləri şablon kimi saxla və sonra bir toxunuşla yenidən aç. | Сохраните эти фильтры как шаблон и открывайте их одним касанием. | Save these filters as a template and reopen them with one tap. |
| `search.save_title` | Axtarışı saxla | Сохранить поиск | Save search |
| `search.saved_created` | Axtarış yadda saxlanıldı. | Поиск сохранён. | Search saved. |
| `search.saved_empty` | Hələ saxlanmış axtarış yoxdur. | Пока нет сохранённых поисков. | No saved searches yet. |
| `search.saved_short` | Saxlanmışlar | Сохранённые | Saved |
| `search.saved_state` | Saxlanıldı | Сохранено | Saved |
| `search.saved_success` | Axtarış yadda saxlanıldı. | Поиск сохранён. | Search saved. |
| `search.saved_title` | Saxlanmış axtarışlar | Сохранённые поиски | Saved searches |
| `search.segment_route` | Marşrut | Маршрут | Route |
| `search.segment_user` | İstifadəçi | Люди | People |
| `search.show_results` | Nəticələri göstər | Показать результаты | Show results |
| `search.sort_title` | Sıralama | Сортировка | Sorting |
| `search.to_placeholder` | Hara | Куда | To |
| `search.type_all` | Hamısı | Все | All |
| `search.type_shipment` | Göndəriş | Отправление | Shipment |
| `search.type_trip` | Səfər | Поездка | Trip |
| `search.user_clear` | Təmizlə | Очистить | Clear |
| `search.user_deliveries_template` | {count} çatdırılma | {count} доставок | {count} deliveries |
| `search.user_empty_subtitle` | «{query}» üzrə nəticə yoxdur. Adı və ya @username-i yoxla. | Нет результатов по «{query}». Проверьте имя или @username. | No results for «{query}». Check the name or @username. |
| `search.user_empty_title` | Heç kim tapılmadı | Никого не найдено | No one found |
| `search.user_follow` | İzlə | Подписаться | Follow |
| `search.user_following` | İzlənilir | Вы подписаны | Following |
| `search.user_loading_more` | Daha çox yüklənir… | Загрузка ещё… | Loading more… |
| `search.user_min_chars` | Ən azı 2 simvol daxil edin | Введите минимум 2 символа | Enter at least 2 characters |
| `search.user_network_error` | Bağlantı yoxdur — nəticələr yüklənmədi | Нет соединения — результаты не загрузились | No connection — results didn't load |
| `search.user_new_no_rating` | Yeni istifadəçi · reytinq yoxdur | Новый пользователь · нет рейтинга | New user · no rating |
| `search.user_prompt_subtitle` | İnsanları adı, soyadı və ya istifadəçi adı ilə tap. | Ищите людей по имени, фамилии или нику. | Find people by name, surname or username. |
| `search.user_prompt_title` | Ad və ya @username ilə axtar | Поиск по имени или @username | Search by name or @username |
| `search.user_rate_limit_prefix` | Çox tez-tez axtarış —  | Слишком частые запросы —  | Too many searches —  |
| `search.user_rate_limit_suffix` |  sonra yenidən cəhd et |  повторите попытку |  try again |
| `search.user_recent_title` | Son axtarışlar | Недавние поиски | Recent searches |
| `search.user_retry` | Təkrar | Повторить | Retry |
| `search.user_search_hint` | Ad, soyad və ya @username | Имя, фамилия или @username | Name, surname or @username |
| `search.verified` | Təsdiqlənmiş | Проверен | Verified |
| `search.verified_only` | Yalnız təsdiqlənmiş istifadəçilər | Только проверенные пользователи | Verified users only |
| `search.weight_max` | Maks kq | Макс кг | Max kg |
| `search.weight_min` | Min kq | Мин кг | Min kg |

## settings  (23)

| key | AZ | RU | EN |
|---|---|---|---|
| `settings.notif_critical_note` | Hesab və təhlükəsizlik bildirişləri (giriş, parol, təsdiq, xəbərdarlıq) həmişə göndərilir və söndürülə bilməz. | Уведомления об аккаунте и безопасности (вход, пароль, подтверждение, предупреждение) отправляются всегда и не могут быть отключены. | Account and security notifications (login, password, verification, alerts) are always sent and can't be turned off. |
| `settings.notif_email_subtitle` | Vacib yeniliklər e-poçtla | Важные новости по эл. почте | Important updates by email |
| `settings.notif_follows_subtitle` | Yeni izləyici və elanları | Новые подписчики и их объявления | New followers and their listings |
| `settings.notif_follows_title` | İzləmə | Подписки | Follows |
| `settings.notif_group_categories` | Kateqoriyalar | Категории | Categories |
| `settings.notif_group_channels` | Kanallar | Каналы | Channels |
| `settings.notif_group_quiet` | Sakit saatlar | Тихие часы | Quiet hours |
| `settings.notif_listings_subtitle` | Təsdiq, rədd, vaxt, uyğun elan | Одобрение, отклонение, срок, подходящее объявление | Approval, rejection, expiry, matching listings |
| `settings.notif_listings_title` | Elanlar | Объявления | Listings |
| `settings.notif_marketing_subtitle` | Kampaniya və elanlar | Акции и анонсы | Promotions and announcements |
| `settings.notif_marketing_title` | Yeniliklər & təkliflər | Новости и предложения | News & offers |
| `settings.notif_messages_subtitle` | Yeni və cavabsız mesajlar | Новые и неотвеченные сообщения | New and unanswered messages |
| `settings.notif_messages_title` | Mesajlar | Сообщения | Messages |
| `settings.notif_push_subtitle` | Telefona anında bildiriş | Мгновенные уведомления на телефон | Instant alerts on your phone |
| `settings.notif_push_title` | Push bildirişlər | Push-уведомления | Push notifications |
| `settings.notif_quiet_range_label` | Başlanğıc — son | Начало — конец | Start — end |
| `settings.notif_quiet_subtitle` | Seçilən saatlarda push gəlməz | В выбранные часы push не приходит | No push during selected hours |
| `settings.notif_quiet_title` | Push-u sakitləşdir | Отключить push | Mute push |
| `settings.notif_reviews_subtitle` | Yeni rəy və xatırlatma | Новые отзывы и напоминания | New reviews and reminders |
| `settings.notif_saved` | Ayarlar saxlandı. | Настройки сохранены. | Settings saved. |
| `settings.notif_saved_search_subtitle` | Axtarışınıza uyğun yeni elan | Новые объявления по вашему запросу | New listings matching your search |
| `settings.notif_shipments_subtitle` | Təklif, çatdırılma, sifariş | Предложение, доставка, заказ | Offers, delivery, orders |
| `settings.notif_shipments_title` | Sövdələşmə & təkliflər | Сделки и предложения | Deals & offers |

## sort  (8)

| key | AZ | RU | EN |
|---|---|---|---|
| `sort.date_asc` | Ən köhnə | Сначала старые | Oldest |
| `sort.date_desc` | Ən yeni | Сначала новые | Newest |
| `sort.price_asc` | Qiymət: aşağıdan | Цена: по возрастанию | Price: low to high |
| `sort.price_desc` | Qiymət: yuxarıdan | Цена: по убыванию | Price: high to low |
| `sort.rating_desc` | Ən yüksək reytinq | Самый высокий рейтинг | Highest rating |
| `sort.relevance` | Uyğunluq | Релевантность | Relevance |
| `sort.weight_asc` | Çəki: azdan | Вес: по возрастанию | Weight: low to high |
| `sort.weight_desc` | Çəki: çoxdan | Вес: по убыванию | Weight: high to low |

## support  (22)

| key | AZ | RU | EN |
|---|---|---|---|
| `support.attach_image` | Şəkil əlavə et (ops.) | Прикрепить фото (необяз.) | Attach image (optional) |
| `support.attach_image_soon` | Şəkil əlavə etmə tezliklə | Прикрепление фото скоро | Image attachments coming soon |
| `support.close` | Bağla | Закрыть | Close |
| `support.message_hint` | Problemi və ya sualını ətraflı yaz… | Опишите проблему или вопрос подробнее… | Describe your problem or question… |
| `support.message_label` | Mesaj | Сообщение | Message |
| `support.response_time_prefix` | Adətən | Обычно отвечаем в течение | We usually reply within |
| `support.response_time_suffix` | ərzində cavablayırıq. Sorğunu ətraflı yaz. | . Опишите запрос подробнее. | . Please describe your request in detail. |
| `support.response_time_value` | 24 saat | 24 часов | 24 hours |
| `support.send_failed` | Göndərilmədi. Yenidən yoxla. | Не отправлено. Попробуйте снова. | Not sent. Please try again. |
| `support.sent_ref_prefix` | Müraciət nömrən | Номер вашего обращения | Your request number |
| `support.sent_ref_suffix` | . Cavabı e-poçt və bildirişlə alacaqsan. | . Ответ придёт на эл. почту и в уведомлениях. | . You'll get a reply by email and notification. |
| `support.sent_title` | Mesajın göndərildi | Сообщение отправлено | Your message was sent |
| `support.subject_hint` | Qısa başlıq | Краткий заголовок | Short title |
| `support.subject_label` | Başlıq | Заголовок | Title |
| `support.submit` | Göndər | Отправить | Send |
| `support.topic_account` | Hesab | Аккаунт | Account |
| `support.topic_general` | Ümumi | Общее | General |
| `support.topic_label` | Mövzu | Тема | Topic |
| `support.topic_payment` | Ödəniş | Оплата | Payment |
| `support.topic_suggestion` | Təklif | Предложение | Suggestion |
| `support.topic_technical` | Texniki | Техническое | Technical |
| `support.validation_required` | Başlıq və mesajı doldur. | Заполните заголовок и сообщение. | Please fill in the title and message. |

## tier  (49)

| key | AZ | RU | EN |
|---|---|---|---|
| `tier.badge_comeback` | Geri qayıt | Вернуться | Come back |
| `tier.badge_current` | Cari | Текущий | Current |
| `tier.badge_ready` | Hazır | Готово | Ready |
| `tier.bronze_plus` | Bürünc+ | Бронза+ | Bronze+ |
| `tier.deliveries_done` | Çatdırılma kifayətdir ✓ | Доставок достаточно ✓ | Deliveries are enough ✓ |
| `tier.deliveries_first` | İlk çatdırılmanı tamamla | Выполните первую доставку | Complete your first delivery |
| `tier.deliveries_remaining_template` | {count} çatdırılma qalıb | Осталось доставок: {count} | {count} deliveries left |
| `tier.demoted_body_template` | Reytinqin dəyişdiyi üçün səviyyən {from} → {to} oldu. Tələbləri tamamlayaraq geri qayıda bilərsən. | Из-за изменения рейтинга ваш уровень стал {from} → {to}. Выполните условия, чтобы вернуться. | Because your rating changed, your level went {from} → {to}. Complete the requirements to get it back. |
| `tier.demoted_title` | Səviyyən dəyişdi | Ваш уровень изменился | Your level changed |
| `tier.error_body` | Statusunu yükləyə bilmədik. İnternet bağlantını yoxla və yenidən cəhd et. | Не удалось загрузить статус. Проверьте подключение к интернету и попробуйте снова. | We couldn't load your status. Check your connection and try again. |
| `tier.error_title` | Yüklənmədi | Не загрузилось | Couldn't load |
| `tier.footer_count_template` | {count} şərt qalıb | Осталось условий: {count} | {count} requirements left |
| `tier.footer_first` | İlk sifarişini tamamla və yüksəl! | Выполните первый заказ и повысьтесь! | Complete your first order and level up! |
| `tier.footer_first_review` | İlk rəyini al — yüksəlmək üçün reytinq lazımdır | Получите первый отзыв — для повышения нужен рейтинг | Get your first review — you need a rating to level up |
| `tier.footer_rating` | Reytinqini yüksəlt | Повысьте рейтинг | Raise your rating |
| `tier.gold_plus` | Qızıl+ | Золото+ | Gold+ |
| `tier.hero_sub_new` | Səyahətinə yenicə başladın 👋 | Вы только начали свой путь 👋 | You've just started your journey 👋 |
| `tier.hero_sub_template` | Sən {tier} səviyyədəsən | Вы на уровне {tier} | You're at {tier} level |
| `tier.kyc_button` | Hesabını təsdiqlə | Подтвердите аккаунт | Verify your account |
| `tier.kyc_button_big` | Hesabı təsdiqlə | Подтвердить аккаунт | Verify account |
| `tier.kyc_label` | Hesab təsdiqi (KYC) | Подтверждение аккаунта (KYC) | Account verification (KYC) |
| `tier.kyc_unverified` | Təsdiqlənməyib | Не подтверждено | Not verified |
| `tier.kyc_verified` | Təsdiqlənib | Подтверждено | Verified |
| `tier.ladder_kyc_legend` | Yuxarı səviyyələr üçün hesab təsdiqi (KYC) tələb olunur | Для высоких уровней требуется подтверждение аккаунта (KYC) | Account verification (KYC) is required for higher levels |
| `tier.ladder_title` | Bütün səviyyələr | Все уровни | All levels |
| `tier.laststep_caption` | Təsdiqdən dərhal sonra yüksələcəksən | Вы повыситесь сразу после подтверждения | You'll level up right after verification |
| `tier.laststep_sub` | Çatdırılma və reytinqin hazırdır — yalnız hesab təsdiqi qalıb. | Доставки и рейтинг готовы — осталось только подтвердить аккаунт. | Your deliveries and rating are ready — only account verification is left. |
| `tier.laststep_title_template` | {tier} səviyyəsinə son addım! | Последний шаг до уровня {tier}! | One last step to {tier} level! |
| `tier.max_badge` | Ən yüksək səviyyədəsən 🏆 | Вы на высшем уровне 🏆 | You're at the top level 🏆 |
| `tier.metric_deliveries_template` | {count} çatdırılma | {count} доставок | {count} deliveries |
| `tier.metric_no_rating` | reytinq yoxdur | нет рейтинга | no rating yet |
| `tier.metric_rating_template` | {rating} reytinq | рейтинг {rating} | {rating} rating |
| `tier.note` | Səviyyə reytinqindən asılıdır — reytinqin düşsə səviyyə dəyişə bilər, qalxsa geri qayıdır. | Уровень зависит от рейтинга — если он упадёт, уровень может измениться, а при росте вернётся. | Your level depends on your rating — if it drops your level can change, and it comes back when it rises. |
| `tier.platinum` | Platin | Платина | Platinum |
| `tier.progress_title_template` | {tier} səviyyəsinə keçmək üçün | Чтобы перейти на уровень {tier} | To reach {tier} level |
| `tier.range_open_template` | {min}+ çatdırılma | {min}+ доставок | {min}+ deliveries |
| `tier.range_rating_template` |  · reytinq {min}+ |  · рейтинг {min}+ |  · rating {min}+ |
| `tier.range_single_template` | {n} çatdırılma | {n} доставок | {n} deliveries |
| `tier.range_span_template` | {min}-{max} çatdırılma | {min}-{max} доставок | {min}-{max} deliveries |
| `tier.rating_done` | Reytinq kifayətdir ✓ | Рейтинга достаточно ✓ | Rating is enough ✓ |
| `tier.rating_none` | Hələ reytinqin yoxdur | У вас пока нет рейтинга | You don't have a rating yet |
| `tier.rating_remaining_template` | min {min} lazımdır — hazırda {cur} · {gap} qalıb | нужно мин. {min} — сейчас {cur} · осталось {gap} | min {min} required — currently {cur} · {gap} to go |
| `tier.ready_sub` | Növbəti çatdırılmadan sonra yüksələcəksən. | Вы повысите уровень после следующей доставки. | You'll level up after your next delivery. |
| `tier.ready_title_template` | {tier} səviyyəsinə hazırsan! | Вы готовы к уровню {tier}! | You're ready for {tier} level! |
| `tier.req_deliveries` | Çatdırılma | Доставки | Deliveries |
| `tier.req_rating_template` | Reytinq (min {min}) | Рейтинг (мин. {min}) | Rating (min {min}) |
| `tier.silver_plus` | Gümüş+ | Серебро+ | Silver+ |
| `tier.tier_start` | Başlanğıc | Начало | Start |
| `tier.title` | Statusum | Мой статус | My status |

## time  (6)

| key | AZ | RU | EN |
|---|---|---|---|
| `time.days_ago` | {n} gün əvvəl | {n} дн. назад | {n} days ago |
| `time.days_ago_template` | {count} gün əvvəl | {count} дн. назад | {count} days ago |
| `time.hours_ago_template` | {count} saat əvvəl | {count} ч. назад | {count} hours ago |
| `time.now` | indi | сейчас | now |
| `time.today` | bugün | сегодня | today |
| `time.yesterday` | dünən | вчера | yesterday |

## validation  (8)

| key | AZ | RU | EN |
|---|---|---|---|
| `validation.cities_must_differ` | Şəhərlər fərqli olmalıdır. | Города должны отличаться. | Cities must be different. |
| `validation.city_required` | Şəhər seçin. | Выберите город. | Select a city. |
| `validation.date_required` | Tarix seçin. | Выберите дату. | Select a date. |
| `validation.end_date_after_start` | Son tarix başlanğıc tarixindən sonra olmalıdır. | Дата окончания должна быть позже даты начала. | The end date must be after the start date. |
| `validation.package_required` | Ən azı bir bağlama növü seçin. | Выберите хотя бы один тип посылки. | Select at least one package type. |
| `validation.price_required` | Qiymət daxil edin. | Укажите цену. | Enter the price. |
| `validation.time_required` | Saat seçin. | Выберите время. | Select a time. |
| `validation.weight_required` | Çəki daxil edin. | Укажите вес. | Enter the weight. |

## verification  (2)

| key | AZ | RU | EN |
|---|---|---|---|
| `verification.doc_types_load_failed` | Sənəd növləri yüklənə bilmədi. Yenidən cəhd et. | Не удалось загрузить типы документов. Попробуйте снова. | Couldn't load document types. Try again. |
| `verification.submit_failed` | Göndərmək alınmadı. Yenidən cəhd et. | Не удалось отправить. Попробуйте снова. | Submission failed. Try again. |

