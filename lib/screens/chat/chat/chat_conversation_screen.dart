import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/network/response/chat_response.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_screen.dart';
import '../../../presentation/bloc/error_dispatcher.dart';
import '../../../services/wawat_content.dart';
import '../bloc/chat_conversation_bloc.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';
import '../../home/tabs/profile_tab/unread_chat_bloc.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _brand100 = Color(0xFFCFE3FD);
const _ink900 = Color(0xFF0F172A);
const _ink700 = Color(0xFF334155);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);
const _emerald = Color(0xFF22C55E);
const _threadBg = Color(0xFFEAEEF4);

class ChatConversationScreen extends BaseScreen {
  final Conversation conversation;

  ChatConversationScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState
    extends BaseState<ChatConversationScreen, ChatConversationBloc>
    with ErrorDispatcher {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  File? _selectedFile;
  Map<String, String> _content = const {};
  AppLifecycleListener? _lifecycleListener;
  late bool _isBlockedByMe;
  late bool _isBlockedByOther;
  late bool _isPinned;
  late bool _isArchived;

  bool get _isBlocked => _isBlockedByMe || _isBlockedByOther;

  @override
  bool get useSystemOverlay => false;

  @override
  void initState() {
    super.initState();
    _isBlockedByMe = widget.conversation.isBlocked;
    _isBlockedByOther = widget.conversation.isBlockedByOther;
    _isPinned = widget.conversation.isPinned;
    _isArchived = widget.conversation.isArchived;
    bloc.initChat(widget.conversation.id).then((_) async {
      await bloc.loadMessages();
      if (mounted) {
        sl.get<UnreadChatBloc>().fetchUnreadCount();
      }
    });
    WawatContent.loadDefault().then((content) {
      if (mounted) setState(() => _content = content);
    });
    _scrollController.addListener(_onScroll);
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        bloc.reconnectRealtime();
        sl.get<UnreadChatBloc>().fetchUnreadCount();
      },
      onInactive: () => bloc.stopTyping(),
      onPause: () => bloc.stopTyping(),
      onDetach: () => bloc.stopTyping(),
    );
  }

  String _t(String key, [String? fallback]) {
    return WawatContent.text(_content, key, fallback);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      bloc.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    bloc.stopTyping();
    _messageController.dispose();
    _lifecycleListener?.dispose();
    super.dispose();
  }

  @override
  Widget body() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _threadBg,
        body: SafeArea(
          child: Column(
            children: [
              _ConversationHeader(
                conversation: widget.conversation,
                onBack: () => Navigator.of(context).maybePop(),
                onMenu: _showConversationOptions,
              ),
              Expanded(
                child: Stack(
                  children: [
                    const Positioned.fill(child: _ThreadBackground()),
                    StreamBuilder<bool>(
                      stream: bloc.isLoadingStream,
                      initialData: true,
                      builder: (context, loadingSnapshot) {
                        return StreamBuilder<Map<String, ShipmentData>>(
                          stream: bloc.shipmentsStream,
                          initialData: const {},
                          builder: (context, shipmentSnapshot) {
                            return StreamBuilder<List<ChatMessage>>(
                              stream: bloc.messagesStream,
                              initialData: const [],
                              builder: (context, snapshot) {
                                final messages = snapshot.data ?? const [];
                                if (loadingSnapshot.data == true &&
                                    messages.isEmpty) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: _brand,
                                      strokeWidth: 2,
                                    ),
                                  );
                                }
                                if (messages.isEmpty) {
                                  return _EmptyConversation(
                                    user: widget.conversation.user,
                                    content: _content,
                                  );
                                }

                                return RefreshIndicator(
                                  color: _brand,
                                  onRefresh: bloc.loadMessages,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    reverse: true,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                        14, 12, 14, 12),
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      final message = messages[index];
                                      final showDate = _shouldShowDate(
                                        messages,
                                        index,
                                      );
                                      return Column(
                                        children: [
                                          if (showDate)
                                            _DateSeparator(
                                              date: _dateLabel(
                                                message.createdAtDateTime,
                                              ),
                                            ),
                                          MessageBubble(
                                            message: message,
                                            isMyMessage:
                                                bloc.isMyMessage(message),
                                            shipment:
                                                message.card?.shipmentId == null
                                                    ? null
                                                    : shipmentSnapshot.data?[
                                                        message
                                                            .card!.shipmentId],
                                            onShipmentAction:
                                                _handleShipmentAction,
                                            onRetry: bloc.retryMessage,
                                            onLongPress: _showMessageOptions,
                                            onReview: _showReviewDialog,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              StreamBuilder<bool>(
                stream: bloc.otherUserTypingStream,
                initialData: false,
                builder: (context, snapshot) {
                  if (snapshot.data != true) return const SizedBox.shrink();
                  return _TypingIndicator(
                    user: widget.conversation.user,
                  );
                },
              ),
              if (_selectedFile != null)
                _FilePreview(
                    file: _selectedFile!,
                    onClear: () {
                      setState(() => _selectedFile = null);
                    }),
              ChatInput(
                controller: _messageController,
                enabled: !_isBlocked,
                content: _content,
                disabledText: _isBlockedByMe
                    ? _t(
                        'chat.input.blocked_by_me',
                      )
                    : _t(
                        'chat.input.blocked',
                      ),
                onSend: _send,
                onAttachImage: _pickImage,
                onChanged: bloc.onComposerChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldShowDate(List<ChatMessage> messages, int index) {
    final current = messages[index].createdAtDateTime;
    if (index == messages.length - 1) return true;
    final next = messages[index + 1].createdAtDateTime;
    return current.year != next.year ||
        current.month != next.month ||
        current.day != next.day;
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);
    if (messageDate == today) return _t('common.today');
    if (messageDate == today.subtract(const Duration(days: 1))) {
      return _t('common.yesterday');
    }
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedFile == null) return;
    _messageController.clear();
    final image = _selectedFile;
    if (mounted) setState(() => _selectedFile = null);
    await bloc.sendMessage(text, image);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null || !mounted) return;

    final file = File(pickedFile.path);
    final extension = pickedFile.path.split('.').last.toLowerCase();
    final supported = {'jpg', 'jpeg', 'png', 'webp'}.contains(extension);
    final size = await file.length();
    if (!supported || size > 30 * 1024 * 1024) {
      if (!mounted) return;
      _showError(
        !supported
            ? _t(
                'chat.image.unsupported',
                'Yalnız JPG, PNG və WEBP şəkilləri dəstəklənir.',
              )
            : _t(
                'chat.image.too_large',
                'Şəklin ölçüsü 30 MB-dan çox ola bilməz.',
              ),
      );
      return;
    }
    setState(() => _selectedFile = file);
  }

  Future<void> _handleShipmentAction(
    String shipmentId,
    String action,
  ) async {
    try {
      final body = await _shipmentActionBody(action);
      if (body == null && {'counter', 'dispute', 'cancel'}.contains(action)) {
        return;
      }
      final message =
          await bloc.runShipmentAction(shipmentId, action, body: body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message ?? _t('common.operation_completed'),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _brand,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_extractError(e)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFEF4444),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> _shipmentActionBody(String action) async {
    if (action == 'counter') {
      return _showCounterDialog();
    }
    if (action == 'dispute') {
      final reason = await _showTextPrompt(
        title: _t('chat.shipment.dispute', 'Problem bildir'),
        hint: _t('chat.shipment.reason', 'Səbəbi yaz'),
        minLength: 5,
      );
      return reason == null ? null : {'reason': reason};
    }
    if (action == 'cancel') {
      final note = await _showTextPrompt(
        title: _t('chat.shipment.cancel', 'Sövdələşməni ləğv et'),
        hint: _t('chat.shipment.reason', 'Səbəbi yaz'),
      );
      return note == null
          ? null
          : {
              'reason_code': 'other',
              if (note.isNotEmpty) 'reason_note': note,
            };
    }
    return null;
  }

  Future<Map<String, dynamic>?> _showCounterDialog() async {
    final weightController = TextEditingController();
    final priceController = TextEditingController();
    final noteController = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t('chat.shipment.counter', 'Təklifi dəyiş')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _t('chat.shipment.weight', 'Çəki (kq)'),
              ),
            ),
            TextField(
              controller: priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _t('chat.shipment.price', 'Ümumi qiymət'),
              ),
            ),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: _t('chat.shipment.note', 'Qeyd'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('common.cancel')),
          ),
          FilledButton(
            onPressed: () {
              final body = <String, dynamic>{};
              final weight = double.tryParse(
                weightController.text.replaceAll(',', '.'),
              );
              final price = double.tryParse(
                priceController.text.replaceAll(',', '.'),
              );
              if (weight != null) body['weight_kg'] = weight;
              if (price != null) body['price_total'] = price;
              if (noteController.text.trim().isNotEmpty) {
                body['note'] = noteController.text.trim();
              }
              Navigator.pop(context, body);
            },
            child: Text(_t('common.confirm')),
          ),
        ],
      ),
    );
    weightController.dispose();
    priceController.dispose();
    noteController.dispose();
    return result;
  }

  Future<String?> _showTextPrompt({
    required String title,
    required String hint,
    int minLength = 0,
    int maxLength = 1000,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 5,
          maxLength: maxLength,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('common.cancel')),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.length < minLength) return;
              Navigator.pop(context, text);
            },
            child: Text(_t('common.confirm')),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _showReviewDialog(String shipmentId) async {
    final commentController = TextEditingController();
    var rating = 5;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(_t('chat.review.title', 'Rəy yaz')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final value = index + 1;
                  return IconButton(
                    onPressed: () => setDialogState(() => rating = value),
                    icon: Icon(
                      value <= rating
                          ? PhosphorIconsFill.star
                          : PhosphorIconsRegular.star,
                      color: const Color(0xFFF59E0B),
                    ),
                  );
                }),
              ),
              TextField(
                controller: commentController,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: _t('chat.review.comment', 'Şərhinizi yazın'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(_t('common.cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(_t('common.confirm')),
            ),
          ],
        ),
      ),
    );
    final comment = commentController.text.trim();
    commentController.dispose();
    if (result != true) return;

    try {
      final message = await bloc.submitShipmentReview(
        shipmentId,
        rating: rating,
        comment: comment,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message ?? _t('review.submitted', 'Rəy göndərildi'),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _brand,
        ),
      );
    } catch (error) {
      _showError(_extractError(error));
    }
  }

  String _extractError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final errors = data['errors'];
        if (errors is Map) {
          for (final value in errors.values) {
            if (value is List && value.isNotEmpty) {
              return value.first.toString();
            }
          }
        }
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) return message;
      }
    }
    final text = error.toString();
    final messageMatch = RegExp(r'"message":"([^"]+)"').firstMatch(text);
    return messageMatch?.group(1) ??
        _t('common.error', 'Xəta baş verdi. Yenidən cəhd edin.');
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  void _showMessageOptions(ChatMessage message) {
    final isMine = bloc.isMyMessage(message);
    final canEdit = isMine &&
        message.type == 'text' &&
        message.isRead != true &&
        !message.id.startsWith('local-');
    final canDelete =
        message.type != 'system_card' && !message.id.startsWith('local-');

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.body?.isNotEmpty == true)
                _SheetTile(
                  icon: PhosphorIconsRegular.copy,
                  label: _t('chat.message.copy', 'Kopyala'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: message.body!));
                    Navigator.pop(sheetContext);
                  },
                ),
              if (canEdit)
                _SheetTile(
                  icon: PhosphorIconsRegular.pencilSimple,
                  label: _t('chat.message.edit', 'Redaktə et'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _editMessage(message);
                  },
                ),
              if (canDelete)
                _SheetTile(
                  icon: PhosphorIconsRegular.trash,
                  label: _t('chat.message.delete', 'Sil'),
                  danger: true,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _deleteMessage(message);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editMessage(ChatMessage message) async {
    final controller = TextEditingController(text: message.body);
    final body = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_t('chat.message.edit', 'Redaktə et')),
        content: TextField(
          controller: controller,
          minLines: 1,
          maxLines: 5,
          maxLength: 5000,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(_t('common.cancel')),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: Text(_t('common.save')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (body == null) return;
    try {
      await bloc.editMessage(message.id, body);
    } catch (error) {
      _showError(_extractError(error));
    }
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    try {
      await bloc.deleteMessage(message.id);
    } catch (error) {
      _showError(_extractError(error));
    }
  }

  void _showConversationOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _HeaderAvatar(user: widget.conversation.user, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.conversation.user.fullname,
                            style: const TextStyle(
                              color: _ink900,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            _t('chat.action.profile'),
                            style:
                                const TextStyle(color: _ink400, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _SheetTile(
                  icon: PhosphorIconsRegular.pushPin,
                  label: _isPinned
                      ? _t('chat.action.unpin')
                      : _t('chat.action.pin'),
                  onTap: () {
                    Navigator.pop(context);
                    _runConversationAction(() async {
                      await bloc.setPinned(!_isPinned);
                      if (mounted) {
                        setState(() => _isPinned = !_isPinned);
                      }
                    });
                  },
                ),
                _SheetTile(
                  icon: PhosphorIconsRegular.archive,
                  label: _isArchived
                      ? _t('chat.action.unarchive')
                      : _t('chat.action.archive'),
                  onTap: () {
                    Navigator.pop(context);
                    _runConversationAction(() async {
                      await bloc.setArchived(!_isArchived);
                      if (!mounted) return;
                      setState(() => _isArchived = !_isArchived);
                      Navigator.of(this.context).maybePop();
                    });
                  },
                ),
                _SheetTile(
                  icon: PhosphorIconsRegular.prohibit,
                  label: _isBlockedByMe
                      ? _t('chat.action.unblock')
                      : _t('chat.action.block'),
                  danger: true,
                  onTap: () {
                    Navigator.pop(context);
                    _runConversationAction(() async {
                      await bloc.setUserBlocked(
                        widget.conversation.user.apiId,
                        !_isBlockedByMe,
                      );
                      if (mounted) {
                        setState(() => _isBlockedByMe = !_isBlockedByMe);
                        if (_isBlockedByMe) {
                          bloc.stopTyping();
                        }
                      }
                    });
                  },
                ),
                _SheetTile(
                  icon: PhosphorIconsRegular.trash,
                  label: _t('chat.action.delete'),
                  danger: true,
                  onTap: () {
                    Navigator.pop(context);
                    _runConversationAction(() async {
                      await bloc.deleteConversation();
                      if (mounted) {
                        Navigator.of(this.context).maybePop();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _runConversationAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      _showError(_extractError(error));
    }
  }

  @override
  ChatConversationBloc provideBloc() => ChatConversationBloc();
}

class _ConversationHeader extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onBack;
  final VoidCallback onMenu;

  const _ConversationHeader({
    required this.conversation,
    required this.onBack,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final user = conversation.user;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: _ink900.withValues(alpha: 0.06)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onBack,
            child: const SizedBox(
              width: 36,
              height: 40,
              child:
                  Icon(PhosphorIconsBold.arrowLeft, color: _ink700, size: 22),
            ),
          ),
          _HeaderAvatar(user: user, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ink900,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(PhosphorIconsFill.sealCheck,
                          color: _brand, size: 13),
                    ],
                  ],
                ),
                Text(
                  user.getLastSeenText(context),
                  maxLines: 1,
                  style: TextStyle(
                    color: user.isOnline ? _emerald : _ink400,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onMenu,
            child: const SizedBox(
              width: 36,
              height: 40,
              child: Icon(PhosphorIconsBold.dotsThreeVertical,
                  color: _ink500, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  final ChatUser user;

  const _TypingIndicator({
    required this.user,
  });

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _threadBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: _ink900.withValues(alpha: 0.08),
              child: Text(
                widget.user.initials,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 9,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(
                  color: _ink900.withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _ink900.withValues(alpha: 0.07),
                    blurRadius: 1.5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final elapsedSeconds =
                      (_controller.lastElapsedDuration ?? Duration.zero)
                              .inMicroseconds /
                          Duration.microsecondsPerSecond;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (index) => _HtmlTypingDot(
                        state: _typingDotStateAt(
                          elapsedSeconds,
                          index * 0.2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HtmlTypingDot extends StatelessWidget {
  final (double, double) state;

  const _HtmlTypingDot({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Transform.translate(
        offset: Offset(0, state.$1),
        child: Opacity(
          opacity: state.$2,
          child: const SizedBox(
            width: 6,
            height: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF94A3B8),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _typingAnimationSeconds = 1.2;

(double, double) _typingDotStateAt(
  double elapsedSeconds,
  double delaySeconds,
) {
  final localTime = elapsedSeconds - delaySeconds;
  if (localTime < 0) return (0, 1);
  return _typingDotState((localTime / _typingAnimationSeconds) % 1);
}

(double, double) _typingDotState(double progress) {
  if (progress <= 0.3) {
    final value = Curves.ease.transform(progress / 0.3);
    return (-4 * value, 0.4 + 0.6 * value);
  }
  if (progress <= 0.6) {
    final value = Curves.ease.transform((progress - 0.3) / 0.3);
    return (-4 + 4 * value, 1 - 0.6 * value);
  }
  return (0, 0.4);
}

class _HeaderAvatar extends StatelessWidget {
  final ChatUser user;
  final double size;

  const _HeaderAvatar({required this.user, required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: _brand100,
          backgroundImage: user.avatarUrl.isEmpty
              ? null
              : CachedNetworkImageProvider(user.avatarUrl),
          child: user.avatarUrl.isEmpty
              ? Text(
                  user.initials,
                  style: TextStyle(
                    color: _brand,
                    fontSize: size * 0.31,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : null,
        ),
        if (user.isOnline)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: _emerald,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _ThreadBackground extends StatelessWidget {
  const _ThreadBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotPainter(), child: const SizedBox.expand());
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(_threadBg, BlendMode.src);
    final paint = Paint()..color = _ink900.withValues(alpha: 0.035);
    for (double x = 0; x < size.width; x += 22) {
      for (double y = 0; y < size.height; y += 22) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DateSeparator extends StatelessWidget {
  final String date;

  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: _ink900.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          date,
          style: const TextStyle(
            color: _ink500,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  final ChatUser user;
  final Map<String, String> content;

  const _EmptyConversation({required this.user, required this.content});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 38),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: _ink900.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(PhosphorIconsRegular.handWaving,
                  color: _brand, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              WawatContent.text(content, 'chat.thread.empty_title'),
              style: const TextStyle(
                color: _ink900,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              WawatContent.text(
                content,
                'chat.thread.empty_subtitle',
              ).replaceAll('{name}', user.fullname),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ink500,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilePreview extends StatelessWidget {
  final File file;
  final VoidCallback onClear;

  const _FilePreview({required this.file, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final isImage = RegExp(r'\.(png|jpg|jpeg|webp)$', caseSensitive: false)
        .hasMatch(file.path);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              color: _brand50,
              child: isImage
                  ? Image.file(file, fit: BoxFit.cover)
                  : const Icon(PhosphorIconsRegular.file, color: _brand),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              file.path.split('/').last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink900,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(PhosphorIconsBold.x, color: _ink400),
          ),
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFEF4444) : _ink900;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: danger ? color : _ink500),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
