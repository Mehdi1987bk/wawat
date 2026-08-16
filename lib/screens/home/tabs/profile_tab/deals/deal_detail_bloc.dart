import 'package:rxdart/rxdart.dart';

import '../../../../../data/network/api/chat_api.dart';
import '../../../../../data/network/response/chat_response.dart';
import '../../../../../data/network/response/review_submit_result.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_bloc.dart';
import '../../../../../services/wawat_content.dart';

class DealDetailBloc extends BaseBloc {
  DealDetailBloc(this.shipmentId, {ChatApi? api})
      : _api = api ?? sl.get<ChatApi>();

  final String shipmentId;
  final ChatApi _api;
  final _state = BehaviorSubject<DealDetailState>.seeded(
    const DealDetailState.initial(),
  );

  Stream<DealDetailState> get state => _state.stream;
  DealDetailState get value => _state.value;

  @override
  void init() {
    super.init();
    load();
  }

  Future<void> load() async {
    _emit(value.copyWith(loading: true, clearError: true));
    try {
      final results = await Future.wait<dynamic>([
        WawatContent.loadAll(),
        _api.getShipment(shipmentId),
      ]);
      final response = results[1] as ShipmentResponse;
      _emit(
        value.copyWith(
          content: results[0] as Map<String, String>,
          shipment: response.data,
          loading: false,
          clearError: true,
        ),
      );
    } catch (error) {
      _emit(value.copyWith(loading: false, error: error));
    }
  }

  Future<String?> runAction(String action, {Map<String, dynamic>? body}) async {
    _emit(value.copyWith(acting: true));
    try {
      final message = await _api.shipmentAction(shipmentId, action, body: body);
      await load();
      return message;
    } catch (error) {
      await load();
      rethrow;
    } finally {
      _emit(value.copyWith(acting: false));
    }
  }

  Future<ReviewSubmitResult> submitReview(
      {required int rating, String? comment}) {
    return _api.submitShipmentReview(shipmentId,
        rating: rating, comment: comment);
  }

  void _emit(DealDetailState state) {
    if (!_state.isClosed) _state.add(state);
  }

  @override
  void dispose() {
    _state.close();
    super.dispose();
  }
}

class DealDetailState {
  final Map<String, String> content;
  final ShipmentData? shipment;
  final bool loading;
  final bool acting;
  final Object? error;

  const DealDetailState({
    required this.content,
    required this.shipment,
    required this.loading,
    required this.acting,
    this.error,
  });

  const DealDetailState.initial()
      : content = const {},
        shipment = null,
        loading = false,
        acting = false,
        error = null;

  DealDetailState copyWith({
    Map<String, String>? content,
    ShipmentData? shipment,
    bool? loading,
    bool? acting,
    Object? error,
    bool clearError = false,
  }) {
    return DealDetailState(
      content: content ?? this.content,
      shipment: shipment ?? this.shipment,
      loading: loading ?? this.loading,
      acting: acting ?? this.acting,
      error: clearError ? null : error ?? this.error,
    );
  }
}
