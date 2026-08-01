import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../data/network/response/user_search_response.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../profile_tab/new_profile/new_profile_screen.dart';
import '../../profile_tab/new_profile/profile_api.dart';
import '../../profile_tab/tier/tier_badge.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _ink900 = Color(0xFF0F172A);
const _ink700 = Color(0xFF334155);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);
const _ink300 = Color(0xFFCBD5E1);
const _amber = Color(0xFFF59E0B);
const _emerald = Color(0xFF22C55E);
const _hlBg = Color(0x73F2FC2A); // accent yellow @ ~45%

Color _cText(bool d) => d ? WawatDark.textPrimary : _ink900;
Color _cText2(bool d) => d ? WawatDark.textSecondary : _ink700;
Color _cMuted(bool d) => d ? WawatDark.textMuted : _ink400;
Color _cCard(bool d) => d ? WawatDark.surface : Colors.white;
Color _cField(bool d) => d ? WawatDark.surfaceAlt : _ink900.withValues(alpha: 0.05);
Color _cLine(bool d) => d ? WawatDark.border : _ink900.withValues(alpha: 0.05);

const _kRecentKey = 'user_search_recent_v1';
const _kMinChars = 2;
const _kPerPage = 20;

/// Second tab of the Search screen: elastic people search (GET /users/search)
/// with the six states from the design — initial (recent), <2 chars, skeleton,
/// results, empty, and the 429/network error banners.
class UserSearchTab extends StatefulWidget {
  /// The shared segmented [Marşrut | İstifadəçi] control, rendered at the top.
  final Widget tabsBar;

  const UserSearchTab({super.key, required this.tabsBar});

  @override
  State<UserSearchTab> createState() => _UserSearchTabState();
}

enum _Phase { initial, tooShort, loading, results, empty, error }

class _UserSearchTabState extends State<UserSearchTab> {
  final _api = WawatProfileApi();
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();

  Timer? _debounce;
  Timer? _retryTicker;
  int _reqId = 0; // bumps on every query → stale responses are ignored

  String _query = '';
  _Phase _phase = _Phase.initial;
  int _retryAfter = 0; // seconds left in the 429 cooldown (0 → network error)

  final List<UserSearchItem> _items = [];
  int _page = 1;
  int _lastPage = 1;
  bool _loadingMore = false;

  List<UserSearchItem> _recent = [];
  // Optimistic follow state per user id (absent → default "İzlə").
  final Map<String, bool> _following = {};

  bool get _rateLimited => _retryAfter > 0;

  @override
  void initState() {
    super.initState();
    _loadRecent();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _retryTicker?.cancel();
    _controller.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ── recent (local) ────────────────────────────────────────────────────────
  Future<void> _loadRecent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kRecentKey);
      if (raw == null) return;
      final list = jsonDecode(raw);
      if (list is! List) return;
      final parsed = list
          .whereType<Map>()
          .map((e) => UserSearchItem.fromJson(Map<String, dynamic>.from(e)))
          .where((u) => u.id.isNotEmpty)
          .toList();
      if (mounted) setState(() => _recent = parsed);
    } catch (_) {/* ignore corrupt cache */}
  }

  Future<void> _persistRecent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kRecentKey,
        jsonEncode(_recent.map((e) => e.toRecentJson()).toList()),
      );
    } catch (_) {}
  }

  void _pushRecent(UserSearchItem item) {
    _recent
      ..removeWhere((e) => e.id == item.id)
      ..insert(0, item);
    if (_recent.length > 8) _recent = _recent.sublist(0, 8);
    _persistRecent();
  }

  void _removeRecent(String id) {
    setState(() => _recent.removeWhere((e) => e.id == id));
    _persistRecent();
  }

  void _clearRecent() {
    setState(() => _recent = []);
    _persistRecent();
  }

  // ── query / search ────────────────────────────────────────────────────────
  void _onChanged(String text) {
    _query = text;
    _debounce?.cancel();
    final trimmed = text.trim();
    if (trimmed.length < _kMinChars) {
      setState(() {
        _items.clear();
        _phase = trimmed.isEmpty ? _Phase.initial : _Phase.tooShort;
      });
      return;
    }
    // Debounce 350ms; a stale in-flight request is dropped by _reqId.
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(reset: true));
  }

  void _clearQuery() {
    _controller.clear();
    _onChanged('');
    _focus.requestFocus();
  }

  Future<void> _search({required bool reset}) async {
    final q = _query.trim();
    if (q.length < _kMinChars) return;
    if (_rateLimited) return; // honor the cooldown — don't spam

    final token = ++_reqId;
    final page = reset ? 1 : _page + 1;

    setState(() {
      if (reset) {
        _phase = _Phase.loading;
      } else {
        _loadingMore = true;
      }
    });

    try {
      final res = await _api.searchUsers(q, page: page, perPage: _kPerPage);
      if (!mounted || token != _reqId) return; // superseded → ignore
      setState(() {
        if (reset) {
          _items
            ..clear()
            ..addAll(res.items);
        } else {
          _items.addAll(res.items);
        }
        _page = res.currentPage;
        _lastPage = res.lastPage;
        _loadingMore = false;
        _phase = _items.isEmpty ? _Phase.empty : _Phase.results;
      });
    } on DioException catch (e) {
      if (!mounted || token != _reqId) return;
      if (e.response?.statusCode == 429) {
        _enterRateLimit(e.response);
      } else {
        setState(() {
          _loadingMore = false;
          _phase = _Phase.error;
        });
      }
    } catch (_) {
      if (!mounted || token != _reqId) return;
      setState(() {
        _loadingMore = false;
        _phase = _Phase.error;
      });
    }
  }

  void _enterRateLimit(Response? response) {
    var seconds = 0;
    final body = response?.data;
    if (body is Map && body['retry_after'] != null) {
      seconds = int.tryParse(body['retry_after'].toString()) ?? 0;
    }
    if (seconds <= 0) {
      final header = response?.headers.value('retry-after');
      seconds = int.tryParse(header ?? '') ?? 5;
    }
    setState(() {
      _loadingMore = false;
      _retryAfter = seconds;
      _phase = _Phase.error;
    });
    _retryTicker?.cancel();
    _retryTicker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _retryAfter -= 1);
      if (_retryAfter <= 0) {
        t.cancel();
        _retry();
      }
    });
  }

  void _retry() {
    _retryTicker?.cancel();
    _retryAfter = 0;
    if (_query.trim().length >= _kMinChars) {
      _search(reset: true);
    } else {
      setState(() => _phase = _Phase.initial);
    }
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.extentAfter > 320) return;
    if (_phase != _Phase.results) return;
    if (_loadingMore || _rateLimited) return;
    if (_page >= _lastPage) return;
    _search(reset: false);
  }

  // ── follow (optimistic) ───────────────────────────────────────────────────
  bool _isFollowing(UserSearchItem u) => _following[u.id] ?? false;

  Future<void> _toggleFollow(UserSearchItem u) async {
    final next = !_isFollowing(u);
    setState(() => _following[u.id] = next); // optimistic
    try {
      if (next) {
        await _api.follow(u.id);
      } else {
        await _api.unfollow(u.id);
      }
    } catch (_) {
      if (mounted) setState(() => _following[u.id] = !next); // rollback
    }
  }

  void _openProfile(UserSearchItem u) {
    _pushRecent(u);
    _focus.unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PublicProfileScreen(userId: u.id)),
    );
  }

  List<String> get _queryWords => _query
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        widget.tabsBar,
        _searchField(isDark),
        Expanded(child: _content(isDark)),
      ],
    );
  }

  Widget _searchField(bool d) {
    final active = _focus.hasFocus || _query.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? _cCard(d) : _cField(d),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? _brand.withValues(alpha: 0.35) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(PhosphorIconsRegular.magnifyingGlass,
                size: 20, color: active ? _brand : _cMuted(d)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                onChanged: _onChanged,
                autofocus: false,
                textInputAction: TextInputAction.search,
                style: TextStyle(
                  color: _cText(d),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Ad, soyad və ya @username',
                  hintStyle: TextStyle(
                    color: _cMuted(d),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onSubmitted: (_) {
                  if (_query.trim().length >= _kMinChars) {
                    _debounce?.cancel();
                    _search(reset: true);
                  }
                },
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                onTap: _clearQuery,
                behavior: HitTestBehavior.opaque,
                child: Icon(PhosphorIconsBold.xCircle,
                    size: 20, color: _cMuted(d)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _content(bool d) {
    // Error banners sit above whatever content is available.
    if (_phase == _Phase.error) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        children: [
          if (_rateLimited) _rateBanner(d) else _networkBanner(d),
        ],
      );
    }
    switch (_phase) {
      case _Phase.initial:
        return _recentView(d);
      case _Phase.tooShort:
        return _tooShortView(d);
      case _Phase.loading:
        return _skeletonView(d);
      case _Phase.empty:
        return _emptyView(d);
      case _Phase.results:
        return _resultsView(d);
      case _Phase.error:
        return const SizedBox.shrink();
    }
  }

  // ── state: recent (initial) ───────────────────────────────────────────────
  Widget _recentView(bool d) {
    if (_recent.isEmpty) return _promptView(d);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Son axtarışlar',
                style: TextStyle(
                    color: _cText(d),
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            GestureDetector(
              onTap: _clearRecent,
              child: const Text('Təmizlə',
                  style: TextStyle(
                      color: _brand,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ..._recent.map((u) => _recentRow(u, d)),
      ],
    );
  }

  Widget _recentRow(UserSearchItem u, bool d) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openProfile(u),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            _Avatar(item: u, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(u.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: _cText(d),
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                      ),
                      if (u.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(PhosphorIconsFill.sealCheck,
                            color: _brand, size: 13),
                      ],
                    ],
                  ),
                  if (u.username != null)
                    Text('@${u.username}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: _cMuted(d),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _removeRecent(u.id),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(PhosphorIconsRegular.x, size: 18, color: _ink300),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── state: prompt / too short ─────────────────────────────────────────────
  Widget _promptView(bool d) => _centered(
        d,
        icon: PhosphorIconsRegular.magnifyingGlass,
        iconBg: d ? WawatDark.brandChip : _brand50,
        iconColor: _brand,
        title: 'Ad və ya @username ilə axtar',
        subtitle: 'İnsanları adı, soyadı və ya istifadəçi adı ilə tap.',
      );

  Widget _tooShortView(bool d) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
          child: Row(
            children: [
              Icon(PhosphorIconsRegular.info, size: 14, color: _cMuted(d)),
              const SizedBox(width: 6),
              Text('Ən azı 2 simvol daxil edin',
                  style: TextStyle(
                      color: _cMuted(d),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Expanded(child: _promptView(d)),
      ],
    );
  }

  // ── state: skeleton ───────────────────────────────────────────────────────
  Widget _skeletonView(bool d) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 6,
      itemBuilder: (_, __) => _SkeletonRow(isDark: d),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
    );
  }

  // ── state: results ────────────────────────────────────────────────────────
  Widget _resultsView(bool d) {
    return ListView.separated(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      itemCount: _items.length + (_page < _lastPage ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index >= _items.length) return _moreLoader(d);
        return _UserCard(
          item: _items[index],
          isDark: d,
          following: _isFollowing(_items[index]),
          words: _queryWords,
          onTap: () => _openProfile(_items[index]),
          onFollow: () => _toggleFollow(_items[index]),
        );
      },
    );
  }

  Widget _moreLoader(bool d) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: _cMuted(d)),
            ),
            const SizedBox(width: 8),
            Text('Daha çox yüklənir…',
                style: TextStyle(
                    color: _cMuted(d),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  // ── state: empty ──────────────────────────────────────────────────────────
  Widget _emptyView(bool d) => _centered(
        d,
        icon: PhosphorIconsRegular.userFocus,
        iconBg: d ? WawatDark.surfaceAlt : _ink900.withValues(alpha: 0.05),
        iconColor: _ink300,
        title: 'Heç kim tapılmadı',
        subtitle:
            '«${_query.trim()}» üzrə nəticə yoxdur. Adı və ya @username-i yoxla.',
      );

  // ── banners ───────────────────────────────────────────────────────────────
  Widget _rateBanner(bool d) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: d ? WawatDark.warningBg : const Color(0xFFFEF6E7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF6D48A)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsFill.hourglassMedium,
              size: 18, color: const Color(0xFFE8A400)),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Çox tez-tez axtarış — ',
                children: [
                  TextSpan(
                      text: '${_retryAfter}s',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const TextSpan(text: ' sonra yenidən cəhd et'),
                ],
              ),
              style: const TextStyle(
                  color: Color(0xFF8A5D00),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          _bannerBtn('Təkrar', const Color(0xFFE8A400), _retry),
        ],
      ),
    );
  }

  Widget _networkBanner(bool d) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: d ? WawatDark.dangerSoftBg : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsFill.wifiSlash,
              size: 18, color: Color(0xFFEF4444)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Bağlantı yoxdur — nəticələr yüklənmədi',
                style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          _bannerBtn('Təkrar', const Color(0xFFEF4444), _retry),
        ],
      ),
    );
  }

  Widget _bannerBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── shared empty/prompt layout ────────────────────────────────────────────
  Widget _centered(
    bool d, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 90, 32, 32),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _cText(d),
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _cText2(d).withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Segmented [Marşrut | İstifadəçi] control shared by both search tabs.
class SearchSegmentTabs extends StatelessWidget {
  final int index; // 0 = routes, 1 = users
  final ValueChanged<int> onChanged;

  const SearchSegmentTabs({
    super.key,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final d = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: d ? WawatDark.surfaceAlt : _ink900.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _seg(d, 'Marşrut', PhosphorIconsBold.mapPinLine, 0),
            _seg(d, 'İstifadəçi', PhosphorIconsBold.usersThree, 1),
          ],
        ),
      ),
    );
  }

  Widget _seg(bool d, String label, IconData icon, int i) {
    final selected = index == i;
    final fg = selected
        ? (d ? WawatDark.textPrimary : _ink900)
        : (d ? WawatDark.textMuted : _ink500);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? (d ? WawatDark.surface : Colors.white) : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _ink900.withValues(alpha: d ? 0 : 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: fg, fontSize: 12.5, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── result card ─────────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final UserSearchItem item;
  final bool isDark;
  final bool following;
  final List<String> words;
  final VoidCallback onTap;
  final VoidCallback onFollow;

  const _UserCard({
    required this.item,
    required this.isDark,
    required this.following,
    required this.words,
    required this.onTap,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cCard(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cLine(isDark)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: _ink900.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          children: [
            _Avatar(item: item, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: _Highlighted(
                          text: item.fullName,
                          words: words,
                          style: TextStyle(
                              color: _cText(isDark),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (item.isVerified) ...[
                        const SizedBox(width: 5),
                        const Icon(PhosphorIconsFill.sealCheck,
                            color: _brand, size: 14),
                      ],
                      if (item.tier != null) ...[
                        const SizedBox(width: 6),
                        TierBadge(tier: item.tier!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  if (item.username != null)
                    _Highlighted(
                      text: '@${item.username}',
                      words: words,
                      style: TextStyle(
                          color: _cMuted(isDark),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600),
                    ),
                  const SizedBox(height: 3),
                  _trustRow(isDark),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _followButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _trustRow(bool d) {
    if (item.isNewUser) {
      return Text('Yeni istifadəçi · reytinq yoxdur',
          style: TextStyle(
              color: _cMuted(d), fontSize: 11.5, fontWeight: FontWeight.w600));
    }
    return Row(
      children: [
        const Icon(PhosphorIconsFill.star, size: 13, color: _amber),
        const SizedBox(width: 3),
        Text((item.ratingAvg ?? 0).toStringAsFixed(1),
            style: TextStyle(
                color: _cText2(d), fontSize: 11.5, fontWeight: FontWeight.w700)),
        const SizedBox(width: 3),
        Text('(${item.ratingCount})',
            style: TextStyle(
                color: _cMuted(d), fontSize: 11.5, fontWeight: FontWeight.w600)),
        if (item.completedShipments > 0) ...[
          Text('  ·  ',
              style: TextStyle(color: _ink300, fontSize: 11.5)),
          Text('${item.completedShipments} çatdırılma',
              style: TextStyle(
                  color: _cMuted(d),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }

  Widget _followButton(bool d) {
    if (following) {
      return GestureDetector(
        onTap: onFollow,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: d ? WawatDark.surfaceAlt : _ink900.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('İzlənilir',
              style: TextStyle(
                  color: d ? WawatDark.textSecondary : const Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ),
      );
    }
    return GestureDetector(
      onTap: onFollow,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: _brand,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(PhosphorIconsBold.plus, size: 11, color: Colors.white),
            SizedBox(width: 4),
            Text('İzlə',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ── avatar with online dot ──────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final UserSearchItem item;
  final double size;

  const _Avatar({required this.item, required this.size});

  static const _gradients = [
    [Color(0xFF017BFE), Color(0xFF024FA3)],
    [Color(0xFF10B981), Color(0xFF047857)],
    [Color(0xFF6366F1), Color(0xFF4338CA)],
    [Color(0xFFE8A400), Color(0xFFB67C00)],
    [Color(0xFF94A3B8), Color(0xFF475569)],
  ];

  String get _initials {
    final parts = item.fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = item.avatarThumbUrl;
    final grad = _gradients[item.id.hashCode.abs() % _gradients.length];
    final fallback = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: grad,
        ),
      ),
      child: Text(_initials,
          style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.32,
              fontWeight: FontWeight.w800)),
    );
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: SizedBox(
              width: size,
              height: size,
              child: (url == null || url.isEmpty)
                  ? fallback
                  : CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => fallback,
                      errorWidget: (_, __, ___) => fallback,
                    ),
            ),
          ),
          if (item.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _emerald,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? WawatDark.surface
                        : Colors.white,
                    width: 2.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── matched-substring highlight ─────────────────────────────────────────────
class _Highlighted extends StatelessWidget {
  final String text;
  final List<String> words;
  final TextStyle style;

  const _Highlighted({
    required this.text,
    required this.words,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Text(text,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
    }
    final lower = text.toLowerCase();
    // Mark every character covered by any query word, then coalesce runs.
    final marked = List<bool>.filled(text.length, false);
    for (final w in words) {
      if (w.isEmpty) continue;
      var from = 0;
      while (true) {
        final idx = lower.indexOf(w, from);
        if (idx < 0) break;
        for (var k = idx; k < idx + w.length && k < text.length; k++) {
          marked[k] = true;
        }
        from = idx + w.length;
      }
    }
    final spans = <TextSpan>[];
    var i = 0;
    while (i < text.length) {
      final on = marked[i];
      var j = i;
      while (j < text.length && marked[j] == on) {
        j++;
      }
      spans.add(TextSpan(
        text: text.substring(i, j),
        style: on
            ? style.copyWith(
                backgroundColor: _hlBg,
                color: _ink900,
                fontWeight: FontWeight.w800)
            : null,
      ));
      i = j;
    }
    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ── skeleton row ────────────────────────────────────────────────────────────
class _SkeletonRow extends StatelessWidget {
  final bool isDark;

  const _SkeletonRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base = isDark ? WawatDark.surfaceAlt : const Color(0xFFE7EBF1);
    Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
              color: base, borderRadius: BorderRadius.circular(6)),
        );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cCard(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cLine(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: base, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(140, 12),
                const SizedBox(height: 8),
                bar(80, 10),
                const SizedBox(height: 8),
                bar(110, 10),
              ],
            ),
          ),
          const SizedBox(width: 10),
          bar(56, 30),
        ],
      ),
    );
  }
}
