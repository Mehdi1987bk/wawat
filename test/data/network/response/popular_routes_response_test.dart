import 'package:buking/data/network/response/popular_routes_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the popular routes response contract', () {
    final response = PopularRoutesResponse.fromJson({
      'data': [
        {
          'city_from_id': 153698,
          'city_to_id': 153713,
          'city_from': 'Moskva',
          'city_to': 'Bakı',
          'travelers_count': 4,
          'min_price': 0,
          'currency': 'USD',
        },
        {
          'city_from_id': 154140,
          'city_to_id': 153690,
          'city_from': 'Gəncə',
          'city_to': 'İstanbul',
          'travelers_count': 2,
          'min_price': 5.5,
          'currency': 'USD',
        },
      ],
    });

    expect(response.data, hasLength(2));
    expect(response.data.first.label, 'Moskva → Bakı');
    expect(response.data.first.fromCity.id, 153698);
    expect(response.data.first.toCity.id, 153713);
    expect(response.data.first.formattedMinPrice, '0');
    expect(response.data.last.formattedMinPrice, '5.5');
  });

  test('uses an empty list when data is absent', () {
    final response = PopularRoutesResponse.fromJson(const {});

    expect(response.data, isEmpty);
  });
}
