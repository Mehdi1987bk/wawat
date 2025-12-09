import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/network/response/partner_user_response.dart';
import '../../../../../../services/theme_manager.dart';
import '../../widget/wawat_courier_card.dart';

class CourierDocumentsTab extends StatelessWidget {
  final Data data;

  const CourierDocumentsTab({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return Column(
          children: [
            _buildContactInfo(isDark),
            const SizedBox(height: 16),
            _buildProfessionalInfo(isDark),
            const SizedBox(height: 16),
            _buildLanguages(isDark),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildContactInfo(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Color(0xFF5B5BFF), size: 20),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                child: const Text('Контактная информация'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.phone,
            title: 'Телефон',
            value: data.user.phone ?? '--',
            iconColor: Colors.green,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.email,
            title: 'Email',
            value: data.user.email ?? '--',
            iconColor: Colors.grey,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.calendar_today,
            title: 'На платформе',
            value: data.user.createdAt == null
                ? '--'
                : data.user.createdAt.toString(),
            iconColor: Colors.purple,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.access_time,
            title: 'Последний раз в сети',
            value: data.user.lastSeenAt == null
                ? '--'
                : data.user.lastSeenAt.toString(),
            iconColor: Colors.red,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfo(bool isDark) {
    final professional = data.professional;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.work, color: Color(0xFF5B5BFF), size: 20),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                child: const Text('Профессиональная информация'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.stars,
            title: 'Опыт работы',
            value: professional.experienceYears != null
                ? '${professional.experienceYears} лет'
                : '--',
            iconColor: Colors.orange,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.fitness_center,
            title: 'Максимальный вес',
            value: professional.maxWeightKg != null
                ? '${professional.maxWeightKg} кг'
                : '--',
            iconColor: Colors.blue,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.security,
            title: 'Страхование',
            value: professional.insuranceUsd != null
                ? '\$${professional.insuranceUsd}'
                : '--',
            iconColor: Colors.green,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.attach_money,
            title: 'Диапазон цен (\$/кг)',
            value: professional.priceFrom != null && professional.priceTo != null
                ? '\$${professional.priceFrom} - \$${professional.priceTo}'
                : '--',
            iconColor: Colors.teal,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.schedule,
            title: 'Рабочие часы',
            value: professional.workTimeFrom != null && professional.workTimeTo != null
                ? '${professional.workTimeFrom} - ${professional.workTimeTo}'
                : '--',
            iconColor: Colors.indigo,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.timer,
            title: 'Время ответа',
            value: professional.responseTimeMinutes != null
                ? '${professional.responseTimeMinutes} мин'
                : '--',
            iconColor: Colors.deepOrange,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.check_circle,
            title: 'Вовремя доставок',
            value: professional.onTimePercent != null
                ? '${professional.onTimePercent}%'
                : '--',
            iconColor: Colors.lightGreen,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600],
                ),
                child: Text(title),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
                child: Text(value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecializationItem({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isDark ? const Color(0xFF6B7280) : Colors.grey[400],
            size: 28,
          ),
          const SizedBox(height: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguages(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language, color: Color(0xFF5B5BFF), size: 20),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                child: const Text('Языки общения'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.user.languages
                .map((lang) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                lang.name,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
