import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../resourses/wawat_dark.dart';
import '../../services/theme_manager.dart';

class OtpCodeInput extends StatefulWidget {
  const OtpCodeInput({
    super.key,
    required this.onChanged,
    this.onCompleted,
    this.length = 6,
    this.enabled = true,
    this.hasError = false,
    this.resetToken = 0,
  });

  final ValueChanged<String> onChanged;

  final ValueChanged<String>? onCompleted;

  final int length;
  final bool enabled;
  final bool hasError;

  final int resetToken;

  @override
  State<OtpCodeInput> createState() => _OtpCodeInputState();
}

class _OtpCodeInputState extends State<OtpCodeInput> {
  static const _brand = Color(0xFF0271EB);

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
    for (final c in _controllers) {
      c.addListener(_repaint);
    }
    for (final n in _nodes) {
      n.addListener(_repaint);
    }
  }

  void _repaint() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant OtpCodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetToken != widget.resetToken) {
      for (final c in _controllers) {
        c.clear();
      }
      if (widget.enabled) _nodes.first.requestFocus();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _emit() {
    final code = _code;
    widget.onChanged(code);
    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  void _distribute(String digits) {
    final take = digits.length > widget.length
        ? digits.substring(0, widget.length)
        : digits;
    for (var i = 0; i < widget.length; i++) {
      _controllers[i].text = i < take.length ? take[i] : '';
    }
    final focusIndex =
        take.length >= widget.length ? widget.length - 1 : take.length;
    _nodes[focusIndex].requestFocus();
    _emit();
  }

  void _onChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      _distribute(digits);
      return;
    }
    if (digits.isEmpty) {
      if (index > 0) _nodes[index - 1].requestFocus();
    } else {
      if (_controllers[index].text != digits) {
        _controllers[index].text = digits;
      }
      if (index < widget.length - 1) {
        _nodes[index + 1].requestFocus();
      } else {
        _nodes[index].unfocus();
      }
    }
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeManager>(context).isDarkMode;
    return AutofillGroup(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            List.generate(widget.length, (index) => _cell(index, isDark)),
      ),
    );
  }

  Widget _cell(int index, bool isDark) {
    final filled = _controllers[index].text.isNotEmpty;
    final focused = _nodes[index].hasFocus;
    final active = filled || focused;

    final Color border = widget.hasError
        ? (focused ? Colors.red : Colors.red.shade300)
        : (active
            ? (isDark ? WawatDark.focusRing : _brand)
            : (isDark ? WawatDark.border : const Color(0xFFE3E8F0)));
    final Color fill = widget.hasError
        ? (isDark ? WawatDark.surfaceAlt : const Color(0xFFFFF3F3))
        : (filled
            ? (isDark ? WawatDark.brandSoft : const Color(0xFFEFF5FF))
            : (isDark ? WawatDark.surfaceAlt : Colors.white));

    return GestureDetector(
      onTap: widget.enabled ? () => _nodes[index].requestFocus() : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: 48,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: active ? 1.6 : 1.2),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: (active ? _brand : const Color(0xFF0F172A))
                        .withValues(alpha: active ? 0.16 : 0.05),
                    blurRadius: active ? 12 : 7,
                    offset: Offset(0, active ? 4 : 3),
                  ),
                ],
        ),
        child: TextField(
          enabled: widget.enabled,
          controller: _controllers[index],
          focusNode: _nodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          cursorColor: _brand,
          showCursor: true,
          style: TextStyle(
            color: isDark ? WawatDark.textPrimary : const Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
          decoration: const InputDecoration(
            counterText: '',
            isCollapsed: true,
            contentPadding: EdgeInsets.zero,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          onChanged: (v) => _onChanged(index, v),
        ),
      ),
    );
  }
}
