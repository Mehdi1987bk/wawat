# Wawatair — CMS keys the backend must add (`GET /content`)

Add every key below to the content service for **all 6 languages** (`az, en, ru, tr, ua, es`).
The **Azerbaijani** text is the source of truth; translate the rest.

## Why
- The app already references **358** content keys. **180 of them are NOT in the CMS today** —
  the app shows the Azerbaijani fallback for these and never localizes them to other languages.
- The rest are strings currently hardcoded in the app that we're migrating to keys.

## Before adding
- **Don't create duplicates.** If the same text already exists under another key, keep one key and tell us which.
- `{x}` = runtime placeholder — keep the exact token in every language.
- Lines marked **⚠ confirm** have provisional AZ copy — please confirm the final wording.

**Total: 301 keys.**

---

## promotion — VIP / boost / payment screens  (54)
- `promotion.action.extend` — Uzat
- `promotion.action.renew` — Yenilə
- `promotion.active_template` — {type} artıq aktivdir
- `promotion.boost_description` — Elanın axtarış və lentdə seçdiyin mövqe zolağında görünəcək.
- `promotion.boost_short` — İlk 10 / 50 / 100 mövqe
- `promotion.checkout.boost_title_template` — Önə çək · {tier}
- `promotion.checkout.duration` — Müddət
- `promotion.checkout.end` — Bitmə
- `promotion.checkout.package` — Paket
- `promotion.checkout.start` — Başlama
- `promotion.checkout.starts_after_approval` — Təsdiqdən dərhal sonra
- `promotion.checkout.vip_title` — VİP promosyon
- `promotion.created_subtitle` — Adətən 1–2 saat ərzində təsdiqlənir. Təsdiqdən sonra lentdə görünəcək.
- `promotion.created_title` — Elanın yoxlamaya göndərildi
- `promotion.cta.boost_too` — Önə də çək
- `promotion.cta.continue_duration` — Davam et — müddət seç
- `promotion.cta.upgrade_tier` — Zolağı yüksəlt
- `promotion.duration.best_value` — Ən sərfəli paket
- `promotion.duration.popular` — Populyar seçim
- `promotion.duration.short_trial` — Qısa sınaq
- `promotion.duration_template` — {days} gün
- `promotion.empty` — Bu bölmədə promosyon yoxdur.
- `promotion.listing_template` — Elan #{id}
- `promotion.my_title` — Promosyonlarım
- `promotion.position_description_template` — Nəticələrin ilk {count}-liyində daha çox baxış
- `promotion.preview_full_title` — Elanın lentdə görünüşü
- `promotion.preview_title` — Lentdə belə görünəcək
- `promotion.pricing_unavailable` — Promosyon paketlərini yükləmək alınmadı.
- `promotion.remaining.days_template` — {days} gün {hours} saat qalıb
- `promotion.remaining.expired` — Müddəti bitib
- `promotion.remaining.hours_template` — {hours} saat qalıb
- `promotion.section.all` — Bütün elanlar
- `promotion.skip` — İndi yox, elanlarıma keç
- `promotion.starting_from` — başlanğıc
- `promotion.status.active_boost` — Elanın indi seçilmiş mövqe zolağında önə çıxarılır.
- `promotion.status.active_vip` — Elanın indi VİP-dir və lentin ən yuxarısında görünəcək.
- `promotion.status.failed` — Kartından məbləğ tutulmadı. Yenidən cəhd edə bilərsən.
- `promotion.status.pending` — Bankın və ya ödəniş provayderinin təsdiqini gözləyirik. Nəticə hazır olanda bildiriş alacaqsan.
- `promotion.step.duration` — Müddət seç
- `promotion.step.extend_duration` — Müddəti artır
- `promotion.step.position` — Mövqe zolağını seç
- `promotion.summary.boost_template` — {tier} · {days} gün
- `promotion.summary.vip_template` — {days} gün VİP
- `promotion.tabs.active_template` — Aktiv ({count})
- `promotion.tabs.expired_template` — Bitmiş ({count})
- `promotion.tier_note` — VİP elanlar həmişə önə çəkilmiş elanların da üstündədir.
- `promotion.upsell_title` — Elanını daha çox insana çatdır
- `promotion.vip_active` — VİP aktiv
- `promotion.vip_benefit.badge` — Tac nişanı və qızılı çərçivə
- `promotion.vip_benefit.section` — Ayrıca «VİP elanlar» bölməsində üst sıra
- `promotion.vip_benefit.views` — Orta hesabla daha çox baxış
- `promotion.vip_benefits_title` — VİP nə qazandırır?
- `promotion.vip_description` — Elanın lentin ən yuxarısında, ayrıca «VİP elanlar» bölməsində görünəcək.
- `promotion.vip_short` — Ən yuxarıda, ayrıca bölmədə

## search — feed & results, filters, sorting  (38)
- `search.advanced` — Ətraflı axtarış
- `search.alert_active` — Bildiriş aktiv
- `search.applied_hint` — Filtrlər tətbiq olunur · «Ətraflı»-ya yenidən basıb yığmaq olar
- `search.date_from` — Başlanğıc
- `search.date_to` — Son
- `search.end_subtitle` — Başqa marşrutu yoxla
- `search.end_title` — Nəticələrin sonu
- `search.filter` — Filtrlə
- `search.filter_any` — Fərqi yoxdur
- `search.filter_date` — Tarix aralığı
- `search.filter_package_type` — Bağlama növləri
- `search.filter_price` — Qiymət aralığı
- `search.filter_rating` — Reytinq
- `search.filter_tier` — İstifadəçi səviyyəsi
- `search.filter_type` — Elan tipi
- `search.filter_weight` — Çəki aralığı
- `search.filter_weight_price` — Çəki və qiymət
- `search.filters_title` — Ətraflı axtarış
- `search.following` — İzləyirsiniz
- `search.following_only` — Yalnız izlədiyim istifadəçilər
- `search.hero_subtitle` — Haradan hara göndərmək istəyirsən?
- `search.hero_title` — Marşrutu axtar
- `search.last_check_template` — Son yoxlama: {time}
- `search.network_error_subtitle` — İnternet bağlantını yoxla
- `search.network_error_title` — Bağlantı yoxdur
- `search.price_max` — Maks ₼
- `search.price_min` — Min ₼
- `search.results_count_template` — {count} nəticə
- `search.saved_empty` — Hələ saxlanmış axtarış yoxdur.
- `search.saved_short` — Saxlanmışlar
- `search.show_results` — Nəticələri göstər
- `search.sort_title` — Sıralama
- `search.type_shipment` — Göndəriş
- `search.type_trip` — Səfər
- `search.verified` — Təsdiqlənmiş
- `search.verified_only` — Yalnız təsdiqlənmiş istifadəçilər
- `search.weight_max` — Maks kq
- `search.weight_min` — Min kq

## profile — public profile & profile actions  (32)
- `profile.avatar_camera` — Kameradan çək
- `profile.avatar_delete` — Şəkli sil
- `profile.avatar_gallery` — Qalereyadan seç
- `profile.avatar_hint` — JPG/PNG/WEBP · maks 10 MB
- `profile.avatar_title` — Profil şəkli
- `profile.change_password` — Parolu dəyiş
- `profile.delete_account` — Hesabı sil
- `profile.deliveries` — Çatdırılma
- `profile.edit` — Profili redaktə et
- `profile.empty_listings_subtitle` — Yeni elan yaratdıqdan sonra burada görünəcək.
- `profile.empty_listings_title` — Hələ elan yoxdur
- `profile.followers` — İzləyici
- `profile.following` — İzləyir
- `profile.help_faq` — Kömək & FAQ
- `profile.language` — Dil
- `profile.listings` — Elanlar
- `profile.load_failed` — Məlumat yüklənmədi.
- `profile.logout` — Çıxış
- `profile.my_listings` — Elanlarım
- `profile.not_verified` — Təsdiqlənməyib
- `profile.notification_settings` — Bildiriş ayarları
- `profile.privacy` — Məxfilik
- `profile.rating` — Reytinq
- `profile.response` — Cavab
- `profile.settings.account` — Hesab
- `profile.settings.preferences` — Tərcihlər
- `profile.settings.support` — Dəstək
- `profile.support` — Dəstək
- `profile.terms_privacy` — Qaydalar & məxfilik siyasəti
- `profile.verification_unavailable` — Təsdiqləmə məlumatı yüklənmədi.
- `profile.verified` — Təsdiqlənib
- `profile.verify_account` — Hesabınızı təsdiqləyin

## settings — notification & account settings  (23)
- `settings.notif_critical_note` — Hesab və təhlükəsizlik bildirişləri (giriş, parol, təsdiq, xəbərdarlıq) həmişə göndərilir və söndürülə bilməz.
- `settings.notif_email_subtitle` — Vacib yeniliklər e-poçtla
- `settings.notif_follows_subtitle` — Yeni izləyici və elanları
- `settings.notif_follows_title` — İzləmə
- `settings.notif_group_categories` — Kateqoriyalar
- `settings.notif_group_channels` — Kanallar
- `settings.notif_group_quiet` — Sakit saatlar
- `settings.notif_listings_subtitle` — Təsdiq, rədd, vaxt, uyğun elan
- `settings.notif_listings_title` — Elanlar
- `settings.notif_marketing_subtitle` — Kampaniya və elanlar
- `settings.notif_marketing_title` — Yeniliklər & təkliflər
- `settings.notif_messages_subtitle` — Yeni və cavabsız mesajlar
- `settings.notif_messages_title` — Mesajlar
- `settings.notif_push_subtitle` — Telefona anında bildiriş
- `settings.notif_push_title` — Push bildirişlər
- `settings.notif_quiet_range_label` — Başlanğıc — son
- `settings.notif_quiet_subtitle` — Seçilən saatlarda push gəlməz
- `settings.notif_quiet_title` — Push-u sakitləşdir
- `settings.notif_reviews_subtitle` — Yeni rəy və xatırlatma
- `settings.notif_saved` — Ayarlar saxlandı.
- `settings.notif_saved_search_subtitle` — Axtarışınıza uyğun yeni elan
- `settings.notif_shipments_subtitle` — Təklif, çatdırılma, sifariş
- `settings.notif_shipments_title` — Sövdələşmə & təkliflər

## referral — invite a friend  (22)
- `referral.both_earn` — İkiniz də qazanırsınız
- `referral.both_earn_hint` — ilk sifarişdən sonra {amount} promokod.
- `referral.code_copied` — Kod kopyalandı
- `referral.code_label` — DƏVƏT KODUN
- `referral.empty_subtitle` — Linki paylaş — dostların burada görünəcək.
- `referral.empty_title` — Hələ heç kimi dəvət etməmisən
- `referral.friend_joins` — Dostun qoşulur
- `referral.friend_joins_hint` — link ilə qeydiyyatdan keçir.
- `referral.hero_note` — Dostun ilk sifarişini tamamlayanda promokod hər ikinizə gedir.
- `referral.hero_prefix` — Dostunu dəvət et, hər ikiniz
- `referral.hero_suffix` — qazanın
- `referral.item_invited` — Dəvət olunub
- `referral.item_waiting_first_order` — İlk sifariş gözlənilir
- `referral.link_copied` — Link kopyalandı
- `referral.my_invites` — Dəvət etdiklərim
- `referral.share_invite_link` — Dəvət linkini paylaş
- `referral.share_link` — Linki paylaş
- `referral.share_link_hint` — dostuna dəvət linkini göndər.
- `referral.share_text` — Wawatair-ə qoşul, hər ikimiz {amount} qazanaq! Kod: {code}. {link}
- `referral.stat_earned` — Qazanılan
- `referral.stat_invited` — Dəvət
- `referral.stat_joined` — Qoşulan

## support — contact support  (17)
- `support.attach_image` — Şəkil əlavə et (ops.)
- `support.attach_image_soon` — Şəkil əlavə etmə tezliklə
- `support.close` — Bağla
- `support.message_hint` — Problemi və ya sualını ətraflı yaz…
- `support.response_time_prefix` — Adətən
- `support.response_time_suffix` — ərzində cavablayırıq. Sorğunu ətraflı yaz.
- `support.response_time_value` — 24 saat
- `support.send_failed` — Göndərilmədi. Yenidən yoxla.
- `support.sent_ref_prefix` — Müraciət nömrən
- `support.sent_ref_suffix` — . Cavabı e-poçt və bildirişlə alacaqsan.
- `support.sent_title` — Mesajın göndərildi
- `support.subject_hint` — Qısa başlıq
- `support.subject_label` — Başlıq
- `support.submit` — Göndər
- `support.topic_general` — Ümumi
- `support.topic_label` — Mövzu
- `support.validation_required` — Başlıq və mesajı doldur.

## reports — my reports  (15)
- `reports.empty_subtitle` — Elan, istifadəçi və ya mesaj barədə şikayət etsən, burada görünəcək.
- `reports.empty_title` — Şikayətin yoxdur
- `reports.evidence_attached` — Sübut əlavə edilib
- `reports.explanation_label` — İzah
- `reports.id_template` — Şikayət #{id}
- `reports.moderation_response` — Moderasiya cavabı
- `reports.result_resolved` — Həll olundu
- `reports.status_label` — Vəziyyət
- `reports.status_resolved` — Həll olundu
- `reports.step_result` — Nəticə
- `reports.step_reviewing_hint` — Moderasiya komandası yoxlayır
- `reports.step_sent` — Göndərildi
- `reports.subject_listing` — Elan barədə şikayət
- `reports.subject_message` — Mesaj barədə şikayət
- `reports.subject_user` — İstifadəçi barədə şikayət

## deals — deal detail gaps  (17)
- `deals.active_badge_template` — {count} aktiv
- `deals.auto_completed_note` — Mal çatdırıldıqdan 3 gün sonra göndərən təsdiq etmədiyi üçün sövdələşmə avtomatik tamamlandı. Rəy yaza bilərsiniz.
- `deals.cancel.reason_label` — Ləğv səbəbi
- `deals.coming_soon` — Tezliklə aktiv olacaq.
- `deals.confirm.delivered.title` — Çatdırdığınızı təsdiqləyirsiniz?
- `deals.confirm.irreversible_body` — Bu əməldən sonra sövdələşmə tamamlanmış sayılacaq və geri qaytarıla bilməz.
- `deals.confirm.picked_up.title` — Malı götürdüyünüzü təsdiqləyirsiniz?
- `deals.detail_title.picked_up` — Mal yoldadır
- `deals.expired_note` — Təklifin cavab müddəti bitdi. Yenidən təklif göndərə bilərsiniz.
- `deals.expired_unanswered` — Cavabsız qaldı
- `deals.operation_failed` — Əməliyyat alınmadı. Yenidən cəhd edin.
- `deals.pending_expires_template` — Təklifin vaxtı: {date}-a qədər
- `deals.reason_prefix` — Səbəb
- `deals.review.question_template` — {name} ilə təcrübən necə idi?
- `deals.review_sent` — Rəy göndərildi
- `deals.terms.trip_date` — Səfər
- `deals.title_short` — Sövdələşmə

## create — new listing  (9)
- `create.free_after_review` — Pulsuz · yoxlanışdan sonra dərc olunur
- `create.negotiable` — Qiymətdə danışıq olar
- `create.package_select` — Bağlama növü
- `create.package_selected_count` — {count} seçildi
- `create.quick_select` — Tez seçim
- `create.step_details` — Detallar
- `create.step_preview` — Önizləmə
- `create.step_route` — Marşrut
- `create.step_template` — Addım {step}/{total}

## chat — system cards & image validation  (7)
- `chat.card.cancel_reason` — Səbəb: {reason}
- `chat.message.edited` — redaktə edildi
- `chat.message.retry` — Yenidən cəhd
- `chat.open_error` — Söhbəti açmaq alınmadı.
- `chat.proposal.counter` — Dəyiş
- `chat.proposal.decline` — Rədd
- `chat.user_not_found` — İstifadəçi məlumatı tapılmadı.

## sort — sort options  (8)
- `sort.date_asc` — Ən köhnə
- `sort.date_desc` — Ən yeni
- `sort.price_asc` — Qiymət: aşağıdan
- `sort.price_desc` — Qiymət: yuxarıdan
- `sort.rating_desc` — Ən yüksək reytinq
- `sort.relevance` — Uyğunluq
- `sort.weight_asc` — Çəki: azdan
- `sort.weight_desc` — Çəki: çoxdan

## faq — help & FAQ  (8)
- `faq.contact_subtitle` — Komandamız kömək etməyə hazırdır.
- `faq.contact_title` — Cavab tapmadın?
- `faq.empty` — Hələ sual yoxdur
- `faq.load_failed` — FAQ yüklənmədi
- `faq.no_results` — «{query}» üzrə nəticə yoxdur
- `faq.no_results_hint` — Başqa açar sözlə yoxla və ya dəstəyə yaz.
- `faq.search_hint` — Sualını axtar…
- `faq.subtitle` — Suallarına cavab tap

## about — about screen  (6)
- `about.copyright` — © 2026 Wawatair · Bütün hüquqlar qorunur
- `about.follow_us` — Bizi izlə
- `about.terms` — İstifadə şərtləri
- `about.up_to_date` — Ən son versiyadasan
- `about.version` — Versiya {version}
- `about.website` — Veb sayt

## notification — date-group headers  (6)
- `notification.group_old` — Köhnə
- `notification.group_this_week` — Bu həftə
- `notification.time_days_ago` — {count} gün əvvəl
- `notification.time_hours_ago` — {count} saat əvvəl
- `notification.time_minutes_ago` — {count} dəqiqə əvvəl
- `notification.time_now` — indi

## promo — promo codes  (5)
- `promo.copied` — Kod kopyalandı
- `promo.error_body` — Promokodları yükləyə bilmədik. İnternet bağlantını yoxla.
- `promo.error_title` — Bağlantı yoxdur
- `promo.hint` — Kodu elanı VİP edərkən və ya önə çəkərkən ödənişdə tətbiq et.
- `promo.title` — Promokodlarım

## enum — report reasons  (6)
> **CORRECTION (supersedes earlier `enum.report_reason.*` request).** The canonical
> taxonomy is the existing backend `App\Enums\ReportReasonCode`:
> `spam, fraud, abuse, fake, inappropriate, other`. The app's report pickers (listing
> report + user report) already send exactly these codes; it never sends `misleading`
> or `prohibited_item`. Please add the CMS keys below and **drop the earlier
> `enum.report_reason.*` keys** (abuse/fraud/inappropriate/misleading/prohibited_item)
> — those came from a stale display map and are not used. Keep `fraud` = "Fırıldaq".
- `enum.report_reason_code.spam` — Spam
- `enum.report_reason_code.fraud` — Fırıldaq
- `enum.report_reason_code.abuse` — Təhqir
- `enum.report_reason_code.fake` — Saxta
- `enum.report_reason_code.inappropriate` — Uyğunsuz
- `enum.report_reason_code.other` — Digər

## auth — referral at registration  (4)
- `auth.referral_code_label` — Dəvət kodu (istəyə bağlı)
- `auth.referral_code_hint` — Dostunun kodu
- `auth.referral_invited_by` — Sizi {name} dəvət etdi — qeydiyyatdan sonra hər ikiniz {reward} qazanacaqsınız
- `auth.referral_promo_received` — Sizə {amount} promokod verildi 🎁

## common — shared states  (9)
- `common.back` — Geri
- `common.cancel` — İmtina et
- `common.close` — Bağla
- `common.coming_soon` — {label} tezliklə aktiv olacaq.
- `common.confirm` — Təsdiq et
- `common.load_failed_generic` — Məlumatı yükləyə bilmədik. İnternet bağlantını yoxla.
- `common.no_connection` — Bağlantı yoxdur
- `common.reset` — Sıfırla
- `common.retry` — Yenidən cəhd et

## menu — extra items  (4)
- `menu.appearance` — Görünüş
- `menu.connections` — İzləyicilər və izlədiklərim
- `menu.promo_codes` — Promokodlarım
- `menu.promotions` — Promosyonlarım

## favorites — saved listings  (4)
- `favorites.empty_subtitle` — Bəyəndiyin elanları ürək işarəsi ilə burada saxla.
- `favorites.empty_title` — Hələ sevimli elan yoxdur
- `favorites.subtitle` — Yadda saxladığın elanlar
- `favorites.title` — Sevimlilər

## home — hero & feed  (3)
- `home.hero_subtitle` — Səyahət edənlərlə göndərənləri birləşdiririk ⚠ confirm
- `home.hero_title` — Bağlamanı kim aparsın? ⚠ confirm
- `home.stats_prefix` — Bu ay ⚠ confirm

## time — relative time  (3)
- `time.days_ago_template` — {count} gün əvvəl
- `time.hours_ago_template` — {count} saat əvvəl
- `time.now` — indi

## picker  (2)
- `picker.date_help` — Tarix seç
- `picker.time_help` — Saat seç

## listing  (1)
- `listing.detail_title` — Elan

## feed  (1)
- `feed.end` — Hamısı bu qədər

## privacy_policy  (2)
- `privacy_policy.empty` — Məzmun yoxdur
- `privacy_policy.load_error` — Məxfilik siyasətini yükləmək olmadı

---

## Not CMS keys (ignore)
- Month names (`Yan/Yanvar…`) come from `intl DateFormat(locale)`.
- Currency/units (`₼`,`kq`) and bare numbers/dates are not keys.
