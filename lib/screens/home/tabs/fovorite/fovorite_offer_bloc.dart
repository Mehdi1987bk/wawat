import '../../../../../data/network/request/offer_response.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/paginable_bloc.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../../../../../domain/entities/pagination.dart';

class FovoriteOfferBloc extends PaginableBloc<OfferModel> {
  final authRepository = sl.get<AuthRepository>();
  final Stream onReflash;

  FovoriteOfferBloc(
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

  @override
  Future<Pagination<OfferModel>> provideSource(int page) {
    return run(authRepository.getFavorites(
      page,
    ));
  }

  Future<void> setFavorites(int offerId) async {
    await authRepository.setFavorites(OfferResponse(offerId: offerId));
    load(refresh: true); // Обновляем список
  }
}
