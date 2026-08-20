import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/presentation/bloc/error_dispatcher.dart';
import 'package:buking/screens/home/tabs/profile_tab/settings/privacy_tab/privacy_tab_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../data/network/request/notification_settings.dart';
import '../../../../../../data/network/request/privacy_settings.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../../presentation/resourses/theme_colors.dart';
import '../../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../../services/localization_service.dart';
import '../../../../../../services/telemetry/telemetry_consent.dart';
import '../../../../../../services/theme_aware_screen.dart';
import '../../../../../../services/theme_manager.dart';
import '../experience_tab/experience_tab_screen.dart';

class PrivacyTab extends BaseScreen {
  final bool showPhoneTab;
  final bool showEmailTab;
  final bool showActivityTime;
  final bool showNewMessages;
  final bool showNewReviews;
  final bool showMarketing;

  PrivacyTab({
    Key? key,
    required this.showPhoneTab,
    required this.showEmailTab,
    required this.showActivityTime,
    required this.showNewMessages,
    required this.showNewReviews,
    required this.showMarketing,
  }) : super(key: key);

  @override
  State<PrivacyTab> createState() => _PrivacyTabState();
}

class _PrivacyTabState extends BaseState<PrivacyTab, PrivacyTabBloc>
    with ErrorDispatcher {
  final ValueNotifier<bool> _isFormValid = ValueNotifier(false);

  late bool showPhoneTab;
  late bool showEmailTab;
  late bool showActivityTime;
  late bool showNewMessages;
  late bool showNewReviews;
  late bool showMarketing;

  // Сохраняем исходные значения
  late bool _initialShowPhoneTab;
  late bool _initialShowEmailTab;
  late bool _initialShowActivityTime;
  late bool _initialShowNewMessages;
  late bool _initialShowNewReviews;
  late bool _initialShowMarketing;

  @override
  void initState() {
    super.initState();
    // Инициализируем текущие значения из widget
    showPhoneTab = widget.showPhoneTab;
    showEmailTab = widget.showEmailTab;
    showActivityTime = widget.showActivityTime;
    showNewMessages = widget.showNewMessages;
    showNewReviews = widget.showNewReviews;
    showMarketing = widget.showMarketing;

    // Сохраняем исходные значения
    _initialShowPhoneTab = widget.showPhoneTab;
    _initialShowEmailTab = widget.showEmailTab;
    _initialShowActivityTime = widget.showActivityTime;
    _initialShowNewMessages = widget.showNewMessages;
    _initialShowNewReviews = widget.showNewReviews;
    _initialShowMarketing = widget.showMarketing;
  }

  void _checkFormValidity() {
    final hasChanges = showPhoneTab != _initialShowPhoneTab ||
        showEmailTab != _initialShowEmailTab ||
        showActivityTime != _initialShowActivityTime ||
        showNewMessages != _initialShowNewMessages ||
        showNewReviews != _initialShowNewReviews ||
        showMarketing != _initialShowMarketing;

    _isFormValid.value = hasChanges;
  }

  @override
  Widget body() {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return ThemeAwareScreen(
          isDark: isDark,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: cCard(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: cCardBorder(isDark),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5B4FFF), Color(0xFFD946EF)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.shield,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? WawatDark.textPrimary
                                    : Colors.black,
                              ),
                              child: Text(S.of(context).gret4h5h53g2b),
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? WawatDark.textSecondary
                                    : const Color(0xFF8E8E93),
                              ),
                              child: Text(S.of(context).vfsvf33fr),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? WawatDark.textPrimary : Colors.black,
                      ),
                      child: Text(S.of(context).vsf3r4gh57j6hnbd),
                    ),
                    const SizedBox(height: 12),
                    _buildToggleRow(S.of(context).myiuk7564hd, showPhoneTab,
                        (value) {
                      setState(() => showPhoneTab = value);
                      _checkFormValidity();
                    }, isDark),
                    const SizedBox(height: 8),
                    _buildToggleRow(S.of(context).emailnhrtybe, showEmailTab,
                        (value) {
                      setState(() => showEmailTab = value);
                      _checkFormValidity();
                    }, isDark),
                    const SizedBox(height: 8),
                    _buildToggleRow(
                        S.of(context).bgfbgt4ry46hj57jhg, showActivityTime,
                        (value) {
                      setState(() => showActivityTime = value);
                      _checkFormValidity();
                    }, isDark),
                    const SizedBox(height: 24),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? WawatDark.textPrimary : Colors.black,
                      ),
                      child: Text(S.of(context).jyntytrk5j34r),
                    ),
                    const SizedBox(height: 12),
                    _buildToggleRow(
                        S.of(context).trbgtvrger56fd, showNewMessages, (value) {
                      setState(() => showNewMessages = value);
                      _checkFormValidity();
                    }, isDark),
                    const SizedBox(height: 8),
                    _buildToggleRow(S.of(context).ger4tr3345, showNewReviews,
                        (value) {
                      setState(() => showNewReviews = value);
                      _checkFormValidity();
                    }, isDark),
                    const SizedBox(height: 8),
                    _buildToggleRow(S.of(context).bfvdeb3gg34, showMarketing,
                        (value) {
                      setState(() => showMarketing = value);
                      _checkFormValidity();
                    }, isDark),
                    Container(
                      height: 50,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isFormValid,
                        builder: (_, isValid, __) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              disabledBackgroundColor:
                                  const Color(0xFF5B4FFF).withOpacity(0.3),
                              backgroundColor: const Color(0xFF5B4FFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            onPressed: isValid ? _addEmployer : null,
                            child: Text(
                              S.of(context).gbd423g54bd,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildDiagnosticsCard(isDark),
            ],
          ),
        );
      },
    );
  }

  /// Диагностика и аналитика.
  ///
  /// Стоит отдельной карточкой и сохраняется мгновенно, без кнопки «Сохранить»:
  /// это локальный выбор устройства, он не уходит на бэкенд вместе с настройками
  /// приватности профиля и не должен зависеть от валидности той формы.
  ///
  /// Наличие этого переключателя — не украшение: без него нельзя заявить
  /// «Data collection is optional» в Google Play Data safety и корректно
  /// ответить на вопросы App Privacy в App Store Connect.
  Widget _buildDiagnosticsCard(bool isDark) {
    return AnimatedBuilder(
      animation: TelemetryConsent.instance,
      builder: (context, _) {
        final consent = TelemetryConsent.instance;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: cCard(isDark),
            borderRadius: BorderRadius.circular(16),
            border: cCardBorder(isDark),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0F7BF4), Color(0xFF0257AE)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.insights_rounded,
                        color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('privacy_diagnostics_title',
                              'Diaqnostika və analitika'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                isDark ? WawatDark.textPrimary : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr('privacy_diagnostics_subtitle',
                              'Tətbiqdəki nasazlıqları tapmağa kömək edir. Reklam üçün istifadə olunmur.'),
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: isDark
                                ? WawatDark.textSecondary
                                : const Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildToggleRow(
                tr('privacy_crash_reports', 'Nasazlıq hesabatları'),
                consent.crashReportsEnabled,
                (value) => consent.setCrashReportsEnabled(value),
                isDark,
              ),
              const SizedBox(height: 8),
              _buildToggleRow(
                tr('privacy_usage_stats', 'İstifadə statistikası'),
                consent.analyticsEnabled,
                (value) => consent.setAnalyticsEnabled(value),
                isDark,
              ),
              const SizedBox(height: 12),
              Text(
                tr('privacy_diagnostics_note',
                    'Şəxsi məlumatlar — telefon, e-poçt və mesajların mətni — göndərilmir.'),
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: isDark ? WawatDark.textMuted : const Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleRow(
      String label, bool value, Function(bool) onChanged, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isDark ? WawatDark.surfaceAlt : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? WawatDark.textPrimary : Colors.black,
            ),
            child: Text(label),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF5B4FFF),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor:
                isDark ? WawatDark.border : const Color(0xFFD1D1D6),
          ),
        ],
      ),
    );
  }

  @override
  PrivacyTabBloc provideBloc() {
    return PrivacyTabBloc();
  }

  void _addEmployer() async {
    final bool finalShowPhoneTab = showPhoneTab;
    final bool finalShowEmailTab = showEmailTab;
    final bool finalShowActivityTime = showActivityTime;
    final bool finalShowNewMessages = showNewMessages;
    final bool finalShowNewReviews = showNewReviews;
    final bool finalShowMarketing = showMarketing;

    bloc
        .privacyProfile(PrivacySettings(
      showPhone: finalShowPhoneTab,
      showEmail: finalShowEmailTab,
      showLastSeen: finalShowActivityTime,
    ))
        .then(
      (onValue) {
        bloc.customersMe();
        showIOSStyleMessage(context, S.of(context).greg5g4g4g3);
      },
    );
    bloc
        .notificationsProfile(NotificationSettings(
      notifyNewMessages: finalShowNewMessages,
      notifyReviews: finalShowNewReviews,
      notifyMarketing: finalShowMarketing,
    ))
        .then(
      (onValue) {
        bloc.customersMe();
      },
    );
  }
}
