import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/response/listing_response.dart';
import '../../../../../presentation/common/listing_share.dart';
import '../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/localization_service.dart';
import '../../../../../services/wawat_content.dart';
import '../../profile_tab/new_profile/new_profile_screen.dart';
import '../../profile_tab/new_profile/profile_api.dart';
import '../../profile_tab/tier/tier_badge.dart';
import 'listing_expired.dart';

Future<Map<String, String>>? _listingContentFuture;

Future<Map<String, String>> _loadListingContent() {
  return _listingContentFuture ??= WawatContent.loadDefault();
}

class _OwnerAvatarCache {
  static final Map<String, String> _resolved = {};
  static final Map<String, Future<String>> _inFlight = {};

  static String? cached(String id) => _resolved[id];

  static Future<String> resolve(String id) {
    final done = _resolved[id];
    if (done != null) return Future.value(done);
    return _inFlight[id] ??= _load(id);
  }

  static Future<String> _load(String id) async {
    try {
      final user = await WawatProfileApi().user(id);
      final full = user.avatarUrl?.trim() ?? '';
      final thumb = user.avatarThumbUrl?.trim() ?? '';
      final url = thumb.isNotEmpty ? thumb : full;
      _resolved[id] = url;
      return url;
    } catch (_) {
      _resolved[id] =
          '';
      return '';
    } finally {
      _inFlight.remove(id);
    }
  }
}

typedef ListingFavoriteCallback = Future<void> Function(
  Listing listing,
  bool nextValue,
);

class ListingCard extends StatefulWidget {
  final Listing listing;
  final Map<String, String> packageNamesByCode;
  final bool isOwner;
  final bool isCompact;
  final bool actionsEnabled;
  final String? promotionTypeOverride;
  final EdgeInsetsGeometry margin;
  final ListingFavoriteCallback? onFavoriteChanged;
  final ValueChanged<Listing>? onOfferTap;
  final ValueChanged<Listing>? onMessageTap;
  final ValueChanged<Listing>? onDetailsTap;
  final ValueChanged<Listing>? onPauseTap;
  final ValueChanged<Listing>? onResumeTap;
  final ValueChanged<Listing>? onRepostTap;
  final ValueChanged<Listing>? onDeleteTap;
  final ValueChanged<Listing>? onVipTap;
  final ValueChanged<Listing>? onBoostTap;
  final ValueChanged<Listing>? onPromotionExtendTap;

  const ListingCard({
    super.key,
    required this.listing,
    this.packageNamesByCode = const {},
    this.isOwner = false,
    this.isCompact = false,
    this.actionsEnabled = true,
    this.promotionTypeOverride,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 16),
    this.onFavoriteChanged,
    this.onOfferTap,
    this.onMessageTap,
    this.onDetailsTap,
    this.onPauseTap,
    this.onResumeTap,
    this.onRepostTap,
    this.onDeleteTap,
    this.onVipTap,
    this.onBoostTap,
    this.onPromotionExtendTap,
  });

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  late bool _isFavorited;
  bool _isExpanded = false;
  bool _isFavoriteBusy = false;
  late final Future<Map<String, String>> _contentFuture;

  String? _resolvedOwnerAvatar;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.listing.isFavorited;
    _contentFuture = _loadListingContent();
    _resolveOwnerAvatar();
  }

  @override
  void didUpdateWidget(covariant ListingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listing.id != widget.listing.id ||
        oldWidget.listing.isFavorited != widget.listing.isFavorited) {
      _isFavorited = widget.listing.isFavorited;
      _isFavoriteBusy = false;
    }
    if (oldWidget.listing.id != widget.listing.id) {
      _resolvedOwnerAvatar = null;
      _resolveOwnerAvatar();
    }
  }

  void _resolveOwnerAvatar() {
    final owner = widget.listing.owner;
    if (owner == null || owner.avatarThumbUrl.isNotEmpty) return;
    final id = (owner.id ?? widget.listing.ownerId ?? '').trim();
    if (id.isEmpty) return;

    final cached = _OwnerAvatarCache.cached(id);
    if (cached != null) {
      if (cached.isNotEmpty) _resolvedOwnerAvatar = cached;
      return;
    }
    _OwnerAvatarCache.resolve(id).then((url) {
      if (mounted && url.isNotEmpty) {
        setState(() => _resolvedOwnerAvatar = url);
      }
    });
  }

  String _ownerAvatarUrl(ListingOwner owner) {
    if (owner.avatarThumbUrl.isNotEmpty) return owner.avatarThumbUrl;
    return _resolvedOwnerAvatar ?? '';
  }

  bool get _isTrip => widget.listing.isTrip;

  /// Просроченное объявление в чужой ленте: карточка остаётся на месте,
  /// но приглушена и без кнопки предложения. Владелец в «Elanlarım» видит
  /// свою карточку как раньше — со статусом и кнопкой «Repost».
  ///
  /// Превью продвижения ([ListingCard.promotionTypeOverride]) показывает,
  /// как объявление будет выглядеть с VIP, — его не серим.
  bool get _expired =>
      widget.listing.isExpired &&
      !widget.isOwner &&
      widget.promotionTypeOverride == null;

  bool get _readonly => widget.listing.isFull && !widget.isOwner && !_expired;

  /// Приглушённый акцент — и для «мест нет», и для просроченного.
  bool get _muted => _readonly || _expired;

  Color _accentOf(bool isDark) {
    if (_muted) {
      return isDark ? WawatDark.textMuted : const Color(0xFF94A3B8);
    }
    return _liveAccentOf(isDark);
  }

  Color _liveAccentOf(bool isDark) {
    if (isDark) {
      return _isTrip ? WawatDark.brandText : WawatDark.warning;
    }
    return _isTrip ? const Color(0xFF0271EB) : const Color(0xFFF59E0B);
  }

  /// Цена и вес: у просроченного — нейтральный серый, чтобы карточка
  /// не тянула взгляд.
  Color _figureColor(Color textColor, bool isDark) {
    if (!_expired) return textColor;
    return isDark ? WawatDark.textSecondary : const Color(0xFF64748B);
  }

  Color _accentSoftOf(bool isDark) {
    if (_muted) {
      return isDark ? WawatDark.surfaceAlt : const Color(0xFFF1F5F9);
    }
    if (isDark) {
      return _isTrip ? WawatDark.brandChip : WawatDark.warningBg;
    }
    return _isTrip ? const Color(0xFFEAF3FE) : const Color(0xFFFFF7ED);
  }

  String? get _promotionType =>
      widget.promotionTypeOverride ??
      widget.listing.promotion?.type ??
      widget.listing.promotionType;

  bool get _hasRunningPromotion {
    final type = widget.listing.promotion?.type ?? widget.listing.promotionType;
    return type != null && type.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final readonly = _readonly;
    final expired = _expired;
    // Просроченная карточка — обычный белый фон, радиус и тень: она не
    // «сломанная», а неактивная. Приглушается только содержимое.
    final cardColor = readonly
        ? (isDark ? WawatDark.surfaceAlt : const Color(0xFFF8FAFC))
        : cCard(isDark);
    final textColor = expired
        ? (isDark ? WawatDark.textSecondary : const Color(0xFF475569))
        : readonly
            ? (isDark ? WawatDark.textSecondary : const Color(0xFF64748B))
            : cText(isDark);
    final mutedColor = expired
        ? (isDark ? WawatDark.textMuted : const Color(0xFF94A3B8))
        : (isDark ? WawatDark.textMuted : const Color(0xFF64748B));
    final isVipCard = _promotionType == 'vip' && !readonly && !expired;
    final borderColor = isVipCard
        ? (isDark ? WawatDark.gold : const Color(0xFFFBBF24))
        : readonly
            ? (isDark ? WawatDark.border : const Color(0x14000000))
            : (isDark ? WawatDark.border : const Color(0x0F0F172A));
    final ownerActions =
        widget.isOwner ? _ownerActionButtons(isDark) : const <Widget>[];

    return FutureBuilder<Map<String, String>>(
      future: _contentFuture,
      initialData: const {},
      builder: (context, snapshot) {
        final content = snapshot.data ?? const {};
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onDetailsTap == null
              ? null
              : () => widget.onDetailsTap!(widget.listing),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: widget.margin,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: borderColor,
                width: isVipCard ? 2 : 1,
              ),
              boxShadow: isDark
                  ? WawatDark.cardShadow
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(textColor, mutedColor, content, isDark),
                const SizedBox(height: 16),
                _buildRoute(textColor, mutedColor, isDark),
                const SizedBox(height: 14),
                _buildMainMeta(textColor, mutedColor, isDark),
                if (!widget.isCompact || _isExpanded) ...[
                  _buildDetails(textColor, mutedColor, isDark),
                ],
                if (widget.listing.owner != null) ...[
                  const SizedBox(height: 16),
                  _buildOwner(textColor, mutedColor, isDark, content),
                ],
                if (widget.isOwner) ...[
                  const SizedBox(height: 14),
                  _buildOwnerStats(textColor, mutedColor, isDark),
                ],
                if (widget.actionsEnabled && !widget.isOwner) ...[
                  const SizedBox(height: 16),
                  _buildPublicActions(textColor, isDark),
                ],
                if (widget.actionsEnabled && ownerActions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildOwnerActions(ownerActions),
                ],
                if (widget.isOwner &&
                    (widget.onVipTap != null ||
                        widget.onBoostTap != null ||
                        widget.onPromotionExtendTap != null) &&
                    (widget.listing.canBePromoted ||
                        _hasRunningPromotion)) ...[
                  const SizedBox(height: 14),
                  _buildPromotionActions(
                      textColor, mutedColor, content, isDark),
                ],
                if (widget.isCompact) _buildExpandButton(isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    Color textColor,
    Color mutedColor,
    Map<String, String> content,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (_expired)
                ListingExpiredPill(label: listingExpiredLabel(widget.listing)),
              _Badge(
                icon: _isTrip
                    ? PhosphorIconsFill.airplaneTakeoff
                    : PhosphorIconsFill.package,
                label: widget.listing.typeLabel ??
                    content[
                        'enum.listing_type.${_isTrip ? 'trip' : 'shipment_post'}'] ??
                    (_isTrip
                        ? tr('enum.listing_type.trip', 'Səfər')
                        : tr('enum.listing_type.shipment_post', 'Göndəriş')),
                color: _accentOf(isDark),
                background: _accentSoftOf(isDark),
              ),
              if (_readonly)
                _Badge(
                  icon: PhosphorIconsFill.prohibit,
                  label: widget.listing.statusLabel ??
                      content['enum.listing_status.fully_booked'] ??
                      content['listing.fully_booked'] ??
                      tr('listing.fully_booked', 'Yer yoxdur'),
                  color: isDark
                      ? WawatDark.textSecondary
                      : const Color(0xFF475569),
                  background:
                      isDark ? WawatDark.elevated : const Color(0xFFE2E8F0),
                ),
              if (_promotionType == 'vip' && !_muted)
                _Badge(
                  icon: PhosphorIconsFill.sealCheck,
                  label: content['enum.promotion_type.vip'] ??
                      tr('enum.promotion_type.vip', 'VİP'),
                  color: isDark ? WawatDark.onGold : const Color(0xFF0F172A),
                  background: isDark ? WawatDark.gold : const Color(0xFFFBBF24),
                ),
              if (_promotionType == 'featured' && !_muted)
                _Badge(
                  icon: PhosphorIconsFill.rocketLaunch,
                  label: content['enum.promotion_type.featured'] ??
                      tr('enum.promotion_type.featured', 'Önə çıxarılan'),
                  color: isDark ? WawatDark.brandText : const Color(0xFF024FA3),
                  background:
                      isDark ? WawatDark.brandChip : const Color(0xFFCFE3FD),
                ),
              if (widget.isOwner && widget.listing.statusLabel != null)
                _Badge(
                  icon: PhosphorIconsRegular.info,
                  label: widget.listing.statusLabel!,
                  color: mutedColor,
                  background: mutedColor.withValues(alpha: 0.12),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _headerIcon(
                icon: PhosphorIconsRegular.shareNetwork,
                color: cFaint(isDark),
                onTap: _shareListing,
                size: 22,
              ),
              if (!widget.isOwner)
                _headerIcon(
                  icon: _isFavorited
                      ? PhosphorIconsFill.heart
                      : PhosphorIconsRegular.heart,
                  // Избранное у просроченного работает (сервер принимает),
                  // поэтому сердечко не гасим — оно остаётся живым цветом.
                  color: _isFavorited
                      ? (_expired ? _liveAccentOf(isDark) : _accentOf(isDark))
                      : cFaint(isDark),
                  onTap: _toggleFavorite,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 24,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(child: Icon(icon, color: color, size: size)),
      ),
    );
  }

  void _shareListing() {
    shareListing(widget.listing, context);
  }

  Widget _buildRoute(Color textColor, Color mutedColor, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _RouteCity(
            city: widget.listing.cityFrom ?? '-',
            color: textColor,
            mutedColor: mutedColor,
            align: TextAlign.right,
          ),
        ),
        const SizedBox(width: 8),
        _RouteLine(
          accent: _accentOf(isDark),
          softAccent: _accentSoftOf(isDark),
          isTrip: _isTrip,
          isDark: isDark,
          muted: _expired,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _RouteCity(
            city: widget.listing.cityTo ?? '-',
            color: textColor,
            mutedColor: mutedColor,
            align: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildMainMeta(Color textColor, Color mutedColor, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
          decoration: BoxDecoration(
            color: _accentSoftOf(isDark),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isTrip
                    ? PhosphorIconsFill.calendarDots
                    : PhosphorIconsRegular.calendarBlank,
                color: _accentOf(isDark),
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                _dateText(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const Spacer(),
        if (_isTrip && widget.listing.allowPriceNegotiation == true)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _accentOf(isDark).withValues(alpha: isDark ? 0.24 : 0.13),
                  _accentOf(isDark).withValues(alpha: isDark ? 0.12 : 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color:
                    _accentOf(isDark).withValues(alpha: isDark ? 0.45 : 0.28),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIconsFill.handshake,
                    size: 16, color: _accentOf(isDark)),
                const SizedBox(width: 7),
                Text(
                  'kq/\$',
                  style: TextStyle(
                    color: _accentOf(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          )
        else if (_isTrip && widget.listing.pricePerKg != null)
          Text.rich(
            TextSpan(
              text: _formatNumber(widget.listing.pricePerKg!),
              style: TextStyle(
                color: _figureColor(textColor, isDark),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(
                  text: ' \$',
                  style: TextStyle(
                    fontSize: 18,
                    color: _figureColor(textColor, isDark),
                  ),
                ),
                TextSpan(
                  text: ' /kq',
                  style: TextStyle(
                    fontSize: 12,
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetails(Color textColor, Color mutedColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isTrip && widget.listing.maxWeightKg != null)
          _buildCapacity(textColor, mutedColor, isDark),
        if (!_isTrip && widget.listing.weightKg != null)
          _InfoRow(
            icon: PhosphorIconsRegular.scales,
            label: tr('listing.weight', 'Çəki'),
            value: '${_formatNumber(widget.listing.weightKg!)} kq',
            textColor: _figureColor(textColor, isDark),
            mutedColor: mutedColor,
          ),
        if (_isTrip && widget.listing.flightNumber != null) ...[
          const SizedBox(height: 10),
          _InfoRow(
            icon: PhosphorIconsRegular.ticket,
            label: tr('listing.flight', 'Reys'),
            value: widget.listing.flightNumber!,
            textColor: textColor,
            mutedColor: mutedColor,
          ),
        ],
        if (_isTrip && widget.listing.allowPriceNegotiation == true) ...[
          const SizedBox(height: 10),
          _Badge(
            icon: PhosphorIconsFill.handshake,
            label: tr('listing.price_negotiable', 'Qiymət razılaşma ilə'),
            color: _accentOf(isDark),
            background: _accentSoftOf(isDark),
          ),
        ],
        if (widget.listing.packageTypeCodes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: widget.listing.packageTypeCodes
                .map((code) => _buildPackageChip(code, isDark))
                .toList(),
          ),
        ],
        if (widget.listing.description != null &&
            widget.listing.description!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            widget.listing.description!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: mutedColor,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCapacity(Color textColor, Color mutedColor, bool isDark) {
    final max = widget.listing.maxWeightKg ?? 0;
    final free = widget.listing.freeWeightKg?.clamp(0, max).toDouble() ?? max;
    final reserved = (widget.listing.reservedKg ?? 0).clamp(0, max).toDouble();
    final progress = max == 0 ? 0.0 : (reserved / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              tr('listing.free_space', 'Boş yer'),
              style: TextStyle(
                color: isDark ? cText2(true) : mutedColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${_formatNumber(free)} / ${_formatNumber(max)} kq',
              style: TextStyle(
                color: _figureColor(textColor, isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: 1 - progress,
            color: isDark
                ? (_isTrip && !_expired
                    ? WawatDark.brandTextStrong
                    : _accentOf(true))
                : _accentOf(false),
            backgroundColor: isDark ? cBorder(true) : const Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageChip(String code, bool isDark) {
    final label = widget.packageNamesByCode[code] ?? code;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFF64748B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _packageIcon(code),
            color: isDark ? cText2(true) : const Color(0xFF64748B),
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isDark ? cText2(true) : const Color(0xFF475569),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwner(
    Color textColor,
    Color mutedColor,
    bool isDark,
    Map<String, String> content,
  ) {
    final owner = widget.listing.owner!;
    final initials = _initials(owner.displayName);
    final ownerId =
        (owner.id ?? widget.listing.ownerId ?? owner.username ?? '').trim();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: ownerId.isEmpty
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PublicProfileScreen(
                    userId: ownerId,
                    initialOwner: owner,
                  ),
                ),
              ),
      child: Container(
        padding: const EdgeInsets.only(top: 14),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? cLine(true) : const Color(0x0F0F172A),
            ),
          ),
        ),
        child: Row(
          children: [
            Builder(
              builder: (context) {
                final avatarUrl = _ownerAvatarUrl(owner);
                return ListingGrayscale(
                  enabled: _expired,
                  child: CircleAvatar(
                  radius: 21,
                  backgroundColor: _accentSoftOf(isDark),
                  backgroundImage: avatarUrl.isEmpty
                      ? null
                      : CachedNetworkImageProvider(avatarUrl),
                  child: avatarUrl.isEmpty
                      ? Text(
                          initials,
                          style: TextStyle(
                            color: _accentOf(isDark),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        )
                      : null,
                  ),
                );
              },
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          owner.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (owner.isVerified) ...[
                        const SizedBox(width: 5),
                        Icon(
                          PhosphorIconsFill.sealCheck,
                          color: _expired
                              ? mutedColor
                              : isDark
                                  ? WawatDark.brandText
                                  : const Color(0xFF0271EB),
                          size: 16,
                        ),
                      ],
                      if (owner.tier != null && owner.tier!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        ListingGrayscale(
                          enabled: _expired,
                          child: TierBadge(tier: owner.tier!, content: content),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (owner.ratingAvg != null) ...[
                        Icon(PhosphorIconsFill.star,
                            color: _expired
                                ? mutedColor
                                : const Color(0xFFFBBF24),
                            size: 15),
                        const SizedBox(width: 4),
                        Text(
                          _formatNumber(owner.ratingAvg!),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (owner.ratingCount != null)
                          Text(
                            ' (${owner.ratingCount})',
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                      if (owner.avgResponseMinutes != null) ...[
                        Text(' · ', style: TextStyle(color: mutedColor)),
                        Text(
                          tr('listing.avg_response', '~{minutes} dəq cavab',
                              {'minutes': '${owner.avgResponseMinutes}'}),
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildOwnerStats(Color textColor, Color mutedColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (widget.listing.viewCount != null)
            Expanded(
              child: _OwnerStat(
                label: tr('listing.views', 'Baxış'),
                value: widget.listing.viewCount.toString(),
                color: textColor,
                mutedColor: mutedColor,
              ),
            ),
          if (widget.listing.favoritesCount != null)
            Expanded(
              child: _OwnerStat(
                label: tr('listing.favorites', 'Sevimli'),
                value: widget.listing.favoritesCount.toString(),
                color: textColor,
                mutedColor: mutedColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPublicActions(Color textColor, bool isDark) {
    if (_expired) {
      // Предложение на просроченное сервер отклонит — кнопки нет совсем.
      // Написать владельцу можно: чат открывается по пользователю, а не
      // по объявлению. Кнопка нейтральная, без брендового цвета.
      return _ActionButton(
        label: tr('common.message', 'Mesaj'),
        icon: PhosphorIconsRegular.chatCircle,
        background: isDark ? WawatDark.surfaceAlt : const Color(0xFFF1F5F9),
        color: isDark ? WawatDark.textSecondary : const Color(0xFF475569),
        onTap: widget.onMessageTap == null
            ? null
            : () => widget.onMessageTap!(widget.listing),
      );
    }
    final offerDisabled = _readonly;
    final ctaBackground = offerDisabled
        ? (isDark ? WawatDark.surfaceAlt : const Color(0xFFEDF1F5))
        : _isTrip
            ? (isDark ? WawatDark.brand : const Color(0xFF0271EB))
            : const Color(0xFFF59E0B);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _ActionButton(
            label: offerDisabled
                ? (widget.listing.statusLabel ??
                    tr('listing.no_space', 'Yer yoxdur'))
                : tr('listing.send_offer', 'Təklif göndər'),
            icon: offerDisabled
                ? PhosphorIconsBold.prohibit
                : PhosphorIconsBold.paperPlaneTilt,
            background: ctaBackground,
            color: offerDisabled
                ? (isDark ? WawatDark.textMuted : const Color(0xFF94A3B8))
                : Colors.white,
            onTap: offerDisabled || widget.onOfferTap == null
                ? null
                : () => widget.onOfferTap!(widget.listing),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _ActionButton(
            label: tr('common.message', 'Mesaj'),
            icon: PhosphorIconsRegular.chatCircle,
            background: _accentSoftOf(isDark),
            color: _accentOf(isDark),
            onTap: widget.onMessageTap == null
                ? null
                : () => widget.onMessageTap!(widget.listing),
          ),
        ),
      ],
    );
  }

  List<Widget> _ownerActionButtons(bool isDark) {
    final listing = widget.listing;
    return [
      if (listing.canBePaused)
        _ActionButton(
          label: tr('listing.pause', 'Dayandır'),
          icon: PhosphorIconsBold.pause,
          background: _accentSoftOf(isDark),
          color: _accentOf(isDark),
          onTap: widget.onPauseTap == null
              ? null
              : () => widget.onPauseTap!(listing),
        ),
      if (listing.canBeResumed)
        _ActionButton(
          label: tr('listing.activate', 'Aktiv et'),
          icon: PhosphorIconsFill.arrowClockwise,
          background: _accentSoftOf(isDark),
          color: _accentOf(isDark),
          onTap: widget.onResumeTap == null
              ? null
              : () => widget.onResumeTap!(listing),
        ),
      if (listing.canBeReposted)
        _ActionButton(
          label: tr('listing.repost', 'Repost'),
          icon: PhosphorIconsBold.arrowClockwise,
          background: isDark ? WawatDark.brandChip : const Color(0xFFEAF3FE),
          color: isDark ? WawatDark.brandText : const Color(0xFF0271EB),
          onTap: widget.onRepostTap == null
              ? null
              : () => widget.onRepostTap!(listing),
        ),
      if (listing.status != 'deleted')
        _ActionButton(
          label: tr('common.delete', 'Sil'),
          icon: PhosphorIconsRegular.trash,
          background:
              isDark ? WawatDark.dangerSoftBg : const Color(0xFFFEE2E2),
          color: isDark ? WawatDark.dangerText : const Color(0xFFDC2626),
          onTap: widget.onDeleteTap == null
              ? null
              : () => widget.onDeleteTap!(listing),
        ),
    ];
  }

  Widget _buildOwnerActions(List<Widget> actions) {
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: actions[i]),
        ],
      ],
    );
  }

  Widget _buildPromotionActions(
    Color textColor,
    Color mutedColor,
    Map<String, String> content,
    bool isDark,
  ) {
    final promotion = widget.listing.promotion;
    final promotionType = promotion?.type ?? widget.listing.promotionType;
    final isVip = promotionType == 'vip';
    final isFeatured = promotionType == 'featured';
    final canPromote = widget.listing.canBePromoted;
    final canBoost = widget.listing.canBuyBoost;

    if (promotionType == null || promotionType.isEmpty) {
      if (!canPromote) return const SizedBox.shrink();
      return Column(
        children: [
          if (widget.listing.status == 'moderation')
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: isDark ? cFill(true) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                WawatContent.text(
                  content,
                  'promotion.pending_activation_note',
                  'Promosyon indi alına bilər — elan təsdiqlənən kimi avtomatik aktivləşəcək.',
                ),
                style: TextStyle(
                  color: isDark ? cText2(true) : const Color(0xFF64748B),
                  fontSize: 11,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: WawatContent.text(
                    content,
                    'promotion.cta.vip',
                    'VİP et',
                  ),
                  icon: PhosphorIconsFill.crownSimple,
                  background: isDark ? WawatDark.gold : const Color(0xFFFBBF24),
                  color: isDark ? WawatDark.onGold : const Color(0xFF0F172A),
                  onTap: widget.onVipTap == null
                      ? null
                      : () => widget.onVipTap!(widget.listing),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: WawatContent.text(
                    content,
                    'promotion.cta.boost',
                    'Önə çək',
                  ),
                  icon: PhosphorIconsFill.rocketLaunch,
                  background:
                      isDark ? WawatDark.brand : const Color(0xFF0271EB),
                  color: Colors.white,
                  onTap: widget.onBoostTap == null
                      ? null
                      : () => widget.onBoostTap!(widget.listing),
                ),
              ),
            ],
          ),
        ],
      );
    }

    final remaining = _promotionRemaining(promotion);
    final accent = isVip
        ? (isDark ? WawatDark.gold : const Color(0xFFFBBF24))
        : (isDark ? WawatDark.brand : const Color(0xFF0271EB));
    final accentTint = isVip
        ? (isDark ? WawatDark.goldSoftText : const Color(0xFFB45309))
        : (isDark ? WawatDark.brandText : const Color(0xFF0271EB));
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: accent.withValues(alpha: 0.30)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    isVip
                        ? PhosphorIconsFill.crownSimple
                        : PhosphorIconsFill.rocketLaunch,
                    color: accentTint,
                    size: 18,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      isVip
                          ? WawatContent.text(
                              content,
                              'promotion.vip_active',
                              'VİP aktiv',
                            )
                          : '${WawatContent.text(content, 'enum.promotion_type.featured', 'Önə çıxarılan')}${promotion?.tierLabel == null ? '' : ' · ${promotion!.tierLabel}'}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    remaining,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 5,
                  value: _listingPromotionProgress(promotion),
                  color: accent,
                  backgroundColor: isDark ? cBorder(true) : Colors.white,
                ),
              ),
            ],
          ),
        ),
        if (canPromote) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: WawatContent.text(
                    content,
                    'promotion.cta.extend',
                    'Uzat',
                  ),
                  icon: PhosphorIconsFill.clockCounterClockwise,
                  background: accent,
                  color: isVip
                      ? (isDark ? WawatDark.onGold : const Color(0xFF0F172A))
                      : Colors.white,
                  onTap: widget.onPromotionExtendTap == null
                      ? null
                      : () => widget.onPromotionExtendTap!(widget.listing),
                ),
              ),
              if (canBoost) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: isFeatured
                        ? WawatContent.text(
                            content,
                            'promotion.cta.upgrade_tier',
                            'Zolağı yüksəlt',
                          )
                        : WawatContent.text(
                            content,
                            'promotion.cta.boost',
                            'Önə çək',
                          ),
                    icon: PhosphorIconsBold.arrowUp,
                    background: isDark ? cFill(true) : const Color(0xFFF8FAFC),
                    color: isDark ? cText2(true) : const Color(0xFF334155),
                    onTap: widget.onBoostTap == null
                        ? null
                        : () => widget.onBoostTap!(widget.listing),
                  ),
                ),
              ],
            ],
          ),
          if (!isVip && widget.listing.canBuyVip) ...[
            const SizedBox(height: 10),
            _ActionButton(
              label: WawatContent.text(content, 'promotion.cta.vip', 'VİP et'),
              icon: PhosphorIconsFill.crownSimple,
              background: isDark ? WawatDark.gold : const Color(0xFFFBBF24),
              color: isDark ? WawatDark.onGold : const Color(0xFF0F172A),
              onTap: widget.onVipTap == null
                  ? null
                  : () => widget.onVipTap!(widget.listing),
            ),
          ],
        ],
      ],
    );
  }

  String _promotionRemaining(ListingPromotion? promotion) {
    if (promotion == null) return '';
    var seconds = promotion.remainingSeconds ?? 0;
    if (seconds <= 0 && promotion.endsAt != null) {
      final end = DateTime.tryParse(promotion.endsAt!)?.toLocal();
      if (end != null) {
        seconds = end.difference(DateTime.now()).inSeconds;
      }
    }
    if (seconds <= 0) return promotion.statusLabel ?? '';
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    if (days > 0) {
      return tr('listing.remaining_days_hours', '{days} gün {hours} saat',
          {'days': '$days', 'hours': '$hours'});
    }
    if (hours > 0) {
      return tr('listing.remaining_hours', '{hours} saat', {'hours': '$hours'});
    }
    final minutes = (seconds % 3600) ~/ 60;
    return tr(
        'listing.remaining_minutes', '{minutes} dəq', {'minutes': '$minutes'});
  }

  double _listingPromotionProgress(ListingPromotion? promotion) {
    if (promotion == null ||
        promotion.startsAt == null ||
        promotion.endsAt == null) {
      return 0;
    }
    final start = DateTime.tryParse(promotion.startsAt!)?.toLocal();
    final end = DateTime.tryParse(promotion.endsAt!)?.toLocal();
    if (start == null || end == null) return 0;
    final total = end.difference(start).inSeconds;
    if (total <= 0) return 1;
    final elapsed = DateTime.now().difference(start).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  Widget _buildExpandButton(bool isDark) {
    final accent = _accentOf(isDark);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: SizedBox(
          height: 42,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isExpanded
                    ? tr('common.collapse', 'Yığ')
                    : tr('common.expand', 'Ətraflı'),
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 160),
                child: Icon(
                  PhosphorIconsRegular.caretDown,
                  color: accent,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (_isFavoriteBusy) return;

    final previous = _isFavorited;
    final next = !previous;
    setState(() {
      _isFavorited = next;
      _isFavoriteBusy = true;
    });

    try {
      await widget.onFavoriteChanged?.call(widget.listing, next);
    } catch (_) {
      if (mounted) {
        setState(() => _isFavorited = previous);
      }
    } finally {
      if (mounted) {
        setState(() => _isFavoriteBusy = false);
      }
    }
  }

  String _dateText(BuildContext context) {
    if (_isTrip) {
      final date = _formatDate(context, widget.listing.flightDate);
      final time = _formatTime(widget.listing.flightTime);
      if (date != null && time != null) return '$date · $time';
      return date ?? time ?? '-';
    }

    final from = _formatDate(context, widget.listing.deliveryDateFrom);
    final to = _formatDate(context, widget.listing.deliveryDateTo);
    if (from != null && to != null) return '$from - $to';
    return from ?? to ?? '-';
  }

  String? _formatDate(BuildContext context, String? value) {
    if (value == null || value.isEmpty) return null;
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat('d MMM', locale).format(date);
  }

  String? _formatTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final raw = value.trim();
    final dt = DateTime.tryParse(raw);
    if (dt != null) {
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    }
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw);
    if (match != null) {
      return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
    }
    return raw;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  IconData _packageIcon(String code) {
    switch (code) {
      case 'documents':
        return PhosphorIconsFill.fileText;
      case 'small_parcel':
        return PhosphorIconsRegular.cube;
      case 'electronics':
        return PhosphorIconsRegular.deviceMobile;
      case 'clothing':
        return PhosphorIconsRegular.shoppingBag;
      case 'food':
        return PhosphorIconsRegular.forkKnife;
      default:
        return PhosphorIconsRegular.dotsThreeCircle;
    }
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'W';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}

class _RouteCity extends StatelessWidget {
  final String city;
  final Color color;
  final Color mutedColor;
  final TextAlign align;

  const _RouteCity({
    required this.city,
    required this.color,
    required this.mutedColor,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      city,
      textAlign: align,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color,
        fontSize: 21,
        height: 1.1,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  final Color accent;
  final Color softAccent;
  final bool isTrip;
  final bool isDark;

  /// Просроченное объявление: в тёмной теме точки и пунктир тоже серые —
  /// синий конец маршрута выглядел бы «живым» на приглушённой карточке.
  /// В светлой теме они и так берут приглушённый [accent].
  final bool muted;

  const _RouteLine({
    required this.accent,
    required this.softAccent,
    required this.isTrip,
    required this.isDark,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final brandDots = isDark && isTrip && !muted;
    final dotColor = brandDots ? WawatDark.brandTextStrong : accent;
    final dashColor = isDark
        ? (brandDots
            ? WawatDark.brandTextStrong.withValues(alpha: 0.40)
            : accent.withValues(alpha: 0.40))
        : accent.withValues(alpha: 0.28);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RouteDot(color: dotColor, isOutlined: false, isDark: isDark),
        _DashedLine(color: dashColor),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: softAccent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isTrip ? PhosphorIconsFill.airplaneTilt : PhosphorIconsFill.package,
            color: accent,
            size: 17,
          ),
        ),
        _DashedLine(color: dashColor),
        _RouteDot(
          color: dotColor,
          isOutlined: true,
          isDark: isDark,
          muted: muted,
        ),
      ],
    );
  }
}

class _RouteDot extends StatelessWidget {
  final Color color;
  final bool isOutlined;
  final bool isDark;
  final bool muted;

  const _RouteDot({
    required this.color,
    required this.isOutlined,
    required this.isDark,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final outlineFill = isDark ? cCard(true) : Colors.white;
    final outlineRing = isDark && !muted ? WawatDark.focusRing : color;
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: isOutlined ? outlineFill : color,
        shape: BoxShape.circle,
        border: isOutlined ? Border.all(color: outlineRing, width: 2) : null,
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  final Color color;

  const _DashedLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16, 1),
      painter: _DashedLinePainter(color),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    var start = 0.0;
    while (start < size.width) {
      canvas.drawLine(Offset(start, 0), Offset(start + 4, 0), paint);
      start += 7;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color textColor;
  final Color mutedColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: mutedColor, size: 17),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            color: mutedColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color mutedColor;

  const _OwnerStat({
    required this.label,
    required this.value,
    required this.color,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: mutedColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.6 : 1,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 17),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
