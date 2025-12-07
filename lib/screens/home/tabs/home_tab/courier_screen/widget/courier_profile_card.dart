import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../../../data/network/response/partner_user_response.dart';
import '../../../../../../domain/repositories/auth_repository.dart';
import '../../../../../../main.dart';
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

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
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
                  margin: EdgeInsets.only(top: 8),
                  padding: EdgeInsets.symmetric(
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
                      SizedBox(width: 3),
                      Text(
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
              Text(
                user.fullname,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${stats.ratingAvg} (${stats.ratingCount} отзывов)',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
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
                  ),
                  _buildStatItem(
                    value: '${data.professional.onTimePercent}%',
                    label: 'Успешно',
                    color: Colors.green,
                  ),
                ],
              ),
              if (data.profile.about != null) const SizedBox(height: 16),
              Text(
                data.profile.about ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      icon: Icons.schedule,
                      value: '${professional.responseTimeMinutes ?? 0}',
                      label: 'минут',
                      sublabel: 'Ответ',
                      color: Color(0xFFF5F8FD),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      icon: Icons.category,
                      value: '${professional.maxWeightKg ?? 0}',
                      label: 'кг',
                      sublabel: 'Макс. вес',
                      color: Color(0xFFF4FDF8),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      icon: Icons.shield,
                      value: '\$${professional.insuranceUsd ?? 0}',
                      label: '',
                      sublabel: 'Страховка',
                      color: Color(0xFFFBF9FE),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      icon: Icons.trending_up,
                      value: '${(professional.onTimePercent ?? 0)}%',
                      label: '',
                      sublabel: 'Воремя',
                      color: Color(0xFFFBFBF1),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 20,bottom: 20),
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5B5FFF), Color(0xFFB74CFF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x335B5FFF),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>  _handleStartChat(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child:  Text(
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
          child: Container(
            margin: EdgeInsets.only(left: 25, top: 10),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
      ],
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
        onSuccess: () {
          // Handle success if needed
        },
      );
    }
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
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
  }) {
    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(height: 8),
          Text(
            value + " " + label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            sublabel,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
