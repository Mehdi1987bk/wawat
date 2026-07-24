import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/response/listing_response.dart';
import '../../../../../services/wawat_content.dart';
import '../../profile_tab/new_profile/new_profile_screen.dart';

Future<Map<String, String>>? _listingContentFuture;

Future<Map<String, String>> _loadListingContent() {
  return _listingContentFuture ??= WawatContent.loadDefault();
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

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.listing.isFavorited;
    _contentFuture = _loadListingContent();
  }

  @override
  void didUpdateWidget(covariant ListingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listing.id != widget.listing.id ||
        oldWidget.listing.isFavorited != widget.listing.isFavorited) {
      _isFavorited = widget.listing.isFavorited;
      _isFavoriteBusy = false;
    }
  }

  bool get _isTrip => widget.listing.isTrip;

  Color get _accent =>
      _isTrip ? const Color(0xFF0271EB) : const Color(0xFFF59E0B);

  Color get _accentSoft =>
      _isTrip ? const Color(0xFFEAF3FE) : const Color(0xFFFFF7ED);

  String? get _promotionType =>
      widget.promotionTypeOverride ??
      widget.listing.promotion?.type ??
      widget.listing.promotionType;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor =
        isDark ? const Color(0xFFB8B8B8) : const Color(0xFF64748B);
    final borderColor =
        _promotionType == 'vip' ? const Color(0xFFF59E0B) : Colors.transparent;

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
                color: borderColor == Colors.transparent
                    ? (isDark ? Colors.white10 : const Color(0x0F0F172A))
                    : borderColor,
                width: _promotionType == 'vip' ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(textColor, mutedColor, content),
                const SizedBox(height: 16),
                _buildRoute(textColor, mutedColor),
                const SizedBox(height: 14),
                _buildMainMeta(textColor, mutedColor),
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
                if (widget.actionsEnabled) ...[
                  const SizedBox(height: 16),
                  widget.isOwner
                      ? _buildOwnerActions()
                      : _buildPublicActions(textColor),
                ],
                if (widget.isOwner &&
                    (widget.onVipTap != null ||
                        widget.onBoostTap != null ||
                        widget.onPromotionExtendTap != null)) ...[
                  const SizedBox(height: 14),
                  _buildPromotionActions(textColor, mutedColor, content),
                ],
                if (widget.isCompact) _buildExpandButton(),
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
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(
                icon: _isTrip
                    ? PhosphorIconsFill.airplaneTakeoff
                    : PhosphorIconsFill.package,
                label: widget.listing.typeLabel ??
                    content[
                        'enum.listing_type.${_isTrip ? 'trip' : 'shipment_post'}'] ??
                    (_isTrip ? 'Səfər' : 'Göndəriş'),
                color: _accent,
                background: _accentSoft,
              ),
              if (_promotionType == 'vip')
                _Badge(
                  icon: PhosphorIconsFill.sealCheck,
                  label: content['enum.promotion_type.vip'] ?? 'VİP',
                  color: const Color(0xFF0F172A),
                  background: const Color(0xFFFBBF24),
                ),
              if (_promotionType == 'featured')
                _Badge(
                  icon: PhosphorIconsFill.rocketLaunch,
                  label: content['enum.promotion_type.featured'] ??
                      'Önə çıxarılan',
                  color: const Color(0xFF024FA3),
                  background: const Color(0xFFCFE3FD),
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
        if (!widget.isOwner)
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _toggleFavorite,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(
                _isFavorited
                    ? PhosphorIconsFill.heart
                    : PhosphorIconsRegular.heart,
                color: _isFavorited ? _accent : mutedColor,
                size: 24,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRoute(Color textColor, Color mutedColor) {
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
        _RouteLine(accent: _accent, softAccent: _accentSoft, isTrip: _isTrip),
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

  Widget _buildMainMeta(Color textColor, Color mutedColor) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isTrip
                      ? PhosphorIconsFill.calendarDots
                      : PhosphorIconsRegular.calendarBlank,
                  color: _accent,
                  size: 18,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    _dateText(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Spacer(),
        if (_isTrip && widget.listing.pricePerKg != null) ...[
          const SizedBox(width: 12),
          Text.rich(
            TextSpan(
              text: _formatNumber(widget.listing.pricePerKg!),
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(
                  text: ' ₼',
                  style: TextStyle(fontSize: 18, color: textColor),
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
      ],
    );
  }

  Widget _buildDetails(Color textColor, Color mutedColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isTrip && widget.listing.maxWeightKg != null)
          _buildCapacity(textColor, mutedColor),
        if (!_isTrip && widget.listing.weightKg != null)
          _InfoRow(
            icon: PhosphorIconsRegular.scales,
            label: 'Çəki',
            value: '${_formatNumber(widget.listing.weightKg!)} kq',
            textColor: textColor,
            mutedColor: mutedColor,
          ),
        if (_isTrip && widget.listing.flightNumber != null) ...[
          const SizedBox(height: 10),
          _InfoRow(
            icon: PhosphorIconsRegular.ticket,
            label: 'Reys',
            value: widget.listing.flightNumber!,
            textColor: textColor,
            mutedColor: mutedColor,
          ),
        ],
        if (_isTrip && widget.listing.allowPriceNegotiation == true) ...[
          const SizedBox(height: 10),
          _Badge(
            icon: PhosphorIconsFill.handshake,
            label: 'Qiymət razılaşma ilə',
            color: _accent,
            background: _accentSoft,
          ),
        ],
        if (widget.listing.packageTypeCodes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children:
                widget.listing.packageTypeCodes.map(_buildPackageChip).toList(),
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

  Widget _buildCapacity(Color textColor, Color mutedColor) {
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
              'Boş yer',
              style: TextStyle(
                color: mutedColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${_formatNumber(free)} / ${_formatNumber(max)} kq',
              style: TextStyle(
                color: textColor,
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
            color: _accent,
            backgroundColor: const Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageChip(String code) {
    final label = widget.packageNamesByCode[code] ?? code;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF64748B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_packageIcon(code), color: const Color(0xFF64748B), size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
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
              color: isDark ? Colors.white10 : const Color(0x0F0F172A),
            ),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: _accentSoft,
              child: Text(
                initials,
                style: TextStyle(
                  color: _accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
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
                        const Icon(
                          PhosphorIconsFill.sealCheck,
                          color: Color(0xFF0271EB),
                          size: 16,
                        ),
                      ],
                      if (_tierLabel(owner.tier, content) != null) ...[
                        const SizedBox(width: 6),
                        _TierBadge(tier: owner.tier!, content: content),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (owner.ratingAvg != null) ...[
                        const Icon(PhosphorIconsFill.star,
                            color: Color(0xFFFBBF24), size: 15),
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
                          '~${owner.avgResponseMinutes} dəq cavab',
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
                label: 'Baxış',
                value: widget.listing.viewCount.toString(),
                color: textColor,
                mutedColor: mutedColor,
              ),
            ),
          if (widget.listing.favoritesCount != null)
            Expanded(
              child: _OwnerStat(
                label: 'Sevimli',
                value: widget.listing.favoritesCount.toString(),
                color: textColor,
                mutedColor: mutedColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPublicActions(Color textColor) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _ActionButton(
            label: 'Təklif göndər',
            icon: PhosphorIconsBold.paperPlaneTilt,
            background: _accent,
            color: Colors.white,
            onTap: widget.onOfferTap == null
                ? null
                : () => widget.onOfferTap!(widget.listing),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _ActionButton(
            label: 'Mesaj',
            icon: PhosphorIconsRegular.chatCircle,
            background: _accentSoft,
            color: _accent,
            onTap: widget.onMessageTap == null
                ? null
                : () => widget.onMessageTap!(widget.listing),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerActions() {
    final canResume = widget.listing.status == 'paused';
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: canResume ? 'Aktiv et' : 'Dayandır',
            icon: canResume
                ? PhosphorIconsFill.arrowClockwise
                : PhosphorIconsBold.pause,
            background: _accentSoft,
            color: _accent,
            onTap: canResume
                ? (widget.onResumeTap == null
                    ? null
                    : () => widget.onResumeTap!(widget.listing))
                : (widget.onPauseTap == null
                    ? null
                    : () => widget.onPauseTap!(widget.listing)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            label: 'Repost',
            icon: PhosphorIconsBold.arrowClockwise,
            background: const Color(0xFFEAF3FE),
            color: const Color(0xFF0271EB),
            onTap: widget.onRepostTap == null
                ? null
                : () => widget.onRepostTap!(widget.listing),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            label: 'Sil',
            icon: PhosphorIconsRegular.trash,
            background: const Color(0xFFFEE2E2),
            color: const Color(0xFFDC2626),
            onTap: widget.onDeleteTap == null
                ? null
                : () => widget.onDeleteTap!(widget.listing),
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionActions(
    Color textColor,
    Color mutedColor,
    Map<String, String> content,
  ) {
    final promotion = widget.listing.promotion;
    final promotionType = promotion?.type ?? widget.listing.promotionType;
    final isVip = promotionType == 'vip';
    final isFeatured = promotionType == 'featured';

    if (promotionType == null || promotionType.isEmpty) {
      return Column(
        children: [
          if (widget.listing.status == 'pending' ||
              widget.listing.status == 'in_moderation')
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                WawatContent.text(
                  content,
                  'promotion.pending_activation_note',
                  'Promosyon indi alına bilər — elan təsdiqlənən kimi avtomatik aktivləşəcək.',
                ),
                style: const TextStyle(
                  color: Color(0xFF64748B),
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
                  background: const Color(0xFFFBBF24),
                  color: const Color(0xFF0F172A),
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
                  background: const Color(0xFF0271EB),
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
    final accent = isVip ? const Color(0xFFFBBF24) : const Color(0xFF0271EB);
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
                    color: isVip ? const Color(0xFFB45309) : accent,
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
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
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
                color: isVip ? const Color(0xFF0F172A) : Colors.white,
                onTap: widget.onPromotionExtendTap == null
                    ? null
                    : () => widget.onPromotionExtendTap!(widget.listing),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                label: isVip
                    ? WawatContent.text(
                        content,
                        'promotion.cta.boost_too',
                        'Önə də çək',
                      )
                    : isFeatured
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
                icon: isVip
                    ? PhosphorIconsFill.rocketLaunch
                    : PhosphorIconsBold.arrowUp,
                background: const Color(0xFFF8FAFC),
                color: const Color(0xFF334155),
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
    if (days > 0) return '$days gün $hours saat';
    if (hours > 0) return '$hours saat';
    final minutes = (seconds % 3600) ~/ 60;
    return '$minutes dəq';
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

  Widget _buildExpandButton() {
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
                _isExpanded ? 'Yığ' : 'Ətraflı',
                style: TextStyle(
                  color: _accent,
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
                  color: _accent,
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

  /// Normalises any time-ish string to `HH:mm` (drops seconds).
  /// Handles full ISO datetimes, `HH:mm:ss`, `HH:mm` and `H:mm`.
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

  const _RouteLine({
    required this.accent,
    required this.softAccent,
    required this.isTrip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RouteDot(color: accent, isOutlined: false),
        _DashedLine(color: accent.withValues(alpha: 0.28)),
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
        _DashedLine(color: accent.withValues(alpha: 0.28)),
        _RouteDot(color: accent, isOutlined: true),
      ],
    );
  }
}

class _RouteDot extends StatelessWidget {
  final Color color;
  final bool isOutlined;

  const _RouteDot({
    required this.color,
    required this.isOutlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: isOutlined ? Colors.white : color,
        shape: BoxShape.circle,
        border: isOutlined ? Border.all(color: color, width: 2) : null,
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

class _TierBadge extends StatelessWidget {
  final String tier;
  final Map<String, String> content;

  const _TierBadge({
    required this.tier,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final style = _tierStyle(tier);
    final label = _tierLabel(tier, content);
    if (label == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: style.color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TierStyle {
  final Color background;
  final Color color;

  const _TierStyle(this.background, this.color);
}

_TierStyle _tierStyle(String tier) {
  switch (tier) {
    case 'new':
      return const _TierStyle(Color(0xFFDCFCE7), Color(0xFF15803D));
    case 'bronze':
      return const _TierStyle(Color(0xFFEFE1D0), Color(0xFF9A5B2A));
    case 'silver':
      return const _TierStyle(Color(0xFFF1F5F9), Color(0xFF475569));
    case 'gold':
      return const _TierStyle(Color(0xFFFEF3C7), Color(0xFFB45309));
    case 'platinum':
      return const _TierStyle(Color(0xFFE0E7FF), Color(0xFF4338CA));
    default:
      return const _TierStyle(Color(0xFFF1F5F9), Color(0xFF475569));
  }
}

String? _tierLabel(String? tier, Map<String, String> content) {
  if (tier == null || tier.trim().isEmpty) return null;
  final cmsLabel = content['enum.user_tier.$tier'];
  if (cmsLabel != null && cmsLabel.trim().isNotEmpty) return cmsLabel;
  switch (tier) {
    case 'new':
      return 'Yeni';
    case 'standard':
      return 'Standart';
    case 'bronze':
      return 'Bürünc';
    case 'silver':
      return 'Gümüş';
    case 'gold':
      return 'Qızıl';
    case 'platinum':
      return 'Platin';
    default:
      return tier;
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
