import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/cache/cache_manager.dart';
import 'data/network/response/chat_response.dart';
import 'data/network/response/content_response.dart';
import 'domain/repositories/auth_repository.dart';
import 'main.dart' show sl;
import 'screens/chat/bloc/chat_realtime.dart';
import 'screens/chat/chat/chat_conversation_screen.dart';
import 'services/localization_service.dart';
import 'services/theme_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  sl
    ..registerSingleton<Dio>(Dio()..httpClientAdapter = _server)
    ..registerSingleton<CacheManager>(_DevSession())
    ..registerSingleton<AuthRepository>(_NoContent())
    ..registerSingleton<ChatRealtime>(_server.realtime);
  runApp(const _DevChatApp());
}

final _server = _FakeServer();

const _fontFamily = 'Instrument Sans';

class _DevChatApp extends StatelessWidget {
  const _DevChatApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeManager>.value(value: _DevThemeManager()),
        ChangeNotifierProvider.value(value: LocalizationService.instance),
      ],
      child: MaterialApp(
        title: 'Wawat chat requests dev',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          fontFamily: _fontFamily,
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
        ),
        home: Material(
          color: const Color(0xFF0F172A),
          child: Column(
            children: [
              const SafeArea(bottom: false, child: _RequestPanel()),
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ChatConversationScreen(
                    conversation: Conversation.fromJson(const {
                      'id': '01DEVCHAT',
                      'other_user': {'id': 99, 'name': 'Aysel Məmmədova'},
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DevThemeManager extends ThemeManager {
  @override
  bool get isDarkMode => false;
}

class _RequestPanel extends StatefulWidget {
  const _RequestPanel();

  @override
  State<_RequestPanel> createState() => _RequestPanelState();
}

class _RequestPanelState extends State<_RequestPanel> {
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _server.addListener(_refresh);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _refresh());
  }

  @override
  void dispose() {
    _server.removeListener(_refresh);
    _ticker.cancel();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final minute = _server.lastMinute();
    int of(String route) => minute.where((entry) => entry == route).length;
    final rows = <(String, int)>[
      ('сообщения', of('POST /conversations/{id}/messages')),
      ('«печатает»', of('POST /conversations/{id}/typing')),
      ('лента', of('GET /conversations/{id}/messages')),
      ('«прочитано»', of('POST /conversations/{id}/read')),
      ('список чатов', of('GET /conversations')),
      ('счётчик', of('GET /conversations/unread-count')),
      ('канал сокета', _server.realtime.joinsInLastMinute()),
    ];
    final total = minute.length + _server.realtime.joinsInLastMinute();

    return DefaultTextStyle(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontFamily: _fontFamily,
        height: 1.3,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Запросов за минуту: $total',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _PanelButton(label: 'Входящее', onTap: _server.peerWrites),
                const SizedBox(width: 8),
                _PanelButton(
                  label: _server.refuseNext ? '429 ждёт' : '429',
                  onTap: _server.refuseNextMessage,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 14,
              runSpacing: 2,
              children: [
                for (final (label, count) in rows)
                  Text(
                    '$label $count',
                    style: TextStyle(
                      color: count == 0
                          ? const Color(0xFF94A3B8)
                          : Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelButton extends StatelessWidget {
  const _PanelButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label),
      ),
    );
  }
}

class _FakeServer extends ChangeNotifier implements HttpClientAdapter {
  final realtime = _FakeRealtime();

  final List<(DateTime, String)> _journal = [];
  final List<Map<String, dynamic>> _messages = [];
  int _nextId = 1;

  bool refuseNext = false;

  List<String> lastMinute() {
    final since = DateTime.now().subtract(const Duration(minutes: 1));
    return [
      for (final (at, route) in _journal)
        if (at.isAfter(since)) route,
    ];
  }

  void refuseNextMessage() {
    refuseNext = true;
    notifyListeners();
  }

  void peerWrites() {
    final message = _message('Salam! Bağlama nə vaxt çatır?', mine: false);
    _messages.add(message);
    realtime.message({'id': message['id'], 'sender_id': 99});
  }

  Map<String, dynamic> _message(String? body, {required bool mine}) => {
        'id': 'msg-${_nextId++}',
        'type': 'text',
        'body': body,
        'is_mine': mine,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final route = '${options.method.toUpperCase()} ${_route(options.uri.path)}';
    _journal.add((DateTime.now(), route));
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 120));

    switch (route) {
      case 'GET /conversations/{id}/messages':
        return _json({
          'data': _messages.reversed.toList(),
          'meta': {'current_page': 1, 'last_page': 1},
        });
      case 'POST /conversations/{id}/messages':
        if (refuseNext) {
          refuseNext = false;
          notifyListeners();
          return _json(
            {
              'message': 'Çox sürətli yazırsınız. 20 saniyə sonra yenidən '
                  'cəhd edin.',
              'code': 'RATE_LIMITED',
              'retry_after': 20,
            },
            status: 429,
            headers: {
              'retry-after': ['20'],
            },
          );
        }
        final sent = options.data;
        final message = _message(
          sent is Map ? sent['body']?.toString() : null,
          mine: true,
        );
        _messages.add(message);
        Timer(
          const Duration(milliseconds: 60),
          () => realtime.message({'id': message['id']}),
        );
        return _json({'data': message}, status: 201);
      default:
        return _json(const <String, dynamic>{});
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

  static ResponseBody _json(
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

class _FakeRealtime implements ChatRealtime {
  final List<DateTime> _joins = [];
  ChatRealtimeHandlers? _handlers;

  @override
  bool get isConnected => true;

  int joinsInLastMinute() {
    final since = DateTime.now().subtract(const Duration(minutes: 1));
    return _joins.where((at) => at.isAfter(since)).length;
  }

  @override
  Future<void> join(
    String token,
    String conversationId,
    ChatRealtimeHandlers handlers,
  ) async {
    if (_handlers == null) _joins.add(DateTime.now());
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

class _DevSession implements CacheManager {
  @override
  Future<String?> getToken() async => 'dev';

  @override
  Future<int?> getUserId() async => 7;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoContent implements AuthRepository {
  @override
  Future<ContentResponse> getContent({String? group, String? lang}) async =>
      ContentResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
