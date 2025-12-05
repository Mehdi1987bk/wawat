import 'package:flutter/material.dart';
import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: WawatColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, -2),
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
                _showAttachOptions();
              }
            },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: WawatColors.inputBackground,
                borderRadius:
                BorderRadius.circular(WawatDimensions.radiusLarge),
              ),
              child: TextField(
                controller: widget.controller,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                style: WawatTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Сообщение...',
                  hintStyle: WawatTextStyles.placeholder,
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
            decoration: BoxDecoration(
              gradient: WawatColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: widget.onSend,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(WawatDimensions.radiusLarge),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: WawatDimensions.spacingSm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: WawatDimensions.spacingMd),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(WawatDimensions.spacingSm),
                decoration: BoxDecoration(
                  gradient: WawatColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.image, color: Colors.white),
              ),
              title: Text('Фото', style: WawatTextStyles.bodyBold),
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
                decoration: BoxDecoration(
                  gradient: WawatColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.insert_drive_file, color: Colors.white),
              ),
              title: Text('Файл', style: WawatTextStyles.bodyBold),
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
