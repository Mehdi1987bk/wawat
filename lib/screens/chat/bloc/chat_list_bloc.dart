import 'dart:async';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../data/cache/cache_manager.dart';
import '../../../data/network/api/chat_api.dart';
import '../../../data/network/response/chat_response.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';
import '../../../services/pusher_service.dart';

class ChatListBloc extends BaseBloc {
  final ChatApi _chatApi = ChatApi(sl.get<Dio>());
  final PusherService _pusherService = PusherService();
  final CacheManager _cacheManager = sl.get<CacheManager>();

  final BehaviorSubject<List<Conversation>> _conversationsSubject =
      BehaviorSubject.seeded([]);
  final BehaviorSubject<bool> _isLoadingMoreSubject =
      BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> _isLoadingSubject = BehaviorSubject.seeded(true);

  Stream<List<Conversation>> get conversationsStream =>
      _conversationsSubject.stream;
  Stream<bool> get isLoadingMoreStream => _isLoadingMoreSubject.stream;
  Stream<bool> get isLoadingStream => _isLoadingSubject.stream;

  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;
  bool _showArchived = false;
  int? _myUserId;
  bool _isInitialized = false; // <-- Добавлено

  /// Инициализация - вызывать в initState
  Future<void> init() async {
    // Предотвращаем двойную инициализацию
    if (_isInitialized) {
      print('⚠️ ChatListBloc already initialized, skipping');
      return;
    }
    _isInitialized = true;

    _myUserId = await _cacheManager.getUserId();
    final token = await _cacheManager.getToken();

    print('🚀 ChatListBloc init: userId=$_myUserId, hasToken=${token != null}');

    if (token != null && _myUserId != null) {
      await _pusherService.initialize(token);
      await _pusherService.subscribeToUserChannel(_myUserId!, _onNewMessage);
      print('✅ Subscribed to user channel for chat list updates');
    }
  }

  void _onNewMessage(dynamic data) {
    print('📬 ChatListBloc received: $data');

    try {
      final conversationId = data['conversation_id']?.toString();
      final messageData = data['message'] as Map<String, dynamic>?;
      final unreadCounts = data['unread_counts'] as Map<String, dynamic>?;

      if (conversationId == null || messageData == null) {
        print('⚠️ Invalid data, skipping');
        return;
      }

      final newMessage = ChatMessage.fromJson(messageData);
      final conversations =
          List<Conversation>.from(_conversationsSubject.value);

      // Находим чат в списке
      final index = conversations.indexWhere((c) => c.id == conversationId);

      if (index == -1) {
        // Чат не найден - перезагружаем список
        print('⚠️ Conversation $conversationId not found, reloading');
        loadConversations();
        return;
      }

      final oldConversation = conversations[index];

      // Получаем новый unread count
      int newUnreadCount = oldConversation.unreadCount;
      if (unreadCounts != null && _myUserId != null) {
        final count = unreadCounts[_myUserId.toString()];
        if (count != null) {
          newUnreadCount = count as int;
        }
      }

      // Создаем обновленный чат
      final updatedConversation = Conversation(
        id: oldConversation.id,
        user: oldConversation.user,
        lastMessage: newMessage,
        unreadCount: newUnreadCount,
        isPinned: oldConversation.isPinned,
        isArchived: oldConversation.isArchived,
        isBlocked: oldConversation.isBlocked,
        isBlockedByOther: oldConversation.isBlockedByOther,
        lastMessageAt: newMessage.createdAt,
      );

      // Удаляем старый
      conversations.removeAt(index);

      // Добавляем в начало соответствующей группы
      if (updatedConversation.isPinned) {
        // Закрепленные всегда в начале
        conversations.insert(0, updatedConversation);
      } else {
        // Находим позицию после всех закрепленных
        int insertAt = 0;
        while (insertAt < conversations.length &&
            conversations[insertAt].isPinned) {
          insertAt++;
        }
        // Вставляем в начало незакрепленных (сортировка по времени будет в UI)
        conversations.insert(insertAt, updatedConversation);
      }

      _conversationsSubject.add(conversations);
      print('✅ Chat list updated: conversation $conversationId moved to top');
    } catch (e) {
      print('❌ Error in _onNewMessage: $e');
    }
  }

  Future<void> loadConversations() async {
    _showArchived = false;
    _currentPage = 1;
    _isLoadingSubject.add(true);

    try {
      final response = await _chatApi.getConversations(20, _currentPage);
      _conversationsSubject.add(response.data);
      _lastPage = response.meta.lastPage;
    } catch (e) {
      print('Error loading conversations: $e');
      _conversationsSubject.addError(e);
    } finally {
      _isLoadingSubject.add(false);
    }
  }

  Future<void> blockUser(int userId) async {
    try {
      await _chatApi.blockUser({'user_id': userId});
      await loadConversations();
    } catch (e) {
      print('Error blocking user: $e');
    }
  }

  Future<void> unblockUser(int userId) async {
    try {
      await _chatApi.unblockUser({'user_id': userId});
      await loadConversations();
    } catch (e) {
      print('Error unblocking user: $e');
    }
  }

  Future<void> loadArchivedConversations() async {
    _showArchived = true;
    _currentPage = 1;
    _isLoadingSubject.add(true);

    try {
      final response =
          await _chatApi.getArchivedConversations(20, _currentPage);
      _conversationsSubject.add(response.data);
      _lastPage = response.meta.lastPage;
    } catch (e) {
      print('Error loading archived conversations: $e');
      _conversationsSubject.addError(e);
    } finally {
      _isLoadingSubject.add(false);
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || _currentPage >= _lastPage) return;

    _isLoadingMore = true;
    _isLoadingMoreSubject.add(true);

    try {
      _currentPage++;
      final response = _showArchived
          ? await _chatApi.getArchivedConversations(20, _currentPage)
          : await _chatApi.getConversations(20, _currentPage);

      final currentConversations = _conversationsSubject.value;
      _conversationsSubject.add([...currentConversations, ...response.data]);
      _lastPage = response.meta.lastPage;
    } catch (e) {
      print('Error loading more: $e');
      _currentPage--;
    } finally {
      _isLoadingMore = false;
      _isLoadingMoreSubject.add(false);
    }
  }

  Future<void> togglePin(String conversationId) async {
    try {
      final currentConversations = _conversationsSubject.value;
      final conversation =
          currentConversations.firstWhere((c) => c.id == conversationId);

      if (conversation.isPinned) {
        await _chatApi.unpinConversation(conversationId);
      } else {
        await _chatApi.pinConversation(conversationId);
      }

      await loadConversations();
    } catch (e) {
      print('Error toggling pin: $e');
    }
  }

  Future<void> toggleArchive(String conversationId) async {
    try {
      final currentConversations = _conversationsSubject.value;
      final conversation =
          currentConversations.firstWhere((c) => c.id == conversationId);

      if (conversation.isArchived) {
        await _chatApi.unarchiveConversation(conversationId);
      } else {
        await _chatApi.archiveConversation(conversationId);
      }

      _conversationsSubject.add(
        currentConversations.where((c) => c.id != conversationId).toList(),
      );
    } catch (e) {
      print('Error toggling archive: $e');
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _chatApi.deleteConversation(conversationId);

      final currentConversations = _conversationsSubject.value;
      _conversationsSubject.add(
        currentConversations.where((c) => c.id != conversationId).toList(),
      );
    } catch (e) {
      print('Error deleting conversation: $e');
    }
  }

  @override
  void dispose() {
    // НЕ отписываемся от user channel при dispose,
    // так как это singleton и может использоваться в других местах
    _conversationsSubject.close();
    _isLoadingMoreSubject.close();
    _isLoadingSubject.close();
    super.dispose();
  }
}
