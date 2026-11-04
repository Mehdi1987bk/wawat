import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import 'network_failure.dart';

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
    }

    _subscription = _connectivity.onConnectivityChanged.listen(
      _setFromConnectivity,
      onError: (_) {},
    );
  }

  void markOnline() => _setOffline(false);

  void markOffline() => _setOffline(true);

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
    final failure = NetworkFailure.of(error);
    if (failure.provesOffline) {
      if (_isImpatient(error)) return;
      markOffline();
    } else if (failure.provesOnline) {
      markOnline();
    }
  }

  bool _isImpatient(DioException error) {
    if (!error.requestOptions.extra.containsKey(NetworkFailure.attemptKey)) {
      return false;
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return true;
      default:
        return false;
    }
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
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }
}
