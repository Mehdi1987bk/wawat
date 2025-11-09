import 'package:flutter/material.dart';

import 'shaker.dart';

const Duration _transitionDuration = Duration(milliseconds: 400);
const Duration _opacityDuration = Duration(milliseconds: 100);

class ErrorAnimation extends StatefulWidget {
  final Widget child;
  final bool show;

  const ErrorAnimation({Key? key, required this.child, required this.show})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ErrorAnimationState();
}

class _ErrorAnimationState extends State<ErrorAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late final Animation<double> _transitionAnim;
  late final Animation<double> _shakeAnim;
  final Tween<double> _reverseAnim = Tween<double>(begin: 0, end: 0);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: _transitionDuration,
      vsync: this,
    );
    _transitionAnim = CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.4, curve: Curves.fastOutSlowIn));
    _shakeAnim = CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn));
  }

  @override
  void didUpdateWidget(covariant ErrorAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.show != widget.show) {
      if (widget.show &&  !_animController.isCompleted) {
            _animController
              ..value = 0.0
              ..forward();
          } else {
            _animController.reverse(from: 0.5);
          }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Shaker(
      animation:
          widget.show ? _shakeAnim : _reverseAnim.animate(_animController.view),
      child: AnimatedOpacity(
        duration:_opacityDuration,
        opacity: widget.show ? 1.0 : 0.0,
        child: SizeTransition(
          axisAlignment: 1.0,
          sizeFactor: _transitionAnim,
          child: widget.child,
        ),
      ),
    );
  }
   @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
