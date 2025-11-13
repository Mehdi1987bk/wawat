import 'package:flutter/material.dart';
import '../../presentation/resourses/wawat_colors.dart';
import '../../presentation/resourses/wawat_dimensions.dart';
import '../../presentation/resourses/wawat_text_styles.dart';

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

  @override
  Widget build(BuildContext context) {
    final height = widget.isModal
        ? WawatDimensions.inputHeightModal
        : WawatDimensions.inputHeight;

    // Проверяем наличие suffixIcon (как явного, так и автоматического для паролей)
    final hasSuffixIcon = widget.suffixIcon != null || widget.obscureText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: WawatTextStyles.label,
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
                  : WawatColors.inputBorder,
              width: _isFocused ? 2 : 1,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            style: WawatTextStyles.body,
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: WawatTextStyles.placeholder,
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.only(
                left: widget.prefixIcon != null
                    ? WawatDimensions.inputTextPadding
                    : WawatDimensions.spacingMd,
                right: hasSuffixIcon
                    ? WawatDimensions.inputTextPadding
                    : WawatDimensions.spacingMd,
                top: 12,
                bottom: 12,
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
                  color: WawatColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
                  : null,
              suffixIconConstraints: BoxConstraints(
                minWidth: WawatDimensions.iconLarge,
                minHeight: WawatDimensions.iconLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dropdown поле
class WawatDropdownField extends StatelessWidget {
  final String? label;
  final String placeholder;
  final Widget? prefixIcon;
  final VoidCallback onTap;
  final String? value;
  final bool isModal;

  const WawatDropdownField({
    Key? key,
    this.label,
    required this.placeholder,
    this.prefixIcon,
    required this.onTap,
    this.value,
    this.isModal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WawatInputField(
      label: label,
      placeholder: placeholder,
      prefixIcon: prefixIcon,
      readOnly: true,
      onTap: onTap,
      isModal: isModal,
      controller: TextEditingController(text: value),
      suffixIcon: Icon(
        Icons.arrow_drop_down,
        color: WawatColors.textSecondary,
      ),
    );
  }
}