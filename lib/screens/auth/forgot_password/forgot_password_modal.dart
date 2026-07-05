import 'package:flutter/material.dart';

import 'forgot_password_screen.dart';

class ForgotPasswordModal extends StatelessWidget {
  const ForgotPasswordModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ForgotPasswordScreen();
  }

  static Future<void> show(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
    );
  }
}
