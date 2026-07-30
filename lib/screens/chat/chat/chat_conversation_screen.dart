import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:buking/presentation/common/app_bottom_sheet.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/network/response/chat_response.dart';
import '../../../main.dart';
import '../../../presentation/bloc/base_screen.dart';
import '../../../presentation/bloc/error_dispatcher.dart';
import '../../../presentation/resourses/wawat_dark.dart';
import '../../../services/notification_socket_service.dart';
import '../../../services/wawat_content.dart';
import '../bloc/chat_conversation_bloc.dart';
import '../widgets/chat_input.dart';
import '../widgets/deal_pin_bar.dart';
import '../widgets/message_bubble.dart';
import '../../home/tabs/profile_tab/deals/deal_detail_screen.dart';
import '../../home/tabs/profile_tab/new_profile/new_profile_screen.dart';
import '../../home/tabs/profile_tab/support/support_screen.dart';
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

// Тёмная ветка = единый графит из [WawatDark]; светлая часть остаётся как была.
Color _cThreadBg(bool d) => d ? WawatDark.bg : _threadBg;
Color _cSurface(bool d) => d ? WawatDark.surface : Colors.white;
Color _cText(bool d) => d ? WawatDark.textPrimary : _ink900;
Color _cText2(bool d) => d ? WawatDark.textSecondary : _ink700;
Color _cText3(bool d) => d ? WawatDark.textSecondary : _ink500;
Color _cMuted(bool d) => d ? WawatDark.textMuted : _ink400;
Color _cGrip(bool d) => d ? WawatDark.grab : const Color(0xFFCBD5E1);
Color _cBrandSoft(bool d) => d ? WawatDark.brandSoft : _brand50;
Color _cHeaderLine(bool d) =>
    d ? WawatDark.divider : _ink900.withValues(alpha: 0.06);

/// Message ids of the newest proposal per shipment. Older proposals in the same
/// deal were superseded by a counter-offer and must stay read-only (no
/// accept/reject/change buttons), so only these ids remain actionable.
Set<String> _currentProposalMessageIds(List<ChatMessage> messages) {
  final latest = <String, ChatMessage>{};
  for (final message in messages) {
    final card = message.card;
    if (card == null || card.type != 'proposal') continue;
    final shipmentId = card.shipmentId;
    if (shipmentId == null || shipmentId.isEmpty) continue;
    final existing = latest[shipmentId];
    if (existing == null ||
        message.createdAtDateTime.isAfter(existing.createdAtDateTime)) {
      latest[shipmentId] = message;
    }
  }
  return latest.values.map((message) => message.id).toSet();
}

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
  ChatReplyRef? _replyTarget;
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
    // Suppress the global new-message banner while this thread is open.
    NotificationSocketService.instance
        .setActiveConversation(widget.conversation.id);
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
    // Surface send failures (e.g. blocked by the peer) with the server message.
    bloc.sendErrorsStream.listen((error) {
      if (mounted) _showError(_extractError(error));
    });
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
    NotificationSocketService.instance.setActiveConversation(null);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Column(
        children: [
          ColoredBox(
            color: _cSurface(isDark),
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ConversationHeader(
                    conversation: widget.conversation,
                    onBack: () => Navigator.of(context).maybePop(),
                    onMenu: _showConversationOptions,
                    onOpenProfile: _openProfile,
                  ),
                  StreamBuilder<ShipmentData?>(
                    stream: bloc.activeShipmentStream,
                    initialData: null,
                    builder: (context, snapshot) {
                      final shipment = snapshot.data;
                      if (shipment == null) return const SizedBox.shrink();
                      return DealPinBar(
                        shipment: shipment,
                        content: _content,
                        onTap: () => _openDeal(shipment.id),
                      );
                    },
                  ),
                ],
              ),
            ),
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

                            final currentOfferIds =
                                _currentProposalMessageIds(messages);

                            return RefreshIndicator(
                              color: _brand,
                              onRefresh: bloc.loadMessages,
                              child: ListView.builder(
                                controller: _scrollController,
                                reverse: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                                        isMyMessage: bloc.isMyMessage(message),
                                        isCurrentOffer:
                                            message.card?.type != 'proposal' ||
                                                currentOfferIds
                                                    .contains(message.id),
                                        shipment:
                                            message.card?.shipmentId == null
                                                ? null
                                                : shipmentSnapshot.data?[
                                                    message.card!.shipmentId],
                                        onShipmentAction: _handleShipmentAction,
                                        onRetry: bloc.retryMessage,
                                        onLongPress: _showMessageOptions,
                                        onReview: _showReviewDialog,
                                        onSupport: _openSupport,
                                        onReply: _startReply,
                                        onOpenProfile: _openProfile,
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
            hasAttachment: _selectedFile != null,
            content: _content,
            disabledText: _isBlockedByMe
                ? _t(
                    'chat.input.blocked_by_me',
                  )
                : _t(
                    'chat.input.blocked',
                  ),
            onDisabledTap: _isBlockedByMe ? _unblockUser : null,
            onSend: _send,
            onAttachImage: _pickImage,
            onChanged: bloc.onComposerChanged,
            replyTo: _replyTarget,
            onCancelReply: () => setState(() => _replyTarget = null),
          ),
        ],
      ),
    );
  }

  /// Unblock straight from the composer banner — direct, no confirmation.
  void _unblockUser() {
    _runConversationAction(() async {
      await bloc.setUserBlocked(widget.conversation.user.apiId, false);
      if (mounted) setState(() => _isBlockedByMe = false);
    });
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

  /// Swipe (or long-press → reply) starts quoting [message] in the composer.
  void _startReply(ChatMessage message) {
    setState(() {
      _replyTarget = ChatReplyRef.fromMessage(
        message,
        quotedIsMine: bloc.isMyMessage(message),
        peerName: widget.conversation.user.fullname,
      );
    });
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedFile == null) return;
    _messageController.clear();
    final image = _selectedFile;
    final reply = _replyTarget;
    if (mounted)
      setState(() {
        _selectedFile = null;
        _replyTarget = null;
      });
    await bloc.sendMessage(text, image, replyTo: reply);
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

  Future<Map<String, dynamic>?> _showCounterDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showAppBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: isDark ? WawatDark.scrim : _ink900.withValues(alpha: 0.4),
      builder: (_) => _CounterSheet(content: _content),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showAppBottomSheet<_ReviewResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: isDark ? WawatDark.scrim : _ink900.withValues(alpha: 0.4),
      builder: (_) => _ReviewSheet(content: _content),
    );
    if (result == null) return;

    try {
      final message = await bloc.submitShipmentReview(
        shipmentId,
        rating: result.rating,
        comment: result.comment,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showAppBottomSheet<void>(
      context: context,
      backgroundColor: _cSurface(isDark),
      barrierColor: isDark ? WawatDark.scrim : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _cGrip(isDark),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              _SheetTile(
                icon: PhosphorIconsRegular.arrowBendUpLeft,
                label: _t('chat.message.reply', 'Cavabla'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _startReply(message);
                },
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showAppBottomSheet<void>(
      context: context,
      backgroundColor: _cSurface(isDark),
      barrierColor: isDark ? WawatDark.scrim : null,
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
                    color: _cGrip(isDark),
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
                            style: TextStyle(
                              color: _cText(isDark),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _t('chat.action.profile'),
                            style:
                                TextStyle(color: _cMuted(isDark), fontSize: 12),
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

  void _openProfile() {
    final user = widget.conversation.user;
    // Prefer the public id (ULID), then username — both resolve on the profile
    // endpoint; a bare numeric id is only a last resort (it can 404).
    final userId = _firstNonEmpty([
      user.publicId,
      user.username,
      user.id > 0 ? user.id.toString() : null,
    ]);
    if (userId == null) {
      _showError(_t('chat.profile.unavailable', 'Profil məlumatı tapılmadı.'));
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PublicProfileScreen(userId: userId)),
    );
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  Future<void> _openDeal(String shipmentId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => DealDetailScreen(shipmentId: shipmentId)),
    );
    if (mounted) bloc.loadMessages();
  }

  void _openSupport() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SupportScreen()),
    );
  }

  @override
  ChatConversationBloc provideBloc() => ChatConversationBloc();
}

class _ConversationHeader extends StatefulWidget {
  final Conversation conversation;
  final VoidCallback onBack;
  final VoidCallback onMenu;
  final VoidCallback onOpenProfile;

  const _ConversationHeader({
    required this.conversation,
    required this.onBack,
    required this.onMenu,
    required this.onOpenProfile,
  });

  @override
  State<_ConversationHeader> createState() => _ConversationHeaderState();
}

class _ConversationHeaderState extends State<_ConversationHeader> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Presence text is time-relative ("onlayn" → "3 dəq əvvəl"): tick so it
    // decays on its own while the screen stays open, without new data.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conversation = widget.conversation;
    final user = conversation.user;
    final lastSeen = user.getLastSeenText(context);
    return Container(
      decoration: BoxDecoration(
        color: _cSurface(isDark),
        border: Border(
          bottom: BorderSide(color: _cHeaderLine(isDark)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onBack,
            child: SizedBox(
              width: 36,
              height: 40,
              child: Icon(PhosphorIconsBold.arrowLeft,
                  color: isDark ? WawatDark.icon : _ink700, size: 22),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onOpenProfile,
              child: Row(
                children: [
                  _HeaderAvatar(user: user, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.fullname,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _cText(isDark),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
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
                        // Only render the status line when there is one — an
                        // empty line would push the name off the avatar's
                        // vertical centre. Green dot + "onlayn" when online,
                        // muted last-seen otherwise.
                        if (lastSeen.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (user.isOnline) ...[
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: _emerald,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                                Flexible(
                                  child: Text(
                                    lastSeen,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: user.isOnline
                                          ? _emerald
                                          : _cMuted(isDark),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      height: 1.05,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onMenu,
            child: SizedBox(
              width: 36,
              height: 40,
              child: Icon(PhosphorIconsBold.dotsThreeVertical,
                  color: _cText3(isDark), size: 22),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ColoredBox(
      color: _cThreadBg(isDark),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isDark
                  ? WawatDark.surfaceAlt
                  : _ink900.withValues(alpha: 0.08),
              child: Text(
                widget.user.initials,
                style: TextStyle(
                  color: isDark
                      ? WawatDark.textSecondary
                      : const Color(0xFF475569),
                  fontSize: 9,
                  height: 1,
                  fontWeight: FontWeight.w600,
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
                color: _cSurface(isDark),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(
                  color: isDark
                      ? WawatDark.border
                      : _ink900.withValues(alpha: 0.05),
                ),
                boxShadow: isDark
                    ? null
                    : [
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
                        color: isDark
                            ? WawatDark.textSecondary
                            : const Color(0xFF94A3B8),
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
  final Color color;

  const _HtmlTypingDot({required this.state, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Transform.translate(
        offset: Offset(0, state.$1),
        child: Opacity(
          opacity: state.$2,
          child: SizedBox(
            width: 6,
            height: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: isDark ? WawatDark.surfaceAlt : _brand100,
          backgroundImage: user.avatarThumbUrl.isEmpty
              ? null
              : CachedNetworkImageProvider(user.avatarThumbUrl),
          child: user.avatarThumbUrl.isEmpty
              ? Text(
                  user.initials,
                  style: TextStyle(
                    color: _brand,
                    fontSize: size * 0.31,
                    fontWeight: FontWeight.w700,
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
                border: Border.all(color: _cSurface(isDark), width: 2),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // ClipRect confines the painter to its own bounds so its background fill
    // can never bleed over the header/composer painted around it.
    return ClipRect(
      child: CustomPaint(
        painter: _DotPainter(isDark: isDark),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  final bool isDark;

  _DotPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Fill only this widget's rect — NOT canvas.drawColor(), which floods the
    // whole canvas clip and would paint over sibling widgets.
    canvas.drawRect(Offset.zero & size, Paint()..color = _cThreadBg(isDark));
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.035)
          : _ink900.withValues(alpha: 0.035);
    for (double x = 0; x < size.width; x += 22) {
      for (double y = 0; y < size.height; y += 22) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _DateSeparator extends StatelessWidget {
  final String date;

  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color:
              isDark ? WawatDark.surfaceAlt : _ink900.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          date,
          style: TextStyle(
            color: _cText3(isDark),
            fontSize: 11,
            fontWeight: FontWeight.w600,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                color: _cSurface(isDark),
                borderRadius: BorderRadius.circular(22),
                border: isDark ? Border.all(color: WawatDark.border) : null,
                boxShadow: isDark
                    ? null
                    : [
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
              style: TextStyle(
                color: _cText(isDark),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              WawatContent.text(
                content,
                'chat.thread.empty_subtitle',
              ).replaceAll('{name}', user.fullname),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _cText3(isDark),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isImage = RegExp(r'\.(png|jpg|jpeg|webp)$', caseSensitive: false)
        .hasMatch(file.path);
    return Container(
      color: _cSurface(isDark),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              color: _cBrandSoft(isDark),
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
              style: TextStyle(
                color: _cText(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: Icon(PhosphorIconsBold.x, color: _cMuted(isDark)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = danger ? const Color(0xFFEF4444) : _cText(isDark);
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: danger ? color : _cText3(isDark)),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Counter-offer compose sheet (design screen 11): weight stepper, total price,
/// optional note → returns the `POST /shipments/{id}/counter` body.
class _CounterSheet extends StatefulWidget {
  final Map<String, String> content;

  const _CounterSheet({required this.content});

  @override
  State<_CounterSheet> createState() => _CounterSheetState();
}

class _CounterSheetState extends State<_CounterSheet> {
  final TextEditingController _weight = TextEditingController(text: '1');
  final TextEditingController _price = TextEditingController();
  final TextEditingController _note = TextEditingController();

  String _t(String key, String fallback) =>
      WawatContent.text(widget.content, key, fallback);

  @override
  void dispose() {
    _weight.dispose();
    _price.dispose();
    _note.dispose();
    super.dispose();
  }

  void _bumpWeight(int delta) {
    final current = double.tryParse(_weight.text.replaceAll(',', '.')) ?? 0;
    final next = (current + delta).clamp(0, 999);
    _weight.text = next % 1 == 0 ? next.toInt().toString() : next.toString();
  }

  void _submit() {
    final body = <String, dynamic>{};
    final weight = double.tryParse(_weight.text.replaceAll(',', '.'));
    final price = double.tryParse(_price.text.replaceAll(',', '.'));
    if (weight != null) body['weight_kg'] = weight;
    if (price != null) body['price_total'] = price;
    if (_note.text.trim().isNotEmpty) body['note'] = _note.text.trim();
    Navigator.of(context).pop(body);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.zero, // keyboard inset handled by showAppBottomSheet
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: _cSurface(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _cGrip(isDark),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Center(
                child: Text(
                  _t('chat.counter.title', 'Təklifi dəyiş'),
                  style: TextStyle(
                    color: _cText(isDark),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _label(_t('chat.counter.weight', 'Çəki'), isDark),
              const SizedBox(height: 6),
              Row(
                children: [
                  _StepBtn(
                    icon: PhosphorIconsBold.minus,
                    background: isDark
                        ? WawatDark.surfaceAlt
                        : _ink900.withValues(alpha: 0.05),
                    color: isDark ? WawatDark.textSecondary : _ink700,
                    onTap: () => _bumpWeight(-1),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CounterField(
                      controller: _weight,
                      suffix: 'kq',
                      textAlign: TextAlign.center,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _StepBtn(
                    icon: PhosphorIconsBold.plus,
                    background: _cBrandSoft(isDark),
                    color: _brand,
                    onTap: () => _bumpWeight(1),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _label(_t('chat.counter.price', 'Ümumi qiymət'), isDark),
              const SizedBox(height: 6),
              _CounterField(
                controller: _price,
                suffix: '\$',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _label(_t('chat.counter.note', 'Qeyd'), isDark),
                  const SizedBox(width: 6),
                  Text(
                    '· ${_t('chat.counter.note_optional', 'istəyə bağlı')}',
                    style: TextStyle(
                      color: _cMuted(isDark),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _CounterField(
                controller: _note,
                hint: _t('chat.counter.note_hint', 'Şərti izah et...'),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(PhosphorIconsBold.paperPlaneTilt,
                      size: 17, color: Colors.white),
                  label: Text(
                    _t('chat.counter.submit', 'Yeni təklif göndər'),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, bool isDark) => Text(
        text,
        style: TextStyle(
          color: _cText2(isDark),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color color;
  final VoidCallback onTap;

  const _StepBtn({
    required this.icon,
    required this.background,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _CounterField extends StatelessWidget {
  final TextEditingController controller;
  final String? suffix;
  final String? hint;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final int? minLines;
  final int maxLines;

  const _CounterField({
    required this.controller,
    this.suffix,
    this.hint,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.minLines,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: textAlign,
      minLines: minLines,
      maxLines: maxLines,
      style: TextStyle(
        color: _cText(isDark),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: _cMuted(isDark), fontWeight: FontWeight.w500),
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: _cMuted(isDark),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor:
            isDark ? WawatDark.surfaceAlt : _ink900.withValues(alpha: 0.02),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color:
                  isDark ? WawatDark.border : _ink900.withValues(alpha: 0.07)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color:
                  isDark ? WawatDark.border : _ink900.withValues(alpha: 0.07)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _brand, width: 1.5),
        ),
      ),
    );
  }
}

class _ReviewResult {
  final int rating;
  final String comment;

  const _ReviewResult(this.rating, this.comment);
}

class _ReviewSheet extends StatefulWidget {
  final Map<String, String> content;

  const _ReviewSheet({required this.content});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  final TextEditingController _comment = TextEditingController();
  int _rating = 5;

  String _t(String key, String fallback) =>
      WawatContent.text(widget.content, key, fallback);

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return _t('chat.review.r1', 'Çox pis');
      case 2:
        return _t('chat.review.r2', 'Pis');
      case 3:
        return _t('chat.review.r3', 'Normal');
      case 4:
        return _t('chat.review.r4', 'Yaxşı');
      default:
        return _t('chat.review.r5', 'Əla');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const amber = Color(0xFFF59E0B);
    return Padding(
      padding: EdgeInsets.zero, // keyboard inset handled by showAppBottomSheet
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: BoxDecoration(
            color: _cSurface(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: _cGrip(isDark),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Center(
                child: Text(
                  _t('chat.review.title', 'Rəy yaz'),
                  style: TextStyle(
                    color: _cText(isDark),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Center(
                child: Text(
                  _t('chat.review.subtitle', 'Təcrübəni qiymətləndir'),
                  style: TextStyle(
                    color: _cMuted(isDark),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final value = index + 1;
                    final active = value <= _rating;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _rating = value),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: Icon(
                          active
                              ? PhosphorIconsFill.star
                              : PhosphorIconsRegular.star,
                          color: active
                              ? amber
                              : (isDark ? WawatDark.iconMuted : _ink400),
                          size: 36,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _ratingLabel(_rating),
                  style: const TextStyle(
                    color: amber,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _t('chat.review.comment_label', 'Şərhiniz'),
                style: TextStyle(
                  color: _cText2(isDark),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              _CounterField(
                controller: _comment,
                hint: _t('chat.review.comment', 'Şərhinizi yazın'),
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        _t('common.cancel', 'İmtina et'),
                        style: TextStyle(
                          color: _cMuted(isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(
                        _ReviewResult(_rating, _comment.text.trim()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brand,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(PhosphorIconsBold.check,
                          size: 17, color: Colors.white),
                      label: Text(
                        _t('common.confirm', 'Təsdiq et'),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
