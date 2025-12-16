import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/network/api/chat_api.dart';
import '../../../../../../data/network/response/partner_user_response.dart';
import '../../../../../../domain/repositories/auth_repository.dart';
import '../../../../../../main.dart';
import '../../../../../../services/theme_manager.dart';
import '../../widget/auth_modal_utils.dart';
import '../../widget/start_chat_modal.dart';

class CourierProfileCard extends StatelessWidget {
  final Data data;

  const CourierProfileCard({
    Key? key,
    required this.data,
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
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
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
                      Container(
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
                          const Text(
                            'Проверен',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
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
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    child: Text(user.fullname),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: List.generate(
                          5,
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
                          color:
                              isDark ? const Color(0xFFE5E7EB) : Colors.black87,
                        ),
                        child: Text(
                            '${stats.ratingAvg} (${stats.ratingCount} отзывов)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        value: '${data.reviewsReceived.length}',
                        label: 'Доставок',
                        color: Colors.blue,
                        isDark: isDark,
                      ),
                      _buildStatItem(
                        value: '${data.professional.onTimePercent}%',
                        label: 'Успешно',
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
                      color:
                          isDark ? const Color(0xFF9CA3AF) : Colors.grey[700],
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
                          value: '${professional.responseTimeMinutes ?? 0}',
                          label: 'минут',
                          sublabel: 'Ответ',
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFF5F8FD),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricItem(
                          icon: Icons.category,
                          value: '${professional.maxWeightKg ?? 0}',
                          label: 'кг',
                          sublabel: 'Макс. вес',
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFF4FDF8),
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
                          sublabel: 'Страховка',
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFFBF9FE),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricItem(
                          icon: Icons.trending_up,
                          value: '${(professional.onTimePercent ?? 0)}%',
                          label: '',
                          sublabel: 'Воремя',
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFFBFBF1),
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
                        child: const Center(
                          child: Text(
                            'Написать',
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
                ],
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
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        );
      },
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
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600],
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
            color: isDark ? const Color(0xFF6B7280) : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(height: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
            child: Text(value + " " + label),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF9CA3AF) : Colors.grey,
            ),
            child: Text(sublabel),
          ),
        ],
      ),
    );
  }
}
