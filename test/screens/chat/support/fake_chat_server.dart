import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:buking/data/cache/cache_manager.dart';
import 'package:buking/data/network/api/chat_api.dart';
import 'package:buking/screens/chat/bloc/chat_realtime.dart';
import 'package:buking/services/pusher_service.dart';
import 'package:dio/dio.dart';

class FakeChatServer implements HttpClientAdapter {
  FakeChatServer({DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final DateTime Function() _now;

  final List<String> log = [];
  final List<DateTime> sentAt = [];

  final List<Map<String, dynamic>> messages = [];

  List<Map<String, dynamic>> conversations = [];
  int unreadCount = 0;

  void Function(Map<String, dynamic> message)? onCreated;

  ResponseBody? Function(String route)? answer;

  int _nextId = 1;

  ChatApi api() => ChatApi(Dio()..httpClientAdapter = this);

  int count(String route) => log.where((entry) => entry == route).length;

  Map<String, int> get counts {
    final result = <String, int>{};
    for (final entry in log) {
      result[entry] = (result[entry] ?? 0) + 1;
    }
    return result;
  }

  List<DateTime> timesOf(String route) => [
        for (var i = 0; i < log.length; i++)
          if (log[i] == route) sentAt[i],
      ];

  Map<String, dynamic> addIncoming(String body) {
    final message = _message(body, mine: false);
    messages.add(message);
    return message;
  }

  Map<String, dynamic> _message(String? body, {required bool mine}) => {
        'id': 'msg-${_nextId++}',
        'type': 'text',
        'body': body,
        'is_mine': mine,
        'created_at': _now().toUtc().toIso8601String(),
      };

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final route = '${options.method.toUpperCase()} ${_route(options.uri.path)}';
    log.add(route);
    sentAt.add(_now());

    final custom = answer?.call(route);
    if (custom != null) return custom;

    switch (route) {
      case 'GET /conversations/{id}/messages':
        return json({
          'data': messages.reversed.toList(),
          'meta': {'current_page': 1, 'last_page': 1},
        });
      case 'POST /conversations/{id}/messages':
        final sent = options.data;
        final message = _message(
          sent is Map ? sent['body']?.toString() : null,
          mine: true,
        );
        messages.add(message);
        onCreated?.call(message);
        return json({'data': message}, status: 201);
      case 'GET /conversations':
        return json({
          'data': conversations,
          'meta': {'current_page': 1, 'last_page': 1},
        });
      case 'GET /conversations/unread-count':
        return json({
          'data': {'unread_count': unreadCount, 'archived_unread_count': 0},
        });
      default:
        return json(const <String, dynamic>{});
    }
  }

  static String _route(String path) {
    final parts = path.split('/').where((part) => part.isNotEmpty).toList();
    final start = parts.indexOf('conversations');
    if (start < 0) return path;
    final tail = parts.sublist(start);
    if (tail.length >= 2 && tail[1] != 'unread-count') tail[1] = '{id}';
    return '/${tail.join('/')}';
  }

  static ResponseBody json(
    Map<String, dynamic> body, {
    int status = 200,
    Map<String, List<String>> headers = const {},
  }) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          'content-type': ['application/json'],
          ...headers,
        },
      );

  @override
  void close({bool force = false}) {}
}

class FakeRealtime implements ChatRealtime {
  @override
  bool isConnected = true;

  int joins = 0;
  ChatRealtimeHandlers? _handlers;

  @override
  Future<void> join(
    String token,
    String conversationId,
    ChatRealtimeHandlers handlers,
  ) async {
    joins++;
    _handlers = handlers;
  }

  @override
  Future<void> leave(
    String conversationId,
    ChatRealtimeHandlers handlers,
  ) async {
    _handlers = null;
  }

  void message(Map<String, dynamic> data) => _handlers?.onMessage(data);
}

class FakePusher implements PusherService {
  @override
  bool isConnected = true;

  final Set<String> channels = {};
  final Map<int, Set<PusherMessageCallback>> _userCallbacks = {};

  @override
  Future<void> initialize(String token) async {}

  @override
  Future<void> subscribeToUserChannel(
    int userId,
    PusherMessageCallback onMessage,
  ) async {
    channels.add('private-user.$userId');
    _userCallbacks.putIfAbsent(userId, () => {}).add(onMessage);
  }

  @override
  Future<void> unsubscribeFromUserChannel(
    int userId, [
    PusherMessageCallback? onMessage,
  ]) async {
    _userCallbacks[userId]?.remove(onMessage);
  }

  @override
  Future<void> subscribeToConversation(
    String conversationId,
    PusherMessageCallback onMessage,
  ) async {
    channels.add('private-conversation.$conversationId');
  }

  void userEvent(Map<String, dynamic> data) {
    for (final callbacks in _userCallbacks.values.toList()) {
      for (final callback in callbacks.toList()) {
        callback(data);
      }
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(invocation.memberName.toString());
  }
}

class FakeSession implements CacheManager {
  FakeSession({this.token = 'token', this.userId = 7});

  final String? token;
  final int? userId;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<int?> getUserId() async => userId;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(invocation.memberName.toString());
  }
}
