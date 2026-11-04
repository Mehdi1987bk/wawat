import 'dart:async';

import 'package:flutter/material.dart';

class AsyncActionButton extends StatefulWidget {
  const AsyncActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.decoration,
    this.color,
    this.gradient,
    this.height = 52,
    this.width = double.infinity,
    this.padding,
    this.borderRadius = 14,
    this.loaderColor = Colors.white,
    this.loaderSize = 22,
    this.loaderStrokeWidth = 2.4,
    this.loading = false,
    this.disabled = false,
    this.disabledOpacity = 0.5,
    this.boxShadow,
  });

  final FutureOr<void> Function()? onPressed;

  final Widget child;

  final BoxDecoration? decoration;
  final Color? color;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  final Color loaderColor;
  final double loaderSize;
  final double loaderStrokeWidth;

  final bool loading;

  final bool disabled;
  final double disabledOpacity;

  @override
  State<AsyncActionButton> createState() => _AsyncActionButtonState();
}

class _AsyncActionButtonState extends State<AsyncActionButton> {
  bool _busy = false;

  bool get _isLoading => _busy || widget.loading;

  Future<void> _handleTap() async {
    if (_isLoading || widget.disabled || widget.onPressed == null) return;
    setState(() => _busy = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final enabled = !widget.disabled && widget.onPressed != null;

    final decoration = widget.decoration ??
        BoxDecoration(
          color: widget.gradient == null
              ? (widget.color ?? Theme.of(context).colorScheme.primary)
              : null,
          gradient: widget.gradient,
          borderRadius: radius,
          boxShadow: widget.boxShadow,
        );

    Widget content = Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: _isLoading ? 0 : 1, child: widget.child),
        if (_isLoading)
          SizedBox(
            width: widget.loaderSize,
            height: widget.loaderSize,
            child: CircularProgressIndicator(
              strokeWidth: widget.loaderStrokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(widget.loaderColor),
            ),
          ),
      ],
    );

    Widget button = Container(
      width: widget.width,
      height: widget.height,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: widget.decoration?.borderRadius is BorderRadius
            ? widget.decoration!.borderRadius as BorderRadius
            : radius,
        child: InkWell(
          onTap: enabled && !_isLoading ? _handleTap : null,
          borderRadius: widget.decoration?.borderRadius is BorderRadius
              ? widget.decoration!.borderRadius as BorderRadius
              : radius,
          child: Padding(
            padding:
                widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: content),
          ),
        ),
      ),
    );

    if (!enabled) {
      button = Opacity(opacity: widget.disabledOpacity, child: button);
    }
    return button;
  }
}
