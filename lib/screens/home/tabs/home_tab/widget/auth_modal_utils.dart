import 'package:flutter/material.dart';
import '../../../../auth/auth_modal/auth_required_modal.dart';
import '../../../../auth/login/login_modal.dart';
import '../../../../auth/registration/registration_modal.dart';

class AuthModalUtils {
  static void showAuthRequiredModal(
      BuildContext context, {
        VoidCallback? onLoginSuccess,
        VoidCallback? onRegisterSuccess,
      }) {
    AuthRequiredModal.show(
      context,
      onRegister: () => _showRegistrationModal(context, onLoginSuccess),
      onLogin: () => _showLoginModal(context, onRegisterSuccess),
    );
  }

  static void _showRegistrationModal(
      BuildContext context,
      VoidCallback? onSuccess,
      ) {
    RegistrationModal.show(
      context,
      onLogin: () => _showLoginModal(context, onSuccess),
    );
  }

  static void _showLoginModal(
      BuildContext context,
      VoidCallback? onSuccess,
      ) {
    LoginModal.show(
      context,
      onRegister: () => _showRegistrationModal(context, onSuccess),
    );
  }
}