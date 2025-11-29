import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/paginable_bloc.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../../../../../domain/entities/pagination.dart';

class SearchOfferBloc extends PaginableBloc<OfferModel> {
  final authRepository = sl.get<AuthRepository>();

  String? offerType;
  String? packageType;
  int? cityFromId;
  int? cityToId;
  String? dateFrom;
  String? dateTo;

  void setSearchParams({
    String? offerType,
    String? packageType,
    int? cityFromId,
    int? cityToId,
    String? dateFrom,
    String? dateTo,
  }) {
    this.offerType = offerType;
    this.packageType = packageType;
    this.cityFromId = cityFromId;
    this.cityToId = cityToId;
    this.dateFrom = dateFrom;
    this.dateTo = dateTo;
  }

  @override
  Future<Pagination<OfferModel>> provideSource(int page) async {
    print('🔍 SearchOfferBloc: Загрузка страницы $page');
    print('Параметры поиска:');
    print('  - offerType: $offerType');
    print('  - packageType: $packageType');
    print('  - cityFromId: $cityFromId');
    print('  - cityToId: $cityToId');
    print('  - dateFrom: $dateFrom');
    print('  - dateTo: $dateTo');

    final response = await authRepository.searchOffers(
      offerType,
      packageType,
      cityFromId,
      cityToId,
      dateFrom,
      dateTo,
      page,
    );

    print('✅ Получено офферов: ${response.data.length}');
    print('Meta: page=${response.meta?.page}, total=${response.meta?.total}, lastPage=${response.meta?.lastPage}');

    // Конвертируем OfferListResponse в Pagination<OfferModel>
    return Pagination<OfferModel>(
      currentPage: response.meta?.page ?? page,
      data: response.data,
      firstPageUrl: '',
      from: (response.meta?.page ?? 1) == 1 ? 1 : ((response.meta?.page ?? 1) - 1) * (response.meta?.perPage ?? 20) + 1,
      lastPage: response.meta?.lastPage ?? 1,
      lastPageUrl: '',
      nextPageUrl: (response.meta?.page ?? 1) < (response.meta?.lastPage ?? 1) ? 'next' : null,
      path: '',
      perPage: response.meta?.perPage ?? 20,
      prevPageUrl: (response.meta?.page ?? 1) > 1 ? 'prev' : null,
      to: (response.meta?.page ?? 1) * (response.meta?.perPage ?? 20),
      total: response.meta?.total ?? response.data.length,
    );
  }
}
