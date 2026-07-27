# Code migration map — hardcoded strings that ALREADY have a CMS key

These strings are rendered as Dart literals but the CMS already serves the text.
Replace each literal with `t('<key>')`. **No backend action** — client-side only.

Total: 177 unique strings across 37 files.

## screens/auth/auth_modal/auth_welcome_screen.dart
- L94: `Daxil ol` → `t('onboarding.login')`

## screens/auth/email_verify/email_verify_screen.dart
- L40: `Təsdiq linki email-inizə göndərildi.` → `t('auth.email_verify_sent')`
- L123: `Davam et` → `t('common.continue')`

## screens/auth/forgot_password/forgot_password_screen.dart
- L350: `Təsdiqlə` → `t('notifications.action.confirm')`
- L479: `Daxil ol` → `t('onboarding.login')`

## screens/auth/login/login_screen.dart
- L215: `Daxil ol` → `t('onboarding.login')`

## screens/auth/registration/registration_screen.dart
- L305: `Məxfilik siyasəti` → `t('legal.privacy.title')`
- L375: `Hesabın var? ` → `t('onboarding.have_account')`
- L381: `Daxil ol` → `t('onboarding.login')`

## screens/chat/widgets/deal_pin_bar.dart
- L110: `Mal götürüldü` → `t('enum.card_type.picked_up')`
- L111: `Çatdırıldı` → `t('enum.card_type.delivered')`
- L112: `Mübahisəli` → `t('enum.shipment_status.disputed')`
- L113: `Tamamlandı` → `t('deals.terms.completed_at')`
- L114: `Avtomatik tamamlandı` → `t('enum.card_type.auto_completed')`

## screens/chat/widgets/message_bubble.dart
- L770: `Qəbul` → `t('deals.step.accepted')`
- L897: `Problem bildirildi` → `t('enum.card_type.disputed')`
- L1203: `Təklif qəbul edildi` → `t('notification.proposal_accepted.title')`
- L1204: `Təklif rədd edildi` → `t('notification.proposal_declined.title')`
- L1205: `Mal götürüldü` → `t('enum.card_type.picked_up')`
- L1206: `Çatdırıldı` → `t('enum.card_type.delivered')`
- L1208: `Avtomatik tamamlandı` → `t('enum.card_type.auto_completed')`
- L1210: `Ləğv edildi` → `t('enum.card_type.cancelled')`
- L1211: `Vaxtı keçdi` → `t('enum.card_type.expired')`
- L1212: `Təklif` → `t('deals.step.proposal')`
- L1237: `Digər` → `t('deals.dispute_reason.other')`

## screens/home/tabs/create_post/create_post_screen.dart
- L93: `Bürünc` → `t('enum.user_tier.bronze')`
- L95: `Gümüş` → `t('enum.user_tier.silver')`
- L97: `Qızıl` → `t('enum.user_tier.gold')`

## screens/home/tabs/home_tab/home_tab_screen.dart
- L162: `VİP elanlar` → `t('promotion.section.vip')`

## screens/home/tabs/home_tab/notification/notification_screen.dart
- L1189: `Bu gün` → `t('common.today')`
- L1190: `dünən` → `t('common.yesterday')`

## screens/home/tabs/home_tab/widget/search_form_page.dart
- L1199: `Səfər` → `t('deals.terms.travel')`
- L1202: `Göndəriş` → `t('enum.listing_type.shipment_post')`

## screens/home/tabs/listings/details/listing_details_screen.dart
- L513: `Elan seçilmişlərdən çıxarıldı.` → `t('listing.unfavorited')`
- L520: `Elanı dayandır?` → `t('my_listings.pause_confirm_title')`
- L522: `Bu elan lentdən çıxacaq və istifadəçilər onu görməyəcək. Davam edək?` → `t('my_listings.pause_confirm_message')`
- L523: `Dayandır` → `t('common.pause')`
- L533: `Əməliyyat alınmadı.` → `t('common.operation_failed')`
- L539: `Elanı aktivləşdir?` → `t('my_listings.resume_confirm_title')`
- L540: `Elan yenidən lentdə görünəcək. Davam edək?` → `t('my_listings.resume_confirm_message')`
- L541: `Aktiv et` → `t('my_listings.resume')`
- L559: `Yenidən paylaş?` → `t('my_listings.repost_confirm_title')`
- L560: `Elan yeni tarixlə yenidən dərc olunacaq. Davam edək?` → `t('my_listings.repost_confirm_message')`
- L561: `Yenidən paylaş` → `t('my_listings.repost')`
- L618: `Elanı sil?` → `t('my_listings.delete_confirm_title')`
- L619: `Bu əməliyyat geri qaytarılmır. Davam etmək istəyirsən?` → `t('my_listings.delete_confirm_message')`
- L835: `Ləğv et` → `t('deals.action.cancel')`
- L1081: `Səfər` → `t('deals.terms.travel')`
- L1169: `VİP` → `t('enum.promotion_type.vip')`
- L1169: `Önə çıxarılan` → `t('enum.promotion_type.featured')`
- L1641: `Çəki` → `t('create.chip.weight')`
- L1811: `Qiymət` → `t('deals.terms.price')`
- L2123: `Bağlama növü` → `t('create.chip.package_type')`
- L2235: `Hamısı` → `t('chat.tab.all')`
- L2491: `Göndəriş` → `t('enum.listing_type.shipment_post')`
- L3139: `Söhbətə keç` → `t('deals.action.message')`
- L3245: `Bağlama` → `t('deals.terms.package')`
- L3964: `Planlarım dəyişdi` → `t('enum.listing_delete_reason.plans_changed')`
- L3965: `Başqa variant tapdım` → `t('enum.listing_delete_reason.found_another')`
- L3966: `Artıq lazım deyil` → `t('enum.listing_delete_reason.no_longer_needed')`
- L3967: `Səhvən yaratdım` → `t('enum.listing_delete_reason.created_by_mistake')`
- L3968: `Digər` → `t('deals.dispute_reason.other')`
- L4138: `Rədd edildi` → `t('enum.card_type.declined')`
- L4149: `Dayandırılıb` → `t('enum.listing_status.paused')`
- L4160: `Vaxtı keçib` → `t('enum.listing_status.expired')`
- L4242: `dünən` → `t('common.yesterday')`

## screens/home/tabs/listings/promotion/promotion_screens.dart
- L190: `Yenidən cəhd et` → `t('block.retry')`
- L702: `Bank kartı` → `t('enum.payment_method.card')`
- L720: `Wawatair balans` → `t('enum.payment_method.balance')`
- L743: `Ödənişlər şifrələnir · kart məlumatı serverdə saxlanmır` → `t('promotion.pay.secure_note')`
- L917: `Ödəniş emal olunur…` → `t('promotion.pay.processing')`
- L930: `Zəhmət olmasa gözlə. Bu ekranı bağlama.` → `t('promotion.pay.processing_hint')`
- L1693: `Ödənişə keç` → `t('promotion.cta.checkout')`
- L2238: `Səfər` → `t('deals.terms.travel')`
- L2243: `Göndəriş` → `t('enum.listing_type.shipment_post')`
- L3503: `Önə çıxarılan` → `t('enum.promotion_type.featured')`

## screens/home/tabs/listings/widgets/listing_card.dart
- L221: `Göndəriş` → `t('enum.listing_type.shipment_post')`
- L221: `Səfər` → `t('deals.terms.travel')`
- L228: `VİP` → `t('enum.promotion_type.vip')`
- L236: `Önə çıxarılan` → `t('enum.promotion_type.featured')`
- L379: `Çəki` → `t('create.chip.weight')`
- L715: `Aktiv et` → `t('my_listings.resume')`
- L715: `Dayandır` → `t('common.pause')`
- L804: `VİP et` → `t('promotion.cta.vip')`
- L820: `Önə çək` → `t('promotion.cta.boost')`
- L1441: `Bürünc` → `t('enum.user_tier.bronze')`
- L1443: `Gümüş` → `t('enum.user_tier.silver')`
- L1445: `Qızıl` → `t('enum.user_tier.gold')`

## screens/home/tabs/profile_tab/about/about_screen.dart
- L102: `Tətbiq haqqında` → `t('menu.about')`
- L126: `Tətbiqi qiymətləndir` → `t('menu.rate_app')`
- L133: `Məxfilik siyasəti` → `t('legal.privacy.title')`

## screens/home/tabs/profile_tab/blocked_users/blocked_users_api.dart
- L29: `Blok götürüldü.` → `t('chat.unblocked_user')`

## screens/home/tabs/profile_tab/blocked_users/blocked_users_screen.dart
- L115: `Bloklanmış istifadəçilər` → `t('block.title')`
- L176: `Blokladığınız istifadəçilər sizə mesaj yaza və elanlarınıza baxa bilməz.` → `t('block.subtitle')`
- L230: `Cəmi :count istifadəçi` → `t('block.count')`
- L257: `Yüklənir…` → `t('block.loading_more')`
- L433: `Blokdan çıxar` → `t('block.unblock')`
- L549: `:name yenidən sizə mesaj yaza və elanlarınıza baxa biləcək.` → `t('block.confirm.body')`
- L579: `Bloku açmaq?` → `t('block.confirm.title')`
- L643: `Açılır…` → `t('block.unblocking')`
- L648: `Bloku aç` → `t('block.confirm.action')`
- L673: `İmtina et` → `t('block.cancel')`
- L770: `Bloklanmış istifadəçi yoxdur` → `t('block.empty.title')`
- L784: `Kimisə bloklasanız, burada görünəcək. Söhbətdə və ya profildə «Blokla» ilə bloklaya bilərsiniz.` → `t('block.empty.body')`
- L846: `İnternet bağlantısını yoxlayıb yenidən cəhd edin.` → `t('block.error.body')`
- L888: `Yenidən cəhd et` → `t('block.retry')`

## screens/home/tabs/profile_tab/deals/deal_action_sheets.dart
- L19: `Mal çatmadı` → `t('deals.dispute_reason.not_delivered')`
- L20: `Mal zədəli / əskik` → `t('deals.dispute_reason.damaged')`
- L21: `Əlaqə kəsildi` → `t('deals.dispute_reason.no_contact')`
- L22: `Digər` → `t('deals.dispute_reason.other')`
- L178: `Qarşı təklif` → `t('deals.action.counter')`
- L191: `Şərtləri dəyişib göndər — qarşı tərəf təsdiqləyəcək.` → `t('deals.counter.hint')`
- L216: `Qeyd (istəyə bağlı)` → `t('deals.note_optional')`
- L244: `Qarşı təklifi göndər` → `t('deals.counter.submit')`
- L290: `Sövdələşməni ləğv et` → `t('deals.cancel.title')`
- L303: `Səbəbi seçin — qarşı tərəfə bildiriləcək.` → `t('deals.cancel.hint')`
- L397: `Problem bildir` → `t('deals.action.dispute')`
- L410: `Nə baş verdiyini yazın — admin araşdıracaq. Sövdələşmə «Mübahisəli» statusuna keçəcək.` → `t('deals.dispute.hint')`
- L459: `Problemi göndər` → `t('deals.dispute.submit')`
- L544: `Bəli, təsdiqlə` → `t('deals.confirm.yes')`
- L644: `Təcrübəni bir neçə sözlə yaz…` → `t('deals.review.prompt')`
- L708: `Rəyi göndər` → `t('deals.review.submit')`

## screens/home/tabs/profile_tab/deals/deal_detail_screen.dart
- L194: `Söhbətə keç` → `t('deals.action.message')`
- L251: `3 gün ərzində təsdiq etməsəniz, sövdələşmə avtomatik tamamlanacaq.` → `t('deals.auto_complete_hint')`
- L275: `Komandamız hər iki tərəflə əlaqə saxlayacaq. Söhbətdə əlavə məlumat verə bilərsiniz.` → `t('deals.dispute.admin_note')`
- L412: `Bu əməldən sonra sövdələşmə tamamlanmış sayılacaq və geri qaytarıla bilməz.` → `t('deals.confirm.complete.body')`
- L445: `Malı aldığınızı təsdiqləyirsiniz?` → `t('deals.confirm.complete.title')`
- L498: `Cavab gözlənilir` → `t('deals.awaiting_reply')`
- L502: `Mal yoldadır` → `t('deals.sub.picked_up_sender')`
- L517: `Sizə yeni təklif gəlib — cavab verin` → `t('deals.sub.pending_me')`
- L518: `Təklifiniz göndərildi · qarşı tərəf cavab verməlidir` → `t('deals.sub.pending_them')`
- L527: `Razılaşma bağlandı · malı göndərəndən götürün` → `t('deals.sub.accepted_carrier')`
- L528: `Razılaşma bağlandı · daşıyıcı malı götürəcək` → `t('deals.sub.accepted_sender')`
- L895: `Mal götürüldü` → `t('enum.card_type.picked_up')`
- L903: `Çatdırıldı` → `t('enum.card_type.delivered')`
- L911: `Tamamlandı` → `t('deals.terms.completed_at')`
- L998: `Daşıyıcı` → `t('deals.role.carrier')`
- L998: `Göndərən` → `t('deals.role.sender')`
- L1223: `Yenidən təklif et` → `t('deals.action.repropose')`
- L1245: `Digər daşıyıcılara bax` → `t('deals.action.browse')`
- L1288: `Təklifi geri götür` → `t('deals.action.withdraw')`
- L1474: `Yüklənmədi. İnternet bağlantısını yoxlayın.` → `t('deals.error.load')`

## screens/home/tabs/profile_tab/deals/deals_list_screen.dart
- L251: `Tarixçə` → `t('deals.section.history')`
- L268: `Hamısı` → `t('chat.tab.all')`
- L275: `Göndərən kimi` → `t('deals.filter.as_sender')`
- L282: `Daşıyıcı kimi` → `t('deals.filter.as_carrier')`
- L443: `Hələ sövdələşməniz yoxdur` → `t('deals.empty.title')`
- L455: `Bir elana təklif göndərin və ya birbaşa söhbətdə razılaşın — sövdələşmələr burada görünəcək.` → `t('deals.empty.body')`
- L489: `Necə işləyir?` → `t('deals.how_it_works')`
- L535: `Yüklənmədi. İnternet bağlantısını yoxlayın.` → `t('deals.error.load')`

## screens/home/tabs/profile_tab/deals/widgets/deal_card.dart
- L204: `Malı aldınız? Təsdiqləyin` → `t('deals.confirm_receipt_hint')`
- L343: `Daşıyıcı` → `t('deals.role.carrier')`
- L343: `Göndərən` → `t('deals.role.sender')`

## screens/home/tabs/profile_tab/deals/widgets/deal_status.dart
- L82: `Qəbul et` → `t('deals.action.accept')`
- L83: `Rədd et` → `t('deals.action.decline')`
- L84: `Qarşı təklif` → `t('deals.action.counter')`
- L85: `Malı götürdüm` → `t('deals.action.picked_up')`
- L87: `Çatdırdım` → `t('deals.action.delivered')`
- L88: `Malı aldım, təsdiqlə` → `t('deals.action.complete')`
- L89: `Problem bildir` → `t('deals.action.dispute')`
- L90: `Ləğv et` → `t('deals.action.cancel')`
- L91: `Rəy yaz` → `t('deals.action.review')`
- L140: `Digər` → `t('deals.dispute_reason.other')`

## screens/home/tabs/profile_tab/deals/widgets/deal_stepper.dart
- L23: `Götürüldü` → `t('deals.step.picked_up')`
- L23: `Qəbul` → `t('deals.step.accepted')`
- L23: `Təklif` → `t('deals.step.proposal')`
- L23: `Çatdı` → `t('deals.step.delivered')`

## screens/home/tabs/profile_tab/faq/faq_screen.dart
- L41: `Kömək & FAQ` → `t('menu.help')`
- L382: `Dəstəyə yaz` → `t('menu.contact_support')`

## screens/home/tabs/profile_tab/legal/legal_doc_screen.dart
- L393: `Yenidən cəhd et` → `t('block.retry')`

## screens/home/tabs/profile_tab/new_profile/new_profile_screen.dart
- L337: `Aldığım rəylər` → `t('menu.reviews_received')`
- L347: `Yazdığım rəylər` → `t('menu.reviews_left')`
- L532: `Profili redaktə et` → `t('menu.edit_profile')`
- L614: `Əməliyyat alınmadı.` → `t('common.operation_failed')`
- L728: `Cavabınız moderasiyaya göndərildi.` → `t('review.reply_submitted')`
- L1003: `Hesabınızı təsdiqləyin` → `t('verification.intro_title')`
- L1543: `Tamamlanmış sifarişlərdən sonra rəylər burada görünəcək.` → `t('review.empty_subtitle')`
- L1557: `Rəylər dərc olunmadan öncə yoxlanılır.` → `t('review.moderation_note')`
- L1883: `Cavabınız yoxlanılır` → `t('review.reply_pending')`
- L2098: `İzləyicilər` → `t('menu.followers')`
- L2108: `İzlədiklərim` → `t('menu.following')`
- L2304: `Təsdiqlənməyib` → `t('menu.not_verified_badge')`
- L2334: `Bildiriş ayarları` → `t('menu.notifications')`
- L2378: `Qaydalar & məxfilik siyasəti` → `t('menu.terms')`
- L2593: `Şəkli dəyiş` → `t('verification.replace_photo')`
- L2700: `Avatar silindi.` → `t('profile.avatar_deleted')`
- L2922: `Parolu dəyiş` → `t('menu.change_password')`
- L4915: `Bürünc` → `t('enum.user_tier.bronze')`
- L4916: `Gümüş` → `t('enum.user_tier.silver')`
- L4917: `Qızıl` → `t('enum.user_tier.gold')`

## screens/home/tabs/profile_tab/new_profile/profile_api.dart
- L97: `İzləməyə başladınız.` → `t('social.followed')`
- L103: `İzləmə dayandırıldı.` → `t('social.unfollowed')`
- L109: `İstifadəçi bloklandı.` → `t('chat.blocked_user')`
- L144: `Məxfilik parametrləri yeniləndi.` → `t('profile.privacy_updated')`
- L158: `Parol dəyişdirildi.` → `t('profile.password_changed')`
- L174: `Avatar yeniləndi.` → `t('profile.avatar_updated')`
- L180: `Avatar silindi.` → `t('profile.avatar_deleted')`
- L192: `Cavabınız moderasiyaya göndərildi.` → `t('review.reply_submitted')`
- L210: `Rəyiniz moderasiyaya göndərildi.` → `t('review.submitted')`
- L220: `Rəy istəyi göndərildi.` → `t('review.request_sent')`

## screens/home/tabs/profile_tab/profile_tab_screen.dart
- L250: `Tətbiq dilini seçin.` → `t('menu.language_subtitle')`
- L337: `Çıxış etmək?` → `t('menu.logout_confirm_title')`
- L350: `Yenidən daxil olmaq üçün e-poçt və parolunuz lazım olacaq.` → `t('menu.logout_confirm_message')`
- L385: `İmtina et` → `t('block.cancel')`
- L516: `Saxlanan axtarışlar` → `t('menu.saved_searches')`
- L578: `Profili redaktə et` → `t('menu.edit_profile')`
- L587: `Hesabı təsdiqlə` → `t('menu.verify_account')`
- L594: `Təsdiqlənməyib` → `t('menu.not_verified_badge')`
- L604: `Parolu dəyiş` → `t('menu.change_password')`
- L626: `Bildiriş ayarları` → `t('menu.notifications')`
- L655: `Bloklanmış istifadəçilər` → `t('block.title')`
- L666: `Dəstək & haqqında` → `t('menu.section_support')`
- L685: `Dəstəyə yaz` → `t('menu.contact_support')`
- L693: `Qaydalar & şərtlər` → `t('legal.terms.title')`
- L703: `Məxfilik siyasəti` → `t('legal.privacy.title')`
- L713: `Tətbiqi qiymətləndir` → `t('menu.rate_app')`
- L747: `Hesabı sil` → `t('menu.delete_account')`
- L865: `Profilə bax` → `t('chat.action.profile')`

## screens/home/tabs/profile_tab/promo/app_review.dart
- L275: `1 dəqiqəni ayır, Store-da bizi qiymətləndir — və hədiyyə promokod qazan.` → `t('app_review.subtitle')`
- L486: `Keç` → `t('onboarding.cta.skip')`

## screens/home/tabs/profile_tab/promo/promo_codes_screen.dart
- L788: `Tətbiqi qiymətləndirdiyin üçün` → `t('promo.source.rate_review')`
- L790: `Dostunu dəvət etdiyin üçün` → `t('promo.source.referral')`
- L792: `Xoş gəlmisən bonusu` → `t('promo.source.welcome')`
- L1269: `Yenidən cəhd et` → `t('block.retry')`

## screens/home/tabs/profile_tab/promo/rate_app_screen.dart
- L125: `Tətbiqi qiymətləndir` → `t('menu.rate_app')`
- L142: `Wawatair-i bəyənirsən?` → `t('app_review.title')`
- L150: `1 dəqiqəni ayır, Store-da bizi qiymətləndir — və hədiyyə promokod qazan.` → `t('app_review.subtitle')`
- L165: `Store-da qiymətləndir` → `t('app_review.cta')`
- L213: `Təşəkkür edirik! ⭐️` → `t('app_review.thanks_title')`

## screens/home/tabs/profile_tab/referral/referral_screen.dart
- L158: `Dostunu dəvət et` → `t('menu.invite')`
- L395: `Digər` → `t('deals.dispute_reason.other')`
- L614: `Gözləyir` → `t('enum.app_review_status.pending')`
- L762: `Yenidən cəhd et` → `t('block.retry')`

## screens/home/tabs/profile_tab/reports/reports_api.dart
- L92: `Digər` → `t('deals.dispute_reason.other')`

## screens/home/tabs/profile_tab/reports/reports_screen.dart
- L120: `Rədd edildi` → `t('enum.card_type.declined')`
- L123: `Gözləyir` → `t('enum.app_review_status.pending')`
- L126: `Baxılır` → `t('enum.verification_status.processing')`
- L213: `Şikayətlərim` → `t('menu.my_reports')`
- L470: `Səbəb` → `t('verification.rejection_reason_label')`
- L762: `Yenidən cəhd et` → `t('block.retry')`

## screens/home/tabs/profile_tab/see_more_offers/delivery_full_list_screen.dart
- L541: `Ləğv et` → `t('deals.action.cancel')`

## screens/home/tabs/profile_tab/settings/notification_settings/notification_settings_screen.dart
- L117: `E-poçt` → `t('menu.email')`
- L159: `Rəylər` → `t('menu.reviews')`
- L175: `Saxlanan axtarışlar` → `t('menu.saved_searches')`
- L373: `Bildiriş ayarları` → `t('menu.notifications')`

## screens/home/tabs/profile_tab/support/support_screen.dart
- L44: `Təklif` → `t('deals.step.proposal')`
- L127: `Dəstəyə yaz` → `t('menu.contact_support')`
