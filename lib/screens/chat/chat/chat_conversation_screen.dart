import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../data/network/response/chat_response.dart';
import '../../../presentation/bloc/base_screen.dart';
import '../../../presentation/bloc/error_dispatcher.dart';
import '../../../services/wawat_content.dart';
import '../bloc/chat_conversation_bloc.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

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

  bool get _isBlocked =>
      widget.conversation.isBlocked || widget.conversation.isBlockedByOther;

  @override
  bool get useSystemOverlay => false;

  @override
  void initState() {
    super.initState();
    bloc.initChat(widget.conversation.id);
    bloc.loadMessages();
    WawatContent.load().then((content) {
      if (mounted) setState(() => _content = content);
    });
    _scrollController.addListener(_onScroll);
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
    _messageController.dispose();
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
                                        onShipmentAction: _handleShipmentAction,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
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
                disabledText: widget.conversation.isBlocked
                    ? _t(
                        'chat.input.blocked_by_me',
                      )
                    : _t(
                        'chat.input.blocked',
                      ),
                onSend: _send,
                onAttachImage: _pickImage,
                onAttachFile: _pickFile,
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
    await bloc.sendMessage(text, _selectedFile);
    _messageController.clear();
    if (mounted) setState(() => _selectedFile = null);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() => _selectedFile = File(pickedFile.path));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    final path = result?.files.single.path;
    if (path != null && mounted) {
      setState(() => _selectedFile = File(path));
    }
  }

  Future<void> _handleShipmentAction(String shipmentId, String action) async {
    try {
      await bloc.runShipmentAction(shipmentId, action);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('common.operation_completed')),
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

  String _extractError(Object error) {
    final text = error.toString();
    final messageMatch = RegExp(r'"message":"([^"]+)"').firstMatch(text);
    return messageMatch?.group(1) ?? _t('common.error');
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
                  label: _t('chat.action.pin'),
                  onTap: () => Navigator.pop(context),
                ),
                _SheetTile(
                  icon: PhosphorIconsRegular.archive,
                  label: _t('chat.action.archive'),
                  onTap: () => Navigator.pop(context),
                ),
                _SheetTile(
                  icon: PhosphorIconsRegular.bellSlash,
                  label: _t('chat.action.mute'),
                  onTap: () => Navigator.pop(context),
                ),
                _SheetTile(
                  icon: PhosphorIconsRegular.prohibit,
                  label: widget.conversation.isBlocked
                      ? _t('chat.action.unblock')
                      : _t('chat.action.block'),
                  danger: true,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        border: Border(bottom: BorderSide(color: _ink900.withOpacity(0.06))),
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
    final paint = Paint()..color = _ink900.withOpacity(0.035);
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
          color: _ink900.withOpacity(0.06),
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
                    color: _ink900.withOpacity(0.08),
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
