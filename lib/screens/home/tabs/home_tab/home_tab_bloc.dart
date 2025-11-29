import 'package:buking/data/network/response/offer_type_model.dart';
import 'package:buking/data/network/response/offer_types_response.dart';
import 'package:intl/intl.dart';

import 'package:rxdart/rxdart.dart';

import '../../../../data/network/request/offer_response.dart';
import '../../../../data/network/response/all_request_data.dart';
import '../../../../data/network/response/cities_response.dart';
import '../../../../data/network/response/offer_models.dart';
import '../../../../data/network/response/packages_response.dart';
import '../../../../data/network/response/user.dart';
import '../../../../domain/entities/pagination.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';
import '../../../../presentation/bloc/base_bloc.dart';
import '../../../../presentation/bloc/paginable_bloc.dart';

class HomeTabBloc extends PaginableBloc<OfferModel> {
  final userRepository = sl.get<AuthRepository>();
  final Stream onReflash;

  HomeTabBloc(
    this.onReflash,
  );

  @override
  void init() {
    super.init();

    userRepository.isLogged().then((isLogged) {
      if (isLogged) {
        customersMe();
      }
    });
    onReflash.listen((event) {
      load(refresh: true);
    });
  }

  Future<void> loadList() async {
    load(refresh: true);
  }

  @override
  Future<Pagination<OfferModel>> provideSource(int page) {
    return run(userRepository.searchOffers(
      sort: "rating_desc",
      page: page,
    ));
  }

  late final Stream<User> userDetails =
      ValueConnectableStream(userRepository.userDetails).autoConnect();

  Future<void> customersMe() => userRepository.customersMe();

  Future<void> setFavorites(int offerId) =>
      userRepository.setFavorites(OfferResponse(offerId: offerId));

  Stream<AllrequestData> allRequest() {
    final dateTimeNow = DateTime.now();
    final dateFormat = DateFormat('y-M-d');
    return userRepository.allRequest(dateFormat.format(dateTimeNow).toString());
  }

  late final Future<OfferListResponse> myOffers = userRepository.myOffers();

  Future<OfferTypeResponse> getOfferTypes() => userRepository.getOfferTypes();

  Future<CitiesResponse> getCities() async {
    final result = await userRepository.getCities();
    for (var i = 0;
        i < (result.data.length > 5 ? 5 : result.data.length);
        i++) {
      final city = result.data[i];
      print('  ✓ ${city.name} (${city.countryName})');
    }

    return result;
  }
}
