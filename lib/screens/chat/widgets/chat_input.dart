import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../services/wawat_content.dart';

const _brand = Color(0xFF0271EB);
const _ink900 = Color(0xFF0F172A);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttachImage;
  final VoidCallback onAttachFile;
  final bool enabled;
  final String? disabledText;
  final Map<String, String> content;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttachImage,
    required this.onAttachFile,
    this.enabled = true,
    this.disabledText,
    this.content = const {},
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncText);
    super.dispose();
  }

  void _syncText() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  String _t(String key, [String? fallback]) {
    return WawatContent.text(widget.content, key, fallback);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return ColoredBox(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _ink900.withOpacity(0.06))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(PhosphorIconsFill.prohibitInset,
                    color: _ink400, size: 18),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    widget.disabledText ?? _t('chat.input.blocked'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _ink500,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _ink900.withOpacity(0.06))),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _showAttachOptions,
                icon: const Icon(PhosphorIconsRegular.plusCircle,
                    color: _ink500, size: 28),
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  decoration: BoxDecoration(
                    color: _ink900.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.only(left: 15, right: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                          style: const TextStyle(
                            color: _ink900,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: _t('chat.input.placeholder'),
                            hintStyle: const TextStyle(
                              color: _ink400,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const Icon(PhosphorIconsRegular.smiley,
                          color: _ink400, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _hasText ? widget.onSend : widget.onAttachImage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _hasText ? _brand : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: _hasText
                        ? [
                            BoxShadow(
                              color: _brand.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _hasText
                        ? PhosphorIconsFill.paperPlaneTilt
                        : PhosphorIconsRegular.camera,
                    color: _hasText ? Colors.white : _ink500,
                    size: _hasText ? 19 : 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttachOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                _AttachTile(
                  icon: PhosphorIconsRegular.image,
                  label: _t('chat.attach.image'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onAttachImage();
                  },
                ),
                _AttachTile(
                  icon: PhosphorIconsRegular.file,
                  label: _t('chat.attach.file'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onAttachFile();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AttachTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AttachTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFFEAF3FE),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _brand),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: _ink900,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
