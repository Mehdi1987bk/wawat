import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../data/network/request/create_review_request.dart';
import '../../../../../data/network/response/notification_response.dart';
import '../../../../../presentation/resourses/wawat_colors.dart';
import '../../../../../presentation/resourses/wawat_text_styles.dart';
import '../../../../../services/theme_manager.dart';
import '../../profile_tab/settings/experience_tab/experience_tab_screen.dart';
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
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          ),
          child: Scaffold(
            backgroundColor:
                isDark ? const Color(0xFF121212) : AppColors.bgColor,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(isDark),
                  Expanded(
                    child: StreamBuilder<NotificationResponse?>(
                      stream: bloc.notificationsStream,
                      builder: (context, snapshot) {
                        return StreamBuilder<bool>(
                          stream: bloc.loadingStream,
                          builder: (context, loadingSnapshot) {
                            if (loadingSnapshot.data == true) {
                              return const Center(
                                child: SizedBox(),
                              );
                            }

                            return StreamBuilder<String?>(
                              stream: bloc.errorStream,
                              builder: (context, errorSnapshot) {
                                if (errorSnapshot.hasData &&
                                    errorSnapshot.data != null) {
                                  return _buildErrorState(
                                      errorSnapshot.data!, isDark);
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data?.data.isEmpty == true) {
                                  return _buildEmptyState(isDark);
                                }

                                return _buildNotificationsList(
                                    snapshot.data!, isDark);
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
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : WawatColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: isDark ? Colors.white : WawatColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: WawatTextStyles.h2.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
              child: const Text('Уведомления'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(NotificationResponse response, bool isDark) {
    return RefreshIndicator(
      onRefresh: () async {
        await bloc.loadNotifications();
      },
      color: WawatColors.primary,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: isDark ? const Color(0xFF121212) : AppColors.bgColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: response.data.length,
          itemBuilder: (context, index) {
            final notification = response.data[index];
            return _buildNotificationItem(notification, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification, bool isDark) {
    return GestureDetector(
      onTap: () => _handleNotificationTap(notification, isDark),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: notification.isRead
              ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
              : (isDark
                  ? WawatColors.primary.withOpacity(0.15)
                  : WawatColors.primary.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? (isDark ? const Color(0xFF2A2A2A) : Colors.transparent)
                : WawatColors.primary.withOpacity(isDark ? 0.2 : 0.1),
            width: 1,
          ),
          boxShadow: isDark
              ? []
              : [
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
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: WawatTextStyles.bodyBold.copyWith(
                              color: isDark
                                  ? Colors.white
                                  : WawatColors.textPrimary,
                            ),
                            child: Text(notification.title ?? ""),
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
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: WawatTextStyles.body.copyWith(
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : WawatColors.textSecondary,
                      ),
                      child: Text(
                        notification.body ?? "",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isDark
                              ? const Color(0xFF6B7280)
                              : WawatColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: WawatTextStyles.caption.copyWith(
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : WawatColors.textSecondary,
                          ),
                          child: Text(_formatDate(notification.createdAt)),
                        ),
                        const Spacer(),
                        if (notification.type == "review_request")
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
      case "review_request":
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
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.network(
                  notification.icon!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(iconData, color: iconColor, size: 24);
                  },
                ),
              ),
            )
          : Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildEmptyState(bool isDark) {
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
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: WawatTextStyles.h2.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
            child: const Text('Нет уведомлений'),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: WawatTextStyles.body.copyWith(
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : WawatColors.textSecondary,
              ),
              child: const Text(
                'У вас пока нет новых уведомлений',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
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
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: WawatTextStyles.h2.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
            child: const Text('Ошибка загрузки'),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: WawatTextStyles.body.copyWith(
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : WawatColors.textSecondary,
              ),
              child: Text(
                error,
                textAlign: TextAlign.center,
              ),
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

  void _handleNotificationTap(NotificationItem notification, bool isDark) {
    // Показываем bottom sheet только для review_request
    if (notification.type == "review_request") {
      _showReviewBottomSheet(notification, isDark);
    }
  }

  void _showReviewBottomSheet(NotificationItem notification, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReviewBottomSheet(
        notification: notification,
        isDark: isDark,
        bloc: bloc,
        onReviewSubmitted: () {
          // Перезагружаем уведомления после отправки отзыва
          bloc.loadNotifications();
        },
      ),
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
  final bool isDark;
  final NotificationBloc bloc;
  final VoidCallback onReviewSubmitted;

  const _ReviewBottomSheet({
    required this.notification,
    required this.isDark,
    required this.bloc,
    required this.onReviewSubmitted,
  });

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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Закрываем клавиатуру при нажатии вне TextField
          FocusScope.of(context).unfocus();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? const Color(0xFF4A4A4A)
                          : WawatColors.backgroundLight,
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
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: WawatTextStyles.h2.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                    child: const Text(
                      'Оставьте отзыв',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: WawatTextStyles.body.copyWith(
                      color: widget.isDark
                          ? const Color(0xFF9CA3AF)
                          : WawatColors.textSecondary,
                    ),
                    child: const Text(
                      'Ваше мнение очень важно для нас',
                      textAlign: TextAlign.center,
                    ),
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
                                : (widget.isDark
                                        ? const Color(0xFF4A4A4A)
                                        : WawatColors.textSecondary)
                                    .withOpacity(0.3),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? const Color(0xFF2A2A2A)
                          : WawatColors.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _commentController,
                      maxLines: 4,
                      maxLength: 500,
                      style: WawatTextStyles.body.copyWith(
                        color: widget.isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Напишите ваш комментарий...',
                        hintStyle: WawatTextStyles.body.copyWith(
                          color: (widget.isDark
                                  ? const Color(0xFF6B7280)
                                  : WawatColors.textSecondary)
                              .withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        counterStyle: WawatTextStyles.caption.copyWith(
                          color: widget.isDark
                              ? const Color(0xFF9CA3AF)
                              : WawatColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isSubmitting || _rating == 0 ? null : _submitReview,
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
                          ? const SizedBox(
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Пожалуйста, выберите оценку'),
            backgroundColor: WawatColors.error,
          ),
        );
      }
      return;
    }

    // Проверяем наличие необходимых данных
    final requesterId = widget.notification.data?.requesterId;
    if (requesterId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Ошибка: отсутствуют данные для отправки отзыва'),
            backgroundColor: WawatColors.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Создаем запрос с правильными параметрами
      final request = CreateReviewRequest(
        reviewRequestId: widget.notification.id, // id уведомления
        targetId: requesterId, // requester_id из data
        rating: _rating, // оценка от 1 до 5
        comment: _commentController.text.trim(), // комментарий
      );

      // Отправляем отзыв
      await widget.bloc.sendReviews(request);

      if (mounted) {
        // Закрываем bottom sheet
        Navigator.of(context).pop();

        showIOSStyleMessage(context, 'Спасибо за ваш отзыв!');

        // Вызываем callback для обновления списка уведомлений
        widget.onReviewSubmitted();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка отправки отзыва: ${e.toString()}'),
            backgroundColor: WawatColors.error,
          ),
        );
      }
    }
  }
}
