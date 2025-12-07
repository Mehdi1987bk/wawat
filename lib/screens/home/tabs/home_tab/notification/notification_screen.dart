import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../data/network/response/notification_response.dart';
import '../../../../../presentation/resourses/wawat_colors.dart';
import '../../../../../presentation/resourses/wawat_text_styles.dart';
import 'notification_bloc.dart';

class NotificationScreen extends BaseScreen {
  NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState
    extends BaseState<NotificationScreen, NotificationBloc> {
  @override
  void initState() {
    super.initState();
    bloc.loadNotifications();
  }

  @override
  Widget body() {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<NotificationResponse?>(
                stream: bloc.notificationsStream,
                builder: (context, snapshot) {
                  return StreamBuilder<bool>(
                    stream: bloc.loadingStream,
                    builder: (context, loadingSnapshot) {
                      if (loadingSnapshot.data == true) {
                        return Center(
                          child: SizedBox(),
                        );
                      }

                      return StreamBuilder<String?>(
                        stream: bloc.errorStream,
                        builder: (context, errorSnapshot) {
                          if (errorSnapshot.hasData &&
                              errorSnapshot.data != null) {
                            return _buildErrorState(errorSnapshot.data!);
                          }

                          if (!snapshot.hasData ||
                              snapshot.data?.data.isEmpty == true) {
                            return _buildEmptyState();
                          }

                          return _buildNotificationsList(snapshot.data!);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: WawatColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: WawatColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Уведомления',
              style: WawatTextStyles.h2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(NotificationResponse response) {
    return RefreshIndicator(
      onRefresh: () async {
        await bloc.loadNotifications();
      },
      color: WawatColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: response.data.length,
        itemBuilder: (context, index) {
          final notification = response.data[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : WawatColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? Colors.transparent
                : WawatColors.primary.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(notification),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title ?? "",
                            style: WawatTextStyles.bodyBold.copyWith(
                              color: WawatColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: WawatColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.body ?? "",
                      style: WawatTextStyles.body.copyWith(
                        color: WawatColors.textSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: WawatColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(notification.createdAt),
                          style: WawatTextStyles.caption,
                        ),
                        const Spacer(),
                        if (notification.type == "ReviewRequest")
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: WawatColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Требует действия',
                              style: WawatTextStyles.caption.copyWith(
                                color: WawatColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationItem notification) {
    Color bgColor;
    Color iconColor;
    IconData iconData;

    switch (notification.type) {
      case "ReviewRequest":
        bgColor = WawatColors.warning.withOpacity(0.1);
        iconColor = WawatColors.warning;
        iconData = Icons.star_outline;
        break;
      case "message":
        bgColor = WawatColors.info.withOpacity(0.1);
        iconColor = WawatColors.info;
        iconData = Icons.message_outlined;
        break;
      default:
        bgColor = WawatColors.primary.withOpacity(0.1);
        iconColor = WawatColors.primary;
        iconData = Icons.star;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: notification.icon != null && notification.icon!.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          notification.icon!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(iconData, color: iconColor, size: 24);
          },
        ),
      )
          : Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: WawatColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 60,
              color: WawatColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Нет уведомлений',
            style: WawatTextStyles.h2,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'У вас пока нет новых уведомлений',
              style: WawatTextStyles.body.copyWith(
                color: WawatColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: WawatColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки',
            style: WawatTextStyles.h2,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error,
              style: WawatTextStyles.body.copyWith(
                color: WawatColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => bloc.loadNotifications(),
            style: ElevatedButton.styleFrom(
              backgroundColor: WawatColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
            child: Text(
              'Попробовать снова',
              style: WawatTextStyles.button,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    if (notification.type != "ReviewRequest" && notification.type != "message") {
      _showReviewBottomSheet(notification);
    }
  }

  void _showReviewBottomSheet(NotificationItem notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReviewBottomSheet(notification: notification),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Только что';
          }
          return '${difference.inMinutes} мин назад';
        }
        return '${difference.inHours} ч назад';
      } else if (difference.inDays == 1) {
        return 'Вчера';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} дн назад';
      } else {
        return DateFormat('dd.MM.yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  NotificationBloc provideBloc() {
    return NotificationBloc();
  }
}

class _ReviewBottomSheet extends StatefulWidget {
  final NotificationItem notification;

  const _ReviewBottomSheet({required this.notification});

  @override
  State<_ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<_ReviewBottomSheet> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: WawatColors.backgroundLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: WawatColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    size: 40,
                    color: WawatColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Оставьте отзыв',
                  style: WawatTextStyles.h2.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ваше мнение очень важно для нас',
                  style: WawatTextStyles.body.copyWith(
                    color: WawatColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starNumber = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = starNumber;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          _rating >= starNumber
                              ? Icons.star
                              : Icons.star_outline,
                          size: 40,
                          color: _rating >= starNumber
                              ? WawatColors.warning
                              : WawatColors.textSecondary.withOpacity(0.3),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: WawatColors.backgroundLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _commentController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Напишите ваш комментарий...',
                      hintStyle: WawatTextStyles.body.copyWith(
                        color: WawatColors.textSecondary.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      counterStyle: WawatTextStyles.caption.copyWith(
                        color: WawatColors.textSecondary,
                      ),
                    ),
                    style: WawatTextStyles.body,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting || _rating == 0
                        ? null
                        : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WawatColors.primary,
                      disabledBackgroundColor:
                      WawatColors.primary.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      'Отправить',
                      style: WawatTextStyles.button.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Пожалуйста, выберите оценку'),
          backgroundColor: WawatColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Здесь добавь свой API запрос
    // await bloc.submitReview(
    //   rating: _rating,
    //   comment: _commentController.text,
    //   notificationId: widget.notification.id,
    // );

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Спасибо за ваш отзыв!'),
          backgroundColor: WawatColors.success,
        ),
      );
    }
  }
}