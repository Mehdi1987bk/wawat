import 'package:buking/screens/chat/bloc/typing_signal.dart';
// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

class _Typing {
  _Typing(this.async) {
    signal = TypingSignal(
      send: (typing) async => sent.add((at: async.elapsed, typing: typing)),
      clock: () => _start.add(async.elapsed),
    );
  }

  static final _start = DateTime(2026, 10, 13, 12);

  final FakeAsync async;
  late final TypingSignal signal;
  final sent = <({Duration at, bool typing})>[];

  void type(Duration duration) {
    final keys = duration.inMilliseconds ~/ 100;
    for (var i = 0; i < keys; i++) {
      signal.onInput('текст $i');
      async.elapse(const Duration(milliseconds: 100));
    }
  }

  Duration get closest {
    var result = const Duration(days: 1);
    for (var i = 1; i < sent.length; i++) {
      final gap = sent[i].at - sent[i - 1].at;
      if (gap < result) result = gap;
    }
    return result;
  }

  List<bool> get values => [for (final request in sent) request.typing];
}

const _s = Duration(seconds: 1);

void main() {
  test('первая буква — «печатает» сразу', () {
    fakeAsync((async) {
      final typing = _Typing(async);
      typing.signal.onInput('п');
      expect(typing.values, [true]);
    });
  });

  test('пока печатает — раз в 3 секунды, а не на каждую клавишу', () {
    fakeAsync((async) {
      final typing = _Typing(async);
      typing.type(_s * 10);

      expect(typing.values, [true, true, true, true]);
      expect(typing.closest, greaterThanOrEqualTo(_s * 3));
    });
  });

  test('замолчал — один раз «перестал», через 3 секунды тишины', () {
    fakeAsync((async) {
      final typing = _Typing(async);
      typing.type(_s);
      async.elapse(_s * 30);

      expect(typing.values, [true, false]);
      expect(typing.closest, greaterThanOrEqualTo(_s * 3));
    });
  });

  test('отправил сообщение — «перестал» не уходит вовсе', () {
    fakeAsync((async) {
      final typing = _Typing(async);
      typing.type(_s);
      typing.signal.onMessageSent();
      async.elapse(_s * 30);

      expect(typing.values, [true]);
    });
  });

  test('16 сообщений за минуту — не больше 20 запросов и не чаще раза в 3 с',
      () {
    fakeAsync((async) {
      final typing = _Typing(async);
      for (var i = 0; i < 16; i++) {
        typing.type(_s * 2);
        typing.signal.onMessageSent();
        async.elapse(const Duration(milliseconds: 1750));
      }
      async.elapse(_s * 10);

      expect(typing.sent.length, lessThanOrEqualTo(20));
      expect(typing.closest, greaterThanOrEqualTo(_s * 3));
      expect(typing.values, isNot(contains(false)));
    });
  });

  test('стёр текст сразу после «печатает» — «перестал» ждёт свои 3 секунды',
      () {
    fakeAsync((async) {
      final typing = _Typing(async);
      typing.signal.onInput('п');
      async.elapse(_s);
      typing.signal.onInput('');
      expect(typing.values, [true]);

      async.elapse(_s * 2);
      expect(typing.values, [true, false]);
      expect(typing.closest, _s * 3);
    });
  });

  test('после «перестал» новое «печатает» — тоже не раньше чем через 3 с', () {
    fakeAsync((async) {
      final typing = _Typing(async);
      typing.type(_s);
      async.elapse(_s * 3);
      typing.type(_s * 5);

      expect(typing.values, [true, false, true]);
      expect(typing.closest, greaterThanOrEqualTo(_s * 3));
    });
  });

  test('вышел из чата сразу после «печатает» — лишнего запроса нет', () {
    fakeAsync((async) {
      final typing = _Typing(async);
      typing.signal.onInput('п');
      async.elapse(_s);
      typing.signal.dispose();
      async.elapse(_s * 30);

      expect(typing.values, [true]);
    });
  });

  test('вышел из чата позже — уходит «перестал»', () {
    fakeAsync((async) {
      final typing = _Typing(async);
      typing.type(_s * 4);
      async.elapse(_s * 2);
      typing.signal.dispose();

      expect(typing.values, [true, true, false]);
      expect(typing.closest, greaterThanOrEqualTo(_s * 3));
    });
  });
}
