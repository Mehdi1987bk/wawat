import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buking/presentation/resourses/wawat_colors.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../services/theme_manager.dart';
import '../../profile_tab/settings/experience_tab/experience_tab_screen.dart';

class StartChatModal {
  static void show(
      BuildContext context, {
        required int userId,
        required String userName,
        Function(String message)? onSuccess,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: _StartChatContent(
            userId: userId,
            userName: userName,
            onSuccess: onSuccess,
          ),
        );
      },
    );
  }
}


class _StartChatContent extends StatefulWidget {
  final int userId;
  final String userName;
  final Function(String message)? onSuccess; // ← Изменено

  const _StartChatContent({
    Key? key,
    required this.userId,
    required this.userName,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<_StartChatContent> createState() => _StartChatContentState();
}

class _StartChatContentState extends State<_StartChatContent> {
  final TextEditingController _messageController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      setState(() {
        _errorMessage = S.of(context).by5htg4refg4tr3few;
      });
      return;
    }

     Navigator.pop(context);

     widget.onSuccess?.call(message);

     showIOSStyleMessage(context, S.of(context).ybrfsg4t34gtgrvfedvfd);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return GestureDetector(
          onTap: () {
            // Скрыть клавиатуру при тапе вне текстового поля
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle bar
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF4A4A4A) : const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Warning section
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFFFF9800) : const Color(0xFFFFB74D),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFFF9800),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
                                  fontWeight: FontWeight.w500,
                                ),
                                child: Text(
                                S.of(context).rth435gtre+  ' ${widget.userName} ' + S.of(context).brtevrfg45rfs,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Title
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                        child:   Text(S.of(context).hrt4h5hte43h454),
                      ),

                      const SizedBox(height: 16),

                      // Message input
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _errorMessage != null
                                ? Colors.red
                                : (isDark ? const Color(0xFF4A4A4A) : const Color(0xFFE0E0E0)),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _messageController,
                          maxLines: 5,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText: S.of(context).rthh4ger34f34,
                            hintStyle: TextStyle(
                              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9E9E9E),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            counterStyle: TextStyle(
                              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9E9E9E),
                              fontSize: 12,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                          onChanged: (value) {
                            if (_errorMessage != null) {
                              setState(() {
                                _errorMessage = null;
                              });
                            }
                          },
                        ),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Send button
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5B5FFF), Color(0xFFB74CFF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x335B5FFF),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _sendMessage,
                            borderRadius: BorderRadius.circular(16),
                            child:   Center(
                              child: Text(
                                S.of(context).brg353gffvw34fr3,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}