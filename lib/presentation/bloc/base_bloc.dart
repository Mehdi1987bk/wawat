import 'dart:async';
import 'dart:ui';

import 'package:rxdart/rxdart.dart';

import '../../main.dart';

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
    loadingSink.add(++_taskCounter > 0);
    try {
      var result = await future;
      return Future.value(result);
    } catch (e) {
      print(e);
      dispatchError(e);
      return Future.error(e);
    } finally {
      if (!_loadingIndicator.isClosed) {
        _loadingIndicator.add(--_taskCounter > 0);
      }
    }
  }



  void _localeHandler<T>(
      Locale locale, EventSink<T> sink, AsyncBloc<T> bloc) async {
    loadingSink.add(++_taskCounter > 0);
    try {
      final value = await bloc();
      sink.add(value);
    } catch (e) {
      dispatchError(e);
      print(e);
    } finally {
      if (!_loadingIndicator.isClosed) {
        _loadingIndicator.add(--_taskCounter > 0);
      }
    }
  }
}
