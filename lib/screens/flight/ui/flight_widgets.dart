import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../presentation/resourses/theme_colors.dart';
import 'flight_tokens.dart';

bool fDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

/// Всплывающее сообщение — как в остальном приложении.
void fToast(BuildContext context, String message) {
  final d = fDark(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: d ? cFill(d) : const Color(0xFF0F172A),
      content: Text(
        message,
        style: TextStyle(
          color: d ? cText(d) : Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    ),
  );
}

/// `.fcard` — основная карточка раздела.
class FCard extends StatelessWidget {
  const FCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final box = Container(
      decoration: BoxDecoration(
        color: cCard(d),
        borderRadius: FT.rCard,
        border: Border.all(color: cLine(d)),
        boxShadow: FT.cardShadow(d),
      ),
      clipBehavior: Clip.antiAlias,
      padding: padding,
      child: child,
    );
    if (onTap == null) return box;
    return InkWell(onTap: onTap, borderRadius: FT.rCard, child: box);
  }
}

/// Карточка-группа: строки [FListRow] без внешних отступов, с разделителями.
class FGroupCard extends StatelessWidget {
  const FGroupCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(Divider(height: 1, thickness: 1, color: cLine(d)));
      }
    }
    return FCard(
      padding: EdgeInsets.zero,
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

/// Заголовок карточки: 14px, тёмный.
class FCardTitle extends StatelessWidget {
  const FCardTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final label = Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: cText(d),
      ),
    );
    if (trailing == null) {
      return Padding(padding: const EdgeInsets.only(bottom: 2), child: label);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(child: label),
          const SizedBox(width: 8),
          trailing!,
        ],
      ),
    );
  }
}

/// Заголовок секции между карточками.
class FSectionTitle extends StatelessWidget {
  const FSectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cText(d),
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// `.srow` — «ключ слева, значение справа», разделитель снизу.
class FRow extends StatelessWidget {
  const FRow(
    this.label, {
    super.key,
    this.value,
    this.valueWidget,
    this.mono = false,
    this.last = false,
    this.valueColor,
    this.onTap,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool mono;
  final bool last;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: cLine(d))),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: cText3(d),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: valueWidget ??
                Text(
                  value ?? '—',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? cText(d),
                    fontFamily: mono ? 'monospace' : null,
                    fontFamilyFallback: mono ? const ['Menlo', 'Courier'] : null,
                  ),
                ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            Icon(PhosphorIconsBold.caretRight, size: 13, color: cMuted(d)),
          ],
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}

/// `.tbadge` — пилюля статуса. `ping` добавляет пульсирующую точку «живое».
class FBadge extends StatelessWidget {
  const FBadge(
    this.text, {
    super.key,
    this.tone = FTone.mute,
    this.icon,
    this.ping = false,
    this.fontSize = 11,
    this.background,
    this.foreground,
    this.onTap,
  });

  final String text;
  final FTone tone;
  final IconData? icon;
  final bool ping;
  final double fontSize;
  final Color? background;
  final Color? foreground;

  /// Значок-кнопка: так сделан чип «Yaxınlıqda» в списке аэропортов.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final fg = foreground ?? tone.fg(d);
    final box = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background ?? tone.bg(d),
        borderRadius: FT.rPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ping) ...[
            const FPing(),
            const SizedBox(width: 6),
          ] else if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: .1,
              color: fg,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return box;
    return InkWell(onTap: onTap, borderRadius: FT.rPill, child: box);
  }
}

/// Пульсирующая точка «данные живые».
class FPing extends StatefulWidget {
  const FPing({super.key, this.size = 8, this.color = FT.liveCore});

  final double size;
  final Color color;

  @override
  State<FPing> createState() => _FPingState();
}

class _FPingState extends State<FPing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeOut.transform(_c.value);
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Transform.scale(
                scale: 1 + t * 1.2,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: FT.livePing.withValues(alpha: .75 * (1 - t)),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// `.recent` — строка-переход: круглая иконка, заголовок, пояснение, шеврон.
/// Самый частый элемент раздела.
class FListRow extends StatelessWidget {
  const FListRow({
    super.key,
    this.icon,
    this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.showCaret = true,
    this.flat = false,
    this.iconBackground,
    this.iconColor,
    this.titleColor,
    this.selected = false,
  });

  final IconData? icon;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showCaret;

  /// Внутри [FGroupCard]: без рамки, фона и тени.
  final bool flat;

  final Color? iconBackground;
  final Color? iconColor;
  final Color? titleColor;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          if (leading != null)
            leading!
          else if (icon != null)
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: iconBackground ?? FT.chip(d),
                borderRadius: FT.rIcon,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: iconColor ?? cText3(d)),
            ),
          if (leading != null || icon != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: titleColor ?? cText(d),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: cMuted(d),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing!,
          ] else if (showCaret && onTap != null) ...[
            const SizedBox(width: 8),
            Icon(PhosphorIconsBold.caretRight, size: 14, color: cMuted(d)),
          ],
        ],
      ),
    );

    if (flat) {
      return onTap == null ? body : InkWell(onTap: onTap, child: body);
    }

    final decorated = Container(
      decoration: BoxDecoration(
        color: selected ? FT.brand50(d) : cCard(d),
        borderRadius: FT.rField,
        border: Border.all(color: selected ? FT.brand : cLine(d)),
        boxShadow: FT.cardShadow(d),
      ),
      child: body,
    );
    if (onTap == null) return decorated;
    return InkWell(
      onTap: onTap,
      borderRadius: FT.rField,
      child: decorated,
    );
  }
}

/// `.btn-pri`
class FPrimaryButton extends StatelessWidget {
  const FPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.loading = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final enabled = onTap != null && !loading;
    return Opacity(
      opacity: enabled ? 1 : .55,
      child: Material(
        color: FT.brand,
        borderRadius: FT.rField,
        elevation: 0,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: FT.rField,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: FT.rField,
              boxShadow: enabled ? FT.brandShadow(d) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `.btn-sec`
class FSecondaryButton extends StatelessWidget {
  const FSecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return InkWell(
      onTap: onTap,
      borderRadius: FT.rField,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: FT.brand50(d),
          borderRadius: FT.rField,
          border: Border.all(color: FT.brand100(d)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: FT.brand600(d)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: FT.brand600(d),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `.btn-gh`
class FGhostButton extends StatelessWidget {
  const FGhostButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.tone,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final FTone? tone;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final fg = tone?.fg(d) ?? cText3(d);
    return Opacity(
      opacity: onTap == null ? .5 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: FT.rField,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: tone == null ? FT.chip(d) : tone!.bg(d),
            borderRadius: FT.rField,
            border: Border.all(color: tone == null ? FT.chipBorder(d) : Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `.seg` — сегментированный переключатель. На небе (`onHero`) инвертирован.
class FSegment extends StatelessWidget {
  const FSegment({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    this.onHero = false,
  });

  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;
  final bool onHero;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: onHero ? Colors.white.withValues(alpha: .14) : FT.chip(d),
        borderRadius: FT.rField,
        border: Border.all(
          color: onHero ? Colors.white.withValues(alpha: .18) : FT.chipBorder(d),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: i == index
                        ? (onHero ? Colors.white : cCard(d))
                        : Colors.transparent,
                    borderRadius: FT.rSoft,
                    boxShadow: i == index && !onHero ? FT.cardShadow(d) : null,
                  ),
                  child: Text(
                    items[i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: i == index
                          ? (onHero ? const Color(0xFF0257AE) : FT.brand)
                          : (onHero
                              ? Colors.white.withValues(alpha: .8)
                              : cText3(d)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `.mbar` + `.mchip` — панель разделов модуля на корневых экранах.
class FChipBar extends StatelessWidget {
  const FChipBar({super.key, required this.items, required this.activeIndex});

  final List<FChipBarItem> items;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Container(
      decoration: BoxDecoration(
        color: cScreen(d),
        border: Border(bottom: BorderSide(color: cLine(d))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: EdgeInsets.only(right: i == items.length - 1 ? 0 : 6),
                child: _chip(d, items[i], i == activeIndex),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(bool d, FChipBarItem item, bool on) => InkWell(
        onTap: item.onTap,
        borderRadius: FT.rPill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: on ? FT.brand : cCard(d),
            borderRadius: FT.rPill,
            border: Border.all(color: on ? FT.brand : cLine(d)),
          ),
          child: Row(
            children: [
              Icon(item.icon,
                  size: 14, color: on ? Colors.white : cText3(d)),
              const SizedBox(width: 5),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: on ? Colors.white : cText3(d),
                ),
              ),
            ],
          ),
        ),
      );
}

class FChipBarItem {
  const FChipBarItem({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

/// Строка из колонок одинаковой высоты: две плитки, четыре времени, три
/// персентиля.
///
/// Обычный `Row(crossAxisAlignment: stretch)` для этого не годится: растяжка
/// по высоте требует конечной высоты, а внутри прокрутки её нет — кадр падает
/// прямо на разметке и экран остаётся пустым. `IntrinsicHeight` сначала
/// считает высоту самой высокой колонки, и только потом строка растягивает
/// остальные до неё.
class FEqualRow extends StatelessWidget {
  const FEqualRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
}

/// `.tiles` / `.tile` — сетка переходов 2×N.
class FTileGrid extends StatelessWidget {
  const FTileGrid({super.key, required this.tiles});

  final List<FTile> tiles;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += 2) {
      final left = tiles[i];
      final right = i + 1 < tiles.length ? tiles[i + 1] : null;
      rows.add(FEqualRow(
        children: [
          Expanded(child: left),
          const SizedBox(width: 10),
          Expanded(child: right ?? const SizedBox.shrink()),
        ],
      ));
      if (i + 2 < tiles.length) rows.add(const SizedBox(height: 10));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }
}

class FTile extends StatelessWidget {
  const FTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.onTap,
    this.wide = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? badge;
  final VoidCallback? onTap;

  /// Плитка на всю ширину: высота по содержимому, как у «Daha çox».
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return InkWell(
      onTap: onTap,
      borderRadius: FT.rTile,
      child: Container(
        constraints: BoxConstraints(minHeight: wide ? 0 : 104),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cCard(d),
          borderRadius: FT.rTile,
          border: Border.all(color: cLine(d)),
          boxShadow: FT.cardShadow(d),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: FT.brand50(d),
                    borderRadius: FT.rIcon,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 19, color: FT.brand600(d)),
                ),
                const SizedBox(height: 7),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: cText(d),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: cMuted(d),
                    ),
                  ),
                ],
              ],
            ),
            if (badge != null)
              Positioned(right: 0, top: 0, child: badge!),
          ],
        ),
      ),
    );
  }
}

/// Полоска «Данные на …» (§4.2). Показывается **только** при
/// `meta.stale: true`, и это не ошибка: экран под ней обычный.
class FStaleLine extends StatelessWidget {
  const FStaleLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: cFill(d),
        border: Border(bottom: BorderSide(color: cLine(d))),
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsBold.clockCounterClockwise,
              size: 14, color: cMuted(d)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: cText3(d),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Небо карточки рейса: фирменный синий, три кольца и вращающийся луч.
class FSky extends StatelessWidget {
  const FSky({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.background,
    this.rings = FSky.defaultRings,
    this.sweep = FSky.defaultSweep,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// По умолчанию — цвет неба. Карточка входа в раздел передаёт сюда
  /// фирменный синий.
  final Color? background;

  final List<FSkyRing> rings;
  final FSkyRing sweep;

  /// Кольца неба: размер и вынос за правый верхний угол — как в прототипе.
  static const defaultRings = <FSkyRing>[
    FSkyRing(200, -50, -60),
    FSkyRing(320, -110, -120),
    FSkyRing(440, -180, -190),
  ];

  static const defaultSweep = FSkyRing(260, -70, -80);

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Container(
      width: double.infinity,
      color: background ?? FT.hero(d),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: _SkyArt(dark: d, rings: rings, sweep: sweep),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// Одно кольцо неба: диаметр и смещение от правого верхнего угла.
class FSkyRing {
  const FSkyRing(this.size, this.right, this.top);

  final double size;
  final double right;
  final double top;
}

class _SkyArt extends StatefulWidget {
  const _SkyArt({
    required this.dark,
    required this.rings,
    required this.sweep,
  });

  final bool dark;
  final List<FSkyRing> rings;
  final FSkyRing sweep;

  @override
  State<_SkyArt> createState() => _SkyArtState();
}

class _SkyArtState extends State<_SkyArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4800),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ring = FT.heroRing(widget.dark);
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final r in widget.rings) _ring(ring, r.size, r.right, r.top),
          Positioned(
            right: widget.sweep.right,
            top: widget.sweep.top,
            width: widget.sweep.size,
            height: widget.sweep.size,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => Transform.rotate(
                angle: _c.value * 2 * math.pi,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        FT.heroSweep(widget.dark),
                        FT.heroSweep(widget.dark).withValues(alpha: 0),
                      ],
                      stops: const [0, .34],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring(Color color, double size, double right, double top) => Positioned(
        right: right,
        top: top,
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
        ),
      );
}

/// Шапка на небе: круглая кнопка «назад», заголовок, кнопки справа.
class FSkyHeader extends StatelessWidget {
  const FSkyHeader({
    super.key,
    required this.title,
    this.onBack,
    this.actions = const [],
    this.subtitle,
  });

  final String title;
  final VoidCallback? onBack;
  final List<FSkyAction> actions;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
      child: Row(
        children: [
          if (onBack != null) ...[
            _round(PhosphorIconsBold.arrowLeft, onBack!),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
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
          ),
          for (final a in actions) ...[
            const SizedBox(width: 8),
            _round(a.icon, a.onTap, active: a.active),
          ],
        ],
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

class FSkyAction {
  const FSkyAction({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;
}

/// Поле поиска на небе: белая рамка на синем, ввод прямо здесь.
class FHeroSearchField extends StatelessWidget {
  const FHeroSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.uppercase = false,
    this.keyboardType,
    this.trailing,
    this.icon = PhosphorIconsBold.magnifyingGlass,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  /// Номер рейса и код аэропорта в прототипе набраны капителью с разрядкой.
  final bool uppercase;

  final TextInputType? keyboardType;
  final Widget? trailing;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .14),
        borderRadius: FT.rField,
        border: Border.all(color: Colors.white.withValues(alpha: .2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: FT.onHero(.6)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              keyboardType: keyboardType,
              textInputAction: TextInputAction.search,
              textCapitalization: uppercase
                  ? TextCapitalization.characters
                  : TextCapitalization.none,
              cursorColor: Colors.white,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: uppercase ? 1.1 : null,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FT.onHero(.6),
                  letterSpacing: uppercase ? 1.1 : null,
                ),
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// `.rt` — маршрут на небе: код, город, время, терминал/выход, а посередине
/// длительность и расстояние.
class FRouteBlock extends StatelessWidget {
  const FRouteBlock({
    super.key,
    required this.fromCode,
    required this.toCode,
    this.fromCity,
    this.toCity,
    this.fromTime,
    this.toTime,
    this.fromWas,
    this.toWas,
    this.fromMeta,
    this.toMeta,
    this.duration,
    this.distance,
    this.middleIcon = PhosphorIconsFill.airplaneTilt,
  });

  final String fromCode;
  final String toCode;
  final String? fromCity;
  final String? toCity;
  final String? fromTime;
  final String? toTime;

  /// Прежнее время, когда расписание сдвинулось: зачёркнуто.
  final String? fromWas;
  final String? toWas;

  final String? fromMeta;
  final String? toMeta;
  final String? duration;
  final String? distance;
  final IconData middleIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _side(
            code: fromCode,
            city: fromCity,
            time: fromTime,
            was: fromWas,
            meta: fromMeta,
            align: CrossAxisAlignment.start,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (duration != null)
                Text(
                  duration!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: FT.onHero(.5),
                  ),
                ),
              const SizedBox(height: 4),
              Icon(middleIcon, size: 18, color: FT.onHero(.7)),
              if (distance != null) ...[
                const SizedBox(height: 4),
                Text(
                  distance!,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: FT.onHero(.4),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _side(
            code: toCode,
            city: toCity,
            time: toTime,
            was: toWas,
            meta: toMeta,
            align: CrossAxisAlignment.end,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _side({
    required String code,
    String? city,
    String? time,
    String? was,
    String? meta,
    required CrossAxisAlignment align,
    required TextAlign textAlign,
  }) =>
      Column(
        crossAxisAlignment: align,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            code,
            textAlign: textAlign,
            style: const TextStyle(
              fontSize: 32,
              height: 1,
              fontWeight: FontWeight.w700,
              letterSpacing: -.64,
              color: Colors.white,
            ),
          ),
          if (city != null) ...[
            const SizedBox(height: 4),
            Text(
              city,
              textAlign: textAlign,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: FT.onHero(.6),
              ),
            ),
          ],
          if (time != null) ...[
            const SizedBox(height: 10),
            Text(
              time,
              textAlign: textAlign,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
          if (was != null)
            Text(
              was,
              textAlign: textAlign,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: FT.struck,
                decoration: TextDecoration.lineThrough,
                decorationColor: FT.struck,
              ),
            ),
          if (meta != null) ...[
            const SizedBox(height: 5),
            Text(
              meta,
              textAlign: textAlign,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: FT.onHero(.5),
              ),
            ),
          ],
        ],
      );
}

/// `.prog` — полоса пути с самолётом. Процент приходит с сервера
/// (`progress_percent`), сами мы его не считаем.
class FProgressBar extends StatelessWidget {
  const FProgressBar({super.key, required this.percent, this.showPlane = true});

  final double percent;
  final bool showPlane;

  @override
  Widget build(BuildContext context) {
    final p = percent.clamp(0, 100) / 100;
    return SizedBox(
      height: 32,
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 13.5,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .14),
                    borderRadius: FT.rPill,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 13.5,
                child: Container(
                  height: 5,
                  width: w * p,
                  decoration: BoxDecoration(
                    color: FT.accent,
                    borderRadius: FT.rPill,
                    boxShadow: [
                      BoxShadow(
                        color: FT.accent.withValues(alpha: .45),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
              ),
              _dot(0),
              _dot(w),
              if (showPlane)
                Positioned(
                  left: (w * p) - 16,
                  top: 0,
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        const BoxShadow(
                          color: Color(0x73000000),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                        BoxShadow(
                          color: FT.accent.withValues(alpha: .18),
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(PhosphorIconsFill.airplaneTilt,
                        size: 15, color: Color(0xFF0A1B3E)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _dot(double left) => Positioned(
        left: left - 3.5,
        top: 12.5,
        child: Container(
          height: 7,
          width: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: .45),
          ),
        ),
      );
}

/// `.live-g` — три ячейки живой телеметрии на небе.
class FLiveGrid extends StatelessWidget {
  const FLiveGrid({super.key, required this.cells});

  final List<FLiveCell> cells;

  @override
  Widget build(BuildContext context) {
    return FEqualRow(
      children: [
        for (var i = 0; i < cells.length; i++) ...[
          if (i != 0) const SizedBox(width: 8),
          Expanded(child: cells[i]),
        ],
      ],
    );
  }
}

class FLiveCell extends StatelessWidget {
  const FLiveCell({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: FT.rField,
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: .4,
              color: FT.onHero(.55),
            ),
          ),
        ],
      ),
    );
  }
}

/// Крупная фирменная кнопка-строка — «создать объявление этим рейсом».
class FBrandActionCard extends StatelessWidget {
  const FBrandActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return InkWell(
      onTap: onTap,
      borderRadius: FT.rField,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FT.brand,
          borderRadius: FT.rField,
          boxShadow: FT.brandShadow(d),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .22),
                borderRadius: FT.rIcon,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: FT.onHero(.85),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(PhosphorIconsBold.caretRight,
                size: 15, color: FT.onHero(.9)),
          ],
        ),
      ),
    );
  }
}

/// Иконка в мягком квадрате — `.ico`.
class FIconChip extends StatelessWidget {
  const FIconChip({
    super.key,
    required this.icon,
    this.size = 36,
    this.background,
    this.color,
    this.iconSize,
  });

  final IconData icon;
  final double size;
  final Color? background;
  final Color? color;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: background ?? FT.chip(d),
        borderRadius: FT.rIcon,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize ?? size * .5, color: color ?? cText3(d)),
    );
  }
}

/// `.sk` — мерцающая заглушка.
class FSkeleton extends StatefulWidget {
  const FSkeleton({
    super.key,
    this.height = 14,
    this.width,
    this.radius = 8,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  State<FSkeleton> createState() => _FSkeletonState();
}

class _FSkeletonState extends State<FSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final base = d
        ? Colors.white.withValues(alpha: .05)
        : const Color(0xFF0F172A).withValues(alpha: .05);
    final hi = d
        ? Colors.white.withValues(alpha: .12)
        : const Color(0xFF0F172A).withValues(alpha: .10);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final x = _c.value * 2 - 1;
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + x * 2, 0),
              end: Alignment(1 + x * 2, 0),
              colors: [base, hi, base],
              stops: const [.3, .5, .7],
            ),
          ),
        );
      },
    );
  }
}

/// Строка-поле: подпись заглавными, значение, подсказка и шеврон.
///
/// В прототипе ею набраны «Haradan / Haraya / Tarix» на экране выбора рейса.
class FFieldRow extends StatelessWidget {
  const FFieldRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.hint,
    this.onTap,
    this.filled = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? hint;
  final VoidCallback? onTap;

  /// `false` — значение ещё не выбрано: показывается приглушённым.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Material(
      color: cCard(d),
      borderRadius: FT.rField,
      child: InkWell(
        onTap: onTap,
        borderRadius: FT.rField,
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
          decoration: BoxDecoration(
            borderRadius: FT.rField,
            border: Border.all(color: cLine(d)),
            boxShadow: FT.cardShadow(d),
          ),
          child: Row(
            children: [
              FIconChip(icon: icon, size: 36, iconSize: 16),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .6,
                        color: cText3(d),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: filled ? cText(d) : cText3(d),
                      ),
                    ),
                    if (hint != null)
                      Text(
                        hint!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cText3(d),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(PhosphorIconsBold.caretRight, size: 15, color: cText3(d)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Строка выбора с круглой отметкой справа.
///
/// Выбранная: синяя рамка и мягкая синяя подложка, отметка залита фирменным
/// цветом. Невыбранная: обычная рамка и пустой кружок.
class FPickRow extends StatelessWidget {
  const FPickRow({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.leading,
    this.padding = const EdgeInsets.fromLTRB(13, 12, 13, 12),
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final Widget? leading;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Material(
      color: selected ? FT.brand50(d) : cCard(d),
      borderRadius: FT.rField,
      child: InkWell(
        onTap: onTap,
        borderRadius: FT.rField,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: FT.rField,
            border: Border.all(color: selected ? FT.brand : cLine(d)),
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 11)],
              Expanded(child: child),
              const SizedBox(width: 11),
              FPickMark(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

/// Круглая отметка выбора — 20 px, как в прототипе.
class FPickMark extends StatelessWidget {
  const FPickMark({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Container(
      height: 20,
      width: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? FT.brand : Colors.transparent,
        border: Border.all(
          color: selected ? FT.brand : cBorder(d),
          width: 2,
        ),
      ),
      child: selected
          ? const Icon(PhosphorIconsBold.check, size: 11, color: Colors.white)
          : null,
    );
  }
}

/// Строка «что будет перенесено» — галочка и текст.
class FCheckLine extends StatelessWidget {
  const FCheckLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            PhosphorIconsFill.checkCircle,
            size: 15,
            color: FT.ok(d),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: cText2(d),
            ),
          ),
        ),
      ],
    );
  }
}

/// Карточка-пояснение на мягком синем — «İzləmə sənin üçün qoşulur».
class FBrandNoteCard extends StatelessWidget {
  const FBrandNoteCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;

  /// Карточка-ссылка: так сделана заметка о связанном объявлении.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final body = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FT.brand50(d),
        borderRadius: FT.rCard,
        border: Border.all(color: FT.brand100(d)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cCard(d),
              borderRadius: FT.rIcon,
              boxShadow: FT.cardShadow(d),
            ),
            child: Icon(icon, size: 17, color: FT.brand600(d)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: cText(d),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    color: cText2(d),
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Icon(
                PhosphorIconsBold.caretRight,
                size: 14,
                color: FT.brand600(d),
              ),
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return body;
    return InkWell(onTap: onTap, borderRadius: FT.rCard, child: body);
  }
}

/// Строка истории события: иконка в чипе, текст, время справа.
class FEventRow extends StatelessWidget {
  const FEventRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.time,
    this.tone = FTone.mute,
    this.last = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? time;
  final FTone tone;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: last
          ? null
          : BoxDecoration(border: Border(bottom: BorderSide(color: cLine(d)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FIconChip(
            icon: icon,
            size: 30,
            iconSize: 14,
            color: tone == FTone.mute ? cText2(d) : tone.fg(d),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: cText(d),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: cText3(d),
                    ),
                  ),
              ],
            ),
          ),
          if (time != null) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                time!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: cText3(d),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Карточка-плашка состояния: минимум текста на цветной подложке.
///
/// Так в прототипе показаны задержка, миник, отмена и смена курса. Причины в
/// ответе нет — поэтому в [message] идёт только то, что пришло с сервера.
class FNoticeCard extends StatelessWidget {
  const FNoticeCard({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.tone = FTone.warn,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? message;
  final FTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final body = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone.bg(d),
        borderRadius: FT.rCard,
        border: Border.all(color: tone.bg(d)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: cCard(d),
              borderRadius: FT.rIcon,
              boxShadow: FT.cardShadow(d),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: tone.fg(d)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                    color: cText(d),
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    message!,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: cText2(d),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(PhosphorIconsBold.caretRight, size: 15, color: cText3(d)),
          ],
        ],
      ),
    );
    if (onTap == null) return body;
    return InkWell(onTap: onTap, borderRadius: FT.rCard, child: body);
  }
}

/// Плитка одного из четырёх времён конца рейса.
///
/// Подпись под числом обязательна: иначе непонятно, расписание это, уточнение
/// авиакомпании, прогноз или факт полосы (§7.2).
class FTimeTile extends StatelessWidget {
  const FTimeTile({
    super.key,
    required this.label,
    required this.hint,
    this.value,
    this.valueColor,
  });

  final String label;
  final String hint;
  final String? value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final empty = value == null || value!.isEmpty;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cFill(d),
        borderRadius: FT.rField,
        border: Border.all(color: cLine(d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
              color: cText3(d),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            empty ? '—' : value!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: empty ? cText3(d) : (valueColor ?? cText(d)),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            hint,
            maxLines: 2,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: cText3(d),
            ),
          ),
        ],
      ),
    );
  }
}

/// Маленькая плитка «подпись сверху, число снизу» — персентили задержек.
class FMiniTile extends StatelessWidget {
  const FMiniTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
      decoration: BoxDecoration(
        color: cFill(d),
        borderRadius: FT.rSoft,
        border: Border.all(color: cLine(d)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: .4,
              color: cText3(d),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor ?? cText(d),
            ),
          ),
        ],
      ),
    );
  }
}

/// Строка-полоска «подпись · доля» — группы задержек.
class FBarRow extends StatelessWidget {
  const FBarRow({
    super.key,
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
    this.last = false,
  });

  final String label;
  final String value;

  /// 0…100.
  final double percent;

  final Color color;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: cText2(d),
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: cText(d),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: FT.rPill,
            child: Container(
              height: 7,
              color: FT.chip(d),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (percent.clamp(0, 100)) / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: FT.rPill,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Спокойная сноска под карточками: объяснение, а не ошибка.
class FInfoNote extends StatelessWidget {
  const FInfoNote(
    this.text, {
    super.key,
    this.icon = PhosphorIconsFill.info,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: FT.chip(d),
        borderRadius: FT.rField,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 15, color: cText3(d)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: cText2(d),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Строка дня в истории рейса: число и месяц слева, время и маршрут в центре,
/// статус справа.
class FDayRow extends StatelessWidget {
  const FDayRow({
    super.key,
    required this.day,
    required this.unit,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.last = false,
    this.dayWidth = 42,
  });

  final String day;

  /// Месяц у прошедших дней, день недели у будущих — так в прототипе.
  final String unit;

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool last;
  final double dayWidth;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final body = Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: cLine(d))),
            ),
      child: Row(
        children: [
          SizedBox(
            width: dayWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: cText(d),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unit.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: cText3(d),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: cText(d),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: cText3(d),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing!,
          ],
        ],
      ),
    );
    if (onTap == null) return body;
    return InkWell(onTap: onTap, child: body);
  }
}

/// Рейс строкой списка: номер, статус, время, маршрут и чем летит.
///
/// Одна и та же строка нужна выбору плеча, табло, результатам поиска и
/// списку рейсов самолёта — поля необязательные, экран показывает то, что у
/// него есть.
class FFlightRow extends StatelessWidget {
  const FFlightRow({
    super.key,
    required this.number,
    this.statusLabel,
    this.statusTone = FTone.mute,
    this.route,
    this.times,
    this.meta,
    this.trailing,
    this.onTap,
  });

  final String number;
  final String? statusLabel;
  final FTone statusTone;

  /// `GYD → IST` — набирается тем же шрифтом, что коды в приложении.
  final String? route;

  /// `13:30 → 15:50`
  final String? times;

  /// `Turkish Airlines · Airbus A321`
  final String? meta;

  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final body = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cCard(d),
        borderRadius: FT.rCard,
        border: Border.all(color: cBorder(d)),
        boxShadow: FT.cardShadow(d),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        number,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: cText(d),
                        ),
                      ),
                    ),
                    if (statusLabel != null) ...[
                      const SizedBox(width: 6),
                      FBadge(
                        statusLabel!.toUpperCase(),
                        tone: statusTone,
                        fontSize: 9,
                      ),
                    ],
                  ],
                ),
                if (route != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      route!,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: cText2(d),
                        fontFamily: 'monospace',
                        fontFamilyFallback: const ['Menlo', 'Courier'],
                      ),
                    ),
                  ),
                if (times != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      times!,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: cText(d),
                      ),
                    ),
                  ),
                if (meta != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      meta!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cText3(d),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing!,
          ],
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(PhosphorIconsBold.caretRight, size: 14, color: cMuted(d)),
          ],
        ],
      ),
    );
    if (onTap == null) return body;
    return InkWell(onTap: onTap, borderRadius: FT.rCard, child: body);
  }
}

/// Тумблер прототипа: 40×23, фирменный синий во включённом состоянии.
class FSwitch extends StatelessWidget {
  const FSwitch({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    final enabled = onChanged != null;
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: GestureDetector(
        onTap: enabled ? () => onChanged!(!value) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: 23,
          width: 40,
          padding: const EdgeInsets.all(2.5),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: value ? FT.brand : cBorder(d),
            borderRadius: FT.rPill,
          ),
          child: Container(
            height: 18,
            width: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x4D000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Строка с тумблером: иконка в чипе, название, пояснение и переключатель.
///
/// Иконка необязательна: в настройках уведомлений строки идут без неё.
class FToggleRow extends StatelessWidget {
  const FToggleRow({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.last = false,
  });

  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: cLine(d))),
            ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              height: 34,
              width: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: FT.chip(d),
                borderRadius: FT.rSoft,
              ),
              child: Icon(icon, size: 15, color: cText2(d)),
            ),
            const SizedBox(width: 11),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: cText(d),
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: cText3(d),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Поле-кнопка на небе: мелкая подпись, значение и уголок.
///
/// Такими на экране слежения набраны «TARİX» и «GEDİŞ»: значение выбирается
/// не вводом, а на другом экране.
class FHeroPickField extends StatelessWidget {
  const FHeroPickField({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.onTap,
  });

  final String label;
  final String value;
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: FT.rField,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .14),
          borderRadius: FT.rField,
          border: Border.all(color: Colors.white.withValues(alpha: .2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .5,
                      color: FT.onHero(.55),
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    PhosphorIconsBold.caretDown,
                    size: 11,
                    color: FT.onHero(.6),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (hint != null)
              Text(
                hint!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: FT.onHero(.55),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
