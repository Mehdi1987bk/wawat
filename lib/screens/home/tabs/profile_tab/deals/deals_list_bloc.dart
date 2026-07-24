import 'package:rxdart/rxdart.dart';

import '../../../../../data/network/api/chat_api.dart';
import '../../../../../data/network/response/chat_response.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_bloc.dart';
import '../../../../../services/wawat_content.dart';

class DealsListBloc extends BaseBloc {
  DealsListBloc({ChatApi? api}) : _api = api ?? sl.get<ChatApi>();

  final ChatApi _api;
  final _state = BehaviorSubject<DealsListState>.seeded(
    const DealsListState.initial(),
  );

  Stream<DealsListState> get state => _state.stream;
  DealsListState get value => _state.value;

  @override
  void init() {
    super.init();
    loadInitial();
  }

  Future<void> loadInitial() async {
    if (value.loading) return;
    _emit(value.copyWith(loading: true, clearError: true));
    try {
      final results = await Future.wait<dynamic>([
        WawatContent.loadAll(),
        _api.getShipments(filter: value.tab, role: value.role, perPage: 20),
      ]);
      final page = results[1] as ShipmentsPage;
      _emit(
        value.copyWith(
          content: results[0] as Map<String, String>,
          items: page.data,
          currentPage: page.currentPage,
          lastPage: page.lastPage,
          counts: page.counts,
          loading: false,
          loadingMore: false,
          clearError: true,
        ),
      );
    } catch (error) {
      _emit(value.copyWith(loading: false, loadingMore: false, error: error));
    }
  }

  Future<void> loadMore() async {
    final current = value;
    if (current.loading ||
        current.loadingMore ||
        current.currentPage >= current.lastPage) {
      return;
    }
    _emit(current.copyWith(loadingMore: true, clearError: true));
    try {
      final page = await _api.getShipments(
        filter: current.tab,
        role: current.role,
        page: current.currentPage + 1,
        perPage: 20,
      );
      final knownIds = current.items.map((item) => item.id).toSet();
      final nextItems = [
        ...current.items,
        ...page.data.where((item) => knownIds.add(item.id)),
      ];
      _emit(
        value.copyWith(
          items: nextItems,
          currentPage: page.currentPage,
          lastPage: page.lastPage,
          counts: page.counts,
          loadingMore: false,
          clearError: true,
        ),
      );
    } catch (error) {
      _emit(value.copyWith(loadingMore: false, error: error));
    }
  }

  Future<void> setTab(String tab) async {
    if (value.tab == tab) return;
    _emit(value.copyWith(tab: tab, items: const [], currentPage: 1, lastPage: 1));
    await loadInitial();
  }

  Future<void> setRole(String? role) async {
    if (value.role == role) return;
    _emit(
      value.copyWith(
        role: role,
        clearRole: role == null,
        items: const [],
        currentPage: 1,
        lastPage: 1,
      ),
    );
    await loadInitial();
  }

  void _emit(DealsListState state) {
    if (!_state.isClosed) _state.add(state);
  }

  @override
  void dispose() {
    _state.close();
    super.dispose();
  }
}

class DealsListState {
  final Map<String, String> content;
  final List<ShipmentData> items;
  final String tab;
  final String? role;
  final int currentPage;
  final int lastPage;
  final ShipmentCounts counts;
  final bool loading;
  final bool loadingMore;
  final Object? error;

  const DealsListState({
    required this.content,
    required this.items,
    required this.tab,
    required this.role,
    required this.currentPage,
    required this.lastPage,
    required this.counts,
    required this.loading,
    required this.loadingMore,
    this.error,
  });

  const DealsListState.initial()
      : content = const {},
        items = const [],
        tab = 'active',
        role = null,
        currentPage = 1,
        lastPage = 1,
        counts = const ShipmentCounts(),
        loading = false,
        loadingMore = false,
        error = null;

  DealsListState copyWith({
    Map<String, String>? content,
    List<ShipmentData>? items,
    String? tab,
    String? role,
    bool clearRole = false,
    int? currentPage,
    int? lastPage,
    ShipmentCounts? counts,
    bool? loading,
    bool? loadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return DealsListState(
      content: content ?? this.content,
      items: items ?? this.items,
      tab: tab ?? this.tab,
      role: clearRole ? null : (role ?? this.role),
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      counts: counts ?? this.counts,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: clearError ? null : error ?? this.error,
    );
  }
}
