import '../../../../../data/network/request/offer_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/paginable_bloc.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../../../../../domain/entities/pagination.dart';

class SearchOfferBloc extends PaginableBloc<OfferModel> {
  final authRepository = sl.get<AuthRepository>();
  final Stream onReflash;
  String? offerType;
  String? packageType;
  int? cityFromId;
  int? cityToId;
  String? dateFrom;
  String? dateTo;

  SearchOfferBloc(
    this.onReflash,
  );

  @override
  void init() {
    super.init();
    onReflash.listen((event) {
      load(refresh: true);
    });
  }

  Future<void> loadList() async {
    load(refresh: true);
  }

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
  Future<Pagination<OfferModel>> provideSource(int page) {
    return run(authRepository.searchOffers(
      offerType,
      packageType,
      cityFromId,
      cityToId,
      dateFrom,
      dateTo,
      page,
    ));
  }

  Future<void> setFavorites(int offerId) =>
      authRepository.setFavorites(OfferResponse(offerId: offerId));
}
