import 'package:flutter/material.dart';
import '../../screens/splesh/splesh_screen.dart';
import '../resourses/app_colors.dart';

class TextInputWithIcon extends StatefulWidget {
  final TextEditingController? controller;
  final TextEditingController _cartController = TextEditingController();
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final String? labelText;
  final TextInputAction? textInputAction;
  final Widget icon;

  TextInputWithIcon(
      {Key? key,
        this.controller,
        this.validator,
        this.autovalidateMode = AutovalidateMode.onUserInteraction,
        this.labelText,
        this.textInputAction,
        required this.icon})
      : super(key: key);

  @override
  State<TextInputWithIcon> createState() => _TextInputWithIconState();
}

class _TextInputWithIconState extends State<TextInputWithIcon> {
  bool isHidden = true;
  var _focusNode = new FocusNode();

  _focusListener() {
    setState(() {});
  }

  @override
  void initState() {
    _focusNode.addListener(_focusListener);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ← ДОБАВЛЕНО: Определяем тему
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white, // ← ДОБАВЛЕНО
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark
                ? Colors.grey.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3), // ← ИСПРАВЛЕНО
            width: 2,
          ),
        ),
        child: Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              finKodNumberFocus = hasFocus;
            });
          },
          child: TextFormField(
              autovalidateMode: widget.autovalidateMode,
              validator: widget.validator,
              controller: widget.controller,
              textInputAction: widget.textInputAction,
              maxLines: 1,
              focusNode: _focusNode,
              cursorColor: AppColors.appColor,
              keyboardAppearance: isDark ? Brightness.dark : Brightness.light, // ← ДОБАВЛЕНО ДЛЯ КЛАВИАТУРЫ
              style: TextStyle(
                  color: isDark ? Colors.white : AppColors.darkBlue, // ← ИСПРАВЛЕНО
                  fontSize: 20
              ),
              decoration: InputDecoration(
                suffixIcon: widget.icon,
                contentPadding: EdgeInsets.only(bottom: 3),
                suffixIconConstraints: BoxConstraints(maxHeight: 50, maxWidth: 50),
                border: InputBorder.none,
                hintStyle: TextStyle(
                    color: finKodNumberFocus || widget._cartController.text.trim().isEmpty
                        ? (isDark ? Colors.white70 : Colors.black54) // ← ИСПРАВЛЕНО
                        : Colors.transparent,
                    fontSize: 18),
                hintText: widget.labelText,
              )),
        ));
  }
}
