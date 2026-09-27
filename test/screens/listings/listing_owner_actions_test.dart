import 'package:buking/data/network/response/listing_response.dart';
import 'package:buking/screens/home/tabs/listings/widgets/listing_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every status the API sends for a listing.
const _allStatuses = [
  'active',
  'moderation',
  'partially_booked',
  'fully_booked',
  'paused',
  'expired',
  'rejected',
  'deleted',
];

const _promotable = {'active', 'moderation'};

Listing _listing(String status, {ListingPromotion? promotion, String? id}) =>
    Listing(
      id: id ?? 'listing-$status',
      type: 'trip',
      status: status,
      cityFrom: 'Bakı',
      cityTo: 'İstanbul',
      promotion: promotion,
      promotionType: promotion?.type,
    );

Future<void> _pumpOwnerCard(WidgetTester tester, Listing listing) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ListingCard(
            listing: listing,
            isOwner: true,
            onVipTap: (_) {},
            onBoostTap: (_) {},
            onPromotionExtendTap: (_) {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('Listing.canBePromoted', () {
    for (final status in _allStatuses) {
      test(status, () {
        expect(_listing(status).canBePromoted, _promotable.contains(status));
      });
    }

    test('unknown status', () {
      expect(Listing(id: 'x', type: 'trip').canBePromoted, isFalse);
    });
  });

  group('owner card without a promotion', () {
    for (final status in _allStatuses) {
      final visible = _promotable.contains(status);
      testWidgets('$status → VIP / boost ${visible ? 'shown' : 'hidden'}', (
        tester,
      ) async {
        await _pumpOwnerCard(tester, _listing(status));
        final matcher = visible ? findsOneWidget : findsNothing;
        expect(find.text('VİP et'), matcher);
        expect(find.text('Önə çək'), matcher);
      });
    }
  });

  group('owner card with a running VIP', () {
    const vip = ListingPromotion(type: 'vip', typeLabel: 'VİP');
    for (final status in _allStatuses) {
      final visible = _promotable.contains(status);
      testWidgets('$status → extend ${visible ? 'shown' : 'hidden'}', (
        tester,
      ) async {
        await _pumpOwnerCard(tester, _listing(status, promotion: vip));
        // The status panel is information, not a CTA — it stays.
        expect(find.text('VİP aktiv'), findsOneWidget);
        expect(find.text('Uzat'), visible ? findsOneWidget : findsNothing);
        // VIP and boost don't mix: no boost CTA of any kind on a VIP listing.
        expect(find.text('Önə də çək'), findsNothing);
        expect(find.text('Önə çək'), findsNothing);
        expect(find.text('Zolağı yüksəlt'), findsNothing);
        expect(find.text('VİP et'), findsNothing);
      });
    }
  });

  group('owner card with a running boost', () {
    const boost = ListingPromotion(type: 'featured', typeLabel: 'Önə çəkilən');
    for (final status in _allStatuses) {
      final visible = _promotable.contains(status);
      testWidgets('$status → VIP / extend ${visible ? 'shown' : 'hidden'}', (
        tester,
      ) async {
        await _pumpOwnerCard(tester, _listing(status, promotion: boost));
        final matcher = visible ? findsOneWidget : findsNothing;
        // A boosted listing may still go VIP, and keeps its boost extension.
        expect(find.text('VİP et'), matcher);
        expect(find.text('Uzat'), matcher);
        expect(find.text('Zolağı yüksəlt'), matcher);
      });
    }
  });

  group('VIP ⟂ boost rule', () {
    test('no promotion → both', () {
      final listing = _listing('active');
      expect(listing.activePromotionType, isNull);
      expect(listing.canBuyVip, isTrue);
      expect(listing.canBuyBoost, isTrue);
    });

    test('VIP (flat promotion_type only) → VIP yes, boost no', () {
      final listing = Listing(
        id: 'x',
        type: 'trip',
        status: 'active',
        promotionType: 'vip',
      );
      expect(listing.activePromotionType, 'vip');
      expect(listing.canBuyVip, isTrue);
      expect(listing.canBuyBoost, isFalse);
    });

    test('boost → VIP yes, boost (extend / upgrade) yes', () {
      final listing = _listing(
        'active',
        promotion: const ListingPromotion(type: 'featured', typeLabel: 'B'),
      );
      expect(listing.activePromotionType, 'featured');
      expect(listing.canBuyVip, isTrue);
      expect(listing.canBuyBoost, isTrue);
    });

    test('the nested promotion.type wins over the flat field', () {
      final listing = Listing(
        id: 'x',
        type: 'trip',
        status: 'active',
        promotionType: 'featured',
        promotion: const ListingPromotion(type: 'vip', typeLabel: 'VİP'),
      );
      expect(listing.activePromotionType, 'vip');
      expect(listing.canBuyBoost, isFalse);
    });

    test('not promotable → neither, whatever the promotion', () {
      final listing = Listing(
        id: 'x',
        type: 'trip',
        status: 'expired',
        promotionType: 'featured',
      );
      expect(listing.canBuyVip, isFalse);
      expect(listing.canBuyBoost, isFalse);
    });
  });

  testWidgets('VIP bought → boost goes on refresh; VIP over → boost is back', (
    tester,
  ) async {
    const vip = ListingPromotion(type: 'vip', typeLabel: 'VİP');
    await _pumpOwnerCard(tester, _listing('active', id: 'same'));
    expect(find.text('Önə çək'), findsOneWidget);

    // The list re-reads the listing after the purchase.
    await _pumpOwnerCard(
      tester,
      _listing('active', id: 'same', promotion: vip),
    );
    expect(find.text('Önə çək'), findsNothing);
    expect(find.text('Önə də çək'), findsNothing);

    // Server cleared promotion_type once the VIP ran out.
    await _pumpOwnerCard(tester, _listing('active', id: 'same'));
    expect(find.text('Önə çək'), findsOneWidget);
    expect(find.text('VİP et'), findsOneWidget);
  });

  group('owner action row', () {
    // Status → which of pause / resume / repost the backend allows.
    const expected = {
      'active': {'Dayandır'},
      'moderation': {'Dayandır'},
      'paused': {'Aktiv et'},
      'expired': {'Repost'},
      'rejected': {'Repost'},
      'partially_booked': <String>{},
      'fully_booked': <String>{},
      'deleted': <String>{},
    };
    for (final entry in expected.entries) {
      final shown = entry.value.isEmpty ? 'none' : entry.value.join(', ');
      testWidgets('${entry.key} → $shown', (tester) async {
        await _pumpOwnerCard(tester, _listing(entry.key));
        for (final label in const ['Dayandır', 'Aktiv et', 'Repost']) {
          expect(
            find.text(label),
            entry.value.contains(label) ? findsOneWidget : findsNothing,
            reason: label,
          );
        }
        expect(
          find.text('Sil'),
          entry.key == 'deleted' ? findsNothing : findsOneWidget,
        );
      });
    }
  });

  testWidgets('a listing that expires while shown loses the CTAs on refresh', (
    tester,
  ) async {
    // Same listing, same card state — only the refreshed status changes.
    await _pumpOwnerCard(tester, _listing('active', id: 'same'));
    expect(find.text('VİP et'), findsOneWidget);

    await _pumpOwnerCard(tester, _listing('expired', id: 'same'));
    expect(find.text('VİP et'), findsNothing);
    expect(find.text('Önə çək'), findsNothing);
  });
}
