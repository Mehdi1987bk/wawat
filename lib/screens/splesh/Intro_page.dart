import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../main.dart';
import '../../presentation/resourses/wawat_dark.dart';
import '../../services/wawat_content.dart';
import '../auth/login/login_screen.dart';
import '../home/home_screen.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  static const _brand = Color(0xFF017BFE);
  static const _ink900 = Color(0xFF0F172A);
  static const _ink500 = Color(0xFF64748B);
  static const _ink400 = Color(0xFF94A3B8);
  static const _ink300 = Color(0xFFCBD5E1);

  final PageController _pageController = PageController();
  Map<String, String> _content = const {};
  int _page = 0;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    WawatContent.load(group: 'onboarding').then((content) {
      if (mounted) setState(() => _content = content);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _text(String key) => WawatContent.text(_content, key);

  Future<void> _complete(Widget destination) async {
    if (_finishing) return;
    _finishing = true;
    await sl.get<AuthRepository>().setIsFirstOpen();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  void _next() {
    if (_page == 2) {
      _complete(HomeScreen());
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: isDark ? WawatDark.bg : Colors.white,
        body: SafeArea(
          child: PageView.builder(
            controller: _pageController,
            itemCount: 3,
            onPageChanged: (value) => setState(() => _page = value),
            itemBuilder: (context, index) {
              return _OnboardingSlide(
                index: index,
                title: _text('onboarding.slide${index + 1}.title'),
                body: _text('onboarding.slide${index + 1}.body'),
                nextLabel: index == 2
                    ? _text('onboarding.cta.start')
                    : _text('onboarding.cta.next'),
                skipLabel: _text('onboarding.cta.skip'),
                haveAccountLabel: _text('onboarding.have_account'),
                loginLabel: _text('onboarding.login'),
                onSkip: () => _complete(HomeScreen()),
                onNext: _next,
                onLogin: () => _complete(LoginScreen()),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.index,
    required this.title,
    required this.body,
    required this.nextLabel,
    required this.skipLabel,
    required this.haveAccountLabel,
    required this.loginLabel,
    required this.onSkip,
    required this.onNext,
    required this.onLogin,
  });

  final int index;
  final String title;
  final String body;
  final String nextLabel;
  final String skipLabel;
  final String haveAccountLabel;
  final String loginLabel;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onLogin;

  static const _brand = _IntroPageState._brand;
  static const _ink900 = _IntroPageState._ink900;
  static const _ink500 = _IntroPageState._ink500;
  static const _ink400 = _IntroPageState._ink400;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 720;
        final artHeight =
            math.min(288.0, math.max(230.0, constraints.maxHeight * 0.37));

        return Padding(
          padding: EdgeInsets.fromLTRB(24, compact ? 8 : 12, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 34,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _BrandLogo(isDark: isDark),
                    if (index < 2)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onSkip,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          child: Text(
                            skipLabel,
                            style: TextStyle(
                              color: isDark ? WawatDark.textMuted : _ink400,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
              SizedBox(height: compact ? 15 : 21),
              SizedBox(
                height: artHeight,
                width: double.infinity,
                child: _OnboardingArt(index: index),
              ),
              SizedBox(height: compact ? 22 : 28),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? WawatDark.textPrimary : _ink900,
                  fontSize: 27,
                  height: 1.08,
                  letterSpacing: -0.65,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: TextStyle(
                  color: isDark ? WawatDark.textSecondary : _ink500,
                  fontSize: 15,
                  height: 1.48,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  3,
                  (dotIndex) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width: dotIndex == index ? 26 : 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: dotIndex == index
                          ? _brand
                          : (isDark
                              ? WawatDark.iconMuted
                              : _IntroPageState._ink300),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _PrimaryButton(
                label: nextLabel,
                onTap: onNext,
              ),
              if (index == 2) ...[
                const SizedBox(height: 11),
                Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onLogin,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 3,
                      ),
                      child: Text.rich(
                        TextSpan(
                          text: '$haveAccountLabel ',
                          children: [
                            TextSpan(
                              text: loginLabel,
                              style: const TextStyle(color: _brand),
                            ),
                          ],
                        ),
                        style: TextStyle(
                          color: isDark ? WawatDark.textMuted : _ink400,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: compact ? 14 : 24),
            ],
          ),
        );
      },
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const logo = Image(
      image: AssetImage('asset/wawatair_primary.png'),
      width: 132,
      height: 27,
      fit: BoxFit.contain,
      alignment: Alignment.centerLeft,
    );
    if (!isDark) return logo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: logo,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _IntroPageState._brand,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55017BFE),
            blurRadius: 18,
            offset: Offset(0, 8),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              PhosphorIcon(
                PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingArt extends StatelessWidget {
  const _OnboardingArt({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final darkEnd =
        index == 1 ? const Color(0xFF023E80) : const Color(0xFF0257AE);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF0F7BF4), darkEnd],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ArtBackgroundPainter(index),
            ),
          ),
          if (index == 0) const _FirstArtContent(),
          if (index == 1) const _SecondArtContent(),
          if (index == 2) const _ThirdArtContent(),
        ],
      ),
    );
  }
}

class _FirstArtContent extends StatelessWidget {
  const _FirstArtContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: PhosphorIcon(
                PhosphorIcons.airplaneTilt(PhosphorIconsStyle.fill),
                size: 31,
                color: _IntroPageState._brand,
              ),
            ),
          ),
        ),
        Positioned(
          left: 18,
          top: 26,
          child: _ArtChip(
            icon: PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
            label: 'Bakı',
          ),
        ),
        Positioned(
          right: 24,
          top: 22,
          child: _ArtChip(
            icon: PhosphorIcons.airplaneTakeoff(PhosphorIconsStyle.fill),
            label: 'İstanbul',
          ),
        ),
        Positioned(
          right: 18,
          bottom: 30,
          child: _ArtChip(
            icon: PhosphorIcons.package(PhosphorIconsStyle.fill),
            label: 'Bağlaman',
          ),
        ),
      ],
    );
  }
}

class _SecondArtContent extends StatelessWidget {
  const _SecondArtContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D0F172A),
                  blurRadius: 30,
                  offset: Offset(0, 12),
                  spreadRadius: -12,
                ),
              ],
            ),
            child: PhosphorIcon(
              PhosphorIcons.package(PhosphorIconsStyle.fill),
              size: 48,
              color: _IntroPageState._brand,
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.23, -0.18),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFF2FC2A),
                shape: BoxShape.circle,
              ),
              child: PhosphorIcon(
                PhosphorIcons.lightning(PhosphorIconsStyle.fill),
                size: 19,
                color: _IntroPageState._ink900,
              ),
            ),
          ),
        ),
        const Positioned(
          left: 22,
          top: 34,
          child: _MoneyChip(),
        ),
        Positioned(
          right: 22,
          bottom: 34,
          child: _ArtChip(
            icon: PhosphorIcons.clock(PhosphorIconsStyle.fill),
            label: '1–2 gündə',
          ),
        ),
      ],
    );
  }
}

class _ThirdArtContent extends StatelessWidget {
  const _ThirdArtContent();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x4D0F172A),
                  blurRadius: 30,
                  offset: Offset(0, 12),
                  spreadRadius: -12,
                ),
              ],
            ),
            child: PhosphorIcon(
              PhosphorIcons.sealCheck(PhosphorIconsStyle.fill),
              size: 59,
              color: _IntroPageState._brand,
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 30,
          child: _ArtChip(
            icon: PhosphorIcons.star(PhosphorIconsStyle.fill),
            iconColor: const Color(0xFFFBBF24),
            label: '4.9 reytinq',
          ),
        ),
        Positioned(
          right: 20,
          bottom: 32,
          child: _ArtChip(
            icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
            label: 'Təhlükəsiz',
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: const Alignment(-0.48, 0.23),
            child: PhosphorIcon(
              PhosphorIcons.star(PhosphorIconsStyle.fill),
              size: 21,
              color: const Color(0xFFFCD34D),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0.52, -0.32),
            child: PhosphorIcon(
              PhosphorIcons.star(PhosphorIconsStyle.fill),
              size: 16,
              color: const Color(0xFFFCD34D),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArtChip extends StatelessWidget {
  const _ArtChip({
    required this.icon,
    required this.label,
    this.iconColor = _IntroPageState._brand,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D0F172A),
            blurRadius: 30,
            offset: Offset(0, 12),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _IntroPageState._ink900,
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyChip extends StatelessWidget {
  const _MoneyChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 37,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D0F172A),
            blurRadius: 30,
            offset: Offset(0, 12),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _IntroPageState._brand,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '₼',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            '5 ₼-dən',
            style: TextStyle(
              color: _IntroPageState._ink900,
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtBackgroundPainter extends CustomPainter {
  const _ArtBackgroundPainter(this.index);

  final int index;

  @override
  void paint(Canvas canvas, Size size) {
    if (index == 0) {
      final path = Path()
        ..moveTo(size.width * 0.06, size.height * 0.75)
        ..quadraticBezierTo(
          size.width * 0.50,
          size.height * 0.20,
          size.width * 0.97,
          size.height * 0.52,
        );
      _drawDashedPath(
        canvas,
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
        dash: 2,
        gap: 10,
      );
      canvas.drawCircle(
        Offset(size.width * 0.06, size.height * 0.75),
        6,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(size.width * 0.97, size.height * 0.52),
        6,
        Paint()..color = const Color(0xFFF2FC2A),
      );
      return;
    }

    if (index == 1) {
      final path = Path()
        ..moveTo(-10, size.height * 0.82)
        ..quadraticBezierTo(
          size.width * 0.50,
          size.height * 0.42,
          size.width + 10,
          size.height * 0.71,
        );
      _drawDashedPath(
        canvas,
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
        dash: 2,
        gap: 12,
      );
      return;
    }

    final white = Paint()..color = Colors.white.withValues(alpha: 0.5);
    final accent = Paint()
      ..color = const Color(0xFFF2FC2A).withValues(alpha: 0.8);
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.24),
      3,
      white,
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.31),
      3.5,
      accent,
    );
    canvas.drawCircle(
      Offset(size.width * 0.76, size.height * 0.76),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dash,
    required double gap,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            math.min(distance + dash, metric.length),
          ),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ArtBackgroundPainter oldDelegate) {
    return oldDelegate.index != index;
  }
}
