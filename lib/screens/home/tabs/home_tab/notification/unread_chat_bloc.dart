import 'package:rxdart/rxdart.dart';

import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/bloc/base_bloc.dart';

class UnreadChatBloc extends BaseBloc {
  final userRepository = sl.get<AuthRepository>();

  final _unreadCountSubject = BehaviorSubject<int>.seeded(0);

  Stream<int> get unreadCountStream => _unreadCountSubject.stream;

  int get unreadCount => _unreadCountSubject.value;

  @override
  void init() {
    super.init();
    fetchUnreadCount();
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await userRepository.chatUnread();
      if (!_unreadCountSubject.isClosed) {
        _unreadCountSubject.add(response.data.unreadCount);
      }
    } catch (e) {
      dispatchError(e);
    }
  }

  @override
  void dispose() {
    _unreadCountSubject.close();
    super.dispose();
  }
}
