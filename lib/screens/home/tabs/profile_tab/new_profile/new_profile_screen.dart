import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:buking/presentation/common/app_bottom_sheet.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/cache/cache_manager.dart';
import '../../../../../data/network/response/listing_response.dart';
import '../../../../../data/network/response/language_response.dart';
import '../../../../../data/network/response/package_types_response.dart';
import '../../../../../domain/entities/pagination.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../services/notification_socket_service.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/wawat_content.dart';
import '../../../home_screen.dart';
import '../../home_tab/widget/auth_modal_utils.dart';
import '../../listings/details/listing_details_screen.dart';
import '../faq/faq_screen.dart';
import '../privacy_policy/privacy_policy_screen.dart';
import '../settings/notification_settings/notification_settings_screen.dart';
import '../support/support_screen.dart';
import '../verification/verification_screen.dart';
import 'avatar_viewer.dart';
import 'profile_api.dart';
import 'profile_models.dart';

const _brand = Color(0xFF017BFE);
const _brand50 = Color(0xFFEAF3FE);
const _ink900 = Color(0xFF0F172A);
const _ink800 = Color(0xFF1E293B);
const _ink700 = Color(0xFF334155);
const _ink600 = Color(0xFF475569);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);
const _ink300 = Color(0xFFCBD5E1);
const _ink200 = Color(0xFFE2E8F0);
const _screen = Color(0xFFF6F8FB);
const _amber = Color(0xFFE8A400);
const _amber50 = Color(0xFFFEF6E7);
const _emerald = Color(0xFF10B981);

// Тема-зависимые цвета. Светлая ветка = точь-в-точь как было (белый режим не меняется),
// тёмная ветка = единый графит из [WawatDark].
Color _cScreen(bool d) => d ? WawatDark.bg : _screen;
Color _cCard(bool d) => d ? WawatDark.surface : Colors.white;
Color _cText(bool d) => d ? WawatDark.textPrimary : _ink900;
Color _cText2(bool d) => d ? WawatDark.textSecondary : _ink500;
Color _cMuted(bool d) => d ? WawatDark.textMuted : _ink400;
Color _cFaint(bool d) => d ? WawatDark.iconMuted : _ink300;
Color _cLine(bool d) => d ? WawatDark.divider : _ink900.withValues(alpha: .06);
Color _cBrandSoft(bool d) => d ? WawatDark.brandSoft : _brand50;
BoxBorder? _cCardBorder(bool d) =>
    d ? Border.all(color: WawatDark.border) : null;

String _tx(Map<String, String> content, String key, String fallback) {
  return WawatContent.text(content, key, fallback);
}

class WawatProfileScreen extends StatefulWidget {
  final String? userId;
  final ListingOwner? initialOwner;
  final bool isSelf;

  /// Tab to open on: 0 = listings, 1 = reviews.
  final int initialTab;

  const WawatProfileScreen({
    super.key,
    this.userId,
    this.initialOwner,
    this.isSelf = false,
    this.initialTab = 0,
  });

  @override
  State<WawatProfileScreen> createState() => _WawatProfileScreenState();
}

class PublicProfileScreen extends WawatProfileScreen {
  const PublicProfileScreen({
    super.key,
    required String userId,
    ListingOwner? initialOwner,
    int initialTab = 0,
  }) : super(
          userId: userId,
          initialOwner: initialOwner,
          isSelf: false,
          initialTab: initialTab,
        );
}

class WawatSettingsScreen extends StatelessWidget {
  final WawatProfileApi api;
  final WawatProfileUser user;
  final Map<String, String> content;
  final VoidCallback? onProfileUpdated;

  const WawatSettingsScreen({
    super.key,
    required this.api,
    required this.user,
    required this.content,
    this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsHubScreen(
      api: api,
      user: user,
      content: content,
      onProfileUpdated: onProfileUpdated ?? () {},
      onVerification: () async {
        try {
          final authUser = await sl.get<AuthRepository>().userDetails.first;
          if (!context.mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VerificationScreen(user: authUser),
            ),
          );
        } catch (_) {
          if (!context.mounted) return;
          _showSnack(
            context,
            _tx(content, 'profile.load_failed', 'Məlumat yüklənmədi.'),
            error: true,
          );
        }
      },
    );
  }
}

class WawatEditProfileScreen extends StatelessWidget {
  final WawatProfileApi api;
  final WawatProfileUser user;
  final Map<String, String> content;

  const WawatEditProfileScreen({
    super.key,
    required this.api,
    required this.user,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return _EditProfileScreen(api: api, user: user, content: content);
  }
}

class WawatPrivacySettingsScreen extends StatelessWidget {
  final WawatProfileApi api;
  final WawatProfileUser user;
  final Map<String, String> content;

  const WawatPrivacySettingsScreen({
    super.key,
    required this.api,
    required this.user,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return _PrivacySettingsScreen(
      api: api,
      initial: user.settings.privacy,
      content: content,
    );
  }
}

class WawatChangePasswordScreen extends StatelessWidget {
  final WawatProfileApi api;
  final Map<String, String> content;

  const WawatChangePasswordScreen({
    super.key,
    required this.api,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return _ChangePasswordScreen(api: api, content: content);
  }
}

class WawatDeleteAccountSheet extends StatelessWidget {
  final WawatProfileApi api;
  final Map<String, String> content;

  const WawatDeleteAccountSheet({
    super.key,
    required this.api,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return _DeleteAccountSheet(api: api, content: content);
  }
}

class WawatFollowListScreen extends StatelessWidget {
  final WawatProfileApi api;
  final WawatProfileUser user;
  final Map<String, String> content;
  final bool following;

  const WawatFollowListScreen({
    super.key,
    required this.api,
    required this.user,
    required this.content,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    return _FollowListScreen(
      api: api,
      user: user,
      content: content,
      following: following,
    );
  }
}

class WawatReviewsScreen extends StatefulWidget {
  final WawatProfileApi api;
  final WawatProfileUser user;
  final Map<String, String> content;
  final bool left;
  final bool canReply;

  const WawatReviewsScreen({
    super.key,
    required this.api,
    required this.user,
    required this.content,
    this.left = false,
    this.canReply = false,
  });

  @override
  State<WawatReviewsScreen> createState() => _WawatReviewsScreenState();
}

class _WawatReviewsScreenState extends State<WawatReviewsScreen> {
  late bool _leftTab;
  late Future<WawatReviewResponse> _future;
  final Set<String> _pendingReplyIds = <String>{};
  int _receivedCount = 0;
  int _leftCount = 0;

  @override
  void initState() {
    super.initState();
    _leftTab = widget.left;
    _receivedCount = widget.user.trust.ratingCount ??
        widget.user.stats.reviewsReceivedCount ??
        0;
    _future = _load();
  }

  Future<WawatReviewResponse> _load() async {
    final loadingLeft = _leftTab;
    final response = await (loadingLeft
        ? widget.api.reviewsLeft()
        : widget.api.reviews(widget.user.id));
    if (mounted) {
      setState(() {
        if (loadingLeft) {
          _leftCount = response.total;
        } else {
          _receivedCount = response.total;
        }
      });
    }
    return response;
  }

  void _switch(bool left) {
    if (_leftTab == left) return;
    setState(() {
      _leftTab = left;
      _future = _load();
    });
  }

  Future<void> _openReplySheet(WawatReview review) async {
    final sent = await showAppBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).brightness == Brightness.dark
          ? WawatDark.scrim
          : null,
      builder: (_) => _ReplyReviewSheet(
        api: widget.api,
        review: review,
        content: widget.content,
      ),
    );
    if (sent == true && mounted) {
      setState(() => _pendingReplyIds.add(review.id));
      _showSnack(
        context,
        _tx(widget.content, 'review.reply_sent', 'Cavab göndərildi.'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _cScreen(isDark),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ProfileTopBar(
              title: _tx(widget.content, 'menu.reviews', 'Rəylərim'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? WawatDark.surfaceAlt
                      : _ink900.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    _Segment(
                      selected: !_leftTab,
                      label: _tx(
                        widget.content,
                        'menu.reviews_received',
                        'Aldığım rəylər',
                      ),
                      count: _receivedCount,
                      onTap: () => _switch(false),
                    ),
                    _Segment(
                      selected: _leftTab,
                      label: _tx(
                        widget.content,
                        'menu.reviews_left',
                        'Yazdığım rəylər',
                      ),
                      count: _leftCount,
                      onTap: () => _switch(true),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<WawatReviewResponse>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _brand),
                    );
                  }
                  if (snapshot.hasError) {
                    return _InlineLoadError(
                      content: widget.content,
                      onRetry: () => setState(() => _future = _load()),
                    );
                  }
                  return ListView(
                    children: [
                      _ReviewsSection(
                        reviews: snapshot.data ??
                            const WawatReviewResponse(
                              data: [],
                              distribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
                            ),
                        user: widget.user,
                        content: widget.content,
                        canReply: widget.canReply && !_leftTab,
                        pendingReplyIds: _pendingReplyIds,
                        onReply: _openReplySheet,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WawatProfileScreenState extends State<WawatProfileScreen> {
  final WawatProfileApi _api = WawatProfileApi();
  late Future<WawatProfileBundle> _future;
  late int _tab = widget.initialTab;
  WawatProfileUser? _userOverride;
  Map<String, String> _content = const {};
  final Set<String> _pendingReplyIds = <String>{};

  bool get _isSelf => widget.isSelf || widget.userId == null;

  /// The signed-in user's identity, read from cache. Used to recognise our own
  /// profile when it is opened through the public route (by id), so the
  /// follow/message bar stays hidden — you can't follow or message yourself.
  String? _myProfileId;
  String? _myUsername;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _loadIdentity();
  }

  Future<void> _loadIdentity() async {
    if (_isSelf) return;
    try {
      final me = await sl.get<CacheManager>().userDetails.first;
      if (!mounted || me == null) return;
      setState(() {
        _myProfileId = me.id?.toString();
        _myUsername = me.username;
      });
    } catch (_) {
      // Not signed in / no cached user — treat as a public profile.
    }
  }

  /// Whether the viewed profile belongs to the signed-in user. True for the
  /// self tab, and also when a public profile resolves to our own id/username.
  bool _isOwnProfile(WawatProfileUser user) {
    if (_isSelf) return true;
    final id = _myProfileId;
    if (id != null && id.isNotEmpty && user.id == id) return true;
    final username = _myUsername;
    return username != null && username.isNotEmpty && user.username == username;
  }

  Future<WawatProfileBundle> _load() async {
    final contentFuture = _api.content();
    final Future<PackageTypesResponse?> packageFuture = _api
        .packageTypes()
        .then<PackageTypesResponse?>((value) => value)
        .catchError((_) => null);
    final user = _isSelf ? await _api.me() : await _api.user(widget.userId!);
    final listingsFuture =
        _isSelf ? _api.myListings() : _api.userListings(user.id);
    final reviewsFuture = _api.reviews(user.id).catchError(
          (_) => const WawatReviewResponse(
            data: [],
            distribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
          ),
        );
    final results = await Future.wait<dynamic>([
      contentFuture,
      packageFuture,
      listingsFuture,
      reviewsFuture,
    ]);
    final packageResponse = results[1];
    final content = results[0] as Map<String, String>;
    _content = content;
    return WawatProfileBundle(
      user: _userOverride ?? user,
      content: content,
      packageNames: packageResponse == null
          ? const {}
          : {
              for (final item in packageResponse.data) item.code: item.name,
            },
      listings: results[2] as Pagination<Listing>,
      reviews: results[3] as WawatReviewResponse,
    );
  }

  void _reload() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _isSelf ? _cScreen(isDark) : _cCard(isDark),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<WawatProfileBundle>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _ProfileSkeleton(showBack: !_isSelf);
            }
            if (snapshot.hasError) {
              if (_isSelf && _isUnauthorized(snapshot.error)) {
                return _ProfileAuthRequired(onRetry: _reload);
              }
              return _ProfileNotFound(onRetry: _reload);
            }
            final bundle = snapshot.requireData;
            final user = _userOverride ?? bundle.user;
            return Stack(
              children: [
                Column(
                  children: [
                    _ProfileTopBar(
                      title: _isSelf ? 'Profil' : user.safeFullName,
                      showBack: !_isSelf,
                      // On our own profile (incl. via the public route) show an
                      // edit-profile action instead of the report/block menu.
                      trailingIcon: _isSelf
                          ? PhosphorIconsRegular.gearSix
                          : (_isOwnProfile(user)
                              ? PhosphorIconsRegular.pencilSimple
                              : PhosphorIconsBold.dotsThreeVertical),
                      onTrailing: _isSelf
                          ? () => _openSettings(bundle)
                          : (_isOwnProfile(user)
                              ? () => _openEditProfile(user, bundle)
                              : () => _showUserMenu(user, bundle.content)),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: _brand,
                        onRefresh: () async {
                          _reload();
                          await _future;
                        },
                        child: ListView(
                          padding: EdgeInsets.only(
                            bottom: _isSelf
                                ? 110 + MediaQuery.of(context).padding.bottom
                                : 96 + MediaQuery.of(context).padding.bottom,
                          ),
                          children: [
                            _ProfileHeader(user: user, content: bundle.content),
                            if (_isSelf && !user.isVerified)
                              _VerificationBanner(
                                content: bundle.content,
                                onTap: _openVerification,
                              ),
                            _StatsRow(user: user, content: bundle.content),
                            _FollowCounters(
                              user: user,
                              content: bundle.content,
                              onFollowers: () => _openFollowList(
                                user,
                                bundle.content,
                                following: false,
                              ),
                              onFollowing: () => _openFollowList(
                                user,
                                bundle.content,
                                following: true,
                              ),
                            ),
                            if (_isSelf)
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                child: _SoftButton(
                                  label: _tx(
                                    bundle.content,
                                    'profile.edit',
                                    'Profili redaktə et',
                                  ),
                                  icon: PhosphorIconsRegular.pencilSimple,
                                  onTap: () => _openEditProfile(user, bundle),
                                ),
                              ),
                            _ProfileTabs(
                              selected: _tab,
                              isSelf: _isSelf,
                              content: bundle.content,
                              listingsCount: bundle.listings.total ??
                                  bundle.listings.data.length,
                              reviewsCount: user.trust.ratingCount ??
                                  user.stats.reviewsReceivedCount ??
                                  bundle.reviews.total,
                              onChanged: (value) =>
                                  setState(() => _tab = value),
                            ),
                            if (_tab == 0)
                              _ListingsSection(
                                listings: bundle.listings.data,
                                packageNames: bundle.packageNames,
                                isSelf: _isSelf,
                                content: bundle.content,
                              )
                            else
                              _ReviewsSection(
                                reviews: bundle.reviews,
                                user: user,
                                content: bundle.content,
                                canReply: _isSelf,
                                pendingReplyIds: _pendingReplyIds,
                                onReply: (review) =>
                                    _openReplySheet(review, bundle.content),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (!_isOwnProfile(user))
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _PublicActionBar(
                      user: user,
                      content: bundle.content,
                      onFollow: () => _toggleFollow(user, bundle.content),
                      onMessage: () => _requireAuthThen(() async {
                        _toast('Mesaj növbəti mərhələdə qoşulacaq.');
                      }),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _toggleFollow(
    WawatProfileUser user,
    Map<String, String> content,
  ) async {
    await _requireAuthThen(() async {
      final next = !user.isFollowing;
      setState(() {
        _userOverride = user.copyWith(
          isFollowing: next,
          followersCount:
              (user.followersCount + (next ? 1 : -1)).clamp(0, 1 << 31),
        );
      });
      try {
        final message =
            next ? await _api.follow(user.id) : await _api.unfollow(user.id);
        _toast(message);
      } catch (_) {
        setState(() => _userOverride = user);
        _toast('Əməliyyat alınmadı.', error: true);
      }
    });
  }

  Future<void> _requireAuthThen(Future<void> Function() action) async {
    final isLogged = await sl.get<AuthRepository>().isLogged();
    if (!mounted) return;
    if (!isLogged) {
      AuthModalUtils.showAuthRequiredModal(context);
      return;
    }
    await action();
  }

  Future<void> _openVerification() async {
    try {
      final user = await sl
          .get<AuthRepository>()
          .userDetails
          .first
          .timeout(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VerificationScreen(user: user)),
      );
    } catch (_) {
      if (!mounted) return;
      _toast(
        _tx(
          _content,
          'profile.verification_unavailable',
          'Təsdiqləmə məlumatı yüklənmədi.',
        ),
        error: true,
      );
    }
  }

  Future<void> _openFollowList(
    WawatProfileUser user,
    Map<String, String> content, {
    required bool following,
  }) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FollowListScreen(
          api: _api,
          user: user,
          content: content,
          following: following,
        ),
      ),
    );
  }

  Future<void> _openSettings(WawatProfileBundle bundle) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SettingsHubScreen(
          api: _api,
          user: bundle.user,
          content: bundle.content,
          onVerification: _openVerification,
          onProfileUpdated: () {
            _userOverride = null;
            _reload();
          },
        ),
      ),
    );
    _reload();
  }

  Future<void> _openEditProfile(
    WawatProfileUser user,
    WawatProfileBundle bundle,
  ) async {
    final updated = await Navigator.of(context).push<WawatProfileUser>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _EditProfileScreen(
          api: _api,
          user: user,
          content: bundle.content,
        ),
      ),
    );
    if (updated != null) {
      setState(() => _userOverride = updated);
      _toast(_tx(bundle.content, 'profile.updated', 'Profil yeniləndi.'));
      _reload();
    }
  }

  Future<void> _openReplySheet(
    WawatReview review,
    Map<String, String> content,
  ) async {
    final sent = await showAppBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).brightness == Brightness.dark
          ? WawatDark.scrim
          : null,
      builder: (_) =>
          _ReplyReviewSheet(api: _api, review: review, content: content),
    );
    if (sent == true) {
      setState(() => _pendingReplyIds.add(review.id));
      _toast(_tx(
        content,
        'review.reply_submitted',
        'Cavabınız moderasiyaya göndərildi.',
      ));
      _reload();
    }
  }

  Future<void> _showUserMenu(
    WawatProfileUser user,
    Map<String, String> content,
  ) async {
    await showAppBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).brightness == Brightness.dark
          ? WawatDark.scrim
          : null,
      builder: (_) => _UserActionSheet(
        onBlock: () async {
          Navigator.pop(context);
          await _requireAuthThen(() async {
            try {
              _toast(await _api.block(user.id));
            } catch (_) {
              _toast('Əməliyyat alınmadı.', error: true);
            }
          });
        },
        onReport: () {
          Navigator.pop(context);
          _showReportSheet(user, content);
        },
      ),
    );
  }

  Future<void> _showReportSheet(
    WawatProfileUser user,
    Map<String, String> content,
  ) async {
    final sent = await showAppBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).brightness == Brightness.dark
          ? WawatDark.scrim
          : null,
      builder: (_) => _ReportUserSheet(api: _api, user: user, content: content),
    );
    if (sent == true) _toast('Şikayət göndərildi.');
  }

  void _toast(String message, {bool error = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error
            ? (isDark ? WawatDark.danger : const Color(0xFFEF4444))
            : (isDark ? WawatDark.elevated : _ink900),
        duration: const Duration(milliseconds: 1500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  final String title;
  final bool showBack;
  final IconData? trailingIcon;
  final VoidCallback? onTrailing;

  const _ProfileTopBar({
    required this.title,
    this.showBack = true,
    this.trailingIcon,
    this.onTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _cCard(isDark),
        border: Border(
          bottom: BorderSide(color: _cLine(isDark)),
        ),
      ),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => Navigator.of(context).maybePop(),
              child: Icon(PhosphorIconsBold.arrowLeft,
                  color: isDark ? WawatDark.icon : _ink700),
            )
          else
            const SizedBox(width: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _cText(isDark),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailingIcon != null)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onTrailing,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(trailingIcon,
                    color: isDark ? WawatDark.icon : _ink700, size: 22),
              ),
            )
          else
            const SizedBox(width: 36),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final WawatProfileUser user;
  final Map<String, String> content;

  const _ProfileHeader({required this.user, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProfileAvatar(user: user, size: 68, tappable: true),
              const SizedBox(width: 14),
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
                              color: _cText(isDark),
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (user.isVerified) ...[
                          const SizedBox(width: 6),
                          Icon(
                            PhosphorIconsFill.sealCheck,
                            color: isDark ? WawatDark.brandText : _brand,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    if (user.username != null)
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          color: _cMuted(isDark),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (user.tier != null && user.tier != 'standard')
                          _TierBadge(tier: user.tier!, content: content),
                        if (user.memberSince != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${user.memberSince!.year}-dən üzv',
                            style: TextStyle(
                              color: _cMuted(isDark),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((user.bio ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 13),
            Text(
              user.bio!.trim(),
              style: TextStyle(
                color: isDark ? WawatDark.textSecondary : _ink600,
                fontSize: 13.5,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (user.languages.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final language in user.languages)
                  _Chip(
                      label: language.name,
                      icon: PhosphorIconsRegular.translate),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  final Map<String, String> content;
  final VoidCallback onTap;

  const _VerificationBanner({
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? WawatDark.warning.withValues(alpha: 0.12) : _amber50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: (isDark ? WawatDark.warning : _amber)
                  .withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(PhosphorIconsFill.sealCheck,
                color: isDark ? WawatDark.warning : _amber),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _tx(content, 'profile.verify_account',
                    'Hesabınızı təsdiqləyin'),
                style: TextStyle(
                  color: _cText(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(PhosphorIconsRegular.caretRight, color: _cMuted(isDark)),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final WawatProfileUser user;
  final Map<String, String> content;

  const _StatsRow({required this.user, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(
              value: user.trust.ratingAvg == null
                  ? '—'
                  : user.trust.ratingAvg!.toStringAsFixed(1),
              label: _tx(content, 'profile.rating', 'Reytinq'),
              icon: PhosphorIconsFill.star,
              iconColor: isDark ? WawatDark.star : _amber,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatTile(
              value:
                  '${user.stats.deliveriesCount ?? user.trust.completedShipmentsCount ?? 0}',
              label: _tx(content, 'profile.deliveries', 'Çatdırılma'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatTile(
              value: user.trust.avgResponseMinutes == null
                  ? '—'
                  : '~${user.trust.avgResponseMinutes}dq',
              label: _tx(content, 'profile.response', 'Cavab'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? iconColor;

  const _StatTile({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: _cCard(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark ? WawatDark.border : _ink900.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: _cText(isDark),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 3),
                Icon(icon, color: iconColor, size: 13),
              ],
            ],
          ),
          const SizedBox(height: 5),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: _cMuted(isDark),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowCounters extends StatelessWidget {
  final WawatProfileUser user;
  final Map<String, String> content;
  final VoidCallback onFollowers;
  final VoidCallback onFollowing;

  const _FollowCounters({
    required this.user,
    required this.content,
    required this.onFollowers,
    required this.onFollowing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: _cCard(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark ? WawatDark.border : _ink900.withValues(alpha: 0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: _FollowCounterButton(
              value: _compact(user.followersCount),
              label: _tx(content, 'profile.followers', 'İzləyici'),
              onTap: onFollowers,
            ),
          ),
          Container(width: 1, height: 44, color: _cLine(isDark)),
          Expanded(
            child: _FollowCounterButton(
              value: _compact(user.followingCount),
              label: _tx(content, 'profile.following', 'İzləyir'),
              onTap: onFollowing,
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowCounterButton extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback onTap;

  const _FollowCounterButton({
    required this.value,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                color: _cText(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: _cMuted(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  final int selected;
  final bool isSelf;
  final Map<String, String> content;
  final int listingsCount;
  final int reviewsCount;
  final ValueChanged<int> onChanged;

  const _ProfileTabs({
    required this.selected,
    required this.isSelf,
    required this.content,
    required this.listingsCount,
    required this.reviewsCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surfaceAlt : _ink900.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _Segment(
            selected: selected == 0,
            label: isSelf
                ? _tx(content, 'profile.my_listings', 'Elanlarım')
                : _tx(content, 'profile.listings', 'Elanlar'),
            count: listingsCount,
            onTap: () => onChanged(0),
          ),
          _Segment(
            selected: selected == 1,
            label: _tx(content, 'review.tab', 'Rəylər'),
            count: reviewsCount,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final bool selected;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _Segment({
    required this.selected,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? WawatDark.elevated : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected && !isDark
                ? [
                    BoxShadow(
                      color: _ink900.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? (isDark ? WawatDark.brandText : _brand)
                      : _cText2(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: selected
                        ? (isDark
                            ? WawatDark.brandBadge
                            : _brand.withValues(alpha: 0.12))
                        : (isDark
                            ? WawatDark.border
                            : _ink900.withValues(alpha: 0.06)),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: selected
                          ? (isDark ? WawatDark.brandText : _brand)
                          : _cText2(isDark),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ListingsSection extends StatelessWidget {
  final List<Listing> listings;
  final Map<String, String> packageNames;
  final bool isSelf;
  final Map<String, String> content;

  const _ListingsSection({
    required this.listings,
    required this.packageNames,
    required this.isSelf,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return _EmptyState(
        icon: PhosphorIconsRegular.airplaneTilt,
        title: _tx(content, 'profile.empty_listings_title', 'Hələ elan yoxdur'),
        subtitle: _tx(
          content,
          'profile.empty_listings_subtitle',
          'Yeni elan yaratdıqdan sonra burada görünəcək.',
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: [
          for (final listing in listings)
            _ProfileListingRow(
              listing: listing,
              packageNames: packageNames,
              isSelf: isSelf,
            ),
        ],
      ),
    );
  }
}

class _ProfileListingRow extends StatelessWidget {
  final Listing listing;
  final Map<String, String> packageNames;
  final bool isSelf;

  const _ProfileListingRow({
    required this.listing,
    required this.packageNames,
    required this.isSelf,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark
        ? (listing.isTrip ? WawatDark.brandText : WawatDark.warning)
        : (listing.isTrip ? _brand : _amber);
    final accent50 = isDark
        ? accent.withValues(alpha: 0.15)
        : (listing.isTrip ? _brand50 : _amber50);
    final subtitle = listing.isTrip
        ? [
            _formatDate(listing.flightDate),
            if (listing.freeWeightKg != null)
              '${_num(listing.freeWeightKg)} kq boş',
            if (listing.allowPriceNegotiation == true)
              'Razılaşma'
            else if (listing.pricePerKg != null)
              '${_num(listing.pricePerKg)} \$/kq',
          ].where((e) => e.isNotEmpty).join(' · ')
        : [
            _dateRange(listing.deliveryDateFrom, listing.deliveryDateTo),
            if (listing.weightKg != null) '${_num(listing.weightKg)} kq',
          ].where((e) => e.isNotEmpty).join(' · ');
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => ListingDetailsScreen(listingId: listing.id)),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cCard(isDark),
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(color: WawatDark.border)
              : Border.all(color: _ink900.withValues(alpha: 0.06)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: _ink900.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                listing.isTrip
                    ? PhosphorIconsFill.airplaneTilt
                    : PhosphorIconsFill.package,
                color: accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${listing.cityFrom ?? '-'} → ${listing.cityTo ?? '-'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _cText(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isSelf && listing.statusLabel != null) ...[
                        const SizedBox(width: 8),
                        _TinyStatus(label: listing.statusLabel!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle.isEmpty ? '—' : subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _cText2(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(PhosphorIconsRegular.caretRight, color: _cFaint(isDark)),
          ],
        ),
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  final WawatReviewResponse reviews;
  final WawatProfileUser user;
  final Map<String, String> content;
  final bool canReply;
  final Set<String> pendingReplyIds;
  final ValueChanged<WawatReview> onReply;

  const _ReviewsSection({
    required this.reviews,
    required this.user,
    required this.content,
    required this.canReply,
    required this.pendingReplyIds,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.data.isEmpty) {
      return _EmptyState(
        icon: PhosphorIconsRegular.star,
        title: _tx(content, 'review.empty_title', 'Hələ rəy yoxdur'),
        subtitle: _tx(
          content,
          'review.empty_subtitle',
          'Tamamlanmış sifarişlərdən sonra rəylər burada görünəcək.',
        ),
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewSummary(user: user, reviews: reviews, content: content),
          const SizedBox(height: 12),
          Text(
            _tx(content, 'review.moderation_note',
                'Rəylər dərc olunmadan öncə yoxlanılır.'),
            style: TextStyle(
              color: _cMuted(isDark),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          for (final review in reviews.data)
            _ReviewCard(
              review: review,
              content: content,
              canReply: canReply,
              isReplyPending: pendingReplyIds.contains(review.id),
              onReply: () => onReply(review),
            ),
        ],
      ),
    );
  }
}

class _ReviewSummary extends StatelessWidget {
  final WawatProfileUser user;
  final WawatReviewResponse reviews;
  final Map<String, String> content;

  const _ReviewSummary({
    required this.user,
    required this.reviews,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final total = user.trust.ratingCount ?? reviews.total;
    final avg = user.trust.ratingAvg;
    final maxCount =
        reviews.distribution.values.fold<int>(0, (a, b) => a > b ? a : b);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDark),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                avg == null ? '—' : avg.toStringAsFixed(1),
                style: TextStyle(
                  color: _cText(isDark),
                  fontSize: 38,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: List.generate(
                  5,
                  (_) => const Icon(
                    PhosphorIconsFill.star,
                    color: Color(0xFFF5B301),
                    size: 13,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _tx(content, 'review.count', '{count} rəy')
                    .replaceAll('{count}', '$total'),
                style: TextStyle(
                  color: _cMuted(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              children: [
                for (final star in [5, 4, 3, 2, 1])
                  _DistributionRow(
                    star: star,
                    count: reviews.distribution[star] ?? 0,
                    max: maxCount,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  final int star;
  final int count;
  final int max;

  const _DistributionRow({
    required this.star,
    required this.count,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final value = max == 0 ? 0.0 : count / max;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              '$star',
              style: TextStyle(
                color: _cText2(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: value,
                color: isDark ? WawatDark.star : const Color(0xFFF5B301),
                backgroundColor: isDark
                    ? WawatDark.surfaceAlt
                    : _ink900.withValues(alpha: 0.06),
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _cMuted(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final WawatReview review;
  final Map<String, String> content;
  final bool canReply;
  final bool isReplyPending;
  final VoidCallback onReply;

  const _ReviewCard({
    required this.review,
    required this.content,
    required this.canReply,
    required this.isReplyPending,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final author = review.author;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ReviewAvatar(author: author),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            author?.displayName ?? '@user',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _cText(isDark),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (author?.isVerified == true) ...[
                          const SizedBox(width: 4),
                          Icon(
                            PhosphorIconsFill.sealCheck,
                            color: isDark ? WawatDark.brandText : _brand,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < review.rating
                              ? PhosphorIconsFill.star
                              : PhosphorIconsRegular.star,
                          color: index < review.rating
                              ? (isDark
                                  ? WawatDark.star
                                  : const Color(0xFFF5B301))
                              : _cFaint(isDark),
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _relativeDate(review.createdAt),
                style: TextStyle(
                  color: _cMuted(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if ((review.comment ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment!.trim(),
              style: TextStyle(
                color: isDark ? WawatDark.textSecondary : _ink600,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 9),
          _VerifiedReviewBadge(content: content),
          if ((review.reply ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? WawatDark.surfaceAlt
                    : _ink900.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsFill.arrowBendUpRight,
                        color: _cText2(isDark),
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _tx(content, 'review.your_reply', 'Sizin cavabınız'),
                        style: TextStyle(
                          color: _cText2(isDark),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.reply!.trim(),
                    style: TextStyle(
                      color: isDark ? WawatDark.textSecondary : _ink600,
                      fontSize: 12.5,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isReplyPending) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: isDark
                    ? WawatDark.warning.withValues(alpha: 0.12)
                    : _amber50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsFill.hourglass,
                    color: isDark ? WawatDark.warning : _amber,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _tx(content, 'review.reply_pending',
                        'Cavabınız yoxlanılır'),
                    style: TextStyle(
                      color: isDark ? WawatDark.warning : _amber,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (canReply) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onReply,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsRegular.arrowBendUpLeft,
                    color: isDark ? WawatDark.brandText : _brand,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _tx(content, 'review.reply_button', 'Cavab yaz'),
                    style: TextStyle(
                      color: isDark ? WawatDark.brandText : _brand,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VerifiedReviewBadge extends StatelessWidget {
  final Map<String, String> content;

  const _VerifiedReviewBadge({required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? WawatDark.success.withValues(alpha: 0.14)
            : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconsFill.checkCircle,
            color: isDark ? WawatDark.success : const Color(0xFF059669),
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            _tx(content, 'review.verified_shipment', 'Təsdiqlənmiş sifariş'),
            style: TextStyle(
              color: isDark ? WawatDark.success : const Color(0xFF059669),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicActionBar extends StatelessWidget {
  final WawatProfileUser user;
  final Map<String, String> content;
  final VoidCallback onFollow;
  final VoidCallback onMessage;

  const _PublicActionBar({
    required this.user,
    required this.content,
    required this.onFollow,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: _cCard(isDark),
        border: Border(
            top: BorderSide(
                color: isDark
                    ? WawatDark.divider
                    : _ink900.withValues(alpha: 0.05))),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: _ink900.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 16,
            child: user.isFollowing
                ? _GhostButton(
                    label: 'İzlənilir',
                    icon: PhosphorIconsFill.check,
                    onTap: onFollow,
                  )
                : _PrimaryButton(
                    label: 'İzlə',
                    icon: PhosphorIconsBold.plus,
                    onTap: onFollow,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 10,
            child: _SoftButton(
              label: 'Mesaj',
              icon: PhosphorIconsFill.chatCircle,
              onTap: onMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowListScreen extends StatefulWidget {
  final WawatProfileApi api;
  final WawatProfileUser user;
  final Map<String, String> content;
  final bool following;

  const _FollowListScreen({
    required this.api,
    required this.user,
    required this.content,
    required this.following,
  });

  @override
  State<_FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<_FollowListScreen> {
  late bool _followingTab = widget.following;
  late Future<List<WawatProfileUser>> _future = _load();

  Future<List<WawatProfileUser>> _load() {
    return widget.api.followers(widget.user.id, following: _followingTab);
  }

  void _switch(bool following) {
    setState(() {
      _followingTab = following;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _cCard(isDark),
      body: SafeArea(
        child: Column(
          children: [
            _ProfileTopBar(
              title: _tx(
                widget.content,
                'menu.connections',
                'İzləyicilər və izlədiklərim',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? WawatDark.surfaceAlt
                      : _ink900.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    _Segment(
                      selected: !_followingTab,
                      label: _tx(
                        widget.content,
                        'menu.followers',
                        'İzləyicilər',
                      ),
                      count: widget.user.followersCount,
                      onTap: () => _switch(false),
                    ),
                    _Segment(
                      selected: _followingTab,
                      label: _tx(
                        widget.content,
                        'menu.following',
                        'İzlədiklərim',
                      ),
                      count: widget.user.followingCount,
                      onTap: () => _switch(true),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<WawatProfileUser>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _brand),
                    );
                  }
                  if (snapshot.hasError) {
                    return _InlineLoadError(
                      content: widget.content,
                      onRetry: () => setState(() => _future = _load()),
                    );
                  }
                  final items = snapshot.data ?? const [];
                  if (items.isEmpty) {
                    return _EmptyState(
                      icon: PhosphorIconsRegular.user,
                      title: _tx(
                        widget.content,
                        'profile.list_empty',
                        'Siyahı boşdur',
                      ),
                      subtitle: _tx(
                        widget.content,
                        'profile.users_will_appear',
                        'Burada istifadəçilər görünəcək.',
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: isDark
                            ? WawatDark.divider
                            : _ink900.withValues(alpha: 0.05)),
                    itemBuilder: (context, index) {
                      return _UserRow(
                        user: items[index],
                        onOpen: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PublicProfileScreen(userId: items[index].id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final WawatProfileUser user;
  final VoidCallback onOpen;

  const _UserRow({required this.user, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _ProfileAvatar(user: user, size: 44),
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
                            color: _cText(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 5),
                        Icon(
                          PhosphorIconsFill.sealCheck,
                          color: isDark ? WawatDark.brandText : _brand,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    [
                      if (user.username != null) '@${user.username}',
                      if (user.trust.ratingAvg != null)
                        '★ ${user.trust.ratingAvg!.toStringAsFixed(1)}',
                    ].join(' · '),
                    style: TextStyle(
                      color: _cMuted(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIconsRegular.caretRight, color: _cFaint(isDark)),
          ],
        ),
      ),
    );
  }
}

class _SettingsHubScreen extends StatelessWidget {
  final WawatProfileApi api;
  final WawatProfileUser user;
  final Map<String, String> content;
  final VoidCallback onVerification;
  final VoidCallback onProfileUpdated;

  const _SettingsHubScreen({
    required this.api,
    required this.user,
    required this.content,
    required this.onVerification,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _cScreen(isDark),
      body: SafeArea(
        child: ListView(
          children: [
            const _ProfileTopBar(title: 'Ayarlar'),
            _GroupHead(_tx(content, 'profile.settings.account', 'Hesab')),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: PhosphorIconsRegular.user,
                  label: _tx(content, 'profile.edit', 'Profili redaktə et'),
                  onTap: () async {
                    final updated =
                        await Navigator.of(context).push<WawatProfileUser>(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => _EditProfileScreen(
                          api: api,
                          user: user,
                          content: content,
                        ),
                      ),
                    );
                    if (updated != null) onProfileUpdated();
                  },
                ),
                _SettingsRow(
                  icon: PhosphorIconsRegular.sealCheck,
                  label:
                      _tx(content, 'profile.verify_account', 'Hesabı təsdiqlə'),
                  trailing: user.isVerified
                      ? _TinyStatus(
                          label:
                              _tx(content, 'profile.verified', 'Təsdiqlənib'),
                        )
                      : _TinyStatus(
                          label: _tx(
                            content,
                            'profile.not_verified',
                            'Təsdiqlənməyib',
                          ),
                          amber: true,
                        ),
                  onTap: onVerification,
                ),
                _SettingsRow(
                  icon: PhosphorIconsRegular.lockKey,
                  label:
                      _tx(content, 'profile.change_password', 'Parolu dəyiş'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _ChangePasswordScreen(
                        api: api,
                        content: content,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _GroupHead(
                _tx(content, 'profile.settings.preferences', 'Tərcihlər')),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: PhosphorIconsRegular.bell,
                  label: _tx(
                    content,
                    'profile.notification_settings',
                    'Bildiriş ayarları',
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  ),
                ),
                _SettingsRow(
                  icon: PhosphorIconsRegular.lockSimple,
                  label: _tx(content, 'profile.privacy', 'Məxfilik'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _PrivacySettingsScreen(
                        api: api,
                        initial: user.settings.privacy,
                        content: content,
                      ),
                    ),
                  ),
                ),
                _SettingsRow(
                  icon: PhosphorIconsRegular.translate,
                  label: _tx(content, 'profile.language', 'Dil'),
                  trailingText: user.preferredLocale ?? 'az',
                  onTap: () {},
                ),
              ],
            ),
            _GroupHead(_tx(content, 'profile.settings.support', 'Dəstək')),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: PhosphorIconsRegular.question,
                  label: _tx(content, 'profile.help_faq', 'Kömək & FAQ'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => FaqScreen()),
                  ),
                ),
                _SettingsRow(
                  icon: PhosphorIconsRegular.fileText,
                  label: _tx(
                    content,
                    'profile.terms_privacy',
                    'Qaydalar & məxfilik siyasəti',
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PrivacyPolicyScreen()),
                  ),
                ),
                _SettingsRow(
                  icon: PhosphorIconsRegular.chatCircle,
                  label: _tx(content, 'profile.support', 'Dəstək'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => SupportScreen()),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
              child: _GhostButton(
                label: _tx(content, 'profile.logout', 'Çıxış'),
                icon: PhosphorIconsRegular.signOut,
                onTap: () async {
                  await api.logout();
                  await sl.get<AuthRepository>().logout();
                  await NotificationSocketService.instance.onLogout();
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
            GestureDetector(
              onTap: () => showAppBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                barrierColor: isDark ? WawatDark.scrim : null,
                builder: (_) => _DeleteAccountSheet(api: api, content: content),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  _tx(content, 'profile.delete_account', 'Hesabı sil'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        isDark ? WawatDark.dangerText : const Color(0xFFEF4444),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'Wawatair · v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _cMuted(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileScreen extends StatefulWidget {
  final WawatProfileApi api;
  final WawatProfileUser user;
  final Map<String, String> content;

  const _EditProfileScreen({
    required this.api,
    required this.user,
    required this.content,
  });

  @override
  State<_EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<_EditProfileScreen> {
  late final TextEditingController _firstName =
      TextEditingController(text: widget.user.firstName ?? '');
  late final TextEditingController _lastName =
      TextEditingController(text: widget.user.lastName ?? '');
  late final TextEditingController _bio =
      TextEditingController(text: widget.user.bio ?? '');
  late final String _locale = widget.user.preferredLocale ?? 'az';
  late final Set<String> _languages =
      widget.user.languages.map((language) => language.code).toSet();
  late Future<LanguageResponse> _languageFuture = widget.api.languages();
  late WawatProfileUser _user = widget.user;
  bool _busy = false;
  bool _dirty = false;

  /// Bumped on every avatar change to force the preview to rebuild — a same-URL
  /// overwrite would otherwise keep the old image even after cache eviction.
  int _avatarVersion = 0;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final user = await widget.api.updateProfile({
        'first_name': _firstName.text.trim(),
        'last_name': _lastName.text.trim(),
        'bio': _bio.text.trim(),
        'preferred_locale': _locale,
        'languages': _languages.toList(),
      });
      if (!mounted) return;
      Navigator.of(context).pop(user);
    } catch (_) {
      if (mounted) {
        _showSnack(
          context,
          _tx(widget.content, 'profile.update_failed', 'Profil yenilənmədi.'),
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 88);
    if (file == null) return;
    try {
      await widget.api.uploadAvatar(File(file.path));
      await _syncAfterAvatarChange();
      if (mounted) {
        _showSnack(
          context,
          _tx(widget.content, 'profile.avatar_updated', 'Avatar yeniləndi.'),
        );
      }
    } catch (_) {
      if (mounted) {
        _showSnack(
          context,
          _tx(widget.content, 'profile.avatar_update_failed',
              'Avatar yenilənmədi.'),
          error: true,
        );
      }
    }
  }

  /// After changing the avatar: drop stale cached image bytes (the server may
  /// reuse the same URL), pull the fresh profile so this screen updates, and
  /// refresh the cached [User] so every `userDetails` listener (menu tab, etc.)
  /// shows the new photo immediately.
  Future<void> _syncAfterAvatarChange() async {
    await _evictAvatar(_user);
    WawatProfileUser fresh;
    try {
      fresh = await widget.api.me();
    } catch (_) {
      fresh = _user;
    }
    await _evictAvatar(fresh);
    if (mounted) {
      setState(() {
        _user = fresh;
        _dirty = true;
        _avatarVersion++;
      });
    }
    try {
      await sl.get<AuthRepository>().customersMe();
    } catch (_) {
      // Cache refresh is best-effort; the upload already succeeded.
    }
  }

  Future<void> _evictAvatar(WawatProfileUser user) async {
    for (final url in [user.avatarUrl, user.avatarThumbUrl]) {
      if (url != null && url.isNotEmpty) {
        await CachedNetworkImage.evictFromCache(url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _cCard(isDark),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ProfileTopBar(
              title: _tx(widget.content, 'profile.edit', 'Profili redaktə et'),
              trailingIcon: PhosphorIconsBold.x,
              // Return the refreshed user when the avatar changed so the parent
              // profile reloads even if nothing else was saved.
              onTrailing: () =>
                  Navigator.of(context).maybePop(_dirty ? _user : null),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: 96 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            _ProfileAvatar(
                              key: ValueKey(_avatarVersion),
                              user: _user,
                              size: 88,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: _showAvatarSheet,
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: _brand,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: _cCard(isDark), width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _brand.withValues(alpha: 0.35),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    PhosphorIconsFill.camera,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _showAvatarSheet,
                          child: Text(
                            _tx(widget.content, 'profile.change_photo',
                                'Şəkli dəyiş'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      // Left-align so the languages section lines up with the
                      // fields instead of being centred (it is content-width).
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _Field(
                                label: _tx(
                                    widget.content, 'profile.first_name', 'Ad'),
                                controller: _firstName,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _Field(
                                label: _tx(widget.content, 'profile.last_name',
                                    'Soyad'),
                                controller: _lastName,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _Field(
                          label: _tx(widget.content, 'profile.bio', 'Bio'),
                          controller: _bio,
                          maxLines: 4,
                          maxLength: 200,
                        ),
                        const SizedBox(height: 14),
                        FutureBuilder<LanguageResponse>(
                          future: _languageFuture,
                          builder: (context, snapshot) {
                            final languages = snapshot.data?.data ?? const [];
                            return _LanguageSelector(
                              languages: languages,
                              selected: _languages,
                              onToggle: (code) {
                                setState(() {
                                  if (_languages.contains(code)) {
                                    _languages.remove(code);
                                  } else {
                                    _languages.add(code);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _BottomCta(
              child: _PrimaryButton(
                label: _tx(widget.content, 'common.save', 'Yadda saxla'),
                icon: PhosphorIconsFill.check,
                onTap: _save,
                loading: _busy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarSheet() {
    showAppBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).brightness == Brightness.dark
          ? WawatDark.scrim
          : null,
      builder: (_) => _AvatarSheet(
        onCamera: () {
          Navigator.pop(context);
          _pickAvatar(ImageSource.camera);
        },
        onGallery: () {
          Navigator.pop(context);
          _pickAvatar(ImageSource.gallery);
        },
        onDelete: () async {
          Navigator.pop(context);
          try {
            await widget.api.deleteAvatar();
            await _syncAfterAvatarChange();
            if (mounted) {
              _showSnack(
                context,
                _tx(widget.content, 'profile.avatar_deleted',
                    'Avatar silindi.'),
              );
            }
          } catch (_) {
            if (mounted) {
              _showSnack(
                context,
                _tx(widget.content, 'profile.avatar_delete_failed',
                    'Avatar silinmədi.'),
                error: true,
              );
            }
          }
        },
        content: widget.content,
      ),
    );
  }
}

class _PrivacySettingsScreen extends StatefulWidget {
  final WawatProfileApi api;
  final WawatPrivacySettings initial;
  final Map<String, String> content;

  const _PrivacySettingsScreen({
    required this.api,
    required this.initial,
    required this.content,
  });

  @override
  State<_PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<_PrivacySettingsScreen> {
  late WawatPrivacySettings _settings = widget.initial;

  Future<void> _update(WawatPrivacySettings next) async {
    final previous = _settings;
    setState(() => _settings = next);
    try {
      final message = await widget.api.updatePrivacy(next);
      if (mounted) _showSnack(context, message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _settings = previous);
      _showSnack(context, 'Məxfilik yenilənmədi.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _cScreen(isDark),
      body: SafeArea(
        child: ListView(
          children: [
            _ProfileTopBar(
              title: _tx(widget.content, 'profile.privacy', 'Məxfilik'),
            ),
            _GroupHead(
              _tx(widget.content, 'profile.privacy_show', 'Profildə göstər'),
            ),
            _SettingsGroup(
              children: [
                _SwitchRow(
                  icon: PhosphorIconsRegular.phone,
                  label: _tx(widget.content, 'profile.privacy_phone',
                      'Telefon nömrəsi'),
                  subtitle: _tx(
                    widget.content,
                    'profile.privacy_visible_to_others',
                    'Başqaları görə bilsin',
                  ),
                  value: _settings.showPhone,
                  onChanged: (value) =>
                      _update(_settings.copyWith(showPhone: value)),
                ),
                _SwitchRow(
                  icon: PhosphorIconsRegular.envelopeSimple,
                  label: _tx(widget.content, 'profile.privacy_email', 'E-poçt'),
                  subtitle: _tx(
                    widget.content,
                    'profile.privacy_visible_to_others',
                    'Başqaları görə bilsin',
                  ),
                  value: _settings.showEmail,
                  onChanged: (value) =>
                      _update(_settings.copyWith(showEmail: value)),
                ),
                _SwitchRow(
                  icon: PhosphorIconsRegular.clock,
                  label: _tx(widget.content, 'profile.privacy_activity',
                      'Aktivlik vaxtı'),
                  subtitle: _tx(
                    widget.content,
                    'profile.privacy_activity_hint',
                    'Son giriş görünsün',
                  ),
                  value: _settings.showActivityTime,
                  onChanged: (value) =>
                      _update(_settings.copyWith(showActivityTime: value)),
                ),
                _SwitchRow(
                  icon: PhosphorIconsRegular.translate,
                  label: _tx(widget.content, 'profile.privacy_languages',
                      'Bildiyim dillər'),
                  subtitle: _tx(
                    widget.content,
                    'profile.privacy_profile_visible',
                    'Profildə görünsün',
                  ),
                  value: _settings.showLanguages,
                  onChanged: (value) =>
                      _update(_settings.copyWith(showLanguages: value)),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _cCard(isDark),
                borderRadius: BorderRadius.circular(20),
                border: isDark
                    ? Border.all(color: WawatDark.border)
                    : Border.all(color: _ink900.withValues(alpha: 0.06)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(PhosphorIconsFill.info,
                      color: _cMuted(isDark), size: 17),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _tx(
                        widget.content,
                        'profile.privacy_note',
                        'Əlaqə həmişə söhbət (chat) vasitəsilə mümkündür — nömrənizi gizli saxlasanız belə.',
                      ),
                      style: TextStyle(
                        color: _cText2(isDark),
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordScreen extends StatefulWidget {
  final WawatProfileApi api;
  final Map<String, String> content;

  const _ChangePasswordScreen({required this.api, required this.content});

  @override
  State<_ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<_ChangePasswordScreen> {
  final _current = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _showCurrent = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_password.text.length < 8) {
      _showSnack(
        context,
        _tx(widget.content, 'profile.password_min',
            'Ən az 8 simvol olmalıdır.'),
        error: true,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final message = await widget.api.changePassword(
        currentPassword: _current.text,
        password: _password.text,
      );
      if (!mounted) return;
      _showSnack(context, message);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) _showSnack(context, _errorMessage(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: _cCard(isDark),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ProfileTopBar(
              title: _tx(
                  widget.content, 'profile.change_password', 'Parolu dəyiş'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _PasswordField(
                    label: _tx(widget.content, 'profile.current_password',
                        'Cari parol'),
                    controller: _current,
                    visible: _showCurrent,
                    onToggle: () =>
                        setState(() => _showCurrent = !_showCurrent),
                    icon: PhosphorIconsRegular.lockKey,
                  ),
                  const SizedBox(height: 16),
                  _PasswordField(
                    label: _tx(
                        widget.content, 'profile.new_password', 'Yeni parol'),
                    controller: _password,
                    visible: _showPassword,
                    onToggle: () =>
                        setState(() => _showPassword = !_showPassword),
                    icon: PhosphorIconsRegular.lockSimple,
                  ),
                  const SizedBox(height: 8),
                  _PasswordStrength(length: _password.text.length),
                  const SizedBox(height: 6),
                  Text(
                    _tx(
                      widget.content,
                      'profile.password_hint',
                      'Ən az 8 simvol, cari paroldan fərqli',
                    ),
                    style: TextStyle(
                      color: _cMuted(isDark),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            _BottomCta(
              child: _PrimaryButton(
                label: _tx(
                  widget.content,
                  'profile.password_update',
                  'Parolu yenilə',
                ),
                icon: PhosphorIconsFill.check,
                onTap: _submit,
                loading: _busy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountSheet extends StatefulWidget {
  final WawatProfileApi api;
  final Map<String, String> content;

  const _DeleteAccountSheet({required this.api, required this.content});

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  bool _confirmed = false;
  bool _busy = false;

  Future<void> _delete() async {
    if (!_confirmed || _busy) return;
    setState(() => _busy = true);
    try {
      final message = await widget.api.deleteAccount();
      await sl.get<AuthRepository>().logout();
      if (!mounted) return;
      Navigator.pop(context);
      _showSnack(context, message);
    } catch (e) {
      if (mounted) _showSnack(context, _errorMessage(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark
                  ? WawatDark.danger.withValues(alpha: 0.14)
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              PhosphorIconsFill.warning,
              color: isDark ? WawatDark.dangerText : const Color(0xFFEF4444),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _tx(widget.content, 'profile.delete_title', 'Hesabı silmək?'),
            style: TextStyle(
              color: _cText(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _tx(
              widget.content,
              'profile.delete_subtitle',
              'Elanlarınız, söhbətləriniz və rəyləriniz gizlədiləcək. Bu əməli geri qaytarmaq mümkün deyil.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _cText2(isDark),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => setState(() => _confirmed = !_confirmed),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? WawatDark.surfaceAlt : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: isDark
                    ? Border.all(color: WawatDark.border)
                    : Border.all(color: _ink900.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Icon(
                    _confirmed
                        ? PhosphorIconsFill.checkSquare
                        : PhosphorIconsRegular.square,
                    color: _confirmed
                        ? (isDark ? WawatDark.brandText : _brand)
                        : _cFaint(isDark),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _tx(
                        widget.content,
                        'profile.delete_confirm_understand',
                        'Nəticələri başa düşürəm',
                      ),
                      style: TextStyle(
                        color: isDark ? WawatDark.textSecondary : _ink700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _DangerButton(
            label: _tx(widget.content, 'profile.delete_account', 'Hesabı sil'),
            icon: PhosphorIconsFill.trash,
            onTap: _confirmed ? _delete : null,
            loading: _busy,
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_tx(widget.content, 'common.cancel', 'İmtina et')),
          ),
        ],
      ),
    );
  }
}

class _ReportUserSheet extends StatefulWidget {
  final WawatProfileApi api;
  final WawatProfileUser user;
  final Map<String, String> content;

  const _ReportUserSheet({
    required this.api,
    required this.user,
    required this.content,
  });

  @override
  State<_ReportUserSheet> createState() => _ReportUserSheetState();
}

class _ReportUserSheetState extends State<_ReportUserSheet> {
  final _note = TextEditingController();
  String _reason = 'spam';
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.api.reportUser(
        userId: widget.user.id,
        reasonCode: _reason,
        note: _note.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _showSnack(context, _errorMessage(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reasons = {
      'spam': _tx(widget.content, 'profile.report_spam', 'Spam'),
      'fraud': _tx(widget.content, 'profile.report_fraud', 'Fırıldaq'),
      'abuse': _tx(widget.content, 'profile.report_abuse', 'Təhqir'),
      'fake': _tx(widget.content, 'profile.report_fake', 'Saxta'),
      'inappropriate':
          _tx(widget.content, 'profile.report_inappropriate', 'Uyğunsuz'),
      'other': _tx(widget.content, 'profile.report_other', 'Digər'),
    };
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tx(
              widget.content,
              'profile.report_user_title',
              'İstifadəçini şikayət et',
            ),
            style: TextStyle(
              color: _cText(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _tx(
              widget.content,
              'profile.report_user_subtitle',
              'Səbəbi seçin. Şikayət anonimdir.',
            ),
            style: TextStyle(
              color: _cText2(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in reasons.entries)
                _ReasonChip(
                  label: entry.value,
                  selected: _reason == entry.key,
                  onTap: () => setState(() => _reason = entry.key),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _Field(
            label: _tx(widget.content, 'profile.report_details', 'Ətraflı'),
            controller: _note,
            maxLines: 3,
            hint: _tx(widget.content, 'common.optional', 'İstəyə bağlı'),
          ),
          const SizedBox(height: 12),
          _PrimaryButton(
            label: 'Şikayəti göndər',
            icon: PhosphorIconsFill.flag,
            onTap: _submit,
            loading: _busy,
          ),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_tx(widget.content, 'common.cancel', 'İmtina et')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyReviewSheet extends StatefulWidget {
  final WawatProfileApi api;
  final WawatReview review;
  final Map<String, String> content;

  const _ReplyReviewSheet({
    required this.api,
    required this.review,
    required this.content,
  });

  @override
  State<_ReplyReviewSheet> createState() => _ReplyReviewSheetState();
}

class _ReplyReviewSheetState extends State<_ReplyReviewSheet> {
  final _reply = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reply.text.trim().isEmpty || _busy) return;
    setState(() => _busy = true);
    try {
      await widget.api.replyReview(
        reviewId: widget.review.id,
        reply: _reply.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _showSnack(context, _errorMessage(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tx(widget.content, 'review.reply_title', 'Cavab yaz'),
            style: TextStyle(
              color: _cText(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? WawatDark.surfaceAlt
                  : _ink900.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.review.comment ?? widget.review.author?.displayName ?? '',
              style: TextStyle(
                color: isDark ? WawatDark.textSecondary : _ink600,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Cavabınız',
            controller: _reply,
            maxLines: 4,
            maxLength: 2000,
            hint: _tx(widget.content, 'review.reply_hint', 'Cavabını yaz…'),
          ),
          const SizedBox(height: 10),
          _PrimaryButton(
            label: _tx(widget.content, 'review.reply_submit', 'Cavabı göndər'),
            icon: PhosphorIconsFill.arrowBendUpLeft,
            onTap: _submit,
            loading: _busy,
          ),
        ],
      ),
    );
  }
}

class _UserActionSheet extends StatelessWidget {
  final VoidCallback onBlock;
  final VoidCallback onReport;

  const _UserActionSheet({
    required this.onBlock,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetAction(
            icon: PhosphorIconsRegular.prohibit,
            label: 'İstifadəçini blokla',
            onTap: onBlock,
          ),
          _SheetAction(
            icon: PhosphorIconsRegular.flag,
            label: 'Şikayət et',
            color: isDark ? WawatDark.dangerText : const Color(0xFFEF4444),
            onTap: onReport,
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bağla'),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final WawatProfileUser user;
  final double size;

  /// When true and a photo exists, tapping opens it full-screen.
  final bool tappable;

  const _ProfileAvatar({
    super.key,
    required this.user,
    required this.size,
    this.tappable = false,
  });

  Widget _initials() => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [_brand, Color(0xFF024FA3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          user.initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _image(String url, {required Widget onError}) => CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
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
    final avatar = ClipOval(
      child: SizedBox(width: size, height: size, child: child),
    );

    final viewUrl = (full != null && full.isNotEmpty)
        ? full
        : (thumb != null && thumb.isNotEmpty ? thumb : null);
    if (!tappable || viewUrl == null) return avatar;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder<void>(
          opaque: false,
          barrierColor: Colors.black,
          pageBuilder: (_, __, ___) => AvatarViewer(url: viewUrl),
        ),
      ),
      child: avatar,
    );
  }
}

class _ReviewAvatar extends StatelessWidget {
  final WawatReviewUser? author;

  const _ReviewAvatar({this.author});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: _brand,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        author?.initials ?? 'U',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final String tier;
  final Map<String, String> content;

  const _TierBadge({required this.tier, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = isDark
        ? switch (tier) {
            'bronze' => (WawatDark.tierBronzeBg, WawatDark.tierBronzeText),
            'silver' => (WawatDark.tierSilverBg, WawatDark.tierSilverText),
            'gold' => (WawatDark.tierGoldBg, WawatDark.tierGoldText),
            'platinum' => (
                WawatDark.tierPlatinumBg,
                WawatDark.tierPlatinumText
              ),
            _ => (WawatDark.successBg, WawatDark.success),
          }
        : switch (tier) {
            'bronze' => (const Color(0xFFEFE1D0), const Color(0xFF9A5B2A)),
            'silver' => (const Color(0xFFF1F5F9), _ink600),
            'gold' => (const Color(0xFFFDECC8), const Color(0xFFB67C00)),
            'platinum' => (const Color(0xFFE0E7FF), const Color(0xFF3730A3)),
            _ => (const Color(0xFFDCFCE7), const Color(0xFF15803D)),
          };
    final label = _tx(content, 'enum.user_tier.$tier', _tierLabel(tier));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: palette.$1,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: palette.$2,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _Chip({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surfaceAlt : Colors.white,
        borderRadius: BorderRadius.circular(99),
        border: isDark
            ? Border.all(color: WawatDark.border)
            : Border.all(color: _ink900.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: _cMuted(isDark), size: 14),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: isDark ? WawatDark.textSecondary : _ink700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyStatus extends StatelessWidget {
  final String label;
  final bool amber;

  const _TinyStatus({required this.label, this.amber = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? (amber ? WawatDark.warning : WawatDark.success)
                .withValues(alpha: 0.14)
            : (amber ? _amber50 : const Color(0xFFECFDF5)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark
              ? (amber ? WawatDark.warning : WawatDark.success)
              : (amber ? _amber : const Color(0xFF059669)),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool loading;

  const _PrimaryButton({
    required this.label,
    this.icon,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return _ButtonBase(
      label: label,
      icon: icon,
      onTap: onTap,
      loading: loading,
      background: _brand,
      foreground: Colors.white,
      shadow: true,
    );
  }
}

class _SoftButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const _SoftButton({
    required this.label,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ButtonBase(
      label: label,
      icon: icon,
      onTap: onTap,
      background: _cBrandSoft(isDark),
      foreground: isDark ? WawatDark.brandText : _brand,
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const _GhostButton({
    required this.label,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ButtonBase(
      label: label,
      icon: icon,
      onTap: onTap,
      background:
          isDark ? WawatDark.surfaceAlt : _ink900.withValues(alpha: 0.05),
      foreground: isDark ? WawatDark.textSecondary : _ink600,
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool loading;

  const _DangerButton({
    required this.label,
    this.icon,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ButtonBase(
      label: label,
      icon: icon,
      onTap: onTap,
      loading: loading,
      background: isDark ? WawatDark.danger : const Color(0xFFEF4444),
      foreground: Colors.white,
    );
  }
}

class _ButtonBase extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color background;
  final Color foreground;
  final bool shadow;
  final bool loading;

  const _ButtonBase({
    required this.label,
    required this.onTap,
    required this.background,
    required this.foreground,
    this.icon,
    this.shadow = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: loading ? null : onTap,
      child: Opacity(
        opacity: onTap == null && !loading ? 0.55 : 1,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            boxShadow: shadow
                ? [
                    BoxShadow(
                      color: _brand.withValues(alpha: 0.36),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: loading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(foreground),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: foreground, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  final Widget child;

  const _BottomCta({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: _cCard(isDark),
        border: Border(
            top: BorderSide(
                color: isDark
                    ? WawatDark.divider
                    : _ink900.withValues(alpha: 0.05))),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: _ink900.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
      ),
      child: child,
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final int? maxLength;
  final String? hint;

  const _Field({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.maxLength,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _cText(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                isDark ? const TextStyle(color: WawatDark.textMuted) : null,
            counterStyle: TextStyle(
              color: _cMuted(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor:
                isDark ? WawatDark.surfaceAlt : _ink900.withValues(alpha: 0.02),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                  color: isDark
                      ? WawatDark.border
                      : _ink900.withValues(alpha: 0.07)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                  color: isDark
                      ? WawatDark.border
                      : _ink900.withValues(alpha: 0.07)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  BorderSide(color: isDark ? WawatDark.focusRing : _brand),
            ),
          ),
          style: TextStyle(
            color: _cText(isDark),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool visible;
  final VoidCallback onToggle;
  final IconData icon;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.visible,
    required this.onToggle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _cText(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: !visible,
          style: isDark ? const TextStyle(color: WawatDark.textPrimary) : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _cMuted(isDark)),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                visible
                    ? PhosphorIconsRegular.eyeSlash
                    : PhosphorIconsRegular.eye,
                color: _cMuted(isDark),
              ),
            ),
            filled: true,
            fillColor:
                isDark ? WawatDark.surfaceAlt : _ink900.withValues(alpha: 0.02),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                  color: isDark
                      ? WawatDark.border
                      : _ink900.withValues(alpha: 0.07)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                  color: isDark
                      ? WawatDark.border
                      : _ink900.withValues(alpha: 0.07)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  BorderSide(color: isDark ? WawatDark.focusRing : _brand),
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordStrength extends StatelessWidget {
  final int length;

  const _PasswordStrength({required this.length});

  @override
  Widget build(BuildContext context) {
    final active = length >= 8 ? 3 : (length >= 4 ? 2 : (length > 0 ? 1 : 0));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        for (var i = 0; i < 4; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i < active
                    ? (isDark ? WawatDark.success : _emerald)
                    : (isDark ? WawatDark.surfaceAlt : _ink200),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          if (i != 3) const SizedBox(width: 4),
        ],
        const SizedBox(width: 8),
        Text(
          active >= 3 ? 'Güclü' : 'Zəif',
          style: TextStyle(
            color: active >= 3
                ? (isDark ? WawatDark.success : _emerald)
                : _cMuted(isDark),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final List<dynamic> languages;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _LanguageSelector({
    required this.languages,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bildiyiniz dillər',
          style: TextStyle(
            color: _cText(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final language in languages)
              GestureDetector(
                onTap: () => onToggle(language.code),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected.contains(language.code)
                        ? _cBrandSoft(isDark)
                        : (isDark ? WawatDark.surfaceAlt : Colors.white),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: selected.contains(language.code)
                          ? _brand
                          : (isDark ? WawatDark.border : _ink200),
                    ),
                  ),
                  child: Text(
                    language.name ?? language.code,
                    style: TextStyle(
                      color: selected.contains(language.code)
                          ? (isDark ? WawatDark.brandText : _brand)
                          : (isDark ? WawatDark.textSecondary : _ink700),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _cCard(isDark),
        borderRadius: BorderRadius.circular(20),
        border: _cCardBorder(isDark),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: _ink900.withValues(alpha: 0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? trailingText;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            _SettingsIcon(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: _cText(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (trailingText != null)
              Text(
                trailingText!,
                style: TextStyle(
                  color: _cMuted(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(width: 6),
            Icon(PhosphorIconsRegular.caretRight, color: _cFaint(isDark)),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          _SettingsIcon(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _cText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _cMuted(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: _brand,
            inactiveThumbColor: isDark ? WawatDark.icon : Colors.white,
            inactiveTrackColor:
                isDark ? WawatDark.elevated : _ink900.withValues(alpha: 0.12),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  final IconData icon;

  const _SettingsIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _cBrandSoft(isDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: isDark ? WawatDark.brandText : _brand, size: 18),
    );
  }
}

class _GroupHead extends StatelessWidget {
  final String label;

  const _GroupHead(this.label);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: _cMuted(isDark),
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _SheetShell extends StatelessWidget {
  final Widget child;

  const _SheetShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        18 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: _cCard(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: isDark ? WawatDark.grab : _ink200,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolved = color ?? (isDark ? WawatDark.textPrimary : _ink800);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: resolved, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: resolved,
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

class _AvatarSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onDelete;
  final Map<String, String> content;

  const _AvatarSheet({
    required this.onCamera,
    required this.onGallery,
    required this.onDelete,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              _tx(content, 'profile.avatar_title', 'Profil şəkli'),
              style: TextStyle(
                color: _cText(isDark),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _SheetAction(
            icon: PhosphorIconsRegular.camera,
            label: _tx(content, 'profile.avatar_camera', 'Kameradan çək'),
            color: isDark ? WawatDark.brandText : _brand,
            onTap: onCamera,
          ),
          _SheetAction(
            icon: PhosphorIconsRegular.image,
            label: _tx(content, 'profile.avatar_gallery', 'Qalereyadan seç'),
            color: isDark ? WawatDark.brandText : _brand,
            onTap: onGallery,
          ),
          _SheetAction(
            icon: PhosphorIconsRegular.trash,
            label: _tx(content, 'profile.avatar_delete', 'Şəkli sil'),
            color: isDark ? WawatDark.dangerText : const Color(0xFFEF4444),
            onTap: onDelete,
          ),
          Text(
            _tx(content, 'profile.avatar_hint', 'JPG/PNG/WEBP · maks 10 MB'),
            style: TextStyle(
              color: _cMuted(isDark),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ReasonChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? _cBrandSoft(isDark)
              : (isDark ? WawatDark.surfaceAlt : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? _brand : (isDark ? WawatDark.border : _ink200)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? (isDark ? WawatDark.brandText : _brand)
                : (isDark ? WawatDark.textSecondary : _ink700),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 360,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: _cBrandSoft(isDark),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Icon(icon,
                color: isDark ? WawatDark.brandText : _brand, size: 38),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _cText(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _cText2(isDark),
                fontSize: 13.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  final bool showBack;

  const _ProfileSkeleton({required this.showBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileTopBar(title: 'Profil', showBack: showBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  const _SkeletonBox(width: 68, height: 68, circle: true),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _SkeletonBox(width: 160, height: 18),
                        SizedBox(height: 8),
                        _SkeletonBox(width: 90, height: 12),
                        SizedBox(height: 8),
                        _SkeletonBox(width: 80, height: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _SkeletonBox(width: double.infinity, height: 42),
              const SizedBox(height: 14),
              Row(
                children: const [
                  Expanded(
                      child: _SkeletonBox(width: double.infinity, height: 64)),
                  SizedBox(width: 8),
                  Expanded(
                      child: _SkeletonBox(width: double.infinity, height: 64)),
                  SizedBox(width: 8),
                  Expanded(
                      child: _SkeletonBox(width: double.infinity, height: 64)),
                ],
              ),
              const SizedBox(height: 14),
              const _SkeletonBox(width: double.infinity, height: 52),
              const SizedBox(height: 14),
              const _SkeletonBox(width: double.infinity, height: 88),
              const SizedBox(height: 10),
              const _SkeletonBox(width: double.infinity, height: 88),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final bool circle;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? WawatDark.skeletonBase : _ink200,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(18),
      ),
    );
  }
}

class _ProfileNotFound extends StatelessWidget {
  final VoidCallback onRetry;

  const _ProfileNotFound({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        const _ProfileTopBar(title: 'Profil'),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDark
                          ? WawatDark.surfaceAlt
                          : _ink900.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      PhosphorIconsRegular.userMinus,
                      color: _cFaint(isDark),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'İstifadəçi tapılmadı',
                    style: TextStyle(
                      color: _cText(isDark),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Bu hesab mövcud deyil, dayandırılıb və ya silinib.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _cText2(isDark),
                      fontSize: 13.5,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 180,
                    child: _PrimaryButton(label: 'Yenilə', onTap: onRetry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineLoadError extends StatelessWidget {
  final Map<String, String> content;
  final VoidCallback onRetry;

  const _InlineLoadError({
    required this.content,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? WawatDark.surfaceAlt
                    : _ink900.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                PhosphorIconsRegular.warningCircle,
                color: _cFaint(isDark),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _tx(
                content,
                'profile.load_failed',
                'Məlumatları yükləmək alınmadı',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _cText(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 180,
              child: _PrimaryButton(
                label: _tx(content, 'common.retry', 'Yenidən cəhd et'),
                onTap: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAuthRequired extends StatelessWidget {
  final VoidCallback onRetry;

  const _ProfileAuthRequired({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        const _ProfileTopBar(title: 'Profil'),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: _cBrandSoft(isDark),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      PhosphorIconsFill.userCirclePlus,
                      color: isDark ? WawatDark.brandText : _brand,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Profil üçün daxil ol',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _cText(isDark),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elanlarını, rəylərini və ayarlarını idarə etmək üçün hesabına daxil ol.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _cText2(isDark),
                      fontSize: 13.5,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _PrimaryButton(
                    label: 'Daxil ol / Qeydiyyat',
                    onTap: () => AuthModalUtils.showAuthRequiredModal(context),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: onRetry,
                    behavior: HitTestBehavior.translucent,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Yenilə',
                        style: TextStyle(
                          color: isDark ? WawatDark.brandText : _brand,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

BoxDecoration _cardDecoration([bool d = false]) {
  return BoxDecoration(
    color: _cCard(d),
    borderRadius: BorderRadius.circular(20),
    border: d
        ? Border.all(color: WawatDark.border)
        : Border.all(color: _ink900.withValues(alpha: 0.06)),
    boxShadow: d
        ? null
        : [
            BoxShadow(
              color: _ink900.withValues(alpha: 0.08),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
  );
}

String _compact(int value) {
  if (value >= 1000) {
    final result = value / 1000;
    return '${result.toStringAsFixed(result >= 10 ? 0 : 1)}K';
  }
  return '$value';
}

String _num(double? value) {
  if (value == null) return '';
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String _formatDate(String? value) {
  if (value == null || value.isEmpty) return '';
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  return '${date.day} ${_month(date.month)}';
}

String _dateRange(String? from, String? to) {
  final a = _formatDate(from);
  final b = _formatDate(to);
  if (a.isEmpty) return b;
  if (b.isEmpty || b == a) return a;
  return '$a – $b';
}

String _month(int month) {
  const months = [
    '',
    'Yan',
    'Fev',
    'Mar',
    'Apr',
    'May',
    'İyun',
    'İyul',
    'Avq',
    'Sen',
    'Okt',
    'Noy',
    'Dek',
  ];
  return months[month];
}

String _relativeDate(DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inDays >= 7) return '${diff.inDays ~/ 7} həftə';
  if (diff.inDays > 0) return '${diff.inDays} gün';
  if (diff.inHours > 0) return '${diff.inHours} saat';
  return 'indi';
}

String _tierLabel(String tier) {
  return switch (tier) {
    'bronze' => 'Bürünc',
    'silver' => 'Gümüş',
    'gold' => 'Qızıl',
    'platinum' => 'Platin',
    'new' => 'Yeni',
    _ => tier,
  };
}

String _errorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null)
      return data['message'].toString();
  }
  return 'Əməliyyat alınmadı.';
}

void _showSnack(BuildContext context, String message, {bool error = false}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error
          ? (isDark ? WawatDark.danger : const Color(0xFFEF4444))
          : (isDark ? WawatDark.elevated : _ink900),
      duration: const Duration(milliseconds: 1500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}

bool _isUnauthorized(Object? error) {
  if (error is DioException) {
    return error.response?.statusCode == 401;
  }
  return false;
}
