import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/network/response/chat_response.dart';
import '../../../presentation/resourses/wawat_colors.dart';
import '../../../presentation/resourses/wawat_dimensions.dart';
import '../../../presentation/resourses/wawat_text_styles.dart';
import '../../../services/theme_manager.dart';
import '../../home/tabs/home_tab/courier_screen/courier_screen.dart';

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
      builder: (context, themeManager, _) {
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
                _buildAvatar(context, isDark),
                SizedBox(width: WawatDimensions.spacingSm),
              ],
              Flexible(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: _bubbleDecoration(isDark),
                  padding: EdgeInsets.all(WawatDimensions.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildContent(context, isDark),
                      const SizedBox(height: 4),
                      _buildTime(context, isDark),
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

  // ================= CONTENT =================

  Widget _buildContent(BuildContext context, bool isDark) {
    final file = message.file;

    if (file != null && file.url.isNotEmpty) {
      final isPdf = _isPdf(file.url);

      if (isPdf) {
        return _buildPdfContent(context, isDark);
      } else {
        return _buildImageContent(context, isDark);
      }
    }

    if (message.body != null) {
      return Text(
        message.body!,
        style: WawatTextStyles.body.copyWith(
          color: isMyMessage
              ? Colors.white
              : (isDark ? Colors.white : WawatColors.textPrimary),
        ),
      );
    }

    return const SizedBox();
  }

  // ================= IMAGE =================

  Widget _buildImageContent(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _showImageFullScreen(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(WawatDimensions.radiusSmall),
        child: CachedNetworkImage(
          imageUrl: message.file!.url,
          width: 200,
          fit: BoxFit.cover,
          placeholder: (_, __) => _imagePlaceholder(isDark),
          errorWidget: (_, __, ___) => _imageError(isDark),
        ),
      ),
    );
  }

  void _showImageFullScreen(BuildContext context) {
    final isDark = context.read<ThemeManager>().isDarkMode;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
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

  // ================= PDF =================

  Widget _buildPdfContent(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor =
    isDark ? Colors.white.withOpacity(0.7) : Colors.black54;
    final iconColor = textColor;

    return GestureDetector(
      onTap: _openFile,
      child: Container(
        padding: EdgeInsets.all(WawatDimensions.spacingMd),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
              const Color(0xFF1E1E1E),
              const Color(0xFF2A2A2A),
            ]
                : [
              const Color(0xFFFFFFFF),
              const Color(0xFFF4F4F4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(WawatDimensions.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            // PDF ICON
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                color: Colors.redAccent,
                size: 30,
              ),
            ),
            SizedBox(width: WawatDimensions.spacingMd),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.file!.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: WawatTextStyles.bodyBold.copyWith(
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PDF document',
                    style: WawatTextStyles.caption.copyWith(
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),

            // NAVIGATION ICON
            Icon(
              Icons.open_in_new,
              size: 20,
              color: iconColor,
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  bool _isPdf(String url) {
    return url.toLowerCase().trim().endsWith('.pdf');
  }

  void _openFile() async {
    final uri = Uri.parse(message.file!.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildAvatar(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) =>
                CourierDetailsScreen(courierId: message.user!.id),
          ),
        );
      },
      child: CircleAvatar(
        radius: 16,
        backgroundImage: message.user!.avatarUrl.isNotEmpty
            ? CachedNetworkImageProvider(message.user!.avatarUrl)
            : null,
        child: message.user!.avatarUrl.isEmpty
            ? Text(message.user!.fullname[0].toUpperCase())
            : null,
      ),
    );
  }

  Widget _buildTime(BuildContext context, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.timeString(context),
          style: WawatTextStyles.caption.copyWith(
            fontSize: 10,
            color: isDark
                ? const Color(0xFF9CA3AF)
                : WawatColors.textSecondary,
          ),
        ),
        if (isMyMessage) ...[
          const SizedBox(width: 4),
          _buildReadStatus(isDark),
        ],
      ],
    );
  }

  Widget _buildReadStatus(bool isDark) {
    final color = isMyMessage
        ? Colors.white.withOpacity(0.9)
        : (isDark ? const Color(0xFF9CA3AF) : WawatColors.textSecondary);

    return Icon(
      message.isRead ? Icons.done_all : Icons.done,
      size: 14,
      color: color,
    );
  }

  BoxDecoration _bubbleDecoration(bool isDark) {
    return BoxDecoration(
      gradient: isMyMessage ? WawatColors.primaryGradient : null,
      color: isMyMessage
          ? null
          : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
      borderRadius: BorderRadius.circular(WawatDimensions.radiusMedium),
      boxShadow: [
        BoxShadow(
          color:
          isDark ? Colors.black.withOpacity(0.3) : WawatColors.shadowLight,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _imagePlaceholder(bool isDark) => Container(
    width: 200,
    height: 200,
    color: isDark ? const Color(0xFF1E1E1E) : WawatColors.inputBackground,
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _imageError(bool isDark) => Container(
    width: 200,
    height: 200,
    color: isDark ? const Color(0xFF1E1E1E) : WawatColors.inputBackground,
    child: const Icon(Icons.error, color: WawatColors.error),
  );
}
