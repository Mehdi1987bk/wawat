import 'package:flutter/material.dart';
import 'package:buking/presentation/resourses/wawat_colors.dart';
import '../../../../../data/network/api/auth_api.dart';
import '../../../../../data/network/response/conversation_response.dart';
import '../../../../../main.dart';

class StartChatModal {
  static void show(
    BuildContext context, {
    required int userId,
    required String userName,
    VoidCallback? onSuccess,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _StartChatContent(
          userId: userId,
          userName: userName,
          onSuccess: onSuccess,
        );
      },
    );
  }
}

class _StartChatContent extends StatefulWidget {
  final int userId;
  final String userName;
  final VoidCallback? onSuccess;

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
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Пожалуйста, введите сообщение';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authApi = sl.get<AuthApi>();
      final response = await authApi.startChat({
        'user_id': widget.userId,
        'body': _messageController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Сообщение отправлено!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Ошибка при отправке сообщения. Попробуйте снова.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Warning section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(0xFFFFB74D),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFFF9800),
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Вы собираетесь написать пользователю ${widget.userName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFE65100),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Title
                Text(
                  'Напишите сообщение',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                SizedBox(height: 16),

                // Message input
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _errorMessage != null
                          ? Colors.red
                          : Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Введите ваше сообщение...',
                      hintStyle: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      counterStyle: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 12,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
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
                  SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],

                SizedBox(height: 24),

                // Send button
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5B5FFF), Color(0xFFB74CFF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
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
                      onTap: _isLoading ? null : _sendMessage,
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Отправить',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Cancel button
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: Text(
                    'Отмена',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5B5FFF),
                    ),
                  ),
                ),

                SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
