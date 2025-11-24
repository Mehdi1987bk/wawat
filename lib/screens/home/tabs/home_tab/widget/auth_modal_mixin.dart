import 'package:flutter/cupertino.dart';

import '../../../../auth/auth_modal/auth_required_modal.dart';
import '../../../../auth/login/login_modal.dart';
import '../../../../auth/registration/registration_modal.dart';

mixin AuthModalMixin {
  void showAuthRequiredModal(BuildContext context) {
    AuthRequiredModal.show(
      context,
      onRegister: () => _showRegistrationModal(context),
      onLogin: () => _showLoginModal(context),
    );
  }

  void _showRegistrationModal(BuildContext context) {
    RegistrationModal.show(
      context,
      onLogin: () => _showLoginModal(context),
    );
  }

  void _showLoginModal(BuildContext context) {
    LoginModal.show(
      context,
      onRegister: () => _showRegistrationModal(context),
    );
  }
}

// Использование:
class AnyScreen extends StatelessWidget with AuthModalMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showAuthRequiredModal(context),
      child: Text('Login'),
    );
  }
}