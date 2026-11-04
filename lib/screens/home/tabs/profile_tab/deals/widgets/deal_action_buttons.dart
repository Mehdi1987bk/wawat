import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../../data/network/response/chat_response.dart';
import '../../../../../../presentation/resourses/wawat_dark.dart';

const double _buttonHeight = 40;
const double _buttonGap = 8;
const double _buttonPadding = 12;

const double _buttonMinPadding = 6;
const int _maxPerLine = 3;

const TextStyle _labelStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  height: 1.2,
);

@visibleForTesting
List<List<double>> layoutDealActionWidths(
  List<double> natural,
  double available, {
  double squeeze = 0,
}) {
  if (natural.isEmpty || available <= 0) return const [];
  final clamped = [for (final width in natural) math.min(width, available)];

  final lines = <List<double>>[];
  var line = <double>[];
  var tightest = 0.0;
  for (final width in clamped) {
    final least = math.max(0.0, width - squeeze);
    final next = line.isEmpty ? least : tightest + _buttonGap + least;
    if (line.isNotEmpty && (line.length == _maxPerLine || next > available)) {
      lines.add(line);
      line = [width];
      tightest = least;
    } else {
      line.add(width);
      tightest = next;
    }
  }
  if (line.isNotEmpty) lines.add(line);

  return [for (final entry in lines) _shareLine(entry, available)];
}

List<double> _shareLine(List<double> natural, double available) {
  var remaining = available - _buttonGap * (natural.length - 1);
  final wanted = natural.fold<double>(0, (sum, width) => sum + width);
  if (wanted > remaining) {
    final cut = (wanted - remaining) / natural.length;
    return [for (final width in natural) width - cut];
  }

  final widths = List<double>.filled(natural.length, 0);
  final open = List<int>.generate(natural.length, (index) => index);
  while (open.isNotEmpty) {
    final share = remaining / open.length;
    final over = open.where((index) => natural[index] > share).toList();
    if (over.isEmpty) {
      for (final index in open) {
        widths[index] = share;
      }
      break;
    }
    for (final index in over) {
      widths[index] = natural[index];
      remaining -= natural[index];
      open.remove(index);
    }
  }
  return widths;
}

class DealActionButtons extends StatelessWidget {
  final List<DealAction> actions;
  final ValueChanged<DealAction> onAction;
  final String? busyKey;
  final bool locked;

  const DealActionButtons({
    super.key,
    required this.actions,
    required this.onAction,
    this.busyKey,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buttonFor(DealAction action) {
      final busy = locked && busyKey != null && busyKey == action.key;
      return _DealActionButton(
        action: action,
        isDark: isDark,
        busy: busy,
        disabled: locked,
        onTap: () => onAction(action),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final natural = _naturalWidths(context);
        if (!constraints.maxWidth.isFinite) {
          return Wrap(
            spacing: _buttonGap,
            runSpacing: _buttonGap,
            children: [
              for (var i = 0; i < actions.length; i++)
                SizedBox(width: natural[i], child: buttonFor(actions[i])),
            ],
          );
        }

        final lines = layoutDealActionWidths(
          natural,
          constraints.maxWidth,
          squeeze: (_buttonPadding - _buttonMinPadding) * 2,
        );
        var index = 0;
        final rows = <Widget>[];
        for (final line in lines) {
          final children = <Widget>[];
          for (final width in line) {
            if (children.isNotEmpty) {
              children.add(const SizedBox(width: _buttonGap));
            }
            children.add(
              SizedBox(width: width, child: buttonFor(actions[index])),
            );
            index++;
          }
          if (rows.isNotEmpty) rows.add(const SizedBox(height: _buttonGap));
          rows.add(Row(mainAxisSize: MainAxisSize.min, children: children));
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        );
      },
    );
  }

  List<double> _naturalWidths(BuildContext context) {
    final style = _effectiveLabelStyle(context);
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    return [
      for (final action in actions)
        _measure(action.label, style, scaler, direction) +
            _buttonPadding * 2 +
            2,
    ];
  }

  static double _measure(
    String text,
    TextStyle style,
    TextScaler scaler,
    TextDirection direction,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width.ceilToDouble();
  }
}

TextStyle _effectiveLabelStyle(BuildContext context) {
  final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
  var style = base.merge(_labelStyle);
  if (MediaQuery.boldTextOf(context)) {
    style = style.merge(const TextStyle(fontWeight: FontWeight.bold));
  }
  return style;
}

class DealCardActions extends StatelessWidget {
  final List<DealAction> actions;
  final ValueChanged<DealAction> onAction;
  final String? busyKey;
  final bool locked;

  const DealCardActions({
    super.key,
    required this.actions,
    required this.onAction,
    this.busyKey,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Container(
          height: 1,
          color: isDark ? WawatDark.divider : const Color(0xFFE8ECF4),
        ),
        const SizedBox(height: 12),
        DealActionButtons(
          actions: actions,
          onAction: onAction,
          busyKey: busyKey,
          locked: locked,
        ),
      ],
    );
  }
}

class _ButtonPalette {
  final Color fill;
  final Color? border;
  final Color text;
  final Color pressed;

  const _ButtonPalette({
    required this.fill,
    required this.text,
    required this.pressed,
    this.border,
  });
}

const Color _pressedOverlay = Color(0x14000000);

_ButtonPalette _paletteFor(String style, bool isDark) {
  switch (style) {
    case 'primary':
      return const _ButtonPalette(
        fill: Color(0xFF234DF1),
        text: Colors.white,
        pressed: _pressedOverlay,
      );
    case 'danger':
      return isDark
          ? const _ButtonPalette(
              fill: Colors.transparent,
              border: WawatDark.dangerSoftBorder,
              text: WawatDark.dangerText,
              pressed: WawatDark.ripple,
            )
          : const _ButtonPalette(
              fill: Colors.transparent,
              border: Color(0xFFF3C8C8),
              text: Color(0xFFC0392B),
              pressed: _pressedOverlay,
            );
    default:
      return isDark
          ? const _ButtonPalette(
              fill: Colors.transparent,
              border: Color(0x29FFFFFF),
              text: WawatDark.textPrimary,
              pressed: WawatDark.ripple,
            )
          : const _ButtonPalette(
              fill: Colors.transparent,
              border: Color(0xFFD5DCEA),
              text: Color(0xFF1B2437),
              pressed: _pressedOverlay,
            );
  }
}

class _DealActionButton extends StatelessWidget {
  final DealAction action;
  final bool isDark;
  final bool busy;
  final bool disabled;
  final VoidCallback onTap;

  const _DealActionButton({
    required this.action,
    required this.isDark,
    required this.busy,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(action.style, isDark);
    final border = palette.border;
    return Semantics(
      button: true,
      enabled: !disabled,
      label: busy ? action.label : null,
      child: Opacity(
        opacity: disabled && !busy ? 0.45 : 1,
        child: Material(
          color: palette.fill,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: border == null ? BorderSide.none : BorderSide(color: border),
          ),
          child: InkWell(
            onTap: disabled ? null : onTap,
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.pressed)
                  ? palette.pressed
                  : Colors.transparent,
            ),
            child: SizedBox(
              height: _buttonHeight,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: _buttonMinPadding),
                child: Center(
                  child: busy
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(palette.text),
                          ),
                        )
                      : Text(
                          action.label,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: _labelStyle.copyWith(color: palette.text),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
