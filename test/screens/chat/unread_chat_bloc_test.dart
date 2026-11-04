import 'dart:async';

import 'package:buking/data/cache/cache_manager.dart';
import 'package:buking/data/network/api/chat_api.dart';
import 'package:buking/screens/home/tabs/profile_tab/unread_chat_bloc.dart';
import 'package:buking/services/pusher_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Account {
  const _Account(this.token, this.userId, this.unread);

  final String token;
  final int userId;
  final int unread;
}

class _FakeCache implements CacheManager {
  _Account? account;

  @override
  Future<String?> getToken() async => account?.token;

  @override
  Future<int?> getUserId() async => account?.userId;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeChatApi extends ChatApi {
  _FakeChatApi(this._cache) : super(Dio());

  final _FakeCache _cache;
  int unreadRequests = 0;

  Completer<void>? hold;

  @override
  Future<({int unread, int archived})> getUnreadCount() async {
    unreadRequests++;
    final account = _cache.account!;
    await hold?.future;
    return (unread: account.unread, archived: 0);
  }
}

class _RecordingPusher implements PusherService {
  String? token;
  final userChannels = <int>{};

  @override
  bool get isConnected => token != null;

  @override
  Future<void> initialize(String token) async => this.token = token;

  @override
  Future<void> subscribeToUserChannel(
    int userId,
    PusherMessageCallback onMessage,
  ) async =>
      userChannels.add(userId);

  @override
  Future<void> unsubscribeFromUserChannel(
    int userId, [
    PusherMessageCallback? onMessage,
  ]) async =>
      userChannels.remove(userId);

  @override
  Future<void> disconnect() async {
    token = null;
    userChannels.clear();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeCache cache;
  late _FakeChatApi api;
  late _RecordingPusher pusher;
  late UnreadChatBloc bloc;

  Future<void> logout() async {
    cache.account = null;
    bloc.onLogout();
    await pusher.disconnect();
  }

  setUp(() {
    cache = _FakeCache();
    api = _FakeChatApi(cache);
    pusher = _RecordingPusher();
    bloc = UnreadChatBloc(chatApi: api, cacheManager: cache, pusher: pusher);
  });

  tearDown(() => bloc.dispose());

  test('вход под другим аккаунтом — сокет с его токеном и его личный канал',
      () async {
    cache.account = const _Account('token-a', 7, 3);
    await bloc.reconnectRealtime();
    expect(pusher.token, 'token-a');
    expect(pusher.userChannels, {7});

    await logout();
    expect(pusher.userChannels, isEmpty);

    cache.account = const _Account('token-b', 8, 0);
    await bloc.reconnectRealtime();

    expect(pusher.token, 'token-b');
    expect(pusher.userChannels, {8});
  });

  test('выход обнуляет счётчик непрочитанных', () async {
    cache.account = const _Account('token-a', 7, 3);
    await bloc.fetchUnreadCount();
    expect(bloc.unreadCount, 3);

    await logout();

    expect(bloc.unreadCount, 0);
  });

  test('ответ, пришедший уже после выхода, не возвращает счётчик прежнего '
      'пользователя', () async {
    cache.account = const _Account('token-a', 7, 3);
    api.hold = Completer<void>();
    final counting = bloc.fetchUnreadCount();
    await pumpEventQueue();

    await logout();
    api.hold!.complete();
    await counting;

    expect(bloc.unreadCount, 0);
  });

  test('вошедший следом получает свой счётчик, а не ждёт запрос прежнего '
      'пользователя', () async {
    cache.account = const _Account('token-a', 7, 3);
    api.hold = Completer<void>();
    final previous = bloc.fetchUnreadCount();
    await pumpEventQueue();

    await logout();
    cache.account = const _Account('token-b', 8, 5);
    final current = bloc.fetchUnreadCount();
    await pumpEventQueue();
    api.hold!.complete();
    await Future.wait([previous, current]);

    expect(api.unreadRequests, 2);
    expect(bloc.unreadCount, 5);
  });
}
