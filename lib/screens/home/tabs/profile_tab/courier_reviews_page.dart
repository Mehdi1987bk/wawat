import 'package:flutter/material.dart';

import '../../../../data/network/response/user.dart';

class CourierReviewsPage extends StatefulWidget {
  final User user;

  const CourierReviewsPage({Key? key, required this.user}) : super(key: key);

  @override
  State<CourierReviewsPage> createState() => _CourierReviewsPageState();
}

class _CourierReviewsPageState extends State<CourierReviewsPage> {
  int _selectedTab = 0; // 0 - Полученные, 1 - Оставленные

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 8),
                  // Иконка
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.star,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Заголовок
                  const Text(
                    'Отзывы',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Подзаголовок
                  const Text(
                    'Ваша репутация и отзывы о работе',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Карточка со статистикой
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Рейтинг
                        const Text(
                          '4.7',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Звезды
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3),
                              child: Icon(
                                Icons.star,
                                color: Color(0xFFFFB800),
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Средний рейтинг',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Всего отзывов
                        const Text(
                          '3',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Всего отзывов',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Процент положительных
                        const Text(
                          '96%',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Положительных',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Табы
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _selectedTab == 0
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Полученные',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: _selectedTab == 0
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: _selectedTab == 0
                                      ? Colors.black
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 1),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: _selectedTab == 1
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Оставленные',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: _selectedTab == 1
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: _selectedTab == 1
                                      ? Colors.black
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Список отзывов
                  _buildReviewItem(
                    name: 'Мария С.',
                    route: 'Москва → Дубай',
                    date: '15 янв 2024',
                    comment:
                        'Отличный курьер! Доставил посылку быстро и аккуратно. Всегда на связи, информировал о статусе доставки. Рекомендую!',
                    rating: 5,
                    avatarColor: const Color(0xFF7C3AED),
                  ),
                  const SizedBox(height: 16),
                  _buildReviewItem(
                    name: 'Алексей К.',
                    route: 'СПб → Лондон',
                    date: '10 янв 2024',
                    comment:
                        'Хороший сервис, но немного задержался с доставкой. В целом доволен.',
                    rating: 4,
                    avatarColor: const Color(0xFF6366F1),
                  ),
                  const SizedBox(height: 16),
                  _buildReviewItem(
                    name: 'Дмитрий В.',
                    route: 'Москва → Стамбул',
                    date: '5 янв 2024',
                    comment:
                        'Профессиональный подход! Посылка дошла в идеальном состоянии. Спасибо за качественную работу!',
                    rating: 5,
                    avatarColor: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem({
    required String name,
    required String route,
    required String date,
    required String comment,
    required int rating,
    required Color avatarColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Аватар
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  avatarColor,
                  avatarColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '👨',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Контент
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    // Звезды
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFB800),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$route • $date',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  comment,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
