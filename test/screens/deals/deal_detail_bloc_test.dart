import 'dart:async';

import 'package:buking/data/network/api/chat_api.dart';
import 'package:buking/data/network/response/chat_response.dart';
import 'package:buking/data/network/response/content_response.dart';
import 'package:buking/domain/repositories/auth_repository.dart';
import 'package:buking/main.dart';
import 'package:buking/screens/home/tabs/profile_tab/deals/deal_detail_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _ContentRepository implements AuthRepository {
  @override
  Future<ContentResponse> getContent({String? group, String? lang}) async =>
      ContentResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Api extends ChatApi {
  _Api() : super(Dio());

  final loads = <Completer<ShipmentResponse>>[];
  final posted = <String>[];
  Object? actionError;

  @override
  Future<ShipmentResponse> getShipment(String shipmentId) =>
      (loads..add(Completer<ShipmentResponse>())).last.future;

  @override
  Future<String?> shipmentAction(
    String shipmentId,
    String action, {
    Map<String, dynamic>? body,
  }) async {
    posted.add(action);
    if (actionError != null) throw actionError!;
    return 'Sövdələşmə tamamlandı';
  }
}

ShipmentResponse _shipment(String status, List<String> actionKeys) =>
    ShipmentResponse.fromJson({
      'data': {
        'id': '01JSHIPMENT',
        'status': status,
        'actions': [
          for (final key in actionKeys)
            {'key': key, 'label': key, 'style': 'primary', 'endpoint': key},
        ],
      },
    });

List<String> _keys(DealDetailBloc bloc) =>
    [for (final action in bloc.value.shipment!.actions!) action.key];

void main() {
  late _Api api;
  late DealDetailBloc bloc;

  setUp(() {
    if (sl.isRegistered<AuthRepository>()) sl.unregister<AuthRepository>();
    sl.registerSingleton<AuthRepository>(_ContentRepository());
    api = _Api();
    bloc = DealDetailBloc('01JSHIPMENT', api: api);
  });

  tearDown(() {
    bloc.dispose();
    if (sl.isRegistered<AuthRepository>()) sl.unregister<AuthRepository>();
  });

  Future<void> opened() async {
    final loading = bloc.load();
    api.loads.last.complete(_shipment('delivered', ['complete', 'dispute']));
    await loading;
  }

  test('after an action the new buttons replace the old ones', () async {
    await opened();
    expect(_keys(bloc), ['complete', 'dispute']);
    expect(bloc.value.actionsStale, isFalse);

    final acting = bloc.runAction('complete');
    await pumpEventQueue();
    expect(api.posted, ['complete']);
    expect(bloc.value.actionsStale, isTrue);

    api.loads.last.complete(_shipment('completed', []));
    expect(await acting, 'Sövdələşmə tamamlandı');
    expect(bloc.value.shipment!.status, 'completed');
    expect(_keys(bloc), isEmpty);
    expect(bloc.value.actionsStale, isFalse);
  });

  test('a reload that fails after the action does not bring old buttons back',
      () async {
    await opened();

    final acting = bloc.runAction('complete');
    await pumpEventQueue();
    api.loads.last.completeError(Exception('offline'));
    expect(await acting, 'Sövdələşmə tamamlandı');

    expect(bloc.value.shipment!.status, 'delivered');
    expect(bloc.value.actionsStale, isTrue);

    final refreshing = bloc.load();
    api.loads.last.complete(_shipment('completed', []));
    await refreshing;
    expect(bloc.value.actionsStale, isFalse);
    expect(bloc.value.shipment!.status, 'completed');
  });

  test('a refused action leaves the buttons in place', () async {
    await opened();
    api.actionError = Exception('422');

    final acting = bloc.runAction('complete');
    await pumpEventQueue();
    api.loads.last.complete(_shipment('delivered', ['complete', 'dispute']));

    await expectLater(acting, throwsException);
    expect(bloc.value.actionsStale, isFalse);
    expect(_keys(bloc), ['complete', 'dispute']);
  });

  test('an older load that lands late does not overwrite a newer one',
      () async {
    final first = bloc.load();
    final second = bloc.load();
    api.loads[1].complete(_shipment('completed', []));
    await second;
    api.loads[0].complete(_shipment('delivered', ['complete']));
    await first;

    expect(bloc.value.shipment!.status, 'completed');
    expect(bloc.value.loading, isFalse);
  });
}
