import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../data/flight_auth.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_widgets.dart';

/// `watch/signin` — зачем нужен вход.
///
/// Экран только объясняет и открывает общий вход приложения: своих полей
/// логина у модуля нет. Смотреть рейсы и аэропорты можно гостем — к аккаунту
/// привязано ровно одно: слежение.
class WatchSignInScreen extends StatelessWidget {
  const WatchSignInScreen({super.key, this.onSignedIn});

  final VoidCallback? onSignedIn;

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('watch_title', 'İzləmə'),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: FHeroIntro(
          title: ft('watch_signin_title', 'Uçuşu izləmək üçün daxil ol'),
          message: ft(
            'watch_signin_message',
            'Uçuşlara və limanlara baxmaq üçün giriş lazım deyil — yalnız '
                'izləmə hesaba bağlıdır.',
          ),
        ),
      ),
      slivers: [
        FlightBody(
          children: [
            FCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FCardTitle(ft('watch_signin_what', 'İzləmə nə verir')),
                  FListRow(
                    flat: true,
                    icon: PhosphorIconsFill.arrowsClockwise,
                    title: ft('watch_signin_status', 'Status dəyişəndə'),
                    subtitle: ft(
                      'watch_signin_status_hint',
                      'uçdu · endi · ləğv · yönləndirildi',
                    ),
                    showCaret: false,
                  ),
                  FListRow(
                    flat: true,
                    icon: PhosphorIconsFill.clockCountdown,
                    title: ft('watch_signin_time', 'Vaxt dəyişəndə'),
                    subtitle: ft(
                      'watch_signin_time_hint',
                      '5 dəqiqədən çox fərq olanda',
                    ),
                    showCaret: false,
                  ),
                  FListRow(
                    flat: true,
                    icon: PhosphorIconsFill.doorOpen,
                    title: ft('watch_signin_gate', 'Qapı və terminal'),
                    subtitle: ft(
                      'watch_signin_gate_hint',
                      'dəyişiklik elan olunanda',
                    ),
                    showCaret: false,
                  ),
                  FListRow(
                    flat: true,
                    icon: PhosphorIconsFill.suitcaseRolling,
                    title: ft('watch_signin_belt', 'Baqaj lenti'),
                    subtitle: ft(
                      'watch_signin_belt_hint',
                      'lent nömrəsi məlum olanda',
                    ),
                    showCaret: false,
                  ),
                ],
              ),
            ),
            FPrimaryButton(
              label: ft('sign_in', 'Daxil ol'),
              icon: PhosphorIconsBold.signIn,
              onTap: () => FlightAuth.present(context, onDone: () {
                onSignedIn?.call();
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(true);
                }
              }),
            ),
            FSecondaryButton(
              label: ft('watch_signin_guest', 'Qonaq kimi baxmağa davam et'),
              icon: PhosphorIconsBold.arrowLeft,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ],
    );
  }
}
