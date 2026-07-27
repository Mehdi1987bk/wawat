import 'dart:async';

import 'package:flutter/material.dart';

/// A button that runs a backend action, showing a centered loader in place of
/// its content while the action is in flight and swallowing repeat taps.
///
/// The loading state can be driven two ways (they combine with OR):
///  * Return a `Future` from [onPressed] — the button awaits it, shows the
///    spinner for exactly that duration and blocks double-submits on its own.
///    This is the preferred wiring: the handler just `await`s its bloc call.
///  * Pass [loading] explicitly — e.g. when the flag already comes from a
///    `bloc.loadingStream`. Effective loading = `loading || <onPressed running>`.
///
/// While loading the [child] (label + icons) is fully hidden — only the loader
/// shows — and the button keeps its size so it doesn't jump.
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

  /// The action to run on tap. Return a `Future` so the button can await it and
  /// keep the loader up until the backend call settles. `null` disables the tap.
  final FutureOr<void> Function()? onPressed;

  /// Normal button content (usually a `Text` or a `Row` of icon + text).
  final Widget child;

  /// Full decoration override. When null one is built from [color]/[gradient]
  /// and [borderRadius].
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

  /// External loading flag (e.g. from a bloc stream). ORs with the internal
  /// in-flight state.
  final bool loading;

  /// Renders as non-interactive at [disabledOpacity] without a spinner.
  final bool disabled;
  final double disabledOpacity;

  @override
  State<AsyncActionButton> createState() => _AsyncActionButtonState();
}

class _AsyncActionButtonState extends State<AsyncActionButton> {
  bool _busy = false;

  bool get _isLoading => _busy || widget.loading;

  Future<void> _handleTap() async {
    // One tap only: ignore while a call is in flight or the button is disabled.
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
        // Keep the label laid out (just invisible) so the button size holds.
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
