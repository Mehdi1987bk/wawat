import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../../main.dart';
import '../../../../../presentation/resourses/wawat_dimensions.dart';
import '../notification/notification_screen.dart';
import 'auth_modal_utils.dart';

Widget BuildHeader(
    BuildContext context, {
      bool isDark = false,
      int unreadCount = 0,
      required VoidCallback onNotificationsReturned,
    }) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: EdgeInsets.all(WawatDimensions.spacingMd),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'asset/mini_logo.png',
          height: 35,
          color: isDark ? Colors.white : null,
          colorBlendMode: isDark ? BlendMode.modulate : null,
        ),

        /// 🔔 Notifications
        GestureDetector(
          onTap: () async {
            final isLogged =
            await sl.get<AuthRepository>().isLogged();

            if (!isLogged) {
              return AuthModalUtils.showAuthRequiredModal(
                context,
              );
            }

            await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => NotificationScreen(),
              ),
            );

            /// 🔥 пользователь вернулся назад
            onNotificationsReturned();
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'asset/notif_aa.png',
                  height: 35,
                  color: isDark ? Colors.white : null,
                  colorBlendMode:
                  isDark ? BlendMode.modulate : null,
                ),
              ),

              /// 🔴 BADGE
              if (unreadCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        width: 2,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 9
                            ? '9+'
                            : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
