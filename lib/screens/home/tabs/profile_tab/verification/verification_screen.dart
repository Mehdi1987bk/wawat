import 'dart:io';
import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/presentation/resourses/app_colors.dart';
import 'package:buking/screens/home/tabs/profile_tab/verification/verification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../data/network/response/user.dart';
import '../../../../../data/network/response/verification_response.dart';
import '../../../../../services/theme_manager.dart';
import '../settings/experience_tab/experience_tab_screen.dart';

class VerificationScreen extends BaseScreen {
  final User user;

  VerificationScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState
    extends BaseState<VerificationScreen, VerificationBloc> {
  File? _passportImage;
  File? _selfieImage;
  bool _isLoading = false;
  bool _isLoadingStatus = true;
  VerificationData? _verificationData;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    try {
      final response = await bloc.verificationStatus();
      setState(() {
        _verificationData = response.data;
        _isLoadingStatus = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStatus = false;
      });
    }
  }

  @override
  Widget body() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        if (_isLoadingStatus) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
            body: Center(
              child: CircularProgressIndicator(
                color: isDark ? const Color(0xFF6366F1) : const Color(0xFF00B4A6),
              ),
            ),
          );
        }

        final hasVerification = _verificationData?.hasVerification ?? false;
        final isVerified = _verificationData?.isVerified ?? false;

        if (isVerified) {
          return _buildVerifiedScreen(isDark);
        }

        if (hasVerification) {
          return _buildPendingScreen(isDark);
        }

        return _buildUploadDocumentsScreen(isDark);
      },
    );
  }

  Widget _buildVerifiedScreen(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    child: const Text('Верификация'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const Icon(
                          Icons.verified_user,
                          color: Color(0xFF4CAF50),
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 32),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        child: const Text('Вы верифицированы!'),
                      ),
                      const SizedBox(height: 16),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600],
                          height: 1.5,
                        ),
                        child: const Text(
                          'Ваш аккаунт успешно верифицирован.\nТеперь у вас есть статус "Проверенный пользователь"',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.task_alt,
                              iconColor: const Color(0xFF4CAF50),
                              iconBgColor: const Color(0xFFE8F5E9),
                              title: 'Документы одобрены',
                              subtitle: 'Все проверки пройдены',
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            Divider(
                              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
                              height: 1,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.check_circle,
                              iconColor: const Color(0xFF4CAF50),
                              iconBgColor: const Color(0xFFE8F5E9),
                              title: 'Проверка завершена',
                              subtitle: 'Аккаунт верифицирован',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E3A1E)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              color: Color(0xFF4CAF50),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? const Color(0xFFB0B0B0) : Colors.grey[700],
                                ),
                                child: const Text(
                                  'Вы можете пользоваться всеми функциями платформы',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingScreen(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    child: const Text('Верификация'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5A623).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const Icon(
                          Icons.pending_outlined,
                          color: Color(0xFFF5A623),
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 32),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        child: const Text('Заявка на рассмотрении'),
                      ),
                      const SizedBox(height: 16),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600],
                          height: 1.5,
                        ),
                        child: const Text(
                          'Ваша заявка на верификацию была успешно отправлена.\nМы проверим ваши документы в течение 1-3 рабочих дней.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.task_alt,
                              iconColor: const Color(0xFF4CAF50),
                              iconBgColor: const Color(0xFFE8F5E9),
                              title: 'Документы отправлены',
                              subtitle: 'Паспорт и селфи получены',
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            Divider(
                              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
                              height: 1,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.schedule,
                              iconColor: const Color(0xFFF5A623),
                              iconBgColor: const Color(0xFFFFF3E0),
                              title: 'На проверке',
                              subtitle: 'Ожидайте результатов',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2A3A)
                              : const Color(0xFFE8F2FC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF4A90D9),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? const Color(0xFFB0B0B0) : Colors.grey[700],
                                ),
                                child: const Text(
                                  'Мы уведомим вас о результатах проверки',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                child: Text(title),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600],
                ),
                child: Text(subtitle),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadDocumentsScreen(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      child: const Text('Верификация'),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF00B4A6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: Colors.white,
                  size: 45,
                ),
              ),
              const SizedBox(height: 24),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                child: const Text('Верификация аккаунта'),
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? const Color(0xFF9CA3AF) : Colors.grey,
                  height: 1.4,
                ),
                child: const Text(
                  'Подтвердите свою личность для повышения\nдоверия',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      child: const Text('Статус верификации'),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600],
                      ),
                      child: const Text('Загрузите документы для проверки'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildDocumentCard(
                icon: Icons.description_outlined,
                iconColor: const Color(0xFF4A90D9),
                iconBgColor: const Color(0xFFE8F2FC),
                title: 'Паспорт',
                subtitle: 'Основной документ',
                status: _passportImage != null ? 'Загружено' : 'Не загружено',
                statusColor: _passportImage != null ? Colors.green : Colors.grey,
                uploadText: 'Загрузить паспорт',
                image: _passportImage,
                onTap: _pickPassportImage,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildDocumentCard(
                icon: Icons.camera_alt_outlined,
                iconColor: const Color(0xFF4CAF50),
                iconBgColor: const Color(0xFFE8F5E9),
                title: 'Селфи с паспортом',
                subtitle: 'Подтверждение личности',
                status: _selfieImage != null ? 'Загружено' : 'Не загружено',
                statusColor: _selfieImage != null ? Colors.green : Colors.grey,
                uploadText: 'Загрузить селфи с паспортом',
                image: _selfieImage,
                onTap: _pickSelfieImage,
                showUploadIcon: true,
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[600],
                    height: 1.5,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Важно: ',
                      style: TextStyle(
                        color: Color(0xFF4A90D9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text:
                      'Проверка документов занимает 1-3 рабочих дня. После одобрения вы получите статус "Проверенный пользователь".',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor: AppColors.appColor.withOpacity(0.6),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Text(
                    'Отправить на проверку',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  VerificationBloc provideBloc() {
    return VerificationBloc();
  }

  Future<void> _pickPassportImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _passportImage = File(image.path);
      });
    }
  }

  Future<void> _pickSelfieImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selfieImage = File(image.path);
      });
    }
  }

  Future<void> _submitVerification() async {
    if (_passportImage == null || _selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, загрузите оба документа'),
          backgroundColor: Colors.orange,
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await bloc.submitVerification(
        passport: _passportImage!,
        selfie: _selfieImage!,
      );

      if (mounted) {
        showIOSStyleMessage(context, 'Документы успешно отправлены на проверку');

        await _loadVerificationStatus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildDocumentCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required String uploadText,
    required File? image,
    required VoidCallback onTap,
    required bool isDark,
    bool showUploadIcon = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      child: Text(title),
                    ),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF6B7280) : Colors.grey[500],
                      ),
                      child: Text(subtitle),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (image == null)
                    Icon(
                      Icons.upload_outlined,
                      size: 18,
                      color: isDark ? const Color(0xFF6B7280) : Colors.grey[400],
                    ),
                  if (image != null)
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: statusColor,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF4A4A4A) : Colors.grey[300]!,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: isDark ? const Color(0xFF4A4A4A) : Colors.grey[350]!,
                  strokeWidth: 1.5,
                  gap: 6,
                ),
                child: image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_outlined,
                      size: 32,
                      color: isDark ? const Color(0xFF6B7280) : Colors.grey[400],
                    ),
                    const SizedBox(height: 10),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? const Color(0xFF9CA3AF) : Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                      child: Text(uploadText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final dashWidth = 8.0;
    final radius = 12.0;

    double x = radius;
    while (x < size.width - radius) {
      path.moveTo(x, 0);
      path.lineTo(x + dashWidth, 0);
      x += dashWidth + gap;
    }

    double y = radius;
    while (y < size.height - radius) {
      path.moveTo(size.width, y);
      path.lineTo(size.width, y + dashWidth);
      y += dashWidth + gap;
    }

    x = radius;
    while (x < size.width - radius) {
      path.moveTo(x, size.height);
      path.lineTo(x + dashWidth, size.height);
      x += dashWidth + gap;
    }

    y = radius;
    while (y < size.height - radius) {
      path.moveTo(0, y);
      path.lineTo(0, y + dashWidth);
      y += dashWidth + gap;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
