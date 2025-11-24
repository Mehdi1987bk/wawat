import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/presentation/bloc/error_dispatcher.dart';
import 'package:buking/screens/home/tabs/profile_tab/settings/privacy_tab/privacy_tab_bloc.dart';
import 'package:flutter/material.dart';

import '../../../../../../data/network/request/privacy_settings.dart';

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

class _PrivacyTabState extends BaseState<PrivacyTab, PrivacyTabBloc> with ErrorDispatcher{
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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Приватность и уведомления',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Управляйте видимостью информации',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Приватность',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _buildToggleRow('Показывать телефон', showPhoneTab, (value) {
                setState(() => showPhoneTab = value);
                _checkFormValidity();
              }),
              const SizedBox(height: 8),
              _buildToggleRow('Показывать email', showEmailTab, (value) {
                setState(() => showEmailTab = value);
                _checkFormValidity();
              }),
              const SizedBox(height: 8),
              _buildToggleRow('Показывать время активности', showActivityTime,
                  (value) {
                setState(() => showActivityTime = value);
                _checkFormValidity();
              }),
              const SizedBox(height: 24),
              const Text(
                'Уведомления',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _buildToggleRow('Новые сообщения', showNewMessages, (value) {
                setState(() => showNewMessages = value);
                _checkFormValidity();
              }),
              const SizedBox(height: 8),
              _buildToggleRow('Новые отзывы', showNewReviews, (value) {
                setState(() => showNewReviews = value);
                _checkFormValidity();
              }),
              const SizedBox(height: 8),
              _buildToggleRow('Маркетинговые уведомления', showMarketing,
                  (value) {
                setState(() => showMarketing = value);
                _checkFormValidity();
              }),
              Container(
                height: 50,
                width: double.infinity,
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isFormValid,
                  builder: (_, isValid, __) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor:
                            Color(0xFF5B4FFF).withOpacity(0.3),
                        backgroundColor: const Color(0xFF5B4FFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: isValid ? _addEmployer : null,
                      child: Text(
                        "Сохранить изменения",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
      ],
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF5B4FFF),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD1D1D6),
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

    print('showPhoneTab: $finalShowPhoneTab');
    print('showEmailTab: $finalShowEmailTab');
    print('showActivityTime: $finalShowActivityTime');
    print('showNewMessages: $finalShowNewMessages');
    print('showNewReviews: $finalShowNewReviews');
    print('showMarketing: $finalShowMarketing');

    bloc
        .privacyProfile(PrivacySettings(
      showPhone: finalShowPhoneTab,
      showEmail: finalShowEmailTab,
      showLastSeen: finalShowActivityTime,
      notifyNewMessages: finalShowNewMessages,
      notifyNewReviews: finalShowNewReviews,
      notifyMarketing: finalShowMarketing,
    ))
        .then(
      (onValue) {
          bloc.customersMe();
          showTopSnackbar("Сохранено", "Сохранено", true, context);
      },
    );
   }
}
