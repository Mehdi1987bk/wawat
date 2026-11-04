import 'dart:async';

class TypingSignal {
  TypingSignal({required this.send, DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  static const interval = Duration(seconds: 3);

  final Future<void> Function(bool typing) send;
  final DateTime Function() _now;

  Timer? _stopTimer;
  DateTime? _lastSentAt;

  bool _shown = false;
  bool _disposed = false;

  void onInput(String text) {
    if (_disposed) return;
    _stopTimer?.cancel();
    if (text.trim().isEmpty) {
      _stopAfter(_untilNextAllowed());
      return;
    }
    if (_untilNextAllowed() == Duration.zero) _emit(true);
    _stopTimer = Timer(interval, _stopNow);
  }

  void onMessageSent() {
    _stopTimer?.cancel();
    _shown = false;
  }

  void stop() {
    _stopTimer?.cancel();
    if (_disposed || !_shown) return;
    if (_untilNextAllowed() == Duration.zero) {
      _emit(false);
    } else {
      _shown = false;
    }
  }

  void dispose() {
    stop();
    _disposed = true;
  }

  void _stopAfter(Duration wait) {
    if (!_shown) return;
    if (wait == Duration.zero) {
      _stopNow();
    } else {
      _stopTimer = Timer(wait, _stopNow);
    }
  }

  void _stopNow() {
    if (_disposed || !_shown) return;
    _emit(false);
  }

  Duration _untilNextAllowed() {
    final last = _lastSentAt;
    if (last == null) return Duration.zero;
    final left = interval - _now().difference(last);
    return left > Duration.zero ? left : Duration.zero;
  }

  void _emit(bool typing) {
    _shown = typing;
    _lastSentAt = _now();
    unawaited(send(typing));
  }
}
