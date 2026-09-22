import 'package:buking/services/app_update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUpdateInfo.fromJson', () {
    test('parses the wrapped backend contract', () {
      final info = AppUpdateInfo.fromJson({
        'data': {
          'force_update': true,
          'latest_version': '1.2.0',
          'title': 'Update',
          'message': 'Install the latest version',
          'store_url': 'https://example.com/store',
        },
      });

      expect(info.forceUpdate, isTrue);
      expect(info.latestVersion, '1.2.0');
      expect(info.title, 'Update');
      expect(info.message, 'Install the latest version');
      expect(info.storeUrl, 'https://example.com/store');
    });

    test('accepts the flat Namazov response and string booleans', () {
      final info = AppUpdateInfo.fromJson({
        'force_update': 'true',
        'latest_version': '2.0.0',
      });

      expect(info.forceUpdate, isTrue);
      expect(info.latestVersion, '2.0.0');
    });

    test('defaults to no forced update for incomplete responses', () {
      final info = AppUpdateInfo.fromJson(const {});

      expect(info.forceUpdate, isFalse);
      expect(info.storeUrl, isNull);
    });
  });
}
