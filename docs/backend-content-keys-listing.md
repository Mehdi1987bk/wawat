# Wawatair mobile content keys

Mobile app reads UI texts from:

`GET /api/v1/content?group=listing`

Expected response shape:

```json
{
  "data": {
    "key.name": "Text value"
  }
}
```

If a key is missing, the app shows the key name itself. Backend should create these keys in `group=listing` before release.

Placeholders must stay exactly as written: `{count}`, `{used}`, `{name}`, `{step}`, `{total}`, `{time}`.

## Common

| Key | Value |
| --- | --- |
| `common.clear` | `Təmizlə` |
| `common.continue` | `Davam et` |
| `common.delete` | `Sil` |
| `common.edit` | `Düzəliş` |
| `common.error` | `Xəta baş verdi` |
| `common.cancel` | `Ləğv et` |
| `common.confirm` | `Təsdiq et` |
| `common.flow_coming_soon` | `Bu axın növbəti mərhələdə qoşulacaq.` |
| `common.max` | `Max` |
| `common.min` | `Min` |
| `common.operation_completed` | `Əməliyyat tamamlandı` |
| `common.operation_failed` | `Əməliyyat alınmadı.` |
| `common.pause` | `Dayandır` |
| `common.reset` | `Sıfırla` |
| `common.retry` | `Yenidən cəhd et` |
| `common.save` | `Saxla` |
| `common.today` | `Bu gün` |
| `common.wait` | `Gözlə...` |
| `common.yesterday` | `Dünən` |

## Create Listing

| Key | Value |
| --- | --- |
| `create.title` | `Yeni elan` |
| `create.free_after_review` | `Pulsuz · yoxlanışdan sonra dərc olunur` |
| `create.step_template` | `Addım {step}/{total}` |
| `create.step_route` | `Marşrut` |
| `create.step_details` | `Detallar` |
| `create.step_preview` | `Önizləmə` |
| `create.quick_select` | `Tez seçim` |
| `create.trip_title` | `Səfər elanı` |
| `create.shipment_title` | `Göndəriş elanı` |
| `create.trip_details_title` | `Səfər detalları` |
| `create.shipment_details_title` | `Göndəriş detalları` |
| `create.preview_title` | `Önizləmə` |
| `create.trip_description` | `Səyahət edirəm, çantamda yer var — çəki və qiymət təyin edirəm.` |
| `create.shipment_description` | `Bağlamam var, aparacaq səyahətçi axtarıram — çatdırılma aralığı seçirəm.` |
| `create.chip.flight_date` | `Uçuş tarixi` |
| `create.chip.empty_weight` | `Boş çəki` |
| `create.chip.price_per_kg` | `1 kq qiyməti` |
| `create.chip.delivery_range` | `Çatdırılma aralığı` |
| `create.chip.weight` | `Çəki` |
| `create.chip.package_type` | `Bağlama növü` |
| `create.moderation_notice` | `Elanın moderasiyadan keçdikdən sonra Kəşf lentində görünür. Qadağan olunmuş məzmun avtomatik yoxlanılır.` |
| `create.route_trip_title` | `Haradan hara uçursan?` |
| `create.route_shipment_title` | `Bağlama haradan hara?` |
| `create.route_trip_subtitle` | `Şəhərləri seç — sistem uyğun göndərişləri tapacaq.` |
| `create.route_shipment_subtitle` | `Göndərmək istədiyin marşrutu seç.` |
| `create.route_shipment_hint` | `Bu marşrutda yaxın tarixlərdə uyğun səyahətçilər tapıla bilər.` |
| `create.flight_date` | `Uçuş tarixi` |
| `create.flight_time` | `Saat` |
| `create.flight_number_label` | `Reys nömrəsi · istəyə bağlı` |
| `create.flight_number_hint` | `məs. J2 5432` |
| `create.flight_number_helper` | `Sərnişinlərə etibar üçün — maks 8 simvol.` |
| `create.empty_weight` | `Boş çəki` |
| `create.max_weight_helper` | `Aparacağın maksimum çəki — limit 32 kq.` |
| `create.price_per_kg_label` | `Qiymət (1 kq üçün)` |
| `create.price_helper` | `Maksimum 99 ₼/kq.` |
| `create.allow_price_negotiation` | `Qiymətdə danışıq olar` |
| `create.delivery_range` | `Çatdırılma aralığı` |
| `create.delivery_range_helper` | `Bağlamanın çatması üçün uyğun tarix aralığı.` |
| `create.package_weight` | `Bağlamanın çəkisi` |
| `create.package_weight_helper` | `Təxmini çəki — limit 32 kq.` |
| `create.accepted_packages_title` | `Hansı bağlamaları götürürsən?` |
| `create.package_type_title` | `Bağlama növü` |
| `create.note_label` | `Qeyd · istəyə bağlı` |
| `create.trip_note_hint` | `Nə götürə bilərsən, şərtlər, əlaqə vaxtı...` |
| `create.shipment_note_hint` | `Bağlama haqqında, kövrəklik, əlaqə...` |
| `create.preview_section` | `Elanın belə görünəcək` |
| `create.publish` | `Dərc et` |
| `create.publishing` | `Dərc olunur...` |
| `create.go_preview` | `Önizləməyə keç` |
| `create.success_title` | `Elan yoxlanışa göndərildi` |
| `create.success_subtitle` | `Moderasiyadan keçdikdən sonra Kəşf lentində görünəcək — adətən bir neçə dəqiqə çəkir.` |
| `create.success_remaining_trip` | `Daha {count} səfər elanı yarada bilərsən` |
| `create.success_remaining_shipment` | `Daha {count} göndəriş elanı yarada bilərsən` |
| `create.success_quota_trip` | `3 aktiv səfər elanı limitindən {used}-i istifadədə` |
| `create.success_quota_shipment` | `3 aktiv göndəriş elanı limitindən {used}-i istifadədə` |
| `create.success_matches_shipments` | `{count} göndəriş səni gözləyir` |
| `create.success_matches_travelers` | `{count} səyahətçi səni gözləyir` |
| `create.success_view_shipments` | `Uyğun göndərişlərə bax` |
| `create.success_view_travelers` | `Uyğun səyahətçilərə bax` |
| `create.success_new_listing` | `Yeni elan` |
| `create.success_my_listings` | `Elanlarım` |
| `create.preview_moderation_prefix` | `Dərc etdikdən sonra elan ` |
| `create.preview_moderation_bold` | `moderasiyaya` |
| `create.preview_moderation_suffix` | ` düşür və təsdiqləndikdə lentdə görünür.` |
| `create.preview_shipment_price_prefix` | `Göndəriş elanında ` |
| `create.preview_shipment_price_bold` | `qiymət yoxdur` |
| `create.preview_shipment_price_suffix` | ` — səyahətçilər sənə təklif göndərəcək.` |
| `create.package_min_one` | `Ən azı 1` |
| `create.package_select` | `Bağlama növü seç` |
| `create.package_selected_count` | `{count} seçildi` |
| `create.package_sheet_subtitle` | `Götürə biləcəyin növləri seç.` |
| `create.package_confirm` | `Təsdiq et ({count})` |
| `create.negotiable` | `Razılaşma ilə` |

## Pickers

| Key | Value |
| --- | --- |
| `picker.date_help` | `Tarix seç` |
| `picker.time_help` | `Saat seç` |

## Validation

| Key | Value |
| --- | --- |
| `validation.city_required` | `Şəhər seç` |
| `validation.cities_must_differ` | `Şəhərlər fərqli olmalıdır` |
| `validation.package_required` | `Ən azı bir növ seç` |
| `validation.date_required` | `Tarix seç` |
| `validation.time_required` | `Saat seç` |
| `validation.weight_required` | `Çəki yaz` |
| `validation.price_required` | `Qiymət yaz` |
| `validation.end_date_after_start` | `Son tarix başlanğıcdan sonra olmalıdır` |

## Listing Limit Gate

| Key | Value |
| --- | --- |
| `limit.trip_new_title` | `Yeni səfər elanı` |
| `limit.shipment_new_title` | `Yeni göndəriş elanı` |
| `limit.active_trip_list` | `Aktiv səfər elanların` |
| `limit.active_shipment_list` | `Aktiv göndəriş elanların` |
| `limit.noun_trip` | `səfər` |
| `limit.noun_shipment` | `göndəriş` |
| `limit.trip_title` | `Aktiv {noun} limitin dolub` |
| `limit.shipment_title` | `Aktiv {noun} limitin dolub` |
| `limit.subtitle_middle` | `Yenisini yaratmaq üçün birini ` |
| `limit.pause_word` | `dayandır` |
| `limit.subtitle_suffix` | ` — limit dərhal azad olur.` |
| `limit.pause_info` | `Dayandırılan elan lentdən çıxır və limiti azad edir. İstədiyin vaxt yenidən aktivləşdirə bilərsən.` |
| `limit.view_all_my_listings` | `Bütün elanlarıma bax` |
| `limit.empty_active` | `Aktiv elan tapılmadı.` |

## Search

| Key | Value |
| --- | --- |
| `search.title` | `Axtarış` |
| `search.saved_created` | `Axtarış bildirişiniz yaradıldı.` |
| `search.saved_success` | `Axtarış saxlandı.` |
| `search.post_opposite_soon` | `Elan yaratma növbəti mərhələdə açılacaq.` |
| `search.recent_title` | `Son axtarışlar` |
| `search.intro_title` | `Marşrut seçib axtar` |
| `search.intro_subtitle` | `Şəhərləri seç — sənə uyğun səfər və göndərişləri tapaq.` |
| `search.route_total_template` | `{count} elan` |
| `search.suggestion_create_alert` | `Bu axtarış üçün bildiriş qur` |
| `search.suggestion_post_opposite` | `Əks elan yerləşdir` |
| `search.suggestion_broaden` | `Axtarışı genişləndir` |
| `search.empty_title` | `Nəticə tapılmadı` |
| `search.empty_subtitle` | `Bu marşrut üzrə uyğun elan yoxdur. Bunları sına:` |
| `search.network_error_title` | `Bağlantı yoxdur` |
| `search.network_error_subtitle` | `İnternet bağlantını yoxla və yenidən cəhd et.` |
| `search.end_title` | `Hamısını gördün` |
| `search.end_subtitle` | `Bu marşrut üzrə bütün elanlar göstərildi` |
| `search.results_count_template` | `{count} elan tapıldı` |
| `search.sort_title` | `Sıralama` |
| `search.filters_title` | `Filtrlər` |
| `search.filter_type` | `Elan tipi` |
| `search.filter_package_type` | `Bağlama növü` |
| `search.filter_price` | `Qiymət (₼/kq)` |
| `search.filter_weight` | `Çəki (kq)` |
| `search.filter_date` | `Tarix aralığı` |
| `search.filter_rating` | `Minimum reytinq` |
| `search.filter_tier` | `Minimum tier` |
| `search.filter_any` | `İstənilən` |
| `search.date_from` | `Başlanğıc` |
| `search.date_to` | `Son` |
| `search.verified_only` | `Yalnız təsdiqlənmiş` |
| `search.following_only` | `İzlədiyim şəxslər` |
| `search.show_results` | `Nəticələri göstər` |
| `search.verified` | `Təsdiqli` |
| `search.following` | `İzlədiyim` |
| `search.saved_title` | `Saxlanmış axtarışlar` |
| `search.saved_empty` | `Hələ saxlanmış axtarış yoxdur.` |
| `search.alert_active` | `Bildiriş aktiv` |
| `search.last_check_template` | `Son yoxlama: {time}` |
| `search.save_title` | `Axtarışı saxla` |
| `search.save_subtitle` | `Bu filtrlərə uyğun yeni elan çıxanda sənə bildiriş göndərək.` |
| `search.save_name_hint` | `məs. Dubai ucuz səfərlər` |
| `search.save_notify` | `Yeni elan olanda bildiriş göndər` |

## Sort And Time

| Key | Value |
| --- | --- |
| `sort.relevance` | `Uyğunluq` |
| `sort.date_desc` | `Ən yeni` |
| `sort.date_asc` | `Ən köhnə` |
| `sort.price_asc` | `Qiymət: ucuzdan` |
| `sort.price_desc` | `Qiymət: bahadan` |
| `sort.weight_desc` | `Çəki: çoxdan` |
| `sort.weight_asc` | `Çəki: azdan` |
| `sort.rating_desc` | `Reytinq: yüksək` |
| `time.now` | `indi` |
| `time.hours_ago_template` | `{count} saat əvvəl` |
| `time.days_ago_template` | `{count} gün əvvəl` |

## Tiers

| Key | Value |
| --- | --- |
| `tier.bronze_plus` | `Bürünc+` |
| `tier.silver_plus` | `Gümüş+` |
| `tier.gold_plus` | `Qızıl+` |
| `tier.platinum` | `Platin` |

Existing keys also used by search/home:

| Key | Value |
| --- | --- |
| `search.button` | `Axtar` |
| `search.from_placeholder` | `Haradan` |
| `search.to_placeholder` | `Hara` |
| `search.type_all` | `Hamısı` |
| `home.popular_routes` | `Populyar marşrutlar` |

## Notifications

| Key | Value |
| --- | --- |
| `notifications.title` | `Bildirişlər` |
| `notifications.read_all` | `Hamısını oxu` |
| `notifications.tab_all` | `Hamısı` |
| `notifications.tab_unread` | `Oxunmamış` |
| `notifications.opened` | `Bildiriş açıldı.` |
| `notifications.mute_hint` | `Bu bildiriş növü ayarlardan söndürülə bilər.` |
| `notifications.request_accepted` | `Sorğu qəbul edildi.` |
| `notifications.request_declined` | `Sorğu rədd edildi.` |
| `notifications.action.accept` | `Qəbul et` |
| `notifications.action.view` | `Bax` |
| `notifications.action.confirm` | `Təsdiqlə` |
| `notifications.action.decline` | `Rədd et` |
| `notifications.sheet.mark_read` | `Oxunmuş kimi işarələ` |
| `notifications.sheet.open` | `Aç` |
| `notifications.sheet.mute_type` | `Bu növü söndür` |
| `notifications.sheet.delete` | `Sil` |
| `notifications.empty_title` | `Hələ bildiriş yoxdur` |
| `notifications.empty_subtitle` | `Təkliflər, mesajlar və elan yenilikləri burada görünəcək.` |
| `notifications.empty_action` | `Elanlara bax` |

## Chat

| Key | Value |
| --- | --- |
| `chat.list.title` | `Söhbətlər` |
| `chat.tab.all` | `Hamısı` |
| `chat.tab.archive` | `Arxiv` |
| `chat.empty_title` | `Hələ söhbətin yoxdur` |
| `chat.empty_subtitle` | `Elan sahibinə Mesaj və ya Təklif göndər yazanda söhbət burada görünəcək.` |
| `chat.empty_archive_title` | `Arxiv boşdur` |
| `chat.empty_archive_subtitle` | `Arxivləşmiş söhbətlər burada görünəcək.` |
| `chat.action.profile` | `Profilə bax` |
| `chat.action.pin` | `Söhbəti sabitlə` |
| `chat.action.unpin` | `Sabitdən çıxar` |
| `chat.action.archive` | `Arxivlə` |
| `chat.action.unarchive` | `Arxivdən çıxar` |
| `chat.action.block` | `Blokla` |
| `chat.action.unblock` | `Bloku aç` |
| `chat.action.delete` | `Söhbəti sil` |
| `chat.action.mute` | `Bildirişi susdur` |
| `chat.input.blocked` | `Bu istifadəçiyə mesaj göndərə bilməzsən` |
| `chat.input.blocked_by_me` | `Bu istifadəçini blokladın. Mesaj göndərə bilməzsən.` |
| `chat.input.placeholder` | `Mesaj yaz...` |
| `chat.attach.image` | `Şəkil` |
| `chat.attach.file` | `Fayl` |
| `chat.thread.empty_title` | `Söhbətə başla` |
| `chat.thread.empty_subtitle` | `{name} ilə hələ yazışmamısan. Salamla və detalları soruş.` |

## My Listings

| Key | Value |
| --- | --- |
| `my_listings.title` | `Mənim elanlarım` |
| `my_listings.subtitle` | `Status, baxış və idarəetmə` |
| `my_listings.pause_confirm_title` | `Elanı dayandır?` |
| `my_listings.pause_confirm_message` | `Bu elan lentdən çıxacaq və istifadəçilər onu görməyəcək. Davam edək?` |
| `my_listings.resume_confirm_title` | `Elanı aktivləşdir?` |
| `my_listings.resume_confirm_message` | `Elan yenidən lentdə görünəcək. Davam edək?` |
| `my_listings.resume` | `Aktiv et` |
| `my_listings.repost_confirm_title` | `Yenidən paylaş?` |
| `my_listings.repost_confirm_message` | `Elan yeni tarixlə yenidən dərc olunacaq. Davam edək?` |
| `my_listings.repost` | `Yenidən paylaş` |
| `my_listings.delete_confirm_title` | `Elanı sil?` |
| `my_listings.delete_confirm_message` | `Bu əməliyyat geri qaytarılmır. Davam etmək istəyirsən?` |
| `my_listings.delete_reason_title` | `Silinmə səbəbi` |
| `my_listings.empty_title` | `Hələ elan yoxdur` |
| `my_listings.empty_subtitle` | `Yeni səfər və ya göndəriş elanı yaratmaq üçün ortadakı + tabına keç.` |

## Enums

| Key | Value |
| --- | --- |
| `enum.listing_delete_reason.plans_changed` | `Planlarım dəyişdi` |
| `enum.listing_delete_reason.found_another` | `Başqa variant tapdım` |
| `enum.listing_delete_reason.no_longer_needed` | `Artıq lazım deyil` |
| `enum.listing_delete_reason.created_by_mistake` | `Səhvən yaratdım` |
| `enum.listing_delete_reason.other` | `Digər` |
