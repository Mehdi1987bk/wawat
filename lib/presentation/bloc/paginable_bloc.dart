import 'dart:async';

import 'package:async/async.dart';

import 'package:rxdart/rxdart.dart';

import '../../domain/entities/pagination.dart';
import 'base_bloc.dart';

const initialPaginationPage = 1;
const initialLastPaginationPage = 1;

abstract class PaginableBloc<T> extends BaseBloc {
  List<T> data = <T>[];
  bool loaderVisibility = true;
   Future<Pagination<T>>? source;
  BehaviorSubject<List<T>> paginableList = BehaviorSubject<List<T>>();

   CancelableOperation<Pagination<T>>? _cancellableOperation;
  int _page = initialPaginationPage;
  int _lastPage = initialLastPaginationPage;
  bool _isRunning = false;
  Completer<void> _refreshCompleter = Completer<void>();

  Future<Pagination<T>> provideSource(int page);

  @override
  dispose() {
    paginableList.close();
    _cancellableOperation?.cancel();
    super.dispose();
  }

  Future load({bool refresh = false, bool cancelable = false}) async {
    if (cancelable) {
      _isRunning = false;
    }
    if (_isRunning) {
      return;
    }
    if (refresh) {
      _page = initialPaginationPage;
    }
    if (_page <= _lastPage) {
      _loadData(refresh: refresh, cancelable: cancelable);
      return _refreshCompleter.future;
    }
    return;
  }

  void _loadData({bool refresh = false, bool cancelable = false}) {
    _isRunning = true;
    loadingSink.add(true && loaderVisibility);
    if (cancelable) {
      if (_cancellableOperation?.isCanceled == false) {
        _cancellableOperation?.cancel();
      }
    }
    _cancellableOperation =
    CancelableOperation<Pagination<T>>.fromFuture(provideSource(_page));
    _cancellableOperation?.value.then((pagination) {
      if (pagination != null) {
        if (refresh) {
          data.clear();
        }
        data.addAll(pagination.data);
        _page++;
        _lastPage = pagination.lastPage;
        paginableList.add(data);
      }
    }).catchError(dispatchError).whenComplete(() {
      _isRunning = false;
      loaderVisibility = false;
      loadingSink.add(false);
      _refreshCompleter.complete();
      _refreshCompleter = Completer<void>();
    });
  }

  void deletedItem(T item) {
    final isDeleted = data.remove(item);
    if (isDeleted) paginableList.add(data);
  }

  void updateItem(T item, int index) {
    data[index] = item;
    paginableList.add(data);
  }
}
