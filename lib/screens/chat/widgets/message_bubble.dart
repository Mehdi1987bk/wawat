import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/network/response/chat_response.dart';
import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';
import '../../../services/theme_manager.dart';
import '../../home/tabs/home_tab/courier_screen/courier_screen.dart'; // Добавьте этот импорт

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
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (BuildContext context) {
                          return CourierDetailsScreen(
                            courierId: message.user!.id,
                          );
                        },
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: isDark
                        ? WawatColors.primary.withOpacity(0.2)
                        : WawatColors.primary.withOpacity(0.1),
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
                ),
                SizedBox(width: WawatDimensions.spacingSm),
              ],
              Flexible(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: isMyMessage ? WawatColors.primaryGradient : null,
                    color: isMyMessage
                        ? null
                        : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
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
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : WawatColors.shadowLight,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(WawatDimensions.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.type == 'image' && message.file != null)
                        _buildImageContent(context, isDark)
                      else if (message.type == 'file' && message.file != null)
                        _buildImageContent(context, isDark)
                      else if (message.body != null)
                          Text(
                            message.body!,
                            style: WawatTextStyles.body.copyWith(
                              color: isMyMessage
                                  ? Colors.white
                                  : (isDark ? Colors.white : WawatColors.textPrimary),
                            ),
                          ),
                      const SizedBox(height: 4),
                      Text(
                        message.timeString(context),
                        style: WawatTextStyles.caption.copyWith(
                          color: isMyMessage
                              ? Colors.white.withOpacity(0.8)
                              : (isDark
                              ? const Color(0xFF9CA3AF)
                              : WawatColors.textSecondary),
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
      },
    );
  }

  Widget _buildImageContent(BuildContext context, bool isDark) {
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
            color: isDark ? const Color(0xFF1E1E1E) : WawatColors.inputBackground,
            child: const Center(
              child: CircularProgressIndicator(
                color: WawatColors.primary,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 200,
            height: 200,
            color: isDark ? const Color(0xFF1E1E1E) : WawatColors.inputBackground,
            child: const Icon(Icons.error, color: WawatColors.error),
          ),
        ),
      ),
    );
  }

  void _showImageFullScreen(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final isDark = themeManager.isDarkMode;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.black,
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
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
}