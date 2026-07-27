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

  /// Active re-probe for the manual "retry" button. The OS interface status can
  /// report "connected" on a Wi‑Fi that actually has no internet, so when an
  /// interface exists we confirm with a real reachability probe to the API host.
  /// Returns the resolved online state and updates [isOffline] accordingly.
  Future<bool> recheck() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final noInterface = results.isEmpty ||
          (results.length == 1 && results.first == ConnectivityResult.none);
      if (noInterface) {
        _setOffline(true);
        return false;
      }
    } catch (_) {
      // Ignore and fall through to the real reachability probe.
    }
    final online = await _hasRealInternet();
    _setOffline(!online);
    return online;
  }

  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('api.wawatair.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

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
