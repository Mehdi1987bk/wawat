import 'package:buking/screens/chat/bloc/chat_conversation_bloc.dart';
import 'package:buking/screens/chat/bloc/chat_list_bloc.dart';
import 'package:buking/screens/home/tabs/profile_tab/unread_chat_bloc.dart';
import 'package:buking/services/network_status_service.dart';
import 'package:buking/services/notification_socket_service.dart';
// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_chat_server.dart';

const _s = Duration(seconds: 1);
const _ms = Duration(milliseconds: 1);

const _conversations = 'GET /conversations';
const _unreadCount = 'GET /conversations/unread-count';
const _getMessages = 'GET /conversations/{id}/messages';
const _postMessage = 'POST /conversations/{id}/messages';
const _read = 'POST /conversations/{id}/read';
const _typing = 'POST /conversations/{id}/typing';

const _chatId = '01CONVERSATION';

final _notifications = NotificationSocketService.instance;

void _newMessageNotification() =>
    _notifications.handleEventForTest({'unreadCount': 1});

class _App {
  _App(this.async, {int conversations = 25}) {
    server = FakeChatServer(clock: _now)
      ..conversations = [
        for (var i = 1; i <= conversations; i++)
          {
            'id': 'conversation-$i',
            'other_user': {'id': 100 + i, 'name': 'Собеседник $i'},
            'unread_count': 0,
          },
      ];
    list = ChatListBloc(
      chatApi: server.api(),
      pusher: pusher,
      cacheManager: FakeSession(),
    );
    badge = UnreadChatBloc(
      chatApi: server.api(),
      pusher: pusher,
      cacheManager: FakeSession(),
    );
  }

  static final _start = DateTime(2026, 10, 13, 19, 33);

  final FakeAsync async;
  late final FakeChatServer server;
  final pusher = FakePusher();
  late final ChatListBloc list;
  late final UnreadChatBloc badge;
  ChatConversationBloc? chat;
  final realtime = FakeRealtime();

  DateTime _now() => _start.add(async.elapsed);

  void start() {
    badge.init();
    list.init().then((_) => list.loadConversations());
    async.elapse(_s);
  }

  void openChat() {
    _notifications.enterConversation(_chatId);
    final bloc = chat = ChatConversationBloc(
      chatApi: server.api(),
      realtime: realtime,
      cacheManager: FakeSession(),
      clock: _now,
    );
    bloc.initChat(_chatId).then((_) => bloc.loadMessages());
    async.elapse(_ms * 10);
  }

  void closeChat() {
    list.refreshCurrent().then((_) => badge.fetchUnreadCount());
    async.elapse(_ms * 300);
    chat?.dispose();
    chat = null;
    _notifications.leaveConversation(_chatId);
    async.elapse(_s);
  }

  void typeAndSend(String text) {
    for (var i = 0; i < 20; i++) {
      chat!.onComposerChanged('$text $i');
      async.elapse(_ms * 100);
    }
    chat!.sendMessage(text, null);
    async.elapse(_ms * 10);
  }

  void close() {
    chat?.dispose();
    list.dispose();
    badge.dispose();
    async.elapse(_s);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    _notifications.leaveConversation(_chatId);
    NetworkStatusService.instance.markOnline();
  });

  test('25 диалогов в списке — каналы на каждый не открываются', () {
    fakeAsync((async) {
      final app = _App(async)..start();

      expect(app.pusher.channels, {'private-user.7'});
      expect(app.server.count(_conversations), 1);
      expect(app.server.count(_unreadCount), 1);
      app.close();
    });
  });

  group('список диалогов', () {
    test('пачка событий — один запрос, а не по запросу на событие', () {
      fakeAsync((async) {
        final app = _App(async)..start();

        for (var i = 0; i < 5; i++) {
          _newMessageNotification();
          app.pusher.userEvent({'id': 'msg-$i'});
          async.elapse(_ms * 20);
        }
        async.elapse(_s);

        expect(app.server.count(_conversations), 2);
        app.close();
      });
    });

    test('под открытым чатом не перезагружается; после закрытия — один раз', () {
      fakeAsync((async) {
        final app = _App(async)..start();
        app.openChat();

        for (var i = 0; i < 16; i++) {
          _newMessageNotification();
          app.pusher.userEvent({'id': 'msg-$i'});
          async.elapse(_s * 3);
        }
        expect(app.server.count(_conversations), 1);

        app.chat!.dispose();
        app.chat = null;
        _notifications.leaveConversation(_chatId);
        async.elapse(_s);
        expect(app.server.count(_conversations), 2);
        app.close();
      });
    });

    test('чат поверх чата: закрыли верхний — список всё ещё не трогаем', () {
      fakeAsync((async) {
        final app = _App(async)..start();
        _notifications.enterConversation(_chatId);
        _notifications.enterConversation('другой');
        _newMessageNotification();
        async.elapse(_s);

        _notifications.leaveConversation('другой');
        async.elapse(_s);
        expect(app.server.count(_conversations), 1);

        _notifications.leaveConversation(_chatId);
        async.elapse(_s);
        expect(app.server.count(_conversations), 2);
        app.close();
      });
    });
  });

  group('счётчик непрочитанных', () {
    test('внутри открытого чата не запрашивается вовсе', () {
      fakeAsync((async) {
        final app = _App(async)..start();
        app.openChat();

        for (var i = 0; i < 35; i++) {
          app.badge.fetchUnreadCount();
          app.pusher.userEvent({'id': 'msg-$i'});
          async.elapse(_s * 2);
        }
        expect(app.server.count(_unreadCount), 1);

        app.chat!.dispose();
        app.chat = null;
        _notifications.leaveConversation(_chatId);
        async.elapse(_s);
        expect(app.server.count(_unreadCount), 2);
        app.close();
      });
    });

    test('экран «нет сети» поверх открытого чата — запрос уходит', () {
      fakeAsync((async) {
        final app = _App(async)..start();
        app.openChat();
        NetworkStatusService.instance.markOffline();

        app.badge.fetchUnreadCount();
        async.elapse(_s);

        expect(app.server.count(_unreadCount), 2);
        app.close();
      });
    });

    test('одновременные просьбы делят один запрос', () {
      fakeAsync((async) {
        final app = _App(async)..start();

        app.badge.fetchUnreadCount();
        app.badge.fetchUnreadCount();
        app.badge.fetchUnreadCount();
        async.elapse(_s);

        expect(app.server.count(_unreadCount), 2);
        app.close();
      });
    });
  });

  test('активная минута целиком: 16 сообщений — около 30 запросов, было 161',
      () {
    fakeAsync((async) {
      final app = _App(async)..start();
      app.openChat();
      final before = app.server.log.length;
      app.server.onCreated = (message) {
        Future<void>.delayed(_ms * 50, () {
          app.realtime.message({'id': message['id']});
          app.pusher.userEvent({'id': message['id']});
        });
      };

      for (var i = 1; i <= 16; i++) {
        app.typeAndSend('сообщение $i');
        async.elapse(_ms * 1740);
      }

      final minute = app.server.log.sublist(before);
      int of(String route) => minute.where((entry) => entry == route).length;
      // ignore: avoid_print
      print('Запросов за минуту: ${minute.length} — ${{
        for (final route in minute.toSet()) route: of(route),
      }}');

      expect(of(_postMessage), 16);
      expect(of(_getMessages), lessThanOrEqualTo(1));
      expect(of(_read), 0);
      expect(of(_conversations), 0);
      expect(of(_unreadCount), 0);
      expect(of(_typing), lessThanOrEqualTo(20));
      expect(minute.length, lessThanOrEqualTo(37));

      final atClose = app.server.log.length;
      app.closeChat();
      final closing = app.server.log.sublist(atClose);
      expect(closing.where((entry) => entry == _conversations).length, 1);
      expect(closing.where((entry) => entry == _unreadCount).length, 1);
      app.close();
    });
  });
}
