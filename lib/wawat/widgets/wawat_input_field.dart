import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/resourses/wawat_colors.dart';
import '../../presentation/resourses/wawat_dimensions.dart';
import '../../presentation/resourses/wawat_text_styles.dart';
import '../../services/theme_manager.dart';
/// Поле ввода для приложения Wawat
class WawatInputField extends StatefulWidget {
  final String? label;
  final String placeholder;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool isModal;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final bool isEmail; // Новый параметр

  const WawatInputField({
    Key? key,
    this.label,
    required this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.isModal = false,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.isEmail = false, // По умолчанию false
  }) : super(key: key);

  @override
  State<WawatInputField> createState() => _WawatInputFieldState();
}

class _WawatInputFieldState extends State<WawatInputField> {
  bool _obscureText = false;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Определяем тип клавиатуры
  TextInputType get _effectiveKeyboardType {
    // Если явно передан keyboardType, используем его
    if (widget.keyboardType != null) {
      return widget.keyboardType!;
    }
    // Если isEmail = true, используем email клавиатуру
    if (widget.isEmail) {
      return TextInputType.emailAddress;
    }
    // По умолчанию обычная клавиатура
    return TextInputType.text;
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.isModal
        ? WawatDimensions.inputHeightModal
        : WawatDimensions.inputHeight;

    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: WawatTextStyles.label.copyWith(
                  color: isDark ? Colors.white70 : WawatTextStyles.label.color,
                ),
              ),
              SizedBox(height: WawatDimensions.spacingSm),
            ],
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(WawatDimensions.inputBorderRadius),
                border: Border.all(
                  color: _isFocused
                      ? WawatColors.inputFocusedBorder
                      : (isDark ? const Color(0xFF4A4A4A) : WawatColors.inputBorder),
                  width: _isFocused ? 0.8 : 0.8,
                ),
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: _obscureText,
                keyboardType: _effectiveKeyboardType, // Используем вычисленный тип
                keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
                onChanged: widget.onChanged,
                onTap: widget.onTap,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                style: WawatTextStyles.body.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: WawatTextStyles.placeholder.copyWith(
                    color: isDark ? const Color(0xFF6B7280) : WawatTextStyles.placeholder.color,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(
                    left: widget.prefixIcon != null
                        ? WawatDimensions.inputTextPadding
                        : WawatDimensions.spacingMd,
                    right: WawatDimensions.spacingMd,
                    top: widget.obscureText ? 11 : 0,
                    bottom: 0,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Padding(
                    padding: EdgeInsets.only(
                      left: WawatDimensions.inputIconPadding,
                      right: WawatDimensions.inputIconPadding,
                    ),
                    child: widget.prefixIcon,
                  )
                      : null,
                  prefixIconConstraints: BoxConstraints(
                    minWidth: WawatDimensions.iconLarge,
                    minHeight: WawatDimensions.iconLarge,
                  ),
                  suffixIcon: widget.suffixIcon != null
                      ? widget.suffixIcon
                      : widget.obscureText
                      ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: isDark ? Colors.white70 : WawatColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
