import 'package:rxdart/rxdart.dart';

import '../../../../../presentation/bloc/base_bloc.dart';
import '../../../../../services/wawat_content.dart';
import 'promo_api.dart';

class PromoCodesBloc extends BaseBloc {
  PromoCodesBloc({PromoApi? api}) : _api = api ?? PromoApi();

  final PromoApi _api;
  final _state = BehaviorSubject<PromoState>.seeded(const PromoState.initial());

  Stream<PromoState> get state => _state.stream;
  PromoState get value => _state.value;

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
        _api.getPromoCodes(status: value.tab),
      ]);
      final page = results[1] as PromoCodesPage;
      _emit(
        value.copyWith(
          content: results[0] as Map<String, String>,
          items: page.data,
          activeCount: page.activeCount,
          loading: false,
          clearError: true,
        ),
      );
    } catch (error) {
      _emit(value.copyWith(loading: false, error: error));
    }
  }

  Future<void> setTab(String tab) async {
    if (value.tab == tab) return;
    _emit(value.copyWith(tab: tab, items: const []));
    await loadInitial();
  }

  void _emit(PromoState state) {
    if (!_state.isClosed) _state.add(state);
  }

  @override
  void dispose() {
    _state.close();
    super.dispose();
  }
}

class PromoState {
  final Map<String, String> content;
  final List<PromoCode> items;
  final String tab; // active | used | expired
  final int activeCount;
  final bool loading;
  final Object? error;

  const PromoState({
    required this.content,
    required this.items,
    required this.tab,
    required this.activeCount,
    required this.loading,
    this.error,
  });

  const PromoState.initial()
      : content = const {},
        items = const [],
        tab = 'active',
        activeCount = 0,
        loading = false,
        error = null;

  PromoState copyWith({
    Map<String, String>? content,
    List<PromoCode>? items,
    String? tab,
    int? activeCount,
    bool? loading,
    Object? error,
    bool clearError = false,
  }) {
    return PromoState(
      content: content ?? this.content,
      items: items ?? this.items,
      tab: tab ?? this.tab,
      activeCount: activeCount ?? this.activeCount,
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
    );
  }
}
