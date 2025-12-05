import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/network/response/chat_response.dart';
import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMyMessage;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMyMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: WawatDimensions.spacingSm,
        left: isMyMessage ? 60 : 0,
        right: isMyMessage ? 0 : 60,
      ),
      child: Row(
        mainAxisAlignment:
            isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage && message.user != null) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: WawatColors.primary.withOpacity(0.1),
              backgroundImage: message.user!.avatarUrl.isNotEmpty
                  ? CachedNetworkImageProvider(message.user!.avatarUrl)
                  : null,
              child: message.user!.avatarUrl.isEmpty
                  ? Text(
                      message.user!.fullname[0].toUpperCase(),
                      style: WawatTextStyles.caption.copyWith(
                        color: WawatColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: WawatDimensions.spacingSm),
          ],
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                gradient: isMyMessage ? WawatColors.primaryGradient : null,
                color: isMyMessage ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(WawatDimensions.radiusMedium),
                  topRight: Radius.circular(WawatDimensions.radiusMedium),
                  bottomLeft: Radius.circular(
                    isMyMessage ? WawatDimensions.radiusMedium : 4,
                  ),
                  bottomRight: Radius.circular(
                    isMyMessage ? 4 : WawatDimensions.radiusMedium,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: WawatColors.shadowLight,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(WawatDimensions.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == 'image' && message.file != null)
                    _buildImageContent(context)
                  else if (message.type == 'file' && message.file != null)
                    _buildImageContent(context)
                  else if (message.body != null)
                    Text(
                      message.body!,
                      style: WawatTextStyles.body.copyWith(
                        color: isMyMessage
                            ? Colors.white
                            : WawatColors.textPrimary,
                      ),
                    ),
                  SizedBox(height: 4),
                  Text(
                    message.timeString,
                    style: WawatTextStyles.caption.copyWith(
                      color: isMyMessage
                          ? Colors.white.withOpacity(0.8)
                          : WawatColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showImageFullScreen(context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(WawatDimensions.radiusSmall),
        child: CachedNetworkImage(
          imageUrl: message.file!.url,
          width: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 200,
            height: 200,
            color: WawatColors.inputBackground,
            child: Center(
              child: CircularProgressIndicator(
                color: WawatColors.primary,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 200,
            height: 200,
            color: WawatColors.inputBackground,
            child: Icon(Icons.error, color: WawatColors.error),
          ),
        ),
      ),
    );
  }

  void _showImageFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: message.file!.url,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openFile() async {
    final uri = Uri.parse(message.file!.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
