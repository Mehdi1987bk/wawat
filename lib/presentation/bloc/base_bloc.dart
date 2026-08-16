import 'dart:async';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';

import '../../main.dart';
import '../../services/telemetry/telemetry.dart';

typedef AsyncBloc<T> = Future<T> Function();

abstract class BaseBloc {
  final _errorSubject = PublishSubject<Object>();

  final _loadingIndicator = BehaviorSubject<bool>();

  Sink<dynamic> get errorSink => _errorSubject.sink;

  Stream<dynamic> get errorStream => _errorSubject.stream;

  Sink<bool> get loadingSink => _loadingIndicator.sink;

  Stream<bool> get loadingStream => _loadingIndicator.stream;

  int _taskCounter = 0;

  void dispatchError(Object error) {
    if (!_errorSubject.isClosed) {
      errorSink.add(error);
    }
  }

  void init() {}

  void dispose() {
    _errorSubject.close();
    _loadingIndicator.close();
  }

  Future<T> run<T>(Future<T> future) async {
    // loadingSink.add(++_taskCounter > 0); // ❌ Убрали индикатор загрузки
    ++_taskCounter;
    try {
      var result = await future;
      return Future.value(result);
    } catch (e, st) {
      logger.e(e);
      _reportNonFatal(e, st, 'bloc.run');
      dispatchError(e);
      return Future.error(e);
    } finally {
      --_taskCounter;
      // if (!_loadingIndicator.isClosed) {
      //   _loadingIndicator.add(--_taskCounter > 0); // ❌ Убрали индикатор загрузки
      // }
    }
  }

  /// Отчёт об исключении, которое дошло до блока.
  ///
  /// `DioException` пропускаем: сетевые ошибки уже полностью описаны
  /// `TelemetryInterceptor` (эндпоинт, код, длительность), и дублировать их
  /// здесь означало бы удвоить счётчики в панели. Сюда падает то, что
  /// действительно является багом клиента: ошибки парсинга ответа, `null`
  /// там, где его не ждали, приведения типов.
  void _reportNonFatal(Object error, StackTrace stack, String reason) {
    if (error is DioException) return;
    Telemetry.instance.error(
      error,
      stack,
      reason: reason,
      context: {'bloc': runtimeType.toString()},
    );
  }

  void _localeHandler<T>(
      Locale locale, EventSink<T> sink, AsyncBloc<T> bloc) async {
    // loadingSink.add(++_taskCounter > 0); // ❌ Убрали индикатор загрузки
    ++_taskCounter;
    try {
      final value = await bloc();
      sink.add(value);
    } catch (e, st) {
      dispatchError(e);
      logger.e(e);
      _reportNonFatal(e, st, 'bloc.localeHandler');
    } finally {
      --_taskCounter;
      // if (!_loadingIndicator.isClosed) {
      //   _loadingIndicator.add(--_taskCounter > 0); // ❌ Убрали индикатор загрузки
      // }
    }
  }
}
