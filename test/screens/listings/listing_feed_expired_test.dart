import 'package:buking/data/network/response/listing_response.dart';
import 'package:buking/domain/entities/pagination.dart';
import 'package:buking/domain/repositories/auth_repository.dart';
import 'package:buking/main.dart' show sl;
import 'package:buking/screens/home/tabs/listings/listing_feed_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Listing _listing(String id, {bool expired = false}) => Listing(
      id: id,
      type: 'trip',
      status: 'active',
      isExpired: expired,
    );

/// Лента из двух страниц. Между запросами объявление `a` просрочилось,
/// и сервер прислал его ещё раз — уже в хвосте второй страницы.
class _Feed implements AuthRepository {
  final Map<int, List<Listing>> pages;

  _Feed(this.pages);

  @override
  Future<Pagination<Listing>> getListings({
    String? type,
    int? cityFromId,
    int? cityToId,
    bool? verifiedOnly,
    bool? following,
    List<String>? packageTypes,
    String? dateFrom,
    String? dateTo,
    double? weightMin,
    double? weightMax,
    double? priceMin,
    double? priceMax,
    double? ratingMin,
    String? tierMin,
    String? sort,
    int? seed,
    required int page,
    int? perPage,
  }) async =>
      Pagination<Listing>(data: pages[page] ?? const [], lastPage: 2);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(sl.reset);

  test('repeat on a later page: no duplicate, nothing grey above live',
      () async {
    sl.registerSingleton<AuthRepository>(_Feed({
      1: [_listing('a'), _listing('b')],
      2: [_listing('c', expired: true), _listing('a', expired: true)],
    }));
    final bloc = ListingFeedBloc();
    await bloc.load();
    await bloc.load();

    expect(bloc.data.map((l) => l.id), ['a', 'b', 'c']);
    // Уже показанное не подменяется: серая копия наверху встала бы выше
    // живого «b», а сервер держит серые строго в хвосте.
    expect(bloc.data.first.isExpired, isFalse);
    final firstGrey = bloc.data.indexWhere((l) => l.isExpired);
    expect(bloc.data.skip(firstGrey).every((l) => l.isExpired), isTrue);
    expect(bloc.paginableList.value.map((l) => l.id), ['a', 'b', 'c']);
  });

  test('pages without repeats pass through untouched', () async {
    sl.registerSingleton<AuthRepository>(_Feed({
      1: [_listing('a'), _listing('b')],
      2: [_listing('c', expired: true)],
    }));
    final bloc = ListingFeedBloc();
    await bloc.load();
    await bloc.load();

    expect(bloc.data.map((l) => l.id), ['a', 'b', 'c']);
    expect(bloc.data.first.isExpired, isFalse);
  });
}
