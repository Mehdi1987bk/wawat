import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/resourses/wawat_colors.dart';
import '../../../../services/theme_manager.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        final isDark = themeManager.isDarkMode;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF1E1E1E)
              : WawatColors.backgroundWhite,
          appBar: AppBar(
            backgroundColor: isDark
                ? const Color(0xFF1E1E1E)
                : WawatColors.backgroundWhite,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Privacy Policy',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Политика конфиденциальности',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Последнее обновление: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : WawatColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  isDark,
                  'Введение',
                  'Мы уважаем вашу конфиденциальность и стремимся защитить ваши персональные данные. Эта политика конфиденциальности объясняет, как мы собираем, используем и защищаем вашу информацию при использовании нашего приложения.',
                ),
                _buildSection(
                  isDark,
                  'Какие данные мы собираем',
                  'Мы можем собирать следующую информацию:\n'
                      '• Имя и контактные данные\n'
                      '• Адрес электронной почты\n'
                      '• Номер телефона\n'
                      '• Информация о заказах и доставках\n'
                      '• Предпочтения коммуникации',
                ),
                _buildSection(
                  isDark,
                  'Как мы используем ваши данные',
                  'Мы используем ваши данные для:\n'
                      '• Предоставления и улучшения наших услуг\n'
                      '• Обработки ваших заказов и доставок\n'
                      '• Связи с вами по поводу ваших заказов\n'
                      '• Отправки уведомлений о статусе доставки\n'
                      '• Анализа использования приложения',
                ),
                _buildSection(
                  isDark,
                  'Защита данных',
                  'Мы применяем соответствующие технические и организационные меры для защиты ваших персональных данных от несанкционированного доступа, изменения, раскрытия или уничтожения.',
                ),
                _buildSection(
                  isDark,
                  'Ваши права',
                  'Вы имеете право:\n'
                      '• Получить доступ к своим персональным данным\n'
                      '• Исправить неточные данные\n'
                      '• Запросить удаление ваших данных\n'
                      '• Отозвать согласие на обработку данных\n'
                      '• Подать жалобу в надзорный орган',
                ),
                _buildSection(
                  isDark,
                  'Изменения в политике',
                  'Мы можем время от времени обновлять эту политику конфиденциальности. Мы уведомим вас о любых изменениях, разместив новую политику на этой странице.',
                ),
                _buildSection(
                  isDark,
                  'Контакты',
                  'Если у вас есть вопросы о нашей политике конфиденциальности, свяжитесь с нами:\n'
                      'Email: support@wawat.com\n'
                      'Телефон: +994 XX XXX XX XX',
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(bool isDark, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}
