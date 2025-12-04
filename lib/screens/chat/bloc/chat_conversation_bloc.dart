import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../data/cache/cache_manager.dart';
import '../../../data/network/api/chat_api.dart';
import '../../../data/network/response/chat_response.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';
import '../../../services/pusher_service.dart';

class ChatConversationBloc extends BaseBloc {
  final ChatApi _chatApi = ChatApi(sl.get<Dio>());
  final PusherService _pusherService = PusherService();
  final CacheManager _cacheManager = sl.get<CacheManager>();

  final BehaviorSubject<List<ChatMessage>> _messagesSubject =
  BehaviorSubject.seeded([]);
  final BehaviorSubject<bool> _isLoadingMoreSubject =
  BehaviorSubject.seeded(false);

  Stream<List<ChatMessage>> get messagesStream => _messagesSubject.stream;
  Stream<bool> get isLoadingMoreStream => _isLoadingMoreSubject.stream;

  int? _conversationId;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;
  int? _myUserId;

  Future<void> initChat(int conversationId) async {
    _conversationId = conversationId;
    _myUserId = await _cacheManager.getUserId();

    final token = await _cacheManager.getToken();
    if (token != null) {
      await _pusherService.initialize(token);
      _pusherService.subscribeToConversation(
        conversationId,
        _onNewMessage,
      );
    }
  }

  void _onNewMessage(dynamic data) {
    try {
      final message = ChatMessage.fromJson(data['message']);
      final currentMessages = _messagesSubject.value;
      // Добавляем новое сообщение в НАЧАЛО (так как список перевернут)
      _messagesSubject.add([message, ...currentMessages]);
    } catch (e) {
      print('Error handling new message: $e');
    }
  }

  Future<void> loadMessages() async {
    if (_conversationId == null) return;

    _currentPage = 1;

    try {
      final response =
      await _chatApi.getMessages(_conversationId!, 50, _currentPage);
      // ВАЖНО: Переворачиваем список - новые сообщения первыми
      _messagesSubject.add(response.data.reversed.toList());
      _lastPage = response.meta.lastPage;
    } catch (e) {
      print('Error loading messages: $e');
      _messagesSubject.addError(e);
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore ||
        _currentPage >= _lastPage ||
        _conversationId == null) {
      return;
    }

    _isLoadingMore = true;
    _isLoadingMoreSubject.add(true);

    try {
      _currentPage++;
      final response =
      await _chatApi.getMessages(_conversationId!, 50, _currentPage);

      final currentMessages = _messagesSubject.value;
      // Добавляем старые сообщения в КОНЕЦ списка
      _messagesSubject.add([
        ...currentMessages,
        ...response.data.reversed.toList(),
      ]);
      _lastPage = response.meta.lastPage;
    } catch (e) {
      print('Error loading more: $e');
      _currentPage--;
    } finally {
      _isLoadingMore = false;
      _isLoadingMoreSubject.add(false);
    }
  }

  Future<void> sendMessage(String? body, File? file) async {
    if (_conversationId == null) return;
    if ((body == null || body.isEmpty) && file == null) return;

    try {
      MessageResponse response;

      if (file != null) {
        response = await _chatApi.sendMessageWithFile(
          _conversationId!,
          file,
          body?.isNotEmpty == true ? body : null,
        );
      } else {
        response = await _chatApi.sendTextMessage(
          _conversationId!,
          {'body': body},
        );
      }

      // Добавляем новое сообщение в НАЧАЛО списка
      final currentMessages = _messagesSubject.value;
      _messagesSubject.add([response.data, ...currentMessages]);
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> blockUser(int userId) async {
    try {
      await _chatApi.blockUser({'user_id': userId});
    } catch (e) {
      print('Error blocking user: $e');
    }
  }

  Future<void> deleteConversation() async {
    if (_conversationId == null) return;

    try {
      await _chatApi.deleteConversation(_conversationId!);
    } catch (e) {
      print('Error deleting conversation: $e');
    }
  }

  bool isMyMessage(ChatMessage message) {
    return message.user?.id == _myUserId;
  }

  @override
  void dispose() {
    if (_conversationId != null) {
      _pusherService.unsubscribe('private-conversation.$_conversationId');
    }
    _messagesSubject.close();
    _isLoadingMoreSubject.close();
    super.dispose();
  }
}
