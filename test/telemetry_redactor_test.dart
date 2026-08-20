import 'package:buking/services/telemetry/telemetry_events.dart';
import 'package:buking/services/telemetry/telemetry_redactor.dart';
import 'package:flutter_test/flutter_test.dart';

/// Эти тесты защищают обещание, данное сторам.
///
/// В `ios/Runner/PrivacyInfo.xcprivacy` и в форме Data safety заявлено, что
/// диагностика не содержит контактных данных, токенов и текстов сообщений.
/// Если редактор перестанет их вычищать, приложение начнёт нарушать
/// собственную декларацию — молча. Поэтому проверяем именно это.
void main() {
  group('TelemetryRedactor.redact', () {
    test('вырезает Bearer-токен', () {
      final out = TelemetryRedactor.redact(
          'GET /listings failed, Authorization: Bearer eyJhbGciOi.abc123_def');
      expect(out, contains('Bearer ***'));
      expect(out, isNot(contains('eyJhbGciOi.abc123_def')));
    });

    test('вырезает JWT в теле ответа', () {
      final out = TelemetryRedactor.redact(
          '{"token":"eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NSJ9.SflKxwRJSM"}');
      expect(out, isNot(contains('SflKxwRJSM')));
    });

    test('вырезает e-mail', () {
      final out = TelemetryRedactor.redact('user tahir.guliyev@gmail.com failed');
      expect(out, isNot(contains('tahir.guliyev@gmail.com')));
      expect(out, contains('***@***'));
    });

    test('вырезает телефон в азербайджанском формате', () {
      final out = TelemetryRedactor.redact('phone +994 50 123 45 67 not found');
      expect(out, isNot(contains('994')));
      expect(out, isNot(contains('123 45 67')));
    });

    test('вырезает пароль и OTP из JSON', () {
      final out = TelemetryRedactor.redact(
          '{"phone":"0501234567","password":"hunter2","otp":"4821"}');
      expect(out, isNot(contains('hunter2')));
      expect(out, isNot(contains('4821')));
    });

    test('обрезает по максимальной длине', () {
      final out = TelemetryRedactor.redact('x' * 1000, maxLength: 50);
      expect(out.length, 50);
      expect(out, endsWith('…'));
    });

    test('сохраняет переносы строк в стек-трейсе', () {
      const stack = '#0  A.build (a.dart:1:2)\n#1  B.build (b.dart:3:4)';
      final out =
          TelemetryRedactor.redact(stack, collapseWhitespace: false);
      expect(out.split('\n').length, 2);
      expect(out, contains('a.dart'));
      expect(out, contains('b.dart'));
    });

    test('на пустом входе не падает', () {
      expect(TelemetryRedactor.redact(null), '');
      expect(TelemetryRedactor.redact(''), '');
    });
  });

  group('TelemetryRedactor.endpoint', () {
    test('схлопывает числовые id — иначе панель не сгруппирует эндпоинты', () {
      expect(TelemetryRedactor.endpoint('/api/v1/listings/8123/proposals'),
          '/listings/{id}/proposals');
      expect(TelemetryRedactor.endpoint('/api/v1/listings/8123'),
          '/listings/{id}');
    });

    test('схлопывает uuid', () {
      expect(
        TelemetryRedactor.endpoint(
            '/api/v1/conversations/3f2a91bc-1111-2222-3333-444455556666/messages'),
        '/conversations/{id}/messages',
      );
    });

    test('отрезает хост и query', () {
      expect(
        TelemetryRedactor.endpoint(
            'https://api.wawatair.com/api/v1/listings?page=2&search=baku'),
        '/listings',
      );
    });

    test('на пустом пути возвращает unknown', () {
      expect(TelemetryRedactor.endpoint(null), 'unknown');
    });
  });

  group('TelemetryRedactor.value', () {
    test('маскирует чувствительные ключи целиком', () {
      final out = TelemetryRedactor.value({
        'listing_id': 12,
        'phone': '+994501234567',
        'body': 'привет, где посылка?',
        'password': 'hunter2',
      }) as Map<String, Object?>;

      expect(out['listing_id'], 12);
      expect(out['phone'], '***');
      expect(out['body'], '***');
      expect(out['password'], '***');
    });

    test('не уходит в бесконечную вложенность', () {
      Object nested = 'leaf';
      for (var i = 0; i < 10; i++) {
        nested = {'k': nested};
      }
      expect(() => TelemetryRedactor.value(nested), returnsNormally);
    });
  });

  group('TelemetrySchema', () {
    test('приводит имя события к требованиям Firebase', () {
      expect(TelemetrySchema.name('Listing Details/Screen'),
          'listing_details_screen');
      expect(TelemetrySchema.name('123start'), 'start');
      expect(TelemetrySchema.name('a' * 60).length,
          TelemetrySchema.maxEventNameLength);
    });

    test('уводит зарезервированные префиксы Firebase из-под запрета', () {
      expect(TelemetrySchema.name('firebase_boot'), startsWith('app_'));
      expect(TelemetrySchema.name('ga_thing'), startsWith('app_'));
    });

    test('оставляет только типы, которые принимает Analytics', () {
      final out = TelemetrySchema.params({
        'count': 5,
        'ratio': 1.5,
        'flag': true,
        'text': 'ok',
        'skipped': null,
        'empty': '   ',
        'list': [1, 2, 3],
      });

      expect(out['count'], 5);
      expect(out['ratio'], 1.5);
      expect(out['flag'], 'true');
      expect(out['text'], 'ok');
      expect(out.containsKey('skipped'), isFalse);
      expect(out.containsKey('empty'), isFalse);
      expect(out['list'], '[1,2,3]');
      for (final v in out.values) {
        expect(v is String || v is num, isTrue,
            reason: 'Analytics отбросит событие с любым другим типом');
      }
    });

    test('режет строковое значение до лимита', () {
      final out = TelemetrySchema.params({'text': 'y' * 300});
      expect((out['text']! as String).length,
          TelemetrySchema.maxParamValueLength);
    });

    test('не отдаёт больше 25 параметров', () {
      final raw = {for (var i = 0; i < 40; i++) 'k$i': i};
      expect(TelemetrySchema.params(raw).length, TelemetrySchema.maxParams);
    });

    test('user property не длиннее лимита', () {
      expect(TelemetrySchema.userPropValue('z' * 100).length,
          TelemetrySchema.maxUserPropValueLength);
      expect(TelemetrySchema.userPropName('a_very_long_user_property_name_here')
          .length,
          lessThanOrEqualTo(TelemetrySchema.maxUserPropNameLength));
    });
  });
}
