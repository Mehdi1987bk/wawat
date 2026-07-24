import '../domain/repositories/auth_repository.dart';
import '../main.dart';

class WawatContent {
  WawatContent._();

  static final Map<String, Future<Map<String, String>>> _futures = {};
  static final Map<String, Map<String, String>> _cache = {};
  static const List<String> defaultGroups = [
    'common',
    'listing',
    'create',
    'search',
    'home',
    'feed',
    'sort',
    'time',
    'chat',
    'notifications',
    'profile',
    'review',
    'menu',
    'limit',
    'picker',
    'validation',
    'enum',
    'tier',
    'my_listings',
    'promotion',
    'onboarding',
    'block',
  ];
  static const Map<String, String> fallbacks = {
    'common.cancel': 'İmtina et',
    'common.confirm': 'Təsdiq et',
    'common.continue': 'Davam et',
    'common.edit': 'Düzəliş',
    'common.save': 'Yadda saxla',
    'common.wait': 'Gözləyin...',
    'common.retry': 'Yenidən cəhd et',
    'common.reset': 'Sıfırla',
    'common.today': 'Bu gün',
    'common.yesterday': 'Dünən',
    'common.operation_completed': 'Əməliyyat tamamlandı',
    'common.error': 'Xəta baş verdi. Yenidən cəhd edin.',
    'onboarding.slide1.title': 'Səyahət edəni göndərənlə birləşdir',
    'onboarding.slide1.body':
        'Uçan minlərlə insanın çantasında boş yer var. Wawatair onları bağlama göndərənlərlə birləşdirir.',
    'onboarding.slide2.title': 'Kargodan ucuz, poçtdan sürətli',
    'onboarding.slide2.body':
        'Qiyməti birbaşa çatda danış, bağlamanı əl-ələ, tez və sərfəli çatdır.',
    'onboarding.slide3.title': 'Təsdiqlənmiş, etibarlı icma',
    'onboarding.slide3.body':
        'Mavi nişan, reytinq və rəylər — kiminlə iş gördüyünü əvvəlcədən bil.',
    'onboarding.cta.next': 'Növbəti',
    'onboarding.cta.skip': 'Keç',
    'onboarding.cta.start': 'Başla',
    'onboarding.have_account': 'Hesabın var?',
    'onboarding.login': 'Daxil ol',
    'create.title': 'Yeni elan',
    'create.free_after_review': 'Pulsuz · yoxlanışdan sonra dərc olunur',
    'create.trip_title': 'Səfər elanı',
    'create.trip_description':
        'Səyahət edirəm, çantamda yer var — çəki və qiymət təyin edirəm.',
    'create.shipment_title': 'Göndəriş elanı',
    'create.shipment_description':
        'Bağlamam var, aparacaq səyahətçi axtarıram — çatdırılma aralığı seçirəm.',
    'create.trip_details_title': 'Səfər detalları',
    'create.shipment_details_title': 'Göndəriş detalları',
    'create.preview_title': 'Önizləmə',
    'create.step_template': 'Addım {step}/{total}',
    'create.step_route': 'Marşrut',
    'create.step_details': 'Detallar',
    'create.step_preview': 'Önizləmə',
    'create.route_trip_title': 'Haradan hara uçursan?',
    'create.route_shipment_title': 'Haradan hara göndərirsən?',
    'create.route_subtitle':
        'Şəhərləri seç — sistem uyğun göndərişləri tapacaq.',
    'create.chip.flight_date': 'Uçuş tarixi',
    'create.chip.empty_weight': 'Boş çəki',
    'create.chip.price_per_kg': '1 kq qiyməti',
    'create.chip.delivery_range': 'Çatdırılma aralığı',
    'create.chip.weight': 'Çəki',
    'create.chip.package_type': 'Bağlama növü',
    'create.quick_select': 'Tez seçim',
    'create.flight_date': 'Uçuş tarixi',
    'create.flight_time': 'Saat',
    'create.flight_number': 'Reys nömrəsi',
    'create.flight_number_hint': 'məs. J2 5432',
    'create.flight_number_helper': 'Sərnişinlərə etibar üçün — maks 8 simvol.',
    'create.empty_weight': 'Boş çəki',
    'create.empty_weight_helper': 'Aparacağın maksimum çəki — limit 32 kq.',
    'create.price_per_kg': 'Qiymət (1 kq üçün)',
    'create.price_helper': 'Maksimum 99 ₼/kq.',
    'create.negotiable': 'Qiymətdə danışıq olar',
    'create.delivery_range': 'Çatdırılma aralığı',
    'create.package_weight': 'Bağlamanın çəkisi',
    'create.package_type_title': 'Hansı bağlamaları götürürsən?',
    'create.package_select': 'Bağlama növü',
    'create.package_selected_count': '{count} seçildi',
    'create.package_min_one': 'Ən azı 1',
    'create.note_label': 'Qeyd · istəyə bağlı',
    'create.note_hint': 'Nə götürə bilərsən, şərtlər, əlaqə vaxtı...',
    'create.preview_section': 'Elanın belə görünəcək',
    'create.go_preview': 'Önizləməyə keç',
    'create.publish': 'Dərc et',
    'create.publishing': 'Dərc olunur...',
    'create.success_title': 'Elan yoxlanışa göndərildi',
    'create.success_subtitle':
        'Moderasiyadan keçdikdən sonra Kəşf lentində görünəcək — adətən bir neçə dəqiqə çəkir.',
    'create.success_remaining_trip': 'Daha {count} səfər elanı yarada bilərsən',
    'create.success_remaining_shipment':
        'Daha {count} göndəriş elanı yarada bilərsən',
    'create.success_quota_trip':
        '3 aktiv səfər elanı limitindən {used}-i istifadədə',
    'create.success_quota_shipment':
        '3 aktiv göndəriş elanı limitindən {used}-i istifadədə',
    'create.success_matches_shipments': '{count} göndəriş səni gözləyir',
    'create.success_matches_travelers': '{count} səyahətçi səni gözləyir',
    'create.success_view_shipments': 'Uyğun göndərişlərə bax',
    'create.success_view_travelers': 'Uyğun səyahətçilərə bax',
    'create.success_new_listing': 'Yeni elan',
    'create.success_my_listings': 'Elanlarım',
    'listing.remaining_template': '{count} qalıb',
    'listing.limit_reached_short': 'Limit dolub',
    'search.from_placeholder': 'Haradan',
    'search.to_placeholder': 'Hara',
    'search.filters_title': 'Ətraflı axtarış',
    'search.sort_title': 'Sıralama',
    'search.filter_package_type': 'Bağlama növləri',
    'search.filter_date': 'Tarix aralığı',
    'search.date_from': 'Başlanğıc',
    'search.date_to': 'Son',
    'search.filter_weight': 'Çəki aralığı',
    'search.weight_min': 'Min kq',
    'search.weight_max': 'Maks kq',
    'search.filter_price': 'Qiymət aralığı',
    'search.price_min': 'Min ₼',
    'search.price_max': 'Maks ₼',
    'search.filter_rating': 'Reytinq',
    'search.filter_tier': 'İstifadəçi səviyyəsi',
    'search.filter_any': 'Fərqi yoxdur',
    'search.verified_only': 'Yalnız təsdiqlənmiş istifadəçilər',
    'search.following_only': 'Yalnız izlədiyim istifadəçilər',
    'search.recent_title': 'Son axtarışlar',
    'search.save_current': 'Axtarışı saxla',
    'search.saved_short': 'Saxlanmışlar',
    'search.saved_state': 'Saxlanıldı',
    'search.saved_title': 'Saxlanmış axtarışlar',
    'search.saved_empty': 'Hələ saxlanmış axtarış yoxdur.',
    'search.save_title': 'Axtarışı saxla',
    'search.save_subtitle':
        'Bu filtrləri şablon kimi saxla və sonra bir toxunuşla yenidən aç.',
    'search.save_name_hint': 'Şablonun adı',
    'search.save_notify': 'Yeni uyğun elanlar barədə bildiriş al',
    'search.saved_success': 'Axtarış yadda saxlanıldı.',
    'search.saved_created': 'Axtarış yadda saxlanıldı.',
    'search.save_error': 'Axtarışı saxlamaq alınmadı. Yenidən cəhd edin.',
    'search.alert_active': 'Bildiriş aktiv',
    'search.last_check_template': 'Son yoxlama: {time}',
    'sort.relevance': 'Uyğunluq',
    'sort.date_desc': 'Ən yeni',
    'sort.date_asc': 'Ən köhnə',
    'sort.price_asc': 'Qiymət: aşağıdan',
    'sort.price_desc': 'Qiymət: yuxarıdan',
    'sort.weight_desc': 'Çəki: çoxdan',
    'sort.weight_asc': 'Çəki: azdan',
    'sort.rating_desc': 'Ən yüksək reytinq',
    'tier.bronze_plus': 'Bürünc+',
    'tier.silver_plus': 'Gümüş+',
    'tier.gold_plus': 'Qızıl+',
    'tier.platinum': 'Platin',
    'chat.user_not_found': 'İstifadəçi məlumatı tapılmadı.',
    'chat.open_error': 'Söhbəti açmaq alınmadı.',
    'chat.list.title': 'Söhbətlər',
    'chat.tab.all': 'Hamısı',
    'chat.tab.archive': 'Arxiv',
    'chat.empty_title': 'Hələ söhbətin yoxdur',
    'chat.empty_subtitle':
        'Elan sahibinə Mesaj və ya Təklif göndər yazanda söhbət burada görünəcək.',
    'chat.empty_archive_title': 'Arxiv boşdur',
    'chat.empty_archive_subtitle': 'Arxivləşmiş söhbətlər burada görünəcək.',
    'chat.action.profile': 'Profilə bax',
    'chat.action.pin': 'Söhbəti sabitlə',
    'chat.action.unpin': 'Sabitdən çıxar',
    'chat.action.archive': 'Arxivlə',
    'chat.action.unarchive': 'Arxivdən çıxar',
    'chat.action.block': 'Blokla',
    'chat.action.unblock': 'Bloku aç',
    'chat.action.delete': 'Söhbəti sil',
    'chat.input.blocked': 'Bu istifadəçiyə mesaj göndərə bilməzsən',
    'chat.input.blocked_by_me':
        'Bu istifadəçini blokladın. Mesaj göndərə bilməzsən.',
    'chat.input.placeholder': 'Mesaj yaz...',
    'chat.attach.image': 'Şəkil',
    'chat.thread.empty_title': 'Söhbətə başla',
    'chat.thread.empty_subtitle':
        '{name} ilə hələ yazışmamısan. Salamla və detalları soruş.',
    'chat.message.copy': 'Kopyala',
    'chat.message.edit': 'Redaktə et',
    'chat.message.delete': 'Sil',
    'chat.image.unsupported': 'Yalnız JPG, PNG və WEBP şəkilləri dəstəklənir.',
    'chat.image.too_large': 'Şəklin ölçüsü 30 MB-dan çox ola bilməz.',
    'chat.review.title': 'Rəy yaz',
    'chat.review.comment': 'Şərhinizi yazın',
    'picker.date_help': 'Tarix seç',
    'picker.time_help': 'Saat seç',
    'validation.city_required': 'Şəhər seçin.',
    'validation.cities_must_differ': 'Şəhərlər fərqli olmalıdır.',
    'validation.package_required': 'Ən azı bir bağlama növü seçin.',
    'validation.date_required': 'Tarix seçin.',
    'validation.time_required': 'Saat seçin.',
    'validation.weight_required': 'Çəki daxil edin.',
    'validation.price_required': 'Qiymət daxil edin.',
    'validation.end_date_after_start':
        'Son tarix başlanğıc tarixindən sonra olmalıdır.',
    'enum.listing_type.trip': 'SƏFƏR',
    'enum.listing_type.shipment_post': 'GÖNDƏRİŞ',
    'enum.promotion_type.vip': 'VİP',
    'enum.promotion_type.featured': 'Önə çıxarılan',
    'enum.user_tier.new': 'Yeni',
    'enum.user_tier.standard': 'Standart',
    'enum.user_tier.bronze': 'Bürünc',
    'enum.user_tier.silver': 'Gümüş',
    'enum.user_tier.gold': 'Qızıl',
    'enum.user_tier.platinum': 'Platin',
    'menu.promotions': 'Promosyonlarım',
    'menu.connections': 'İzləyicilər və izlədiklərim',
    'menu.reviews': 'Rəylərim',
    'profile.list_empty': 'Siyahı boşdur',
    'profile.users_will_appear': 'Burada istifadəçilər görünəcək.',
    'block.title': 'Bloklanmış istifadəçilər',
    'block.subtitle':
        'Blokladığınız istifadəçilər sizə mesaj yaza və elanlarınıza baxa bilməz.',
    'block.count': 'Cəmi :count istifadəçi',
    'block.unblock': 'Blokdan çıxar',
    'block.empty.title': 'Bloklanmış istifadəçi yoxdur',
    'block.empty.body':
        'Kimisə bloklasanız, burada görünəcək. Söhbətdə və ya profildə «Blokla» ilə bloklaya bilərsiniz.',
    'block.confirm.title': 'Bloku açmaq?',
    'block.confirm.body':
        ':name yenidən sizə mesaj yaza və elanlarınıza baxa biləcək.',
    'block.confirm.action': 'Bloku aç',
    'block.cancel': 'İmtina et',
    'block.unblocking': 'Açılır…',
    'block.error.title': 'Yüklənmədi',
    'block.error.body': 'İnternet bağlantısını yoxlayıb yenidən cəhd edin.',
    'block.retry': 'Yenidən cəhd et',
    'block.loading_more': 'Yüklənir…',
    'promotion.created_title': 'Elanın yoxlamaya göndərildi',
    'promotion.created_subtitle':
        'Adətən 1–2 saat ərzində təsdiqlənir. Təsdiqdən sonra lentdə görünəcək.',
    'promotion.upsell_title': 'Elanını daha çox insana çatdır',
    'promotion.vip_short': 'Ən yuxarıda, ayrıca bölmədə',
    'promotion.boost_short': 'İlk 10 / 50 / 100 mövqe',
    'promotion.skip': 'İndi yox, elanlarıma keç',
    'promotion.section.vip': 'VİP elanlar',
    'promotion.section.all': 'Bütün elanlar',
    'promotion.cta.vip': 'VİP et',
    'promotion.cta.boost': 'Önə çək',
    'promotion.cta.extend': 'Uzat',
    'promotion.cta.checkout': 'Ödənişə keç',
    'promotion.cta.boost_too': 'Önə də çək',
    'promotion.cta.upgrade_tier': 'Zolağı yüksəlt',
    'promotion.pending_activation_note':
        'Elan təsdiqlənən kimi promosyon avtomatik aktivləşəcək.',
    'promotion.vip_active': 'VİP aktiv',
    'promotion.checkout_title': 'Sifariş yekunu',
    'promotion.promo_code': 'Promokod (varsa)',
    'promotion.apply': 'Tətbiq et',
    'promotion.total': 'Yekun',
    'promotion.payment_title': 'Ödəniş',
    'promotion.payment_method': 'Ödəniş üsulu',
    'promotion.payment_integration_note':
        'Ödəniş sistemi inteqrasiya mərhələsindədir — provayder qoşulan kimi işləyəcək.',
    'promotion.checkout_open_failed': 'Ödəniş səhifəsini açmaq alınmadı.',
    'promotion.processing_title': 'Ödəniş emal olunur…',
    'promotion.processing_subtitle': 'Zəhmət olmasa gözlə. Bu ekranı bağlama.',
    'promotion.success_title': 'Təbriklər!',
    'promotion.failed_title': 'Ödəniş alınmadı',
    'promotion.refunded_title': 'Məbləğ balansa qaytarıldı',
    'promotion.pending_title': 'Təsdiq gözlənilir',
    'promotion.my_title': 'Promosyonlarım',
    'promotion.empty': 'Bu bölmədə promosyon yoxdur.',
    'promotion.vip_description':
        'Elanın lentin ən yuxarısında, ayrıca «VİP elanlar» bölməsində görünəcək.',
    'promotion.boost_description':
        'Elanın axtarış və lentdə seçdiyin mövqe zolağında görünəcək.',
    'promotion.tier_note':
        'VİP elanlar həmişə önə çəkilmiş elanların da üstündədir.',
    'promotion.pricing_unavailable': 'Promosyon paketlərini yükləmək alınmadı.',
    'promotion.refunded_to_balance': 'Məbləğ Wawatair balansına qaytarıldı.',
    'promotion.step.position': 'Mövqe zolağını seç',
    'promotion.position_description_template':
        'Nəticələrin ilk {count}-liyində daha çox baxış',
    'promotion.tier.top10': 'İlk 10',
    'promotion.tier.top50': 'İlk 50',
    'promotion.tier.top100': 'İlk 100',
    'promotion.cta.continue_duration': 'Davam et — müddət seç',
    'promotion.step.duration': 'Müddət seç',
    'promotion.step.extend_duration': 'Müddəti artır',
    'promotion.duration_template': '{days} gün',
    'promotion.duration.popular': 'Populyar seçim',
    'promotion.duration.short_trial': 'Qısa sınaq',
    'promotion.duration.best_value': 'Ən sərfəli paket',
    'promotion.vip_benefits_title': 'VİP nə qazandırır?',
    'promotion.vip_benefit.section': 'Ayrıca «VİP elanlar» bölməsində üst sıra',
    'promotion.vip_benefit.badge': 'Tac nişanı və qızılı çərçivə',
    'promotion.vip_benefit.views': 'Orta hesabla daha çox baxış',
    'promotion.preview_title': 'Lentdə belə görünəcək',
    'promotion.preview_full_title': 'Elanın lentdə görünüşü',
    'promotion.summary.vip_template': '{days} gün VİP',
    'promotion.summary.boost_template': '{tier} · {days} gün',
    'promotion.checkout.vip_title': 'VİP promosyon',
    'promotion.checkout.boost_title_template': 'Önə çək · {tier}',
    'promotion.checkout.package': 'Paket',
    'promotion.checkout.duration': 'Müddət',
    'promotion.checkout.start': 'Başlama',
    'promotion.checkout.end': 'Bitmə',
    'promotion.checkout.starts_after_approval': 'Təsdiqdən dərhal sonra',
    'promotion.checkout.discount': 'Endirim',
    'promotion.payment.card': 'Bank kartı',
    'promotion.payment.card_subtitle': 'Visa · Mastercard',
    'promotion.payment.balance': 'Wawatair balans',
    'promotion.payment.balance_unavailable': 'Balans: 0.00 ₼ — kifayət etmir',
    'promotion.payment.balance_subtitle':
        'Mock ödəniş · real balans inteqrasiyada',
    'promotion.payment.change_method': 'Ödəniş üsulunu dəyiş',
    'promotion.payment.safety':
        'Ödənişlər şifrələnir · kart məlumatı serverdə saxlanmır',
    'promotion.payment.pay_template': 'Ödə · {amount} ₼',
    'enum.payment_method.card': 'Bank kartı',
    'enum.payment_method.balance': 'Wawatair balans',
    'promotion.pay.title': 'Ödəniş',
    'promotion.pay.processing': 'Ödəniş emal olunur…',
    'promotion.pay.processing_hint': 'Zəhmət olmasa gözlə. Bu ekranı bağlama.',
    'promotion.pay.secure_note':
        'Ödənişlər şifrələnir · kart məlumatı serverdə saxlanmır',
    'promotion.pay.retry': 'Yenidən cəhd et',
    'promotion.activated': 'Təbriklər!',
    'promotion.payment_failed': 'Ödəniş alınmadı',
    'promotion.payment_pending': 'Təsdiq gözlənilir',
    'promotion.provider_unavailable': 'Ödəniş səhifəsini açmaq alınmadı.',
    'promotion.status.package': 'Paket',
    'promotion.status.status': 'Status',
    'promotion.status.end': 'Bitmə',
    'promotion.status.amount': 'Məbləğ',
    'promotion.status.refresh': 'Statusu yenilə',
    'promotion.status.refreshing': 'Yenilənir...',
    'promotion.status.view_listing': 'Elanıma bax',
    'promotion.status.done': 'Bitdi',
    'promotion.status.check_later': 'Sonra profildən yoxla',
    'promotion.status.active_vip':
        'Elanın indi VİP-dir və lentin ən yuxarısında görünəcək.',
    'promotion.status.active_boost':
        'Elanın indi seçilmiş mövqe zolağında önə çıxarılır.',
    'promotion.status.failed':
        'Kartından məbləğ tutulmadı. Yenidən cəhd edə bilərsən.',
    'promotion.status.pending':
        'Bankın və ya ödəniş provayderinin təsdiqini gözləyirik. Nəticə hazır olanda bildiriş alacaqsan.',
    'promotion.tabs.active_template': 'Aktiv ({count})',
    'promotion.tabs.expired_template': 'Bitmiş ({count})',
    'promotion.action.renew': 'Yenilə',
    'promotion.action.extend': 'Uzat',
    'promotion.starting_from': 'başlanğıc',
    'promotion.active_template': '{type} artıq aktivdir',
    'promotion.remaining.expired': 'Müddəti bitib',
    'promotion.remaining.days_template': '{days} gün {hours} saat qalıb',
    'promotion.remaining.hours_template': '{hours} saat qalıb',
    'promotion.listing_template': 'Elan #{id}',
    'promotion.error.generic': 'Əməliyyat alınmadı. Yenidən cəhd et.',
    'promotion.error.load': 'Məlumatları yükləmək alınmadı.',
  };

  static Future<Map<String, String>> load({String group = 'listing'}) {
    final cached = _cache[group];
    if (cached != null) return Future.value(cached);
    return _futures[group] ??= sl
        .get<AuthRepository>()
        .getContent(group: group)
        .then((response) => _cache[group] = response.data)
        .catchError((_) => _cache[group] = const {});
  }

  static Future<Map<String, String>> loadAll() {
    const cacheKey = '__all__';
    final cached = _cache[cacheKey];
    if (cached != null) return Future.value(cached);
    return _futures[cacheKey] ??= sl
        .get<AuthRepository>()
        .getContent()
        .then((response) => _cache[cacheKey] = response.data)
        .catchError((_) => _cache[cacheKey] = const {});
  }

  static Future<Map<String, String>> loadGroups(List<String> groups) async {
    final result = <String, String>{};
    for (final group in groups) {
      result.addAll(await load(group: group));
    }
    return result;
  }

  static Future<Map<String, String>> loadDefault() => loadGroups(defaultGroups);

  static String text(
    Map<String, String> content,
    String key, [
    String? fallback,
  ]) {
    final value = content[key];
    if (value == null || value.trim().isEmpty || value == key) {
      return fallback ?? fallbacks[key] ?? _humanizeKey(key);
    }
    return value;
  }

  static String _humanizeKey(String key) {
    final raw = key.split('.').last.replaceAll('_template', '');
    final words = raw
        .split('_')
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part.trim())
        .toList();
    if (words.isEmpty) return '';
    final joined = words.join(' ');
    return joined[0].toUpperCase() + joined.substring(1);
  }
}
