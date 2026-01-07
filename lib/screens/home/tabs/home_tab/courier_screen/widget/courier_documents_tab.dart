import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/network/response/partner_user_response.dart';
import '../../../../../../generated/l10n.dart';
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
            _buildContactInfo(isDark,context),
            const SizedBox(height: 16),
            _buildProfessionalInfo(isDark,context),
            const SizedBox(height: 16),
            _buildLanguages(isDark,context),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildContactInfo(bool isDark , BuildContext context) {
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
                duration:   Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                child:   Text(S.of(context).bteg4r5344wfvsfdg34wf),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.phone,
            title: S.of(context).tbergwf35grwfsvfg43,
            value: data.user.phone  ??  '--',
            iconColor: Colors.green,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.email,
            title: S.of(context).emailg34rfvfs,
            value: data.user.email ?? '--',
            iconColor: Colors.grey,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.calendar_today,
            title: S.of(context).btegr4tfwrg3frwv,
            value: data.stats.yearsOnPlatform.toString() + " " + S.of(context).etghrwf3fr3,
            iconColor: Colors.purple,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.access_time,
            title: S.of(context).btergwfe5g34rfecerv,
            value: data.user.lastSeenAt == null
                ? '--'
                : DateFormat('dd.MM.yyyy HH:mm').format(data.user.lastSeenAt!),
            iconColor: Colors.red,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfo(bool isDark,BuildContext context) {
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
                child:   Text(S.of(context).bterv4gg353r5r35),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.stars,
            title: S.of(context).bteettgr3gt4g3t4tg3,
            value: professional.experienceYears != null
                ? '${professional.experienceYears} ' + S.of(context).tebh4gterw4htgerwf
                : '--',
            iconColor: Colors.orange,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.fitness_center,
            title: S.of(context).evr4g653twgrv43gr,
            value: professional.maxWeightKg != null
                ? '${professional.maxWeightKg} ' +S.of(context).ethgr46htgbevgte
                : '--',
            iconColor: Colors.blue,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.security,
            title: S.of(context).brtg3rtvebt4rgvbfd,
            value: professional.insuranceUsd != null
                ? '\$${professional.insuranceUsd}'
                : '--',
            iconColor: Colors.green,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.attach_money,
            title: S.of(context).vervrefg3gr45t3t4fwr34,
            value: professional.priceFrom != null && professional.priceTo != null
                ? '\$${professional.priceFrom} - \$${professional.priceTo}'
                : '--',
            iconColor: Colors.teal,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.schedule,
            title: S.of(context).beg53gt342feg35g2fw,
            value: professional.workTimeFrom != null && professional.workTimeTo != null
                ? '${professional.workTimeFrom} - ${professional.workTimeTo}'
                : '--',
            iconColor: Colors.indigo,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.timer,
            title: S.of(context).btrg3243g5vfed34ft,
            value: professional.responseTimeMinutes != null
                ? '${professional.responseTimeMinutes} ' +S.of(context).btegr435tt24fwg34wf
                : '--',
            iconColor: Colors.deepOrange,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.check_circle,
            title: S.of(context).tegr4rt3542frg3r,
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

 

  Widget _buildLanguages(bool isDark, BuildContext context) {
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
                child:   Text(S.of(context).ki7ju6h5ytg4erf53fw),
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
