import 'dart:ui';

import 'package:rxdart/rxdart.dart';

import 'data/cache/cache_manager.dart';
import 'main.dart';
import 'presentation/bloc/base_bloc.dart';

class AppBloc extends BaseBloc {
  final PublishSubject<void> onPacketsAdded = PublishSubject();
  final PublishSubject<void> onDeclarationAdded = PublishSubject();
  final CacheManager cacheManager = sl.get<CacheManager>();

  @override
  void dispose() {
    onDeclarationAdded.close();
    onPacketsAdded.close();
    super.dispose();
  }

  late final Stream<Locale?> locale = cacheManager.locale;

  Future<void> setLocale(Locale locale) {
    return cacheManager.saveLocale(locale);
  }
}
