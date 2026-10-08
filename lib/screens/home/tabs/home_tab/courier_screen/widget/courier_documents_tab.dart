import 'package:flutter/material.dart';
import 'package:buking/services/localization_service.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/network/response/partner_user_response.dart';
import '../../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../../services/theme_manager.dart';

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
            _buildContactInfo(isDark, context),
            const SizedBox(height: 16),
            _buildProfessionalInfo(isDark, context),
            const SizedBox(height: 16),
            _buildLanguages(isDark, context),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildContactInfo(bool isDark, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cCard(true) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: cCardBorder(isDark),
        boxShadow: isDark
            ? WawatDark.cardShadow
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person,
                  color: isDark ? cBrandText(true) : const Color(0xFF5B5BFF),
                  size: 20),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? cText(true) : Colors.black,
                ),
                child: Text(t('courier.contacts')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.phone,
            title: t('common.phone'),
            value: data.user.phone ?? '--',
            iconColor: Colors.green,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.email,
            title: t('auth.email_label'),
            value: data.user.email ?? '--',
            iconColor: Colors.grey,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.calendar_today,
            title: t('courier.on_platform'),
            value: data.stats.yearsOnPlatform.toString() +
                " " +
                t('receipt.days'),
            iconColor: Colors.purple,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.access_time,
            title: t('courier.last_seen'),
            value: _formatResponseTime(data.user.lastSeenAt, context),
            iconColor: Colors.red,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// Normalises a time string to `HH:mm` (drops seconds).
  String _hhmm(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final raw = value.trim();
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw);
    if (match != null) {
      return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
    }
    return raw;
  }

  String _formatResponseTime(String? minutes, BuildContext context) {
    final minutesInt = int.tryParse(minutes ?? '0') ?? 0;

    if (minutesInt == 0) return '0 ' + t('common.minute_short');

    if (minutesInt < 60) {
      return '$minutesInt ' + t('common.minute_short');
    }

    final hours = minutesInt ~/ 60;
    final mins = minutesInt % 60;
    return mins == 0
        ? '$hours ' + t('common.hour_short')
        : '$hours ' +
            t('common.hour_short') +
            ' $mins ' +
            t('common.minute_short');
  }

  Widget _buildProfessionalInfo(bool isDark, BuildContext context) {
    final professional = data.professional;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cCard(true) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: cCardBorder(isDark),
        boxShadow: isDark
            ? WawatDark.cardShadow
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work,
                  color: isDark ? cBrandText(true) : const Color(0xFF5B5BFF),
                  size: 20),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? cText(true) : Colors.black,
                ),
                child: Text(t('courier.professional_info')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.stars,
            title: t('courier.work_experience'),
            value: professional.experienceYears != null
                ? '${professional.experienceYears} ' +
                    t('common.year_short')
                : '--',
            iconColor: Colors.orange,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.fitness_center,
            title: t('courier.max_weight'),
            value: professional.maxWeightKg != null
                ? '${professional.maxWeightKg} ' +
                    t('common.kg')
                : '--',
            iconColor: Colors.blue,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.security,
            title: t('courier.insurance'),
            value: professional.insuranceUsd != null
                ? '\$${professional.insuranceUsd}'
                : '--',
            iconColor: Colors.green,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.attach_money,
            title: t('courier.price_range'),
            value:
                professional.priceFrom != null && professional.priceTo != null
                    ? '\$${professional.priceFrom} - \$${professional.priceTo}'
                    : '--',
            iconColor: Colors.teal,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.schedule,
            title: t('courier.work_hours'),
            value: professional.workTimeFrom != null &&
                    professional.workTimeTo != null
                ? '${_hhmm(professional.workTimeFrom)} - ${_hhmm(professional.workTimeTo)}'
                : '--',
            iconColor: Colors.indigo,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.timer,
            title: t('courier.response_time'),
            value: _formatResponseTime(
                data.professional.responseTimeMinutes, context),
            iconColor: Colors.deepOrange,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.check_circle,
            title: t('courier.on_time_deliveries'),
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
                  color: isDark ? cText2(true) : Colors.grey[600],
                ),
                child: Text(title),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? cText(true) : Colors.black,
                ),
                child: Text(value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguages(bool isDark, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cCard(true) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: cCardBorder(isDark),
        boxShadow: isDark
            ? WawatDark.cardShadow
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language,
                  color: isDark ? cBrandText(true) : const Color(0xFF5B5BFF),
                  size: 20),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? cText(true) : Colors.black,
                ),
                child: Text(t('courier.spoken_languages')),
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
                        color: isDark ? cFill(true) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        lang.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? cText(true) : Colors.black,
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
