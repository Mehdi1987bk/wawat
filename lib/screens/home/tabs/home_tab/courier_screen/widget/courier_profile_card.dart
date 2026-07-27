import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:buking/presentation/common/app_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/network/api/chat_api.dart';
import '../../../../../../data/network/request/create_review_request.dart';
import '../../../../../../data/network/response/partner_user_response.dart';
import '../../../../../../domain/repositories/auth_repository.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../../main.dart';
import '../../../../../../presentation/bloc/error_dispatcher.dart';
import '../../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../../presentation/resourses/wawat_colors.dart';
import '../../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../../presentation/resourses/wawat_text_styles.dart';
import '../../../../../../services/theme_manager.dart';
import '../../../profile_tab/settings/experience_tab/experience_tab_screen.dart';
import '../../widget/auth_modal_utils.dart';
import '../../widget/start_chat_modal.dart';
import 'error_parser.dart';

class CourierProfileCard extends StatelessWidget {
  final Data data;
  final Function(CreateReviewRequest)? onReviewSubmitted;

  const CourierProfileCard({
    Key? key,
    required this.data,
    this.onReviewSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = data.user;
    final stats = data.stats;
    final professional = data.professional;

    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              decoration: BoxDecoration(
                color: isDark ? cCard(true) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: cCardBorder(isDark),
                boxShadow: isDark
                    ? WawatDark.cardShadow
                    : [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (user.avatar != null && user.avatar!.isNotEmpty) {
                            _openFullScreenImage(context, user.avatar!);
                          }
                        },
                        child: Hero(
                          tag: 'courier_avatar_${user.id}',
                          child: user.avatar != null && user.avatar!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    user.avatar!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5B5BFF),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.yellow[600],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  if (user.isVerified == true)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "asset/prof_3.png",
                            width: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            S.of(context).hgterfvb4btgv,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? WawatDark.success
                                  : const Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? cText(true) : Colors.black,
                    ),
                    child: Text(user.fullname),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: List.generate(
                          stats.ratingAvg.toInt(),
                          (index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? cText(true) : Colors.black87,
                        ),
                        child: Text(
                            '${stats.ratingAvg} (${stats.ratingCount} ' +
                                S.of(context).y5rbtvfs4l53),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        value: '${data.stats.deliveriesCount}',
                        label: S.of(context).tbgverfsdclk345frwcs,
                        color: Colors.blue,
                        isDark: isDark,
                      ),
                      _buildStatItem(
                        value: '${(data.professional.onTimePercent ?? "0")}%',
                        label: S.of(context).mftdr4587vfg,
                        color: Colors.green,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  if (data.profile.about != null) const SizedBox(height: 16),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? cText2(true) : Colors.grey[700],
                      height: 1.5,
                    ),
                    child: Text(
                      data.profile.about ?? '',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          icon: Icons.schedule,
                          value: _formatResponseTime(
                              professional.responseTimeMinutes, context),
                          label: /*S.of(context).brh45hg43g4tgve*/ "",
                          sublabel: '',
                          color: isDark ? cFill(true) : const Color(0xFFF5F8FD),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricItem(
                          icon: Icons.category,
                          value: '${professional.maxWeightKg ?? 0}',
                          label: S.of(context).hyrhh6g453grth4ge,
                          sublabel: S.of(context).brthgteb4h5g4t35g,
                          color: isDark ? cFill(true) : const Color(0xFFF4FDF8),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          icon: Icons.shield,
                          value: '\$${professional.insuranceUsd ?? 0}',
                          label: '',
                          sublabel: S.of(context).nrny5nrnrny5n5y454,
                          color: isDark ? cFill(true) : const Color(0xFFFBF9FE),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricItem(
                          icon: Icons.trending_up,
                          value: '${(professional.onTimePercent ?? 0)}%',
                          label: '',
                          sublabel: S.of(context).ntnhnhry454,
                          color: isDark ? cFill(true) : const Color(0xFFFBFBF1),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 20),
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B5FFF), Color(0xFFB74CFF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x335B5FFF),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleStartChat(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: Text(
                            S.of(context).nrhnnryhtnyr464,
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
                ],
              ),
            ),
            Positioned(
              right: 30,
              top: 15,
              child: GestureDetector(
                onTap: () => _handleReviewTap(context, isDark),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(left: 25, top: 10),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? cFill(true) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: isDark ? cText(true) : Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          imageUrl: imageUrl,
          heroTag: 'courier_avatar_${data.user.id}',
        ),
      ),
    );
  }

  String _formatResponseTime(String? minutes, BuildContext context) {
    final minutesInt = int.tryParse(minutes ?? '0') ?? 0;

    if (minutesInt == 0) return '0 ' + S.of(context).vre3gg43gv3r3v3rv;

    if (minutesInt < 60) {
      return '$minutesInt ' + S.of(context).vre3gg43gv3r3v3rv;
    }

    final hours = minutesInt ~/ 60;
    final mins = minutesInt % 60;
    return mins == 0
        ? '$hours ' + S.of(context).trh34tgvrt4h3g4rwev
        : '$hours ' +
            S.of(context).trh34tgvrt4h3g4rwev +
            ' $mins ' +
            S.of(context).vre3gg43gv3r3v3rv;
  }

  void _handleReviewTap(BuildContext context, bool isDark) async {
    final isLogged = await sl.get<AuthRepository>().isLogged();
    if (!isLogged) {
      return AuthModalUtils.showAuthRequiredModal(context);
    }

    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: isDark ? WawatDark.scrim : null,
      builder: (context) => SafeArea(
        child: _CourierReviewBottomSheet(
          courierId: data.user.id ?? 0,
          courierName: data.user.fullname ?? 'Курьер',
          isDark: isDark,
          onReviewSubmitted: (request) {
            if (onReviewSubmitted != null) {
              onReviewSubmitted!(request);
            }
          },
        ),
      ),
    );
  }

  void _handleStartChat(BuildContext context) async {
    final isLogged = await sl.get<AuthRepository>().isLogged();
    if (!isLogged) {
      return AuthModalUtils.showAuthRequiredModal(context);
    } else {
      StartChatModal.show(
        context,
        userId: data.user.id ?? 0,
        userName: data.user.fullname ?? 'Пользователь',
        onSuccess: (message) async {
          try {
            final chatApi = ChatApi(sl.get<Dio>());

            chatApi.startChat({
              'user_id': data.user.id,
              'body': message,
            });
          } catch (e) {
            print('Ошибка отправки сообщения: $e');
          }
        },
      );
    }
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? cText2(true) : Colors.grey[600],
          ),
          child: Text(label),
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
    required String sublabel,
    required Color color,
    required bool isDark,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isDark ? WawatDark.icon : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(height: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? cText(true) : Colors.black,
            ),
            child: Text(value + " " + label),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? cText2(true) : Colors.grey,
            ),
            child: Text(sublabel),
          ),
        ],
      ),
    );
  }
}

class _CourierReviewBottomSheet extends StatefulWidget {
  final int courierId;
  final String courierName;
  final bool isDark;
  final Function(CreateReviewRequest) onReviewSubmitted;

  const _CourierReviewBottomSheet({
    required this.courierId,
    required this.courierName,
    required this.isDark,
    required this.onReviewSubmitted,
  });

  @override
  State<_CourierReviewBottomSheet> createState() =>
      _CourierReviewBottomSheetState();
}

class _CourierReviewBottomSheetState extends State<_CourierReviewBottomSheet> {
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
      padding: EdgeInsets.zero, // keyboard inset handled by showAppBottomSheet
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Закрываем клавиатуру при нажатии вне TextField
          FocusScope.of(context).unfocus();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: widget.isDark ? cCard(true) : Colors.white,
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
                          ? WawatDark.grab
                          : WawatColors.backgroundLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: WawatTextStyles.h2.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? cText(true) : Colors.black,
                    ),
                    child: Text(
                      S.of(context).ntnyyh4664bnrgn,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: WawatTextStyles.body.copyWith(
                      color: widget.isDark
                          ? cText2(true)
                          : WawatColors.textSecondary,
                    ),
                    child: Text(
                      widget.courierName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w500),
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
                                    ? cBorder(true)
                                    : WawatColors.textSecondary
                                        .withOpacity(0.3)),
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
                          ? cFill(true)
                          : WawatColors.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _commentController,
                      maxLines: 4,
                      maxLength: 500,
                      style: WawatTextStyles.body.copyWith(
                        color: widget.isDark ? cText(true) : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: S.of(context).nhthnnhthnty554y54y,
                        hintStyle: WawatTextStyles.body.copyWith(
                          color: widget.isDark
                              ? WawatDark.placeholder
                              : WawatColors.textSecondary.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        counterStyle: WawatTextStyles.caption.copyWith(
                          color: widget.isDark
                              ? cText2(true)
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
                              S.of(context).nhtnhtnyth4465645,
                              style: WawatTextStyles.button.copyWith(
                                fontWeight: FontWeight.w500,
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
            content: Text(S.of(context).rynryyrynrh444646),
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
      final authRepository = sl.get<AuthRepository>();

      final request = CreateReviewRequest(
        reviewRequestId: null,
        targetId: widget.courierId,
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      await authRepository.sendReviews(request);

      if (mounted) {
        Navigator.of(context).pop();
        showIOSStyleMessage(context, S.of(context).gergergre335345);
        widget.onReviewSubmitted(request);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // ✅ Используем парсер
        showTopSnackbar(ErrorParser.parseDioError(e), false, context);
      }
    }
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String heroTag;

  const _FullScreenImageViewer({
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: widget.heroTag,
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _transformationController.value = Matrix4.identity();
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.zoom_out_map,
                        color: Colors.white,
                      ),
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
}
