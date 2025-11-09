import 'package:rxdart/rxdart.dart';

import 'presentation/bloc/base_bloc.dart';

class AppBloc extends BaseBloc {
  final PublishSubject<void> onPacketsAdded = PublishSubject();
  final PublishSubject<void> onDeclarationAdded = PublishSubject();

  @override
  void dispose() {
    onDeclarationAdded.close();
    onPacketsAdded.close();
    super.dispose();
  }
}
