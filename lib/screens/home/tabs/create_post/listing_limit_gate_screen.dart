import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../data/network/response/listing_response.dart';
import '../../../../data/network/response/user.dart';
import '../../../../presentation/bloc/base_screen.dart';
import '../../../../presentation/resourses/wawat_dark.dart';
import '../../../../services/wawat_content.dart';
import '../profile_tab/see_more_offers/delivery_full_list_screen.dart';
import 'create_post_screen.dart';
import 'listing_limit_gate_bloc.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _amber = Color(0xFFF59E0B);
const _amber50 = Color(0xFFFFF7ED);
const _ink900 = Color(0xFF0F172A);
const _ink800 = Color(0xFF1E293B);
const _ink700 = Color(0xFF334155);
const _ink600 = Color(0xFF475569);
const _ink500 = Color(0xFF64748B);
const _emerald = Color(0xFF059669);

class ListingLimitGateScreen extends BaseScreen<ListingLimitGateBloc> {
  final String type;
  final ListingQuotaItem quota;

  ListingLimitGateScreen({
    super.key,
    required this.type,
    required this.quota,
  });

  @override
  State<ListingLimitGateScreen> createState() => _ListingLimitGateScreenState();
}

class _ListingLimitGateScreenState
    extends BaseState<ListingLimitGateScreen, ListingLimitGateBloc> {
  Map<String, String> _content = const {};

  bool get _isTrip => widget.type == 'trip';

  @override
  bool get showProgressIndicator => false;

  @override
  void initState() {
    super.initState();
    bloc.load(widget.type);
    WawatContent.loadDefault().then((content) {
      if (mounted) setState(() => _content = content);
    });
  }

  String _t(String key, [String? fallback]) {
    return WawatContent.text(_content, key, fallback);
  }

  @override
  Widget body() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? WawatDark.bg : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              title: _isTrip
                  ? _t('limit.trip_new_title')
                  : _t('limit.shipment_new_title'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  children: [
                    _Hero(
                      isTrip: _isTrip,
                      quota: widget.quota,
                      content: _content,
                    ),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _isTrip
                            ? _t('limit.active_trip_list')
                            : _t(
                                'limit.active_shipment_list',
                              ),
                        style: TextStyle(
                          color: isDark ? WawatDark.textMuted : _ink500,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<Map<String, String>>(
                      stream: bloc.listingContent,
                      initialData: const {},
                      builder: (context, contentSnapshot) {
                        final content = contentSnapshot.data ?? const {};
                        return StreamBuilder<List<Listing>>(
                          stream: bloc.activeListings,
                          builder: (context, snapshot) {
                            final listings = snapshot.data;
                            if (listings == null) {
                              return const _LoadingList();
                            }
                            if (listings.isEmpty) {
                              return _EmptyList(content: _content);
                            }
                            return Column(
                              children: listings
                                  .map(
                                    (listing) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: _ActiveListingTile(
                                        listing: listing,
                                        isTrip: _isTrip,
                                        content: content,
                                        onPause: () => _pause(listing),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 2),
                    _InfoBox(content: _content),
                  ],
                ),
              ),
            ),
            _BottomCta(onTap: _openMyListings, content: _content),
            StreamBuilder<bool>(
              stream: bloc.isPausing,
              initialData: false,
              builder: (context, snapshot) {
                if (snapshot.data != true) return const SizedBox.shrink();
                return LinearProgressIndicator(
                  minHeight: 2,
                  color: _brand,
                  backgroundColor: isDark ? WawatDark.brandChip : _brand50,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pause(Listing listing) async {
    await bloc.pause(listing, widget.type);
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CreatePostScreen(initialType: widget.type),
      ),
    );
  }

  void _openMyListings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DeliveryFullListScreen()),
    );
  }

  @override
  ListingLimitGateBloc provideBloc() => ListingLimitGateBloc();
}

class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: isDark ? WawatDark.divider : const Color(0x0F0F172A))),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Navigator.of(context).maybePop(),
            child: Icon(PhosphorIconsBold.x,
                color: isDark ? WawatDark.icon : _ink700, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDark ? WawatDark.textPrimary : _ink900,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final bool isTrip;
  final ListingQuotaItem quota;
  final Map<String, String> content;

  const _Hero({
    required this.isTrip,
    required this.quota,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final noun = isTrip
        ? WawatContent.text(content, 'limit.noun_trip')
        : WawatContent.text(content, 'limit.noun_shipment');
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? WawatDark.warningBg : _amber50,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(PhosphorIconsFill.stack,
              color: isDark ? WawatDark.warning : _amber, size: 38),
        ),
        const SizedBox(height: 16),
        Text(
          WawatContent.text(
            content,
            isTrip ? 'limit.trip_title' : 'limit.shipment_title',
          ).replaceAll('{noun}', noun),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? WawatDark.textPrimary : _ink900,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 330),
          child: Text.rich(
            TextSpan(
              text: '${quota.active}/${quota.limit} aktiv $noun elanın var. '
                  '${WawatContent.text(content, 'limit.subtitle_middle')}',
              children: [
                TextSpan(
                  text: WawatContent.text(content, 'limit.pause_word'),
                  style: TextStyle(
                      color: isDark ? WawatDark.textPrimary : _ink800,
                      fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: WawatContent.text(
                    content,
                    'limit.subtitle_suffix',
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? WawatDark.textSecondary : _ink500,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveListingTile extends StatelessWidget {
  final Listing listing;
  final bool isTrip;
  final Map<String, String> content;
  final VoidCallback onPause;

  const _ActiveListingTile({
    required this.listing,
    required this.isTrip,
    required this.content,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = isTrip ? listing.flightDate : listing.deliveryDateFrom;
    final status = listing.statusLabel ??
        content['enum.listing_status.${listing.status}'] ??
        'Aktiv';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? WawatDark.border : const Color(0x0F0F172A)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? WawatDark.brandSoft : _brand50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isTrip
                  ? PhosphorIconsFill.airplaneTilt
                  : PhosphorIconsFill.package,
              color: isDark ? WawatDark.brandText : _brand,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${listing.cityFrom ?? WawatContent.text(content, 'search.from_placeholder')} → ${listing.cityTo ?? WawatContent.text(content, 'search.to_placeholder')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? WawatDark.textPrimary : _ink900,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(PhosphorIconsFill.circle,
                        color: isDark ? WawatDark.success : _emerald, size: 5),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        '$status${date == null ? '' : ' · ${_formatDate(date)}'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? WawatDark.success : _emerald,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onPause,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? WawatDark.surfaceAlt
                    : _ink900.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIconsBold.pause,
                      color: isDark ? WawatDark.icon : _ink700, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    WawatContent.text(content, 'common.pause'),
                    style: TextStyle(
                      color: isDark ? WawatDark.textSecondary : _ink700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final Map<String, String> content;

  const _InfoBox({required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.brandSoft : _brand50.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIconsFill.info,
              color: isDark ? WawatDark.brandText : _brand, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              WawatContent.text(
                content,
                'limit.pause_info',
              ),
              style: TextStyle(
                color: isDark ? WawatDark.textSecondary : _ink600,
                fontSize: 11.5,
                height: 1.28,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  final VoidCallback onTap;
  final Map<String, String> content;

  const _BottomCta({required this.onTap, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surface : Colors.white,
        border: Border(
            top: BorderSide(
                color: isDark ? WawatDark.divider : const Color(0x0F0F172A))),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                isDark ? WawatDark.surfaceAlt : _ink900.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIconsBold.listBullets,
                  color: isDark ? WawatDark.icon : _ink700, size: 20),
              const SizedBox(width: 8),
              Text(
                WawatContent.text(
                  content,
                  'limit.view_all_my_listings',
                ),
                style: TextStyle(
                  color: isDark ? WawatDark.textSecondary : _ink700,
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

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: CircularProgressIndicator(color: _brand),
    );
  }
}

class _EmptyList extends StatelessWidget {
  final Map<String, String> content;

  const _EmptyList({required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surfaceAlt : _ink900.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        WawatContent.text(content, 'limit.empty_active'),
        style: TextStyle(
          color: isDark ? WawatDark.textMuted : _ink500,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _formatDate(String raw) {
  final date = DateTime.tryParse(raw);
  if (date == null) return raw;
  const months = [
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
  return '${date.day} ${months[date.month - 1]}';
}
