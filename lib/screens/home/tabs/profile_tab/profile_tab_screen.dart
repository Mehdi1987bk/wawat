import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../data/network/api/chat_api.dart';
import '../../../../data/network/response/listing_response.dart';
import '../../../../domain/entities/pagination.dart';
import '../../../../data/cache/cache_manager.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';
import '../../../../presentation/resourses/theme_colors.dart';
import '../../../../presentation/resourses/wawat_dark.dart';
import '../../../../services/localization_service.dart';
import '../../../../services/theme_manager.dart';
import '../../../../services/wawat_content.dart';
import '../fovorite/fovorite_offer_screen.dart';
import '../home_tab/search/search_offer_list_screen.dart';
import '../listings/promotion/promotion_screens.dart';
import 'faq/faq_screen.dart';
import 'blocked_users/blocked_users_screen.dart';
import 'deals/deals_list_screen.dart';
import 'about/about_screen.dart';
import 'legal/legal_doc_screen.dart';
import 'promo/promo_api.dart';
import 'promo/promo_codes_screen.dart';
import 'promo/rate_app_screen.dart';
import 'referral/referral_screen.dart';
import 'reports/reports_screen.dart';
import 'new_profile/new_profile_screen.dart';
import 'new_profile/profile_api.dart';
import 'new_profile/profile_models.dart';
import 'see_more_offers/delivery_full_list_screen.dart';
import 'settings/notification_settings/notification_settings_screen.dart';
import 'support/support_screen.dart';
import 'verification/verification_screen.dart';

const _brand = Color(0xFF017BFE); // бренд-заливка (кнопки/иконки) — не меняется
const _ink900 = Color(0xFF0F172A); // светлый near-black (snackbar/danger light)
const _ink700 = Color(0xFF334155); // светлый ink для отдельных light-веток

// Тема-зависимые цвета вынесены в общий theme_colors.dart (c*(isDark)) —
// одна navy-палитра на всё приложение.

String _text(Map<String, String> content, String key, String fallback) {
  return WawatContent.text(content, key, fallback);
}

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  final WawatProfileApi _api = WawatProfileApi();
  late Future<WawatProfileBundle> _future;
  late Future<int> _activeDealsCountFuture;
  late Future<int> _promoActiveCountFuture;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _activeDealsCountFuture = _loadActiveDealsCount();
    _promoActiveCountFuture = _loadPromoActiveCount();
  }

  Future<int> _loadActiveDealsCount() async {
    try {
      final page =
          await sl.get<ChatApi>().getShipments(filter: 'active', perPage: 1);
      return page.counts.active;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _loadPromoActiveCount() async {
    if (!kPromoFeatureEnabled) return 0;
    try {
      final page = await PromoApi().getPromoCodes(status: 'active');
      return page.activeCount;
    } catch (_) {
      return 0;
    }
  }

  Future<WawatProfileBundle> _load() async {
    final results = await Future.wait<dynamic>([
      _api.content(),
      _api.me(),
    ]);

    return WawatProfileBundle(
      user: results[1] as WawatProfileUser,
      content: results[0] as Map<String, String>,
      listings: Pagination<Listing>(data: const [], lastPage: 1),
      reviews: const WawatReviewResponse(
        data: [],
        distribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      ),
      packageNames: const {},
    );
  }

  void _reload() {
    setState(() {
      _future = _load();
      _activeDealsCountFuture = _loadActiveDealsCount();
      _promoActiveCountFuture = _loadPromoActiveCount();
    });
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _openUnavailable(Map<String, String> content, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? WawatDark.surfaceAlt : _ink900,
        content: Text(
          _text(content, 'common.coming_soon', '$label tezliklə aktiv olacaq.'),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _openEditProfile(WawatProfileBundle bundle) async {
    final updated = await Navigator.of(context).push<WawatProfileUser>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => WawatEditProfileScreen(
          api: _api,
          user: bundle.user,
          content: bundle.content,
        ),
      ),
    );
    if (updated != null) _reload();
  }

  Future<void> _openVerification(Map<String, String> content) async {
    try {
      final user = await sl.get<AuthRepository>().userDetails.first;
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VerificationScreen(user: user)),
      );
    } catch (_) {
      if (!mounted) return;
      _openUnavailable(
        content,
        _text(content, 'menu.verify_account', 'Hesabı təsdiqlə'),
      );
    }
  }

  Future<void> _openDeleteAccount(WawatProfileBundle bundle) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WawatDeleteAccountSheet(
        api: _api,
        content: bundle.content,
      ),
    );
  }

  Future<void> _openLanguageSheet(WawatProfileBundle bundle) async {
    final content = bundle.content;
    final current = bundle.user.preferredLocale ?? 'az';
    final fallback = const [
      _LanguageOption('az', 'Azərbaycanca', '🇦🇿'),
      _LanguageOption('en', 'English', '🇬🇧'),
      _LanguageOption('ru', 'Русский', '🇷🇺'),
      _LanguageOption('tr', 'Türkçe', '🇹🇷'),
      _LanguageOption('ua', 'Українська', '🇺🇦'),
      _LanguageOption('es', 'Español', '🇪🇸'),
    ];

    List<_LanguageOption> options = fallback;
    try {
      final response = await _api.languages();
      if (response.data.isNotEmpty) {
        options = response.data
            .map(
              (item) => _LanguageOption(
                item.code == 'uk' ? 'ua' : item.code,
                item.name ?? item.code.toUpperCase(),
                _flagForLocale(item.code),
              ),
            )
            .toList();
      }
    } catch (_) {}

    if (!mounted) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.only(top: 64),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            decoration: BoxDecoration(
              color: cCard(isDark),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 6,
                    decoration: BoxDecoration(
                      color: cFaint(isDark),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _text(content, 'menu.language', 'Dil'),
                  style: TextStyle(
                    color: cText(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _text(
                    content,
                    'menu.language_subtitle',
                    'Tətbiq dilini seçin.',
                  ),
                  style: TextStyle(
                    color: cMuted(isDark),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                ...options.map(
                  (item) => _LanguageRow(
                    option: item,
                    selected: item.code == current,
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      try {
                        // 1) Локально сохраняем язык → Accept-Language-интерцептор
                        //    и MaterialApp.locale переключаются (uk для украинского).
                        final localeCode = item.code == 'ua' ? 'uk' : item.code;
                        await sl
                            .get<CacheManager>()
                            .saveLocale(Locale(localeCode));
                        // 2) Рефетч всей CMS-карты на новом языке (сброс ETag).
                        await LocalizationService.instance
                            .changeLocale(item.code);
                        // 3) Сохраняем предпочтение в профиле.
                        await _api.updateProfile(
                          {'preferred_locale': item.code},
                        );
                        _reload();
                      } catch (_) {
                        if (!mounted) return;
                        _openUnavailable(content, item.name);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(Map<String, String> content) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
            decoration: BoxDecoration(
              color: cCard(isDark),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: cFaint(isDark),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: cFill(isDark),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(PhosphorIconsRegular.signOut,
                      color: cText3(isDark), size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  _text(
                    content,
                    'menu.logout_confirm_title',
                    'Çıxış etmək?',
                  ),
                  style: TextStyle(
                    color: cText(isDark),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _text(
                    content,
                    'menu.logout_confirm_message',
                    'Yenidən daxil olmaq üçün e-poçt və parolunuz lazım olacaq.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: cText2(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () => Navigator.of(sheetContext).pop(true),
                    child: Text(
                      _text(content, 'menu.logout', 'Çıxış'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: Text(
                    'İmtina et',
                    style: TextStyle(
                      color: cMuted(isDark),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;
    await _api.logout();
    await sl.get<AuthRepository>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WawatProfileBundle>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _MenuSkeleton();
        }
        if (!snapshot.hasData) {
          return _MenuError(onRetry: _reload);
        }
        final bundle = snapshot.data!;
        final content = bundle.content;
        final user = bundle.user;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final activeListings =
            user.stats.listingsActive ?? bundle.listings.data.length;
        final reviewsCount =
            user.stats.reviewsReceivedCount ?? bundle.reviews.data.length;

        return Scaffold(
          backgroundColor: cScreen(isDark),
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: cBrandText(isDark),
              backgroundColor: cCard(isDark),
              onRefresh: () async => _reload(),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 112),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Text(
                      _text(content, 'menu.title', 'Menyu'),
                      style: TextStyle(
                        color: cText(isDark),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _ProfileHeaderCard(
                    user: user,
                    content: content,
                    onTap: () => _push(PublicProfileScreen(userId: user.id)),
                  ),
                  _MenuSectionTitle(
                    _text(content, 'menu.section_activity', 'Fəaliyyətim'),
                  ),
                  _MenuGroup(
                    children: [
                      _MenuRow(
                        icon: PhosphorIconsFill.note,
                        label: _text(content, 'menu.my_listings', 'Elanlarım'),
                        badge: activeListings > 0 ? '$activeListings' : null,
                        onTap: () => _push(DeliveryFullListScreen()),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.rocketLaunch,
                        label: _text(
                          content,
                          'menu.promotions',
                          'Promosyonlarım',
                        ),
                        onTap: () => _push(const MyPromotionsScreen()),
                      ),
                      FutureBuilder<int>(
                        future: _activeDealsCountFuture,
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return _MenuRow(
                            icon: PhosphorIconsFill.handshake,
                            label:
                                _text(content, 'menu.deals', 'Sövdələşmələrim'),
                            badge: count > 0
                                ? _text(
                                    content,
                                    'deals.active_badge_template',
                                    '{count} aktiv',
                                  ).replaceAll('{count}', '$count')
                                : null,
                            onTap: () => _push(DealsListScreen()),
                          );
                        },
                      ),
                      if (kPromoFeatureEnabled)
                        FutureBuilder<int>(
                          future: _promoActiveCountFuture,
                          builder: (context, snapshot) {
                            final count = snapshot.data ?? 0;
                            return _MenuRow(
                              icon: PhosphorIconsFill.ticket,
                              label: _text(
                                  content, 'menu.promo_codes', 'Promokodlarım'),
                              badge: count > 0 ? '$count' : null,
                              onTap: () => _push(PromoCodesScreen()),
                            );
                          },
                        ),
                      _MenuRow(
                        icon: PhosphorIconsFill.heart,
                        label: _text(content, 'menu.favorites', 'Seçilmişlər'),
                        onTap: () => _push(FovoriteOfferListScreen()),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.bookmarkSimple,
                        label: _text(
                          content,
                          'menu.saved_searches',
                          'Saxlanan axtarışlar',
                        ),
                        onTap: () => _push(
                          SearchOfferListScreen(openSavedOnStart: true),
                        ),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.users,
                        label: _text(
                          content,
                          'menu.connections',
                          'İzləyicilər və izlədiklərim',
                        ),
                        trailingText:
                            '${user.followersCount} / ${user.followingCount}',
                        isLast: true,
                        onTap: () => _push(
                          WawatFollowListScreen(
                            api: _api,
                            user: user,
                            content: content,
                            following: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _MenuSectionTitle(
                    _text(content, 'menu.section_reviews', 'Rəylər'),
                  ),
                  _MenuGroup(
                    children: [
                      _MenuRow(
                        icon: PhosphorIconsFill.star,
                        label: _text(
                          content,
                          'menu.reviews',
                          'Rəylərim',
                        ),
                        badge: reviewsCount > 0 ? '$reviewsCount' : null,
                        isLast: true,
                        onTap: () => _push(
                          WawatReviewsScreen(
                            api: _api,
                            user: user,
                            content: content,
                            canReply: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _MenuSectionTitle(
                    _text(content, 'menu.section_account', 'Hesab'),
                  ),
                  _MenuGroup(
                    children: [
                      _MenuRow(
                        icon: PhosphorIconsFill.user,
                        label: _text(
                          content,
                          'menu.edit_profile',
                          'Profili redaktə et',
                        ),
                        onTap: () => _openEditProfile(bundle),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.sealCheck,
                        label: _text(
                          content,
                          'menu.verify_account',
                          'Hesabı təsdiqlə',
                        ),
                        badge: user.isVerified
                            ? null
                            : _text(
                                content,
                                'menu.not_verified_badge',
                                'Təsdiqlənməyib',
                              ),
                        amberBadge: !user.isVerified,
                        onTap: () => _openVerification(content),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.lockKey,
                        label: _text(
                          content,
                          'menu.change_password',
                          'Parolu dəyiş',
                        ),
                        onTap: () => _push(
                          WawatChangePasswordScreen(
                            api: _api,
                            content: content,
                          ),
                        ),
                        isLast: true,
                      ),
                    ],
                  ),
                  _MenuSectionTitle(
                    _text(content, 'menu.section_preferences', 'Tərcihlər'),
                  ),
                  _MenuGroup(
                    children: [
                      _MenuRow(
                        icon: PhosphorIconsFill.bell,
                        label: _text(
                          content,
                          'menu.notifications',
                          'Bildiriş ayarları',
                        ),
                        onTap: () => _push(const NotificationSettingsScreen()),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.lockSimple,
                        label: _text(content, 'menu.privacy', 'Məxfilik'),
                        onTap: () => _push(
                          WawatPrivacySettingsScreen(
                            api: _api,
                            user: user,
                            content: content,
                          ),
                        ),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.translate,
                        label: _text(content, 'menu.language', 'Dil'),
                        trailingText: _localeName(user.preferredLocale),
                        onTap: () => _openLanguageSheet(bundle),
                      ),
                      _ThemeModeRow(
                        label: _text(content, 'menu.appearance', 'Görünüş'),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.prohibit,
                        label: _text(
                          content,
                          'menu.blocked_users',
                          'Bloklanmış istifadəçilər',
                        ),
                        isLast: true,
                        onTap: () => _push(BlockedUsersScreen()),
                      ),
                    ],
                  ),
                  _MenuSectionTitle(
                    _text(
                      content,
                      'menu.section_support',
                      'Dəstək & haqqında',
                    ),
                  ),
                  _MenuGroup(
                    children: [
                      _MenuRow(
                        icon: PhosphorIconsFill.question,
                        label: _text(content, 'menu.help', 'Kömək & FAQ'),
                        onTap: () => _push(FaqScreen()),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.flag,
                        label:
                            _text(content, 'menu.my_reports', 'Şikayətlərim'),
                        onTap: () => _push(const ReportsScreen()),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.headset,
                        label: _text(
                            content, 'menu.contact_support', 'Dəstəyə yaz'),
                        onTap: () => _push(SupportScreen()),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.fileText,
                        label: _text(
                          content,
                          'menu.rules',
                          'Qaydalar & şərtlər',
                        ),
                        onTap: () => _push(const LegalDocScreen(
                            slug: 'terms', title: 'Qaydalar & şərtlər')),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.shieldCheck,
                        label: _text(
                          content,
                          'menu.privacy_policy',
                          'Məxfilik siyasəti',
                        ),
                        onTap: () => _push(const LegalDocScreen(
                            slug: 'privacy', title: 'Məxfilik siyasəti')),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.heartStraight,
                        label: _text(
                          content,
                          'menu.rate_app',
                          'Tətbiqi qiymətləndir',
                        ),
                        onTap: () => _push(const RateAppScreen()),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.gift,
                        label:
                            _text(content, 'menu.invite', 'Dostunu dəvət et'),
                        onTap: () => _push(const ReferralScreen()),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.info,
                        label: _text(content, 'menu.about', 'Tətbiq haqqında'),
                        trailingText: 'v1.0.0',
                        isLast: true,
                        onTap: () => _push(const AboutScreen()),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                    child: _MenuActionButton(
                      icon: PhosphorIconsRegular.signOut,
                      label: _text(content, 'menu.logout', 'Çıxış'),
                      onTap: () => _confirmLogout(content),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: _MenuActionButton(
                      icon: PhosphorIconsRegular.trash,
                      label: _text(
                        content,
                        'menu.delete_account',
                        'Hesabı sil',
                      ),
                      danger: true,
                      onTap: () => _openDeleteAccount(bundle),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Wawatair · v1.0.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cMuted(isDark),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final WawatProfileUser user;
  final Map<String, String> content;
  final VoidCallback onTap;

  const _ProfileHeaderCard({
    required this.user,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 14, 12, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cCard(isDark),
          borderRadius: BorderRadius.circular(22),
          border: cCardBorder(isDark),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: _ink900.withValues(alpha: .07),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
        ),
        child: Row(
          children: [
            _MenuAvatar(user: user),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.safeFullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cText(isDark),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 6),
                        Icon(
                          PhosphorIconsFill.sealCheck,
                          color: cBrandText(isDark),
                          size: 16,
                        ),
                      ],
                      if ((user.tier ?? '').isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _SmallTier(label: user.tier!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.username == null || user.username!.isEmpty
                        ? user.email ?? ''
                        : '@${user.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cMuted(isDark),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Text(
                        _text(
                          content,
                          'menu.view_profile',
                          'Profilə bax',
                        ),
                        style: TextStyle(
                          color: cBrandText(isDark),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        PhosphorIconsBold.arrowRight,
                        color: cBrandText(isDark),
                        size: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(PhosphorIconsRegular.caretRight,
                color: cFaint(isDark), size: 18),
          ],
        ),
      ),
    );
  }
}

class _MenuAvatar extends StatelessWidget {
  final WawatProfileUser user;

  const _MenuAvatar({required this.user});

  Widget _initials() => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_brand, Color(0xFF024FA3)]),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          user.initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _image(String url, {required Widget onError}) => CachedNetworkImage(
        imageUrl: url,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        placeholder: (_, __) => _initials(),
        errorWidget: (_, __, ___) => onError,
      );

  @override
  Widget build(BuildContext context) {
    final thumb = user.avatarThumbUrl;
    final full = user.avatarUrl;
    Widget child;
    if (thumb != null && thumb.isNotEmpty) {
      // Thumbnails may 404 (not generated) — fall back to the full image,
      // then to initials, instead of rendering a broken-image icon.
      final hasFull = full != null && full.isNotEmpty && full != thumb;
      child = _image(thumb,
          onError: hasFull ? _image(full, onError: _initials()) : _initials());
    } else if (full != null && full.isNotEmpty) {
      child = _image(full, onError: _initials());
    } else {
      child = _initials();
    }
    return ClipRRect(borderRadius: BorderRadius.circular(18), child: child);
  }
}

class _SmallTier extends StatelessWidget {
  final String label;

  const _SmallTier({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cFill(isDark),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: cText3(isDark),
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MenuSectionTitle extends StatelessWidget {
  final String text;

  const _MenuSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Text(
        text,
        style: TextStyle(
          color: cText2(isDark),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<Widget> children;

  const _MenuGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cCard(isDark),
        borderRadius: BorderRadius.circular(22),
        border: cCardBorder(isDark),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: _ink900.withValues(alpha: .06),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final bool amberBadge;
  final String? trailingText;
  final bool isLast;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.amberBadge = false,
    this.trailingText,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: cCard(isDark),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(
                      color: cLine(isDark),
                      width: 1,
                    ),
                  ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cBrandSoft(isDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: cBrandText(isDark), size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (badge != null && badge!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: amberBadge
                        ? (isDark
                            ? const Color(0x29F5B40A)
                            : const Color(0xFFFFF7ED))
                        : cBrandSoft(isDark),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: amberBadge
                          ? (isDark
                              ? const Color(0xFFF4C64D)
                              : const Color(0xFFD97706))
                          : cBrandText(isDark),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (trailingText != null && trailingText!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    trailingText!,
                    style: TextStyle(
                      color: cMuted(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                PhosphorIconsRegular.caretRight,
                color: cFaint(isDark),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Menu row that toggles the app light/dark theme via [ThemeManager], with an
/// animated day↔night switch (sliding sun/moon knob) as its trailing control.
class _ThemeModeRow extends StatelessWidget {
  final String label;

  const _ThemeModeRow({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: cCard(isDark),
      child: InkWell(
        onTap: () =>
            Provider.of<ThemeManager>(context, listen: false).toggleTheme(),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: cLine(isDark), width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cBrandSoft(isDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(PhosphorIconsFill.circleHalf,
                    color: cBrandText(isDark), size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ThemeSwitch(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated day/night toggle: a gradient track (sky blue ↔ night navy), a
/// sliding white knob whose icon cross-fades sun ↔ moon, and stars that appear
/// at night. Purely visual — the parent row owns the tap/toggle.
class _ThemeSwitch extends StatelessWidget {
  final bool isDark;

  const _ThemeSwitch({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeInOut,
      width: 58,
      height: 32,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF243244), Color(0xFF0C1524)]
              : const [Color(0xFF8EC5FF), Color(0xFF5B9DF9)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0B1220) : const Color(0xFF5B9DF9))
                .withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _StarLayer(show: isDark),
          AnimatedAlign(
            duration: const Duration(milliseconds: 340),
            curve: Curves.easeInOutCubic,
            alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(
                    scale: anim,
                    child: RotationTransition(
                      turns: Tween<double>(begin: 0.55, end: 1).animate(anim),
                      child: child,
                    ),
                  ),
                ),
                child: Icon(
                  isDark ? PhosphorIconsFill.moon : PhosphorIconsFill.sun,
                  key: ValueKey<bool>(isDark),
                  size: 15,
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFF59E0B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fades the three stars in (night) / out (day) together.
class _StarLayer extends StatelessWidget {
  final bool show;

  const _StarLayer({required this.show});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 260),
      opacity: show ? 1 : 0,
      child: const SizedBox.expand(
        child: Stack(
          children: [
            Positioned(left: 6, top: 6, child: _Star(size: 2.5)),
            Positioned(left: 14, top: 13, child: _Star(size: 1.6)),
            Positioned(left: 5, top: 18, child: _Star(size: 1.3)),
          ],
        ),
      ),
    );
  }
}

class _Star extends StatelessWidget {
  final double size;

  const _Star({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MenuActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  final VoidCallback onTap;

  const _MenuActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = danger
        ? (isDark ? const Color(0xFFFF9A9A) : const Color(0xFFEF4444))
        : (isDark ? WawatDark.textPrimary : _ink700);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: danger
              ? (isDark ? const Color(0x1FEF4444) : const Color(0xFFFFEBEE))
              : cCard(isDark),
          border: danger
              ? Border.all(
                  color: isDark
                      ? const Color(0x4CEF4444)
                      : const Color(0xFFFFCDD2))
              : cCardBorder(isDark),
          borderRadius: BorderRadius.circular(18),
          boxShadow: (danger || isDark)
              ? null
              : [
                  BoxShadow(
                    color: _ink900.withValues(alpha: .06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: contentColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: contentColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final _LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? cBrandSoft(isDark) : cCard(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? (isDark ? _brand : _brand.withValues(alpha: .35))
                : cLine(isDark),
          ),
        ),
        child: Row(
          children: [
            Text(option.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.name,
                style: TextStyle(
                  color: selected ? cBrandText(isDark) : cText(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (selected)
              Icon(PhosphorIconsFill.checkCircle,
                  color: cBrandText(isDark), size: 20),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption {
  final String code;
  final String name;
  final String flag;

  const _LanguageOption(this.code, this.name, this.flag);
}

class _MenuSkeleton extends StatelessWidget {
  const _MenuSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: cScreen(isDark),
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: cBrandText(isDark)),
        ),
      ),
    );
  }
}

class _MenuError extends StatelessWidget {
  final VoidCallback onRetry;

  const _MenuError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: cScreen(isDark),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIconsRegular.warningCircle,
                    color: cBrandText(isDark), size: 42),
                const SizedBox(height: 12),
                Text(
                  'Menyu yüklənmədi.',
                  style: TextStyle(
                    color: cText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brand,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Yenidən yoxla'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _localeName(String? code) {
  switch (code) {
    case 'en':
      return 'English';
    case 'ru':
      return 'Русский';
    case 'tr':
      return 'Türkçe';
    case 'ua':
    case 'uk':
      return 'Українська';
    case 'es':
      return 'Español';
    case 'az':
    default:
      return 'Azərbaycanca';
  }
}

String _flagForLocale(String code) {
  switch (code) {
    case 'en':
      return '🇬🇧';
    case 'ru':
      return '🇷🇺';
    case 'tr':
      return '🇹🇷';
    case 'ua':
    case 'uk':
      return '🇺🇦';
    case 'es':
      return '🇪🇸';
    case 'az':
    default:
      return '🇦🇿';
  }
}
