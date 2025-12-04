import 'dart:async';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../data/network/api/chat_api.dart';
import '../../../data/network/response/chat_response.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_bloc.dart';

class ChatListBloc extends BaseBloc {
  final ChatApi _chatApi = ChatApi(sl.get<Dio>());

  final BehaviorSubject<List<Conversation>> _conversationsSubject =
  BehaviorSubject.seeded([]);
  final BehaviorSubject<bool> _isLoadingMoreSubject =
  BehaviorSubject.seeded(false);

  Stream<List<Conversation>> get conversationsStream =>
      _conversationsSubject.stream;
  Stream<bool> get isLoadingMoreStream => _isLoadingMoreSubject.stream;

  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;
  bool _showArchived = false;

  Future<void> loadConversations() async {
    _showArchived = false;
    _currentPage = 1;

    try {
      final response = await _chatApi.getConversations(20, _currentPage);
      _conversationsSubject.add(response.data);
      _lastPage = response.meta.lastPage;
    } catch (e) {
      print('Error loading conversations: $e');
      _conversationsSubject.addError(e);
    }
  }

  Future<void> loadArchivedConversations() async {
    _showArchived = true;
    _currentPage = 1;

    try {
      final response =
      await _chatApi.getArchivedConversations(20, _currentPage);
      _conversationsSubject.add(response.data);
      _lastPage = response.meta.lastPage;
    } catch (e) {
      print('Error loading archived conversations: $e');
      _conversationsSubject.addError(e);
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

  Future<void> togglePin(int conversationId) async {
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

  Future<void> toggleArchive(int conversationId) async {
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

  Future<void> deleteConversation(int conversationId) async {
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
    _conversationsSubject.close();
    _isLoadingMoreSubject.close();
    super.dispose();
  }
}
