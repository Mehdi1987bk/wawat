import 'package:flutter/material.dart';
 import '../../screens/splesh/splesh_screen.dart';
import '../resourses/app_colors.dart';

class TextFildd extends StatefulWidget {
  final TextEditingController? controller;
  final TextEditingController _cartController = TextEditingController();
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final String? labelText;
  final TextInputAction? textInputAction;

  TextFildd(
      {Key? key,
      this.controller,
      this.validator,
      this.autovalidateMode = AutovalidateMode.onUserInteraction,
      this.labelText,
      this.textInputAction})
      : super(key: key);

  @override
  State<TextFildd> createState() => _TextFilddState();
}

class _TextFilddState extends State<TextFildd> {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
        padding: EdgeInsets.only(top: 5, left: 10, right: 10),
        margin: const EdgeInsets.only(top: 5, left: 20, right: 20),
        height: 60,
        decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: new BorderRadius.circular(10.0),
            border: _focusNode.hasFocus
                ? Border.all(color: theme.primaryColor)
                : Border.all(color: theme.dividerColor)),

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
              cursorColor: theme.primaryColor,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 20
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(bottom: 18, left: 15, top: 0, right: 10),
                suffixIconConstraints: BoxConstraints(maxHeight: 50, maxWidth: 50),
                border: InputBorder.none,
                labelStyle: TextStyle(
                    color: finKodNumberFocus || widget._cartController.text.trim().isEmpty
                        ? (isDark ? Colors.white70 : Colors.black54)
                        : Colors.transparent,
                    fontSize: 18),
                labelText: widget.labelText,
              )),
        ));
  }
}
