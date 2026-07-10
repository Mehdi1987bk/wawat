import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../data/network/response/listing_response.dart';
import '../../../../domain/entities/pagination.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';
import '../../../chat/chat/chat_list_screen.dart';
import '../fovorite/fovorite_offer_screen.dart';
import '../home_tab/search/search_offer_list_screen.dart';
import 'faq/faq_screen.dart';
import 'new_profile/new_profile_screen.dart';
import 'new_profile/profile_api.dart';
import 'new_profile/profile_models.dart';
import 'privacy_policy/privacy_policy_screen.dart';
import 'see_more_offers/delivery_full_list_screen.dart';
import 'settings/notification_settings/notification_settings_screen.dart';
import 'support/support_screen.dart';
import 'verification/verification_screen.dart';

const _brand = Color(0xFF017BFE);
const _brand50 = Color(0xFFEAF3FE);
const _ink900 = Color(0xFF0F172A);
const _ink700 = Color(0xFF334155);
const _ink600 = Color(0xFF475569);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);
const _ink300 = Color(0xFFCBD5E1);
const _ink100 = Color(0xFFF1F5F9);
const _screen = Color(0xFFF4F6F9);

String _text(Map<String, String> content, String key, String fallback) {
  final value = content[key];
  if (value == null || value.trim().isEmpty || value == key) return fallback;
  return value;
}

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  final WawatProfileApi _api = WawatProfileApi();
  late Future<WawatProfileBundle> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<WawatProfileBundle> _load() async {
    final contentFuture = _api.content();
    final user = await _api.me();
    final listingsFuture = _api.myListings().catchError(
          (_) => Pagination<Listing>(data: const [], lastPage: 1),
        );
    final reviewsFuture = _api.reviews(user.id).catchError(
          (_) => const WawatReviewResponse(
            data: [],
            distribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
          ),
        );
    final results = await Future.wait<dynamic>([
      contentFuture,
      listingsFuture,
      reviewsFuture,
    ]);

    return WawatProfileBundle(
      user: user,
      content: results[0] as Map<String, String>,
      listings: results[1] ?? Pagination<Listing>(data: const [], lastPage: 1),
      reviews: results[2] as WawatReviewResponse,
      packageNames: const {},
    );
  }

  void _reload() {
    setState(() => _future = _load());
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _openUnavailable(Map<String, String> content, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _ink900,
        content: Text(
          _text(content, 'common.coming_soon', '$label tezliklə aktiv olacaq.'),
          style: const TextStyle(fontWeight: FontWeight.w800),
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                      color: _ink300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _text(content, 'menu.language', 'Dil'),
                  style: const TextStyle(
                    color: _ink900,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _text(
                    content,
                    'menu.language_subtitle',
                    'Tətbiq dilini seçin.',
                  ),
                  style: const TextStyle(
                    color: _ink400,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
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
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _ink300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _ink100,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(PhosphorIconsRegular.signOut,
                      color: _ink600, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  _text(
                    content,
                    'menu.logout_confirm_title',
                    'Çıxış etmək?',
                  ),
                  style: const TextStyle(
                    color: _ink900,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
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
                  style: const TextStyle(
                    color: _ink500,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: const Text(
                    'İmtina et',
                    style: TextStyle(
                      color: _ink400,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
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
        final activeListings =
            user.stats.listingsActive ?? bundle.listings.data.length;
        final reviewsCount =
            user.stats.reviewsReceivedCount ?? bundle.reviews.data.length;

        return Scaffold(
          backgroundColor: _screen,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: _brand,
              onRefresh: () async => _reload(),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 112),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Text(
                      _text(content, 'menu.title', 'Menyu'),
                      style: const TextStyle(
                        color: _ink900,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
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
                        icon: PhosphorIconsFill.handshake,
                        label: _text(content, 'menu.deals', 'Sövdələşmələrim'),
                        onTap: () => _push(ChatListScreen()),
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
                        label: _text(content, 'menu.followers', 'İzləyicilər'),
                        trailingText: '${user.followersCount}',
                        onTap: () => _push(
                          WawatFollowListScreen(
                            api: _api,
                            user: user,
                            content: content,
                            following: false,
                          ),
                        ),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.userCheck,
                        label: _text(content, 'menu.following', 'İzlədiklərim'),
                        trailingText: '${user.followingCount}',
                        isLast: true,
                        onTap: () => _push(
                          WawatFollowListScreen(
                            api: _api,
                            user: user,
                            content: content,
                            following: true,
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
                          'menu.reviews_received',
                          'Aldığım rəylər',
                        ),
                        badge: reviewsCount > 0 ? '$reviewsCount' : null,
                        onTap: () => _push(
                          WawatReviewsScreen(
                            api: _api,
                            user: user,
                            content: content,
                            canReply: true,
                          ),
                        ),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.chatText,
                        label: _text(
                          content,
                          'menu.reviews_left',
                          'Yazdığım rəylər',
                        ),
                        isLast: true,
                        onTap: () => _push(
                          WawatReviewsScreen(
                            api: _api,
                            user: user,
                            content: content,
                            left: true,
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
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.envelopeSimple,
                        label: _text(content, 'menu.email', 'E-poçt'),
                        trailingText: _shortEmail(user.email),
                        isLast: true,
                        onTap: () => _openUnavailable(
                          content,
                          _text(content, 'menu.email', 'E-poçt'),
                        ),
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
                      _MenuRow(
                        icon: PhosphorIconsFill.prohibit,
                        label: _text(
                          content,
                          'menu.blocked_users',
                          'Bloklanmış istifadəçilər',
                        ),
                        isLast: true,
                        onTap: () => _openUnavailable(
                          content,
                          _text(
                            content,
                            'menu.blocked_users',
                            'Bloklanmış istifadəçilər',
                          ),
                        ),
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
                        onTap: () => _openUnavailable(
                          content,
                          _text(
                            content,
                            'menu.my_reports',
                            'Şikayətlərim',
                          ),
                        ),
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
                        onTap: () => _push(PrivacyPolicyScreen()),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.shieldCheck,
                        label: _text(
                          content,
                          'menu.privacy_policy',
                          'Məxfilik siyasəti',
                        ),
                        onTap: () => _push(PrivacyPolicyScreen()),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.heartStraight,
                        label: _text(
                          content,
                          'menu.rate_app',
                          'Tətbiqi qiymətləndir',
                        ),
                        onTap: () => _openUnavailable(
                          content,
                          _text(
                            content,
                            'menu.rate_app',
                            'Tətbiqi qiymətləndir',
                          ),
                        ),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.gift,
                        label:
                            _text(content, 'menu.invite', 'Dostunu dəvət et'),
                        onTap: () => _openUnavailable(
                          content,
                          _text(content, 'menu.invite', 'Dostunu dəvət et'),
                        ),
                      ),
                      _MenuRow(
                        icon: PhosphorIconsFill.info,
                        label: _text(content, 'menu.about', 'Tətbiq haqqında'),
                        trailingText: 'v1.0.0',
                        isLast: true,
                        onTap: () => _openUnavailable(
                          content,
                          _text(
                            content,
                            'menu.about',
                            'Tətbiq haqqında',
                          ),
                        ),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Wawatair · v1.0.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _ink400,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 14, 12, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
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
                          style: const TextStyle(
                            color: _ink900,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          PhosphorIconsFill.sealCheck,
                          color: _brand,
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
                    style: const TextStyle(
                      color: _ink400,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
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
                        style: const TextStyle(
                          color: _brand,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        PhosphorIconsBold.arrowRight,
                        color: _brand,
                        size: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(PhosphorIconsRegular.caretRight,
                color: _ink300, size: 18),
          ],
        ),
      ),
    );
  }
}

class _MenuAvatar extends StatelessWidget {
  final WawatProfileUser user;

  const _MenuAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final imageUrl = user.avatarThumbUrl ?? user.avatarUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
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
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SmallTier extends StatelessWidget {
  final String label;

  const _SmallTier({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _ink100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _ink600,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _ink500,
          fontSize: 12,
          fontWeight: FontWeight.w900,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
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
    return Material(
      color: Colors.white,
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
                      color: _ink900.withValues(alpha: .06),
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
                  color: _brand50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _brand, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink900,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (badge != null && badge!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: amberBadge ? const Color(0xFFFFF7ED) : _brand50,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: amberBadge ? const Color(0xFFD97706) : _brand,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              if (trailingText != null && trailingText!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    trailingText!,
                    style: const TextStyle(
                      color: _ink400,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(
                PhosphorIconsRegular.caretRight,
                color: _ink300,
                size: 16,
              ),
            ],
          ),
        ),
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: danger ? const Color(0xFFFFEBEE) : Colors.white,
          border: danger ? Border.all(color: const Color(0xFFFFCDD2)) : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: danger
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
              color: danger ? const Color(0xFFEF4444) : _ink700,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: danger ? const Color(0xFFEF4444) : _ink700,
                fontSize: 14,
                fontWeight: FontWeight.w900,
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? _brand50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? _brand.withValues(alpha: .35)
                : _ink900.withValues(alpha: .06),
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
                  color: selected ? _brand : _ink900,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (selected)
              const Icon(PhosphorIconsFill.checkCircle,
                  color: _brand, size: 20),
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
    return const Scaffold(
      backgroundColor: _screen,
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: _brand),
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
    return Scaffold(
      backgroundColor: _screen,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(PhosphorIconsRegular.warningCircle,
                    color: _brand, size: 42),
                const SizedBox(height: 12),
                const Text(
                  'Menyu yüklənmədi.',
                  style: TextStyle(
                    color: _ink900,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
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

String _shortEmail(String? email) {
  if (email == null || email.trim().isEmpty) return '';
  final parts = email.split('@');
  if (parts.length != 2 || parts.first.length < 4) return email;
  return '${parts.first.substring(0, 3)}@…';
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
    case 'az':
    default:
      return '🇦🇿';
  }
}
