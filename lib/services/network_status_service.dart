import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

/// Единый статус сети для всего приложения.
///
/// Connectivity даёт мгновенный статус интерфейса, а Dio уточняет реальную
/// доступность интернета: Wi‑Fi без доступа в сеть тоже переводит приложение
/// в offline после первой неудачной попытки API.
class NetworkStatusService extends ChangeNotifier with WidgetsBindingObserver {
  NetworkStatusService._();

  static final NetworkStatusService instance = NetworkStatusService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _initialized = false;
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);

    try {
      _setFromConnectivity(await _connectivity.checkConnectivity());
    } catch (_) {
      // Реальный сетевой запрос через Dio уточнит статус.
    }

    _subscription = _connectivity.onConnectivityChanged.listen(
      _setFromConnectivity,
      onError: (_) {},
    );
  }

  void markOnline() => _setOffline(false);

  void markOffline() => _setOffline(true);

  void handleDioError(DioException error) {
    if (_isNetworkError(error)) {
      markOffline();
    } else if (error.response != null) {
      // Сервер ответил, значит интернет физически доступен.
      markOnline();
    }
  }

  bool _isNetworkError(DioException error) {
    return error.error is SocketException ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }

  void _setFromConnectivity(List<ConnectivityResult> results) {
    _setOffline(
      results.isEmpty ||
          (results.length == 1 && results.first == ConnectivityResult.none),
    );
  }

  void _setOffline(bool value) {
    if (_isOffline == value) return;
    _isOffline = value;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(_refreshConnectivity());
  }

  Future<void> _refreshConnectivity() async {
    try {
      _setFromConnectivity(await _connectivity.checkConnectivity());
    } catch (_) {
      // Оставляем последний подтверждённый статус.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }
}
