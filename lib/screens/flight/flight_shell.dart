import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../presentation/resourses/theme_colors.dart';
import 'flight_routes.dart';
import 'flight_text.dart';
import 'ui/flight_tokens.dart';
import 'ui/flight_widgets.dart';

/// Пять разделов модуля. Панель-переключатель (`mbar`) есть только на их
/// корневых экранах — на остальных путь назад один, стрелкой.
enum FlightSection { map, search, airports, watch, more }

/// Каркас экрана раздела.
///
/// Небо прокручивается вверх под закреплённой шапкой того же цвета — так в
/// прототипе. Шапка закреплена ради строки состояния телефона: иначе под
/// часами проезжал бы светлый контент.
class FlightScaffold extends StatelessWidget {
  const FlightScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.hero,
    this.actions = const [],
    this.onBack,
    this.section,
    this.stale,
    this.slivers = const [],
    this.bottom,
    this.controller,
    this.backIcon = PhosphorIconsBold.arrowLeft,
    this.showBack,
    this.bottomInset = 0,
  });

  final String title;
  final String? subtitle;

  /// Содержимое неба под шапкой.
  final Widget? hero;

  final List<FSkyAction> actions;
  final VoidCallback? onBack;

  /// Если задан — показывается панель разделов, закреплённая сверху.
  final FlightSection? section;

  /// Текст полоски «данные на …» (§4.2). Не ошибка.
  final String? stale;

  final List<Widget> slivers;

  /// Кнопка внизу. Отступ ОС резервируется здесь, экранам об этом думать
  /// не нужно.
  final Widget? bottom;

  final ScrollController? controller;
  final IconData backIcon;

  /// Показывать ли стрелку назад. По умолчанию решает история навигации, но
  /// корню раздела, открытому вкладкой нижнего меню, возвращаться некуда:
  /// стрелка там увела бы человека из всего приложения.
  final bool? showBack;

  /// Запас снизу: когда раздел открыт вкладкой, поверх него лежит нижнее меню
  /// приложения, и последняя карточка иначе уезжает под него.
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final canBack =
        showBack ?? (onBack != null || Navigator.of(context).canPop());
    return Scaffold(
      backgroundColor: cScreen(d),
      body: CustomScrollView(
        controller: controller,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: FT.hero(d),
            surfaceTintColor: FT.hero(d),
            elevation: 0,
            scrolledUnderElevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            automaticallyImplyLeading: false,
            // Явно: на iOS Material центрирует заголовок, если действий меньше
            // двух, а тёмная тема приложения это переопределяет своей
            // `appBarTheme`. Без этой строки одна и та же шапка выходит по
            // центру в светлой теме и слева в тёмной. В макете — слева.
            centerTitle: false,
            titleSpacing: 0,
            toolbarHeight: 52,
            leading: canBack
                ? Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: _round(
                      backIcon,
                      onBack ?? () => Navigator.of(context).maybePop(),
                    ),
                  )
                : const SizedBox(width: 16),
            leadingWidth: canBack ? 60 : 16,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: FT.onHero(.65),
                    ),
                  ),
              ],
            ),
            actions: [
              for (final a in actions)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _round(a.icon, a.onTap, active: a.active),
                ),
              const SizedBox(width: 8),
            ],
          ),
          if (hero != null)
            SliverToBoxAdapter(child: FSky(child: hero!)),
          if (section != null)
            SliverPersistentHeader(
              pinned: true,
              delegate: _ChipBarHeader(
                section: section!,
                background: cScreen(d),
              ),
            ),
          if (stale != null) SliverToBoxAdapter(child: FStaleLine(stale!)),
          ...slivers,
          SliverToBoxAdapter(
            child: SizedBox(height: (bottom == null ? 28 : 12) + bottomInset),
          ),
        ],
      ),
      bottomNavigationBar: bottom == null
          ? null
          : Container(
              decoration: BoxDecoration(
                color: cBar(d),
                border: Border(top: BorderSide(color: cLine(d))),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: bottom,
                ),
              ),
            ),
    );
  }

  Widget _round(IconData icon, VoidCallback onTap, {bool active = false}) =>
      InkWell(
        onTap: onTap,
        borderRadius: FT.rPill,
        child: Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Colors.white : Colors.white.withValues(alpha: .14),
          ),
          alignment: Alignment.center,
          child: Icon(icon,
              size: 17, color: active ? const Color(0xFF0257AE) : Colors.white),
        ),
      );
}

class _ChipBarHeader extends SliverPersistentHeaderDelegate {
  _ChipBarHeader({required this.section, required this.background});

  final FlightSection section;

  /// Нужен только для [shouldRebuild]: при смене темы создаётся новый
  /// делегат с тем же разделом, и без этой проверки панель осталась бы в
  /// старых цветах.
  final Color background;

  static const _height = 52.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return SizedBox(
      height: _height,
      child: FChipBar(
        activeIndex: FlightSection.values.indexOf(section),
        items: [
          FChipBarItem(
            icon: PhosphorIconsRegular.globeHemisphereEast,
            label: ft('section_map', 'Xəritə'),
            onTap: () => FlightNav.section(context, FlightSection.map),
          ),
          FChipBarItem(
            icon: PhosphorIconsFill.magnifyingGlass,
            label: ft('section_search', 'Axtarış'),
            onTap: () => FlightNav.section(context, FlightSection.search),
          ),
          FChipBarItem(
            icon: PhosphorIconsRegular.buildings,
            label: ft('section_airports', 'Limanlar'),
            onTap: () => FlightNav.section(context, FlightSection.airports),
          ),
          FChipBarItem(
            icon: PhosphorIconsRegular.bellRinging,
            label: ft('section_watch', 'İzləmə'),
            onTap: () => FlightNav.section(context, FlightSection.watch),
          ),
          FChipBarItem(
            icon: PhosphorIconsRegular.dotsThreeCircle,
            label: ft('section_more', 'Daha çox'),
            onTap: () => FlightNav.section(context, FlightSection.more),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_ChipBarHeader old) =>
      old.section != section || old.background != background;
}

/// Содержимое экрана с отступами прототипа: 16 по бокам, 18 сверху.
class FlightBody extends StatelessWidget {
  const FlightBody({
    super.key,
    required this.children,
    this.gap = 14,
    this.padding = const EdgeInsets.fromLTRB(16, 18, 16, 0),
  });

  final List<Widget> children;
  final double gap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) items.add(SizedBox(height: gap));
    }
    return SliverPadding(
      padding: padding,
      sliver: SliverList(
        delegate: SliverChildListDelegate(items),
      ),
    );
  }
}
