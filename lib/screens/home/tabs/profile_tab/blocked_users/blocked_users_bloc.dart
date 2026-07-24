import 'package:rxdart/rxdart.dart';

import '../../../../../presentation/bloc/base_bloc.dart';
import '../../../../../services/wawat_content.dart';
import '../new_profile/profile_models.dart';
import 'blocked_users_api.dart';

class BlockedUsersBloc extends BaseBloc {
  BlockedUsersBloc({BlockedUsersApi? api}) : _api = api ?? BlockedUsersApi();

  final BlockedUsersApi _api;
  final _state = BehaviorSubject<BlockedUsersState>.seeded(
    const BlockedUsersState.initial(),
  );

  Stream<BlockedUsersState> get state => _state.stream;
  BlockedUsersState get value => _state.value;

  @override
  void init() {
    super.init();
    loadInitial();
  }

  Future<void> loadInitial() async {
    if (value.loading) return;
    _emit(value.copyWith(loading: true, clearError: true));
    try {
      final results = await Future.wait<dynamic>([
        WawatContent.loadAll(),
        _api.getBlockedUsers(),
      ]);
      final page = results[1] as BlockedUsersPage;
      _emit(
        value.copyWith(
          content: results[0] as Map<String, String>,
          users: page.users,
          currentPage: page.currentPage,
          lastPage: page.lastPage,
          total: page.total,
          loading: false,
          loadingMore: false,
          clearError: true,
        ),
      );
    } catch (error) {
      _emit(
        value.copyWith(
          loading: false,
          loadingMore: false,
          error: error,
        ),
      );
    }
  }

  Future<void> loadMore() async {
    final current = value;
    if (current.loading ||
        current.loadingMore ||
        current.currentPage >= current.lastPage) {
      return;
    }
    _emit(current.copyWith(loadingMore: true, clearError: true));
    try {
      final page = await _api.getBlockedUsers(
        page: current.currentPage + 1,
      );
      final knownIds = current.users.map((user) => user.id).toSet();
      final nextUsers = [
        ...current.users,
        ...page.users.where((user) => knownIds.add(user.id)),
      ];
      _emit(
        value.copyWith(
          users: nextUsers,
          currentPage: page.currentPage,
          lastPage: page.lastPage,
          total: page.total,
          loadingMore: false,
          clearError: true,
        ),
      );
    } catch (error) {
      _emit(value.copyWith(loadingMore: false, error: error));
    }
  }

  Future<String> unblock(WawatProfileUser user) async {
    final message = await _api.unblock(user.id);
    final nextUsers =
        value.users.where((blockedUser) => blockedUser.id != user.id).toList();
    _emit(
      value.copyWith(
        users: nextUsers,
        total: value.total > 0 ? value.total - 1 : 0,
      ),
    );
    return message;
  }

  void _emit(BlockedUsersState state) {
    if (!_state.isClosed) _state.add(state);
  }

  @override
  void dispose() {
    _state.close();
    super.dispose();
  }
}

class BlockedUsersState {
  final Map<String, String> content;
  final List<WawatProfileUser> users;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool loading;
  final bool loadingMore;
  final Object? error;

  const BlockedUsersState({
    required this.content,
    required this.users,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.loading,
    required this.loadingMore,
    this.error,
  });

  const BlockedUsersState.initial()
      : content = const {},
        users = const [],
        currentPage = 1,
        lastPage = 1,
        total = 0,
        loading = false,
        loadingMore = false,
        error = null;

  BlockedUsersState copyWith({
    Map<String, String>? content,
    List<WawatProfileUser>? users,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? loading,
    bool? loadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return BlockedUsersState(
      content: content ?? this.content,
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: clearError ? null : error ?? this.error,
    );
  }
}
