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

  test('price filter labels put the kilogram before the dollar', () {
    expect(
      WawatContent.priceLabel(
        const {'search.price_min': 'Мин \$'},
        'search.price_min',
      ),
      'Мин kq/\$',
    );
  });

  test('price labels drop the AZN symbol the CMS still serves', () {
    expect(
      WawatContent.priceLabel(
        const {'search.price_max': 'Maks ₼'},
        'search.price_max',
      ),
      'Maks kq/\$',
    );
  });

  test('every per-kg spelling collapses to kq/\$ and stays there', () {
    for (final label in [
      'Мин \$/кг',
      'Min \$/kq',
      'Min \$ / kg',
      'Min kq/\$'
    ]) {
      final normalised = WawatContent.priceLabel(
        {'search.price_min': label},
        'search.price_min',
      );

      expect(normalised, endsWith('kq/\$'));
      expect(
        WawatContent.priceLabel(
          {'search.price_min': normalised},
          'search.price_min',
        ),
        normalised,
      );
    }
  });
}
