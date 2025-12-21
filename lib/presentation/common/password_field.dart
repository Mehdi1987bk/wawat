import 'package:flutter/material.dart';
import '../../screens/splesh/splesh_screen.dart';
import 'animated_password_toggle.dart';
import '../resourses/app_colors.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final TextEditingController _cartController = TextEditingController();
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final String? labelText;
  final TextInputAction? textInputAction;

  PasswordField(
      {Key? key,
        this.controller,
        this.validator,
        this.autovalidateMode = AutovalidateMode.onUserInteraction,
        this.labelText,
        this.textInputAction})
      : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
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
        height: 55,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 2),
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
              obscureText: isHidden,
              autofillHints: const [AutofillHints.password],
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
                  suffixIconConstraints: BoxConstraints(maxHeight: 50, maxWidth: 50),
                  border: InputBorder.none,
                  labelStyle: TextStyle(
                      color: finKodNumberFocus || widget._cartController.text.trim().isEmpty
                          ? (isDark ? Colors.white70 : Colors.black54) // ← ИСПРАВЛЕНО
                          : Colors.transparent,
                      fontSize: 18),
                  hintText: '********',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[600] : Colors.grey, // ← ДОБАВЛЕНО
                    letterSpacing: 2.0,
                  ),
                  contentPadding: EdgeInsets.only(top: 8),
                  suffixIcon: AnimatedToggle(
                    onChanged: _toggle,
                  ))),
        ));
  }

  _toggle(bool isHidden) {
    setState(() {
      this.isHidden = isHidden;
    });
  }
}
