import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../presentation/resourses/wawat_colors.dart';
import '../../presentation/resourses/wawat_dimensions.dart';
import '../../presentation/resourses/wawat_text_styles.dart';

enum WawatChipType {
  purple,
  green,
  yellow,
  gray,
}

/// Чип/Тег для приложения Wawat
class WawatChip extends StatelessWidget {
  final String text;
  final WawatChipType type;
  final Widget? icon;
  final VoidCallback? onDelete;

  const WawatChip({
    Key? key,
    required this.text,
    this.type = WawatChipType.purple,
    this.icon,
    this.onDelete,
  }) : super(key: key);

  Color get backgroundColor {
    switch (type) {
      case WawatChipType.purple:
        return WawatColors.chipPurple;
      case WawatChipType.green:
        return WawatColors.chipGreen;
      case WawatChipType.yellow:
        return WawatColors.chipYellow;
      case WawatChipType.gray:
        return WawatColors.chipGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: WawatDimensions.chipHeight,
      padding: EdgeInsets.symmetric(
        horizontal: WawatDimensions.chipPaddingHorizontal,
        vertical: WawatDimensions.chipPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(WawatDimensions.chipBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            SizedBox(width: WawatDimensions.spacingXs),
          ],
          Text(
            text,
            style: WawatTextStyles.chip,
          ),
          if (onDelete != null) ...[
            SizedBox(width: WawatDimensions.spacingXs),
            GestureDetector(
              onTap: onDelete,
              child: Icon(
                Icons.close,
                size: WawatDimensions.iconSmall,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Чип для роли курьера
class WawatRoleChip extends StatelessWidget {
  final String role;

  const WawatRoleChip({
    Key? key,
    required this.role,
  }) : super(key: key);

  // Метод вместо геттера, принимает context
  String _getIcon(BuildContext context) {
    final roleLower = role.toLowerCase();
    final courierText = S.of(context).frefd.toLowerCase();
    final senderText = S.of(context).fvvdf.toLowerCase();
    final buyerText = S.of(context).fvgbfdb.toLowerCase();

    if (roleLower == courierText || roleLower == 'courier') {
      return '✈️';
    } else if (roleLower == senderText || roleLower == 'sender') {
      return '📤';
    } else if (roleLower == buyerText || roleLower == 'buyer') {
      return '🛍️';
    } else {
      return '👤';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WawatChip(
      text: '${_getIcon(context)} $role',
      type: WawatChipType.purple,
    );
  }
}

/// Чип "Проверен"
class WawatVerifiedChip extends StatelessWidget {
  const WawatVerifiedChip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WawatChip(
      text: S.of(context).fvdgd,
      type: WawatChipType.green,
    );
  }
}

/// Чип с рейтингом
class WawatRatingChip extends StatelessWidget {
  final double rating;

  const WawatRatingChip({
    Key? key,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WawatChip(
      text: '⭐ ${rating.toStringAsFixed(1)}',
      type: WawatChipType.yellow,
    );
  }
}