import 'package:flutter/material.dart';

import 'auth_welcome_screen.dart';

class AuthRequiredModal extends StatelessWidget {
  final VoidCallback onRegister;
  final VoidCallback onLogin;

  const AuthRequiredModal({
    Key? key,
    required this.onRegister,
    required this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthWelcomeScreen(
      onRegister: onRegister,
      onLogin: onLogin,
    );
  }

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onRegister,
    required VoidCallback onLogin,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => AuthWelcomeScreen(
          onRegister: onRegister,
          onLogin: onLogin,
        ),
      ),
    );
  }
}
