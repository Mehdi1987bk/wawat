import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/response/chat_response.dart';
import '../../../../../presentation/bloc/base_screen.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/wawat_content.dart';
import 'deal_detail_screen.dart';
import 'deals_list_bloc.dart';
import 'widgets/deal_card.dart';
import 'widgets/deal_status.dart';

class DealsListScreen extends BaseScreen<DealsListBloc> {
  DealsListScreen({super.key});

  @override
  State<DealsListScreen> createState() => _DealsListScreenState();
}

class _DealsListScreenState extends BaseState<DealsListScreen, DealsListBloc> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 180) {
      bloc.loadMore();
    }
  }

  @override
  DealsListBloc provideBloc() => DealsListBloc();

  @override
  Color? backgroundColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? WawatDark.bg : dealScreenBg;
  }

  @override
  bool get showProgressIndicator => false;

  @override
  PreferredSizeWidget appBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? WawatDark.surface : Colors.white,
      surfaceTintColor: isDark ? WawatDark.surface : Colors.white,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 56,
      automaticallyImplyLeading: false,
      titleSpacing: 10,
      title: StreamBuilder<DealsListState>(
        stream: bloc.state,
        initialData: bloc.value,
        builder: (context, snapshot) {
          final content = snapshot.data?.content ?? const {};
          return Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(PhosphorIconsBold.caretLeft,
                      color: isDark ? WawatDark.icon : dealInk700, size: 23),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  WawatContent.text(content, 'deals.title', 'Sövdələşmələrim'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? WawatDark.textPrimary : dealInk900,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _toast(
                  WawatContent.text(content, 'common.coming_soon', 'Tezliklə aktiv olacaq.'),
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? WawatDark.surfaceAlt
                        : dealInk900.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(PhosphorIconsRegular.magnifyingGlass,
                      color: isDark ? WawatDark.iconMuted : dealInk500, size: 18),
                ),
              ),
            ],
          );
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
            height: 1,
            color: isDark ? WawatDark.divider : dealInk900.withValues(alpha: 0.06)),
      ),
    );
  }

  @override
  Widget body() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: isDark ? WawatDark.bg : dealScreenBg,
      child: StreamBuilder<DealsListState>(
        stream: bloc.state,
        initialData: bloc.value,
        builder: (context, snapshot) {
          final state = snapshot.data ?? const DealsListState.initial();
          return Column(
            children: [
              _TabsAndFilters(state: state, bloc: bloc),
              Expanded(child: _buildContent(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(DealsListState state) {
    if (state.loading && state.items.isEmpty) {
      return const _DealsSkeleton();
    }
    if (state.error != null && state.items.isEmpty) {
      return _LoadError(content: state.content, onRetry: bloc.loadInitial);
    }
    if (state.items.isEmpty) {
      return _EmptyState(content: state.content);
    }
    return RefreshIndicator(
      color: dealBrand,
      onRefresh: bloc.loadInitial,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: state.items.length + (state.loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: dealBrand),
                ),
              ),
            );
          }
          final shipment = state.items[index];
          return DealCard(
            shipment: shipment,
            content: state.content,
            onTap: () => _openDetail(shipment),
          );
        },
      ),
    );
  }

  Future<void> _openDetail(ShipmentData shipment) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DealDetailScreen(shipmentId: shipment.id)),
    );
    if (mounted) bloc.loadInitial();
  }

  void _toast(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? WawatDark.elevated : dealInk900,
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }
}

class _TabsAndFilters extends StatelessWidget {
  final DealsListState state;
  final DealsListBloc bloc;

  const _TabsAndFilters({required this.state, required this.bloc});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? WawatDark.surfaceAlt
                : dealInk900.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: _TabSegment(
                  label: WawatContent.text(state.content, 'deals.tab.active', 'Aktiv'),
                  count: state.counts.active,
                  selected: state.tab == 'active',
                  onTap: () => bloc.setTab('active'),
                ),
              ),
              Expanded(
                child: _TabSegment(
                  label: WawatContent.text(state.content, 'deals.tab.history', 'Tarixçə'),
                  count: state.counts.history,
                  selected: state.tab == 'history',
                  onTap: () => bloc.setTab('history'),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _RoleFilterChip(
                  label: WawatContent.text(state.content, 'deals.filter.all', 'Hamısı'),
                  selected: state.role == null,
                  onTap: () => bloc.setRole(null),
                ),
                const SizedBox(width: 8),
                _RoleFilterChip(
                  label: WawatContent.text(state.content, 'deals.filter.sender', 'Göndərən kimi'),
                  selected: state.role == 'sender',
                  onTap: () => bloc.setRole('sender'),
                ),
                const SizedBox(width: 8),
                _RoleFilterChip(
                  label: WawatContent.text(state.content, 'deals.filter.carrier', 'Daşıyıcı kimi'),
                  selected: state.role == 'carrier',
                  onTap: () => bloc.setRole('carrier'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TabSegment extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _TabSegment({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? WawatDark.surface : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: (selected && !isDark)
              ? [BoxShadow(color: dealInk900.withValues(alpha: 0.08), blurRadius: 6)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? dealBrand : (isDark ? WawatDark.textMuted : dealInk500),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? dealBrand.withValues(alpha: 0.15)
                      : (isDark
                          ? WawatDark.surfaceAlt
                          : dealInk900.withValues(alpha: 0.06)),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? dealBrand : (isDark ? WawatDark.textMuted : dealInk500),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoleFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleFilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? WawatDark.elevated : dealInk900)
              : (isDark ? WawatDark.surface : Colors.white),
          borderRadius: BorderRadius.circular(999),
          border: (!selected && isDark) ? Border.all(color: WawatDark.border) : null,
          boxShadow: (selected || isDark)
              ? null
              : [BoxShadow(color: dealInk900.withValues(alpha: 0.06), blurRadius: 4)],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : (isDark ? WawatDark.textSecondary : dealInk600),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Map<String, String> content;

  const _EmptyState({required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                  color: isDark ? WawatDark.brandSoft : dealBrand50,
                  shape: BoxShape.circle),
              child: const Icon(PhosphorIconsFill.handshake, color: dealBrand, size: 44),
            ),
            const SizedBox(height: 20),
            Text(
              WawatContent.text(content, 'deals.empty.title', 'Hələ sövdələşməniz yoxdur'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isDark ? WawatDark.textPrimary : dealInk900,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              WawatContent.text(
                content,
                'deals.empty.body',
                'Bir elana təklif göndərin və ya birbaşa söhbətdə razılaşın — sövdələşmələr burada görünəcək.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isDark ? WawatDark.textMuted : dealInk500,
                  fontSize: 13.5,
                  height: 1.4,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: dealBrand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(PhosphorIconsFill.compass, size: 18),
                label: Text(
                  WawatContent.text(content, 'deals.empty.cta', 'Elanlara bax'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: Text(
                WawatContent.text(content, 'deals.how_it_works', 'Necə işləyir?'),
                style: const TextStyle(color: dealBrand, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final Map<String, String> content;
  final VoidCallback onRetry;

  const _LoadError({required this.content, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dealRed50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFEE2E2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(PhosphorIconsFill.wifiSlash, color: dealRed600, size: 22),
              const SizedBox(height: 8),
              Text(
                WawatContent.text(
                  content,
                  'deals.error.load',
                  'Yüklənmədi. İnternet bağlantısını yoxlayın.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: dealRed600, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: dealRed600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  WawatContent.text(content, 'deals.retry', 'Yenidən'),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DealsSkeleton extends StatelessWidget {
  const _DealsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: const [
        _SkeletonCard(),
        SizedBox(height: 12),
        _SkeletonCard(),
      ],
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.5 + _controller.value * 0.4;
        return Opacity(opacity: opacity, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? WawatDark.surface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? Border.all(color: WawatDark.border) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _bar(isDark, width: 110, height: 20, radius: 999),
                _bar(isDark, width: 60, height: 20, radius: 999),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _bar(isDark, width: 70, height: 22),
                _bar(isDark, width: 24, height: 24, radius: 999),
                _bar(isDark, width: 70, height: 22),
              ],
            ),
            const SizedBox(height: 16),
            _bar(isDark, width: double.infinity, height: 32, radius: 14),
          ],
        ),
      ),
    );
  }

  Widget _bar(bool isDark, {required double width, required double height, double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: isDark ? WawatDark.surfaceAlt : dealInk100,
          borderRadius: BorderRadius.circular(radius)),
    );
  }
}
