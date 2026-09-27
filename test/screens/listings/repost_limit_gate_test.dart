import 'package:buking/data/network/response/user.dart';
import 'package:buking/domain/repositories/auth_repository.dart';
import 'package:buking/main.dart';
import 'package:buking/screens/home/tabs/create_post/listing_limit_gate_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Only `/auth/me` is used by the repost entry; everything else is unexpected.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._me);

  final Future<User> Function() _me;
  int meCalls = 0;

  @override
  Future<User> customersMe() {
    meCalls++;
    return _me();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

ListingQuotaItem _quota(int remaining, {int limit = 3}) => ListingQuotaItem(
  active: limit - remaining,
  limit: limit,
  remaining: remaining,
);

User _meWith({ListingQuotaItem? trip, ListingQuotaItem? shipment}) => User(
  id: 1,
  fullname: 'Test',
  listingQuota: ListingQuota(trip: trip, shipmentPost: shipment),
);

void _useAuth(_FakeAuthRepository repository) {
  if (sl.isRegistered<AuthRepository>()) sl.unregister<AuthRepository>();
  sl.registerSingleton<AuthRepository>(repository);
}

void main() {
  tearDown(() {
    if (sl.isRegistered<AuthRepository>()) sl.unregister<AuthRepository>();
  });

  group('repostNeedsLimitGate', () {
    test('no slot left → gate', () {
      expect(repostNeedsLimitGate(_quota(0)), isTrue);
    });

    test('over the limit (negative remaining) → gate', () {
      expect(repostNeedsLimitGate(_quota(-1)), isTrue);
    });

    test('a slot left → form as before', () {
      expect(repostNeedsLimitGate(_quota(1)), isFalse);
    });

    test('quota unknown → form (server 422 falls back to the gate)', () {
      expect(repostNeedsLimitGate(null), isFalse);
    });
  });

  group('fetchListingQuota', () {
    test('always re-reads /auth/me and picks the listing type', () async {
      final repository = _FakeAuthRepository(
        () async => _meWith(trip: _quota(2), shipment: _quota(0)),
      );
      _useAuth(repository);

      final trip = await fetchListingQuota('trip');
      final shipment = await fetchListingQuota('shipment_post');

      expect(repository.meCalls, 2);
      expect(trip?.remaining, 2);
      expect(repostNeedsLimitGate(trip), isFalse);
      expect(shipment?.remaining, 0);
      expect(repostNeedsLimitGate(shipment), isTrue);
    });

    test('/auth/me fails → null, repost is not blocked', () async {
      _useAuth(_FakeAuthRepository(() async => throw Exception('offline')));

      final quota = await fetchListingQuota('trip');

      expect(quota, isNull);
      expect(repostNeedsLimitGate(quota), isFalse);
    });

    test('no listing_quota in /auth/me → null', () async {
      _useAuth(_FakeAuthRepository(() async => User(id: 1, fullname: 'Test')));

      expect(await fetchListingQuota('shipment_post'), isNull);
    });
  });
}
