import 'package:flutter/material.dart';
import '../../presentation/resourses/wawat_colors.dart';
import '../../presentation/resourses/wawat_dimensions.dart';
import '../../presentation/resourses/wawat_text_styles.dart';

/// Кнопки для приложения Wawat
class WawatButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final Widget? icon;
  final bool isLoading;
  final double? width;
  final double? height;

  const WawatButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? WawatDimensions.buttonHeight,
      decoration: BoxDecoration(
        gradient: isPrimary ? WawatColors.buttonGradient : null,
        color: isPrimary ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(WawatDimensions.buttonBorderRadius),
        border: isPrimary
            ? null
            : Border.all(
                color: WawatColors.primary,
                width: 1,
              ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(WawatDimensions.buttonBorderRadius),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: WawatDimensions.buttonPaddingHorizontal,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isPrimary ? Colors.white : WawatColors.primary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          SizedBox(width: WawatDimensions.spacingSm),
                        ],
                        Text(
                          text,
                          style: WawatTextStyles.button.copyWith(
                            color: isPrimary
                                ? Colors.white
                                : WawatColors.primary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outline кнопка
class WawatOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double? width;
  final double? height;

  const WawatOutlineButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WawatButton(
      text: text,
      onPressed: onPressed,
      isPrimary: false,
      icon: icon,
      width: width,
      height: height,
    );
  }
}
