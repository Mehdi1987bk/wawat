import 'package:flutter/material.dart';

import 'registration_screen.dart';

class RegistrationModal extends StatelessWidget {
  final VoidCallback onLogin;

  const RegistrationModal({
    Key? key,
    required this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RegistrationScreen(onLogin: onLogin);
  }

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onLogin,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => RegistrationScreen(onLogin: onLogin),
      ),
    );
  }
}
