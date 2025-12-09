import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';
import '../../../services/theme_manager.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttachImage;
  final VoidCallback onAttachFile;

  const ChatInput({
    Key? key,
    required this.controller,
    required this.onSend,
    required this.onAttachImage,
    required this.onAttachFile,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _showAttachMenu = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : WawatColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: EdgeInsets.all(WawatDimensions.spacingSm),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _showAttachMenu ? Icons.close : Icons.attach_file,
                  color: WawatColors.primary,
                ),
                onPressed: () {
                  setState(() {
                    _showAttachMenu = !_showAttachMenu;
                  });
                  if (_showAttachMenu) {
                    _showAttachOptions(isDark);
                  }
                },
              ),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : WawatColors.inputBackground,
                    borderRadius: BorderRadius.circular(WawatDimensions.radiusLarge),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    style: WawatTextStyles.body.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Сообщение...',
                      hintStyle: WawatTextStyles.placeholder.copyWith(
                        color: isDark
                            ? const Color(0xFF6B7280)
                            : WawatTextStyles.placeholder.color,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: WawatDimensions.spacingMd,
                        vertical: WawatDimensions.spacingSm,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: WawatDimensions.spacingSm),
              Container(
                decoration: const BoxDecoration(
                  gradient: WawatColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: widget.onSend,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAttachOptions(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(WawatDimensions.radiusLarge),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(top: WawatDimensions.spacingSm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF4A4A4A) : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: WawatDimensions.spacingMd),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(WawatDimensions.spacingSm),
                decoration: const BoxDecoration(
                  gradient: WawatColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.image, color: Colors.white),
              ),
              title: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: WawatTextStyles.bodyBold.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
                child: const Text('Фото'),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onAttachImage();
                setState(() {
                  _showAttachMenu = false;
                });
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(WawatDimensions.spacingSm),
                decoration: const BoxDecoration(
                  gradient: WawatColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.insert_drive_file, color: Colors.white),
              ),
              title: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: WawatTextStyles.bodyBold.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
                child: const Text('Файл'),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onAttachFile();
                setState(() {
                  _showAttachMenu = false;
                });
              },
            ),
            SizedBox(height: WawatDimensions.spacingMd),
          ],
        ),
      ),
    ).then((_) {
      setState(() {
        _showAttachMenu = false;
      });
    });
  }
}
