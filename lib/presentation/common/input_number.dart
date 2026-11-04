import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberFild extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;

  NumberFild({
    Key? key,
    required this.controller,
    this.validator,
    this.labelText,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : super(key: key);

  @override
  _NumberFildState createState() => _NumberFildState();
}

class _NumberFildState extends State<NumberFild> {
  String countryCode = '+994';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Colors.grey.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
            },
            child: Row(
              children: [
                Text(
                  countryCode,
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_outlined,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            child: VerticalDivider(
              thickness: 1,
              color: isDark ? Colors.grey[700] : Colors.grey,
              width: 20,
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              validator: widget.validator,
              autovalidateMode: widget.autovalidateMode,
              keyboardType: TextInputType.phone,
              keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
              inputFormatters: [
                LengthLimitingTextInputFormatter(9),
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '-- -- -- --',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey,
                  letterSpacing: 2.0,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
