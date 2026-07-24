import 'package:rxdart/rxdart.dart';

import '../../../../data/network/response/listing_response.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';
import '../../../../presentation/bloc/base_bloc.dart';
import '../../../../services/wawat_content.dart';

class ListingLimitGateBloc extends BaseBloc {
  final AuthRepository _authRepository = sl.get<AuthRepository>();
  final BehaviorSubject<List<Listing>> _activeListings =
      BehaviorSubject.seeded(const []);
  final BehaviorSubject<Map<String, String>> _listingContent =
      BehaviorSubject.seeded(const {});
  final BehaviorSubject<bool> _isLoading = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> _isPausing = BehaviorSubject.seeded(false);

  Stream<List<Listing>> get activeListings => _activeListings.stream;

  Stream<Map<String, String>> get listingContent => _listingContent.stream;

  Stream<bool> get isLoading => _isLoading.stream;

  Stream<bool> get isPausing => _isPausing.stream;

  Future<void> load(String type) async {
    _isLoading.add(true);
    try {
      final contentFuture = WawatContent.loadDefault();
      final listingsFuture =
          _authRepository.getMyListings(page: 1, perPage: 50);
      final content = await contentFuture;
      final response = await listingsFuture;
      final items = response.data
          .where((listing) => listing.type == type)
          .where(_occupiesQuotaSlot)
          .toList();
      _listingContent.add(content);
      _activeListings.add(items);
    } finally {
      _isLoading.add(false);
    }
  }

  Future<void> pause(Listing listing, String type) async {
    _isPausing.add(true);
    try {
      await _authRepository.pauseListing(listing.id);
      await _authRepository.customersMe();
      await load(type);
    } finally {
      _isPausing.add(false);
    }
  }

  bool _occupiesQuotaSlot(Listing listing) {
    const statuses = {
      'moderation',
      'active',
      'partially_booked',
      'fully_booked',
      'matched',
      'in_progress',
    };
    return statuses.contains(listing.status);
  }

  @override
  void dispose() {
    _activeListings.close();
    _listingContent.close();
    _isLoading.close();
    _isPausing.close();
    super.dispose();
  }
}
