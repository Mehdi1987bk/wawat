import 'package:flutter/material.dart';

import 'login_screen.dart';

class LoginModal extends StatelessWidget {
  final VoidCallback onRegister;

  const LoginModal({
    Key? key,
    required this.onRegister,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoginScreen(onRegister: onRegister);
  }

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onRegister,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => LoginScreen(onRegister: onRegister),
      ),
    );
  }
}
