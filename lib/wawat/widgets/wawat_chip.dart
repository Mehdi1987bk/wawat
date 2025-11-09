import 'package:flutter/material.dart';
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

  String get _icon {
    switch (role.toLowerCase()) {
      case 'курьер':
      case 'courier':
        return '✈️';
      case 'отправитель':
      case 'sender':
        return '📤';
      case 'покупатель':
      case 'buyer':
        return '🛍️';
      default:
        return '👤';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WawatChip(
      text: '$_icon $role',
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
      text: '🟢 Проверен',
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
