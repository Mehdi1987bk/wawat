import 'package:buking/presentation/bloc/base_screen.dart';
import 'package:buking/screens/home/tabs/profile_tab/privacy_policy/privacy_policy_bloc.dart';
import 'package:flutter/material.dart';

import '../../../../../data/network/response/privacy_policy_response.dart';

class PrivacyPolicyScreen extends BaseScreen {
  PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState
    extends BaseState<PrivacyPolicyScreen, PrivacyPolicyBloc> {
  @override
  Widget body() {
    return FutureBuilder<PrivacyPolicyResponse>(
      future: bloc.privacyPolicy(),
      builder: (context, snapshot) {
        return Placeholder();
      }
    );
  }

  @override
  PrivacyPolicyBloc provideBloc() {
    return PrivacyPolicyBloc();
  }
}
