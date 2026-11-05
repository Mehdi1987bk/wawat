import 'dart:convert';

import 'package:buking/data/network/response/content_response.dart';
import 'package:buking/data/network/response/listing_response.dart';
import 'package:buking/domain/repositories/auth_repository.dart';
import 'package:buking/main.dart' show sl;
import 'package:buking/screens/home/tabs/listings/widgets/listing_card.dart';
import 'package:buking/screens/home/tabs/listings/widgets/listing_expired.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// Живые ответы GET /api/v1/listings (Accept-Language: ru) от 05.11.2026.
// Поля зависят от type: у shipment_post нет полей рейса вовсе.
Map<String, dynamic> _liveTripJson() => {
      'id': '01M3TQ19EB97PMPFY8SFTCF5V6',
      'type': 'trip',
      'type_label': 'Путешественник',
      'status': 'active',
      'status_label': 'Активно',
      'city_from_id': 153690,
      'city_to_id': 153713,
      'city_from': 'Стамбул',
      'city_to': 'Баку',
      'package_type_codes': ['documents', 'clothing', 'other'],
      'description': 'kiçik eşyalar qebul edilir',
      'view_count': 3913,
      'promotion_type': null,
      'favorites_count': 2,
      'is_favorited': false,
      'available_actions': <dynamic>[],
      'is_full': false,
      'is_expired': false,
      'has_pending_proposals': null,
      'owner': {
        'username': 'azada.malikzade',
        'first_name': 'Azada',
        'last_name': 'Malikzade',
        'full_name': 'Azada Malikzade',
        'avatar_url': null,
        'avatar_thumb_url': null,
        'is_verified': false,
        'tier': 'new',
        'rating_avg': 0,
        'rating_count': 0,
        'completed_shipments_count': 0,
        'avg_response_minutes': null,
      },
      'flight_date': '2026-11-06',
      'flight_time': '23:10',
      'flight_number': 'PC854',
      'max_weight_kg': 5,
      'reserved_kg': 0,
      'price_per_kg': 10,
      'allow_price_negotiation': false,
      'created_at': '2026-06-09T08:35:14+00:00',
    };

Map<String, dynamic> _expiredShipmentJson({bool withAvatar = true}) => {
      'id': '01M3TQ19EB97PMPFY8SFTCF5W4',
      'type': 'shipment_post',
      'type_label': 'Отправитель',
      'status': 'expired',
      'status_label': 'Истекло',
      'city_from_id': 153713,
      'city_to_id': 153690,
      'city_from': 'Баку',
      'city_to': 'Стамбул',
      'package_type_codes': ['documents'],
      'description':
          'A3 boyutunda tek adet resmi evrak zarf içerisinde gönderilecektir.',
      'view_count': 9,
      'promotion_type': null,
      'favorites_count': 0,
      'is_favorited': false,
      'available_actions': <dynamic>[],
      'is_full': false,
      'is_expired': true,
      'has_pending_proposals': null,
      'owner': {
        'username': 'ferda.aydar',
        'first_name': 'Ferda',
        'last_name': 'Aydar',
        'full_name': 'Ferda Aydar',
        'avatar_url': withAvatar
            ? 'https://api.wawatair.com/storage/avatars/user-319-1781038180.jpg?v=1793844611'
            : null,
        'avatar_thumb_url': withAvatar
            ? 'https://api.wawatair.com/storage/avatars/user-319-1781038180_thumb.jpg?v=1793844611'
            : null,
        'is_verified': false,
        'tier': 'new',
        'rating_avg': 0,
        'rating_count': 0,
        'completed_shipments_count': 0,
        'avg_response_minutes': null,
      },
      'delivery_date_from': '2026-06-11',
      'delivery_date_to': '2026-06-15',
      'weight_kg': null,
      'created_at': '2026-06-10T07:45:20+00:00',
    };

class _NoContent implements AuthRepository {
  @override
  Future<ContentResponse> getContent({String? group, String? lang}) async =>
      ContentResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpCard(
  WidgetTester tester,
  Listing listing, {
  bool isOwner = false,
  String? promotionTypeOverride,
  ListingFavoriteCallback? onFavoriteChanged,
  ValueChanged<Listing>? onDetailsTap,
  ValueChanged<Listing>? onOfferTap,
  ValueChanged<Listing>? onMessageTap,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ListingCard(
            listing: listing,
            isOwner: isOwner,
            promotionTypeOverride: promotionTypeOverride,
            onFavoriteChanged: onFavoriteChanged,
            onDetailsTap: onDetailsTap,
            onOfferTap: onOfferTap ?? (_) {},
            onMessageTap: onMessageTap ?? (_) {},
            onRepostTap: (_) {},
            onDeleteTap: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    sl.registerSingleton<AuthRepository>(_NoContent());
  });
  tearDownAll(sl.reset);

  group('Listing.isExpired parsing', () {
    test('live trip → false, flight fields present', () {
      final listing = Listing.fromJson(_liveTripJson());
      expect(listing.isExpired, isFalse);
      expect(listing.flightNumber, 'PC854');
    });

    test('expired shipment_post (no flight keys at all) parses', () {
      final listing = Listing.fromJson(_expiredShipmentJson());
      expect(listing.isExpired, isTrue);
      expect(listing.isShipment, isTrue);
      expect(listing.flightDate, isNull);
      expect(listing.flightTime, isNull);
      expect(listing.pricePerKg, isNull);
      expect(listing.maxWeightKg, isNull);
      expect(listing.weightKg, isNull);
      expect(listing.deliveryDateFrom, '2026-06-11');
    });

    test('field absent → false; 1 / "true" → true', () {
      final base = _liveTripJson()..remove('is_expired');
      expect(Listing.fromJson(base).isExpired, isFalse);
      expect(
        Listing.fromJson({..._liveTripJson(), 'is_expired': 1}).isExpired,
        isTrue,
      );
      expect(
        Listing.fromJson({..._liveTripJson(), 'is_expired': 'true'}).isExpired,
        isTrue,
      );
    });

    test('round-trips through toJson', () {
      final listing = Listing.fromJson(_expiredShipmentJson());
      final json = jsonDecode(jsonEncode(listing.toJson()));
      expect(Listing.fromJson(json as Map<String, dynamic>).isExpired, isTrue);
    });

    test('expiry follows is_expired, not status', () {
      // Рейс уже вылетел, а крон ещё не перевёл status.
      final justDeparted = Listing.fromJson(
        {..._liveTripJson(), 'is_expired': true},
      );
      expect(justDeparted.status, 'active');
      expect(justDeparted.isExpired, isTrue);
    });
  });

  group('listingExpiredLabel', () {
    test('server status_label once status is expired', () {
      final listing = Listing.fromJson(_expiredShipmentJson());
      expect(listingExpiredLabel(listing), 'Истекло');
    });

    test('status not switched yet → CMS label, never «Активно»', () {
      final listing = Listing.fromJson({..._liveTripJson(), 'is_expired': true});
      expect(listingExpiredLabel(listing), isNot('Активно'));
      expect(listingExpiredLabel(listing), 'Vaxtı keçib');
    });
  });

  group('ListingCard, expired, public feed', () {
    testWidgets('pill with server label, no offer button, message stays', (
      tester,
    ) async {
      Listing? messaged;
      await _pumpCard(
        tester,
        Listing.fromJson(_expiredShipmentJson(withAvatar: false)),
        onMessageTap: (l) => messaged = l,
      );

      expect(find.byType(ListingExpiredPill), findsOneWidget);
      expect(find.text('Истекло'), findsOneWidget);
      expect(find.byIcon(PhosphorIconsFill.clockCountdown), findsOneWidget);
      expect(find.text('Təklif göndər'), findsNothing);
      expect(find.text('Yer yoxdur'), findsNothing);

      await tester.tap(find.text('Mesaj'));
      expect(messaged?.id, '01M3TQ19EB97PMPFY8SFTCF5W4');
    });

    testWidgets('pill is not dimmed by an Opacity ancestor', (tester) async {
      await _pumpCard(
        tester,
        Listing.fromJson(_expiredShipmentJson(withAvatar: false)),
      );
      final opacities = find.ancestor(
        of: find.byType(ListingExpiredPill),
        matching: find.byType(Opacity),
      );
      expect(opacities, findsNothing);
    });

    testWidgets('heart works and the card opens details', (tester) async {
      final calls = <bool>[];
      Listing? opened;
      await _pumpCard(
        tester,
        Listing.fromJson(_expiredShipmentJson(withAvatar: false)),
        onFavoriteChanged: (listing, next) async => calls.add(next),
        onDetailsTap: (l) => opened = l,
      );

      await tester.tap(find.byIcon(PhosphorIconsRegular.heart));
      await tester.pump();
      expect(calls, [true]);
      expect(find.byIcon(PhosphorIconsFill.heart), findsOneWidget);

      await tester.tap(find.text('Баку'));
      expect(opened?.id, '01M3TQ19EB97PMPFY8SFTCF5W4');
    });

    testWidgets('owner avatar is greyscaled', (tester) async {
      await _pumpCard(
        tester,
        Listing.fromJson(_expiredShipmentJson(withAvatar: false)),
      );
      expect(
        find.ancestor(
          of: find.byType(CircleAvatar),
          matching: find.byType(ColorFiltered),
        ),
        findsOneWidget,
      );
    });

    testWidgets('just departed (status still active) is grey too', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        Listing.fromJson({..._liveTripJson(), 'is_expired': true}),
      );
      expect(find.byType(ListingExpiredPill), findsOneWidget);
      expect(find.text('Активно'), findsNothing);
      expect(find.text('Təklif göndər'), findsNothing);
    });
  });

  group('ListingCard, nothing else changes', () {
    testWidgets('live trip keeps the offer button and no pill', (
      tester,
    ) async {
      Listing? offered;
      await _pumpCard(
        tester,
        Listing.fromJson(_liveTripJson()),
        onOfferTap: (l) => offered = l,
      );
      expect(find.byType(ListingExpiredPill), findsNothing);
      expect(find.byType(ColorFiltered), findsNothing);
      await tester.tap(find.text('Təklif göndər'));
      expect(offered?.id, '01M3TQ19EB97PMPFY8SFTCF5V6');
    });

    testWidgets('fully booked keeps its disabled «no space» button', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        Listing.fromJson({
          ..._liveTripJson(),
          'status': 'fully_booked',
          'status_label': 'Yer yoxdur',
          'is_full': true,
        }),
      );
      expect(find.byType(ListingExpiredPill), findsNothing);
      expect(find.text('Yer yoxdur'), findsWidgets);
      expect(find.text('Təklif göndər'), findsNothing);
    });

    testWidgets('VIP preview of a just-departed listing is not greyed', (
      tester,
    ) async {
      // Превью в покупке продвижения рисует карточку «как увидят другие»;
      // пока крон не сменил status, владелец может туда попасть.
      await _pumpCard(
        tester,
        Listing.fromJson({..._liveTripJson(), 'is_expired': true}),
        promotionTypeOverride: 'vip',
      );
      expect(find.byType(ListingExpiredPill), findsNothing);
      expect(find.byType(ColorFiltered), findsNothing);
    });

    testWidgets('owner sees own expired listing as before (Repost, no pill)', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        Listing.fromJson(_expiredShipmentJson(withAvatar: false)),
        isOwner: true,
      );
      expect(find.byType(ListingExpiredPill), findsNothing);
      expect(find.text('Repost'), findsOneWidget);
    });
  });
}
