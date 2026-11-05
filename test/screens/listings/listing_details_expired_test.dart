import 'package:buking/data/network/response/content_response.dart';
import 'package:buking/data/network/response/listing_response.dart';
import 'package:buking/data/network/response/package_types_response.dart';
import 'package:buking/domain/repositories/auth_repository.dart';
import 'package:buking/main.dart' show sl;
import 'package:buking/screens/home/tabs/listings/details/listing_details_screen.dart';
import 'package:buking/screens/home/tabs/listings/widgets/listing_expired.dart';
import 'package:buking/services/localization_service.dart';
import 'package:buking/services/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

// Живой ответ GET /api/v1/listings/{id} по просроченному shipment_post
// (05.11.2026): 200 для посетителя, полей рейса нет вовсе.
Map<String, dynamic> _expiredShipment({String status = 'expired'}) => {
      'id': '01M3TQ19EB97PMPFY8SFTCF5W4',
      'type': 'shipment_post',
      'type_label': 'Отправитель',
      'status': status,
      'status_label': status == 'expired' ? 'Истекло' : 'Активно',
      'city_from': 'Баку',
      'city_to': 'Стамбул',
      'package_type_codes': ['documents'],
      'description': 'A3 boyutunda tek adet resmi evrak.',
      'view_count': 9,
      'promotion_type': null,
      'favorites_count': 0,
      'is_favorited': false,
      'available_actions': <dynamic>[],
      'is_full': false,
      'is_expired': true,
      'owner': {
        'username': 'ferda.aydar',
        'full_name': 'Ferda Aydar',
        'is_verified': false,
        'tier': 'new',
        'rating_avg': 0,
        'rating_count': 0,
      },
      'delivery_date_from': '2026-06-11',
      'delivery_date_to': '2026-06-15',
      'weight_kg': null,
      'created_at': '2026-06-10T07:45:20+00:00',
    };

Map<String, dynamic> _liveTrip() => {
      'id': 'live-trip',
      'type': 'trip',
      'type_label': 'Səyahətçi',
      'status': 'active',
      'status_label': 'Aktiv',
      'city_from': 'İstanbul',
      'city_to': 'Bakı',
      'package_type_codes': ['documents'],
      'is_favorited': false,
      'is_full': false,
      'is_expired': false,
      'owner': {'username': 'azada', 'full_name': 'Azada M', 'tier': 'new'},
      'flight_date': '2026-11-06',
      'flight_time': '23:10',
      'flight_number': 'PC854',
      'max_weight_kg': 5,
      'reserved_kg': 0,
      'price_per_kg': 10,
      'allow_price_negotiation': false,
    };

class _Repo implements AuthRepository {
  Map<String, dynamic> json = const {};

  @override
  Future<ContentResponse> getContent({String? group, String? lang}) async =>
      ContentResponse();

  @override
  Future<bool> isLogged() async => false;

  @override
  Future<PackageTypesResponse> getListingPackageTypes() async =>
      PackageTypesResponse(data: [
        PackageType(code: 'documents', name: 'Sənədlər', icon: ''),
      ]);

  @override
  Future<ListingResponse> getListingDetails(String id) async =>
      ListingResponse.fromJson({'data': json});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LightTheme extends ThemeManager {
  @override
  bool get isDarkMode => false;
}

final _repo = _Repo();

Future<void> _pumpDetails(WidgetTester tester, Map<String, dynamic> json) async {
  _repo.json = json;
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeManager>.value(value: _LightTheme()),
        ChangeNotifierProvider.value(value: LocalizationService.instance),
      ],
      child: MaterialApp(
        home: ListingDetailsScreen(listingId: json['id'] as String),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    sl.registerSingleton<AuthRepository>(_repo);
  });
  tearDownAll(sl.reset);

  testWidgets('expired: opens, pill in header, strip instead of offer', (
    tester,
  ) async {
    await _pumpDetails(tester, _expiredShipment());

    expect(find.text('Баку'), findsWidgets);
    expect(find.byType(ListingExpiredPill), findsOneWidget);
    expect(find.text('Истекло'), findsOneWidget);
    expect(find.text('Təklif göndər'), findsNothing);
    expect(find.text(listingExpiredNotice()), findsOneWidget);
    // Остальное доступно: написать владельцу и добавить в избранное.
    expect(find.text('Mesaj'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.heart), findsOneWidget);
  });

  testWidgets('expired strip is not tappable and opens no sheet', (
    tester,
  ) async {
    await _pumpDetails(tester, _expiredShipment());
    await tester.tap(find.text(listingExpiredNotice()), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('just departed (status still active): grey by is_expired', (
    tester,
  ) async {
    await _pumpDetails(tester, _expiredShipment(status: 'active'));
    expect(find.byType(ListingExpiredPill), findsOneWidget);
    expect(find.text('Активно'), findsNothing);
    expect(find.text('Təklif göndər'), findsNothing);
  });

  testWidgets('live listing keeps the offer button and has no pill', (
    tester,
  ) async {
    await _pumpDetails(tester, _liveTrip());
    expect(find.byType(ListingExpiredPill), findsNothing);
    expect(find.text('Təklif göndər'), findsOneWidget);
    expect(find.text(listingExpiredNotice()), findsNothing);
  });

  test('strip text exists in every app language', () {
    // До загрузки CMS текст берётся из запасных переводов по языку.
    expect(listingExpiredNotice(), isNotEmpty);
  });
}
