import 'package:buking/screens/payments/iap/iap_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the backend purchase catalogue', () {
    final products = parseIapCatalog({
      'data': {
        'products': [
          {
            'product_id': 'wawat.app.vip.3d',
            'kind': 'vip',
            'duration_days': 3,
            'price': '1.99',
            'currency': 'USD',
          },
          {
            'product_id': 'wawat.app.boost.small',
            'package_id': 'boost-small',
            'kind': 'featured',
            'package': 'small',
            'name': 'Önə çıxarılan · Kiçik',
            'description': 'Zəmanətli göstəriş paketi',
            'guaranteed_min': 117,
            'guaranteed_max': 235,
            'recommended': true,
            'sort_order': 2,
            'price': 9,
            'currency': 'AZN',
          },
          {
            'product_id': 'wawat.app.quota.trip.5',
            'kind': 'quota',
            'listing_type': 'trip',
            'extra_listings': 5,
            'price': 15,
            'currency': 'AZN',
          },
        ],
      },
    });

    expect(products, hasLength(3));
    expect(products[0].kind, IapProductKind.vip);
    expect(products[0].durationDays, 3);
    expect(products[0].price, 1.99);
    expect(products[1].kind, IapProductKind.featured);
    expect(products[1].boostPackage, 'small');
    expect(products[1].packageId, 'boost-small');
    expect(products[1].name, 'Önə çıxarılan · Kiçik');
    expect(products[1].description, 'Zəmanətli göstəriş paketi');
    expect(products[1].guaranteedMin, 117);
    expect(products[1].guaranteedMax, 235);
    expect(products[1].recommended, isTrue);
    expect(products[1].sortOrder, 2);
    expect(products[2].kind, IapProductKind.quota);
    expect(products[2].listingType, 'trip');
    expect(products[2].extraListings, 5);
  });

  test('selects the promotion product by server metadata', () {
    final vip = iapProductForPromotion(
      kDevIapProducts,
      promotionType: 'vip',
      durationDays: 5,
    );
    final boost = iapProductForPromotion(
      kDevIapProducts,
      promotionType: 'featured',
      boostPackage: 'medium',
    );

    expect(vip?.productId, 'wawat.app.vip.5d');
    expect(boost?.productId, 'wawat.app.boost.medium');
  });

  test('preserves the backend product id and duration', () {
    final products = parseIapCatalog({
      'data': {
        'products': [
          {
            'product_id': 'wawat.app.vip.1d',
            'kind': 'vip',
            'duration_days': 1,
            'price': 3,
            'currency': 'AZN',
          },
        ],
      },
    });

    expect(products.single.productId, 'wawat.app.vip.1d');
    expect(products.single.durationDays, 1);
  });
}
