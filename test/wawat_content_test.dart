import 'package:buking/services/wawat_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    WawatContent.setRuntimeTranslations(const {});
  });

  test('current locale translations override a stale screen content map', () {
    WawatContent.setRuntimeTranslations(
      const {'menu.language': 'Русский язык'},
    );

    expect(
      WawatContent.text(
        const {'menu.language': 'Dil'},
        'menu.language',
      ),
      'Русский язык',
    );
  });

  test('screen content remains the fallback for a missing runtime key', () {
    WawatContent.setRuntimeTranslations(
      const {'menu.language': 'Русский язык'},
    );

    expect(
      WawatContent.text(
        const {'menu.support': 'Dəstək'},
        'menu.support',
      ),
      'Dəstək',
    );
  });
}
