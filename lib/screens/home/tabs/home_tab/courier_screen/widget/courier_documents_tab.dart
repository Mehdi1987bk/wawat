import 'package:flutter/material.dart';
import '../../../../../../data/network/response/partner_user_response.dart';
import '../../widget/wawat_courier_card.dart';

class CourierDocumentsTab extends StatelessWidget {
  final Data data;

  const CourierDocumentsTab({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildContactInfo(),
        const SizedBox(height: 16),
        _buildProfessionalInfo(),
        const SizedBox(height: 16),
        _buildLanguages(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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
              Icon(Icons.person, color: const Color(0xFF5B5BFF), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Контактная информация',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.phone,
            title: 'Телефон',
            value: data.user.phone ?? '--',
            iconColor: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.email,
            title: 'Email',
            value: data.user.email ?? '--',
            iconColor: Colors.grey,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.calendar_today,
            title: 'На платформе',
            value: data.user.createdAt == null
                ? '--'
                : data.user.createdAt.toString(),
            iconColor: Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.access_time,
            title: 'Последний раз в сети',
            value: data.user.lastSeenAt == null
                ? '--'
                : data.user.lastSeenAt.toString(),
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfo() {
    final professional = data.professional;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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
              Icon(Icons.work, color: const Color(0xFF5B5BFF), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Профессиональная информация',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.fitness_center,
            title: 'Максимальный вес',
            value: professional.maxWeightKg != null
                ? '${professional.maxWeightKg} кг'
                : '--',
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.security,
            title: 'Страхование',
            value: professional.insuranceUsd != null
                ? '\$${professional.insuranceUsd}'
                : '--',
            iconColor: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.attach_money,
            title: 'Диапазон цен (\$/кг)',
            value: professional.priceFrom != null && professional.priceTo != null
                ? '\$${professional.priceFrom} - \$${professional.priceTo}'
                : '--',
            iconColor: Colors.teal,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.schedule,
            title: 'Рабочие часы',
            value: professional.workTimeFrom != null && professional.workTimeTo != null
                ? '${professional.workTimeFrom} - ${professional.workTimeTo}'
                : '--',
            iconColor: Colors.indigo,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.timer,
            title: 'Время ответа',
            value: professional.responseTimeMinutes != null
                ? '${professional.responseTimeMinutes} мин'
                : '--',
            iconColor: Colors.deepOrange,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.check_circle,
            title: 'Вовремя доставок',
            value: professional.onTimePercent != null
                ? '${professional.onTimePercent}%'
                : '--',
            iconColor: Colors.lightGreen,
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
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[400], size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguages() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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
              Icon(Icons.language, color: const Color(0xFF5B5BFF), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Языки общения',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.user.languages
                .map((lang) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                lang.name,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black,
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