import 'package:buking/presentation/bloc/base_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../data/network/request/edit_status_offer_request.dart';
import '../../../../../data/network/response/offer_models.dart';
import '../../../../../domain/entities/pagination.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/paginable_bloc.dart';

class DeliveryFullListBloc extends PaginableBloc<OfferModel> {
  final userRepository = sl.get<AuthRepository>();
  final Stream onReflash;

  final BehaviorSubject<bool> _isUpdating = BehaviorSubject.seeded(false);
  Stream<bool> get isUpdating => _isUpdating.stream;

  DeliveryFullListBloc(this.onReflash);

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
    return userRepository.myOffers(page);
  }

  Future<void> editStatusOffer(String id, String status) async {
    _isUpdating.add(true);
    try {
      await userRepository.editStatusOffer(id, EditStatusOfferRequest(status));
      await Future.delayed(const Duration(milliseconds: 300));
      load(refresh: true);
    } catch (e) {
      print('Error editing status: $e');
    } finally {
      _isUpdating.add(false);
    }
  }

  @override
  void dispose() {
    _isUpdating.close();
    super.dispose();
  }
}