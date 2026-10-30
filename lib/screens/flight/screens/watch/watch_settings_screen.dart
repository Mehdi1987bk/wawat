import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../data/network/request/notification_settings.dart';
import '../../../../data/network/response/notifications.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../main.dart';
import '../../data/flight_auth.dart';
import '../../data/flight_error.dart';
import '../../flight_shell.dart';
import '../../flight_text.dart';
import '../../ui/flight_states.dart';
import '../../ui/flight_widgets.dart';

/// `watch/settings` — настройки уведомлений.
///
/// Ключи общие с приложением (`PUT /profile/notifications`), поэтому экран
/// отправляет только те, что сам показывает: все поля `sometimes`, остальные
/// настройки человека остаются как были.
///
/// `notify_flights` выключает все девять рейсовых типов сразу — и push, и
/// внутри приложения (§11). Отдельного «в приложении» ключа у сервера нет,
/// поэтому такого тумблера на экране тоже нет.
///
/// Тихие часы задаются парой: один ключ без второго сервер отклоняет (422),
/// а оба пустых значения выключают их совсем.
class WatchSettingsScreen extends StatefulWidget {
  const WatchSettingsScreen({super.key});

  @override
  State<WatchSettingsScreen> createState() => _WatchSettingsScreenState();
}

class _WatchSettingsScreenState extends State<WatchSettingsScreen> {
  final AuthRepository _repository = sl.get<AuthRepository>();

  bool _loading = true;
  bool _saving = false;
  bool _signedIn = true;

  bool _push = true;
  bool _email = true;
  bool _flights = true;
  bool _listings = true;
  String? _quietStart;
  String? _quietEnd;

  bool get _quietEnabled => _quietStart != null && _quietEnd != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!await FlightAuth.signedIn()) {
      if (!mounted) return;
      setState(() {
        _signedIn = false;
        _loading = false;
      });
      return;
    }
    try {
      await _repository.customersMe();
      final user = await _repository.userDetails.first;
      _apply(user.notifications);
    } catch (_) {
      // Значения по умолчанию уже выставлены — экран не должен падать из-за
      // одного запроса.
    } finally {
      if (mounted) {
        setState(() {
          _signedIn = true;
          _loading = false;
        });
      }
    }
  }

  void _apply(Notifications? settings) {
    _push = settings?.notifyPush ?? true;
    _email = settings?.notifyEmail ?? true;
    _flights = settings?.notifyFlights ?? true;
    _listings = settings?.notifyListings ?? true;
    _quietStart = _clean(settings?.quietHoursStart);
    _quietEnd = _clean(settings?.quietHoursEnd);
  }

  String? _clean(String? value) =>
      value == null || value.isEmpty ? null : value;

  @override
  Widget build(BuildContext context) {
    return FlightScaffold(
      title: ft('watch_settings_title', 'Bildiriş ayarları'),
      hero: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: FHeroIntro(
          title: ft('watch_settings_hero', 'Bildirişlər'),
          message: ft(
            'watch_settings_hero_message',
            'Nə vaxt və necə xəbər alacağını seç',
          ),
        ),
      ),
      slivers: [
        FlightBody(children: _body()),
      ],
    );
  }

  List<Widget> _body() {
    if (!_signedIn) {
      return [
        FSignInRequired(
          onSignIn: () => FlightAuth.present(context, onDone: _load),
          title: ft('watch_settings_signin', 'Ayarlar hesaba bağlıdır'),
          message: ft(
            'watch_settings_signin_message',
            'Bildiriş ayarlarını dəyişmək üçün hesaba daxil ol.',
          ),
        ),
      ];
    }
    if (_loading) return const [FCardSkeleton(rows: 3), FCardSkeleton(rows: 3)];
    return [
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCardTitle(ft('watch_settings_how', 'Necə xəbər verək')),
            FToggleRow(
              icon: PhosphorIconsFill.deviceMobile,
              title: ft('watch_settings_push', 'Push bildiriş'),
              subtitle: ft('watch_settings_push_hint', 'Telefona dərhal gəlir'),
              value: _push,
              onChanged: (value) =>
                  _save(NotificationSettings(notifyPush: value),
                      () => _push = value),
            ),
            FToggleRow(
              icon: PhosphorIconsFill.envelopeSimple,
              title: ft('watch_settings_email', 'E-poçt'),
              subtitle: ft(
                'watch_settings_email_hint',
                'Günün yekunu bir məktubda',
              ),
              value: _email,
              last: true,
              onChanged: (value) =>
                  _save(NotificationSettings(notifyEmail: value),
                      () => _email = value),
            ),
          ],
        ),
      ),
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCardTitle(ft('watch_settings_what', 'Nə barədə xəbər verək')),
            FToggleRow(
              icon: PhosphorIconsFill.airplaneTilt,
              title: ft('watch_settings_flights', 'Uçuş bildirişləri'),
              subtitle: ft(
                'watch_settings_flights_hint',
                'İzlədiyim uçuşlarda status, vaxt, qapı, baqaj lenti',
              ),
              value: _flights,
              onChanged: (value) =>
                  _save(NotificationSettings(notifyFlights: value),
                      () => _flights = value),
            ),
            FToggleRow(
              icon: PhosphorIconsFill.megaphone,
              title: ft('watch_settings_listings', 'Elanlarımla bağlı'),
              subtitle: ft(
                'watch_settings_listings_hint',
                'Təsdiq, bitmə vaxtı, uyğun elan',
              ),
              value: _listings,
              last: true,
              onChanged: (value) =>
                  _save(NotificationSettings(notifyListings: value),
                      () => _listings = value),
            ),
          ],
        ),
      ),
      FCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCardTitle(ft('watch_settings_quiet', 'Sakit saatlar')),
            FToggleRow(
              icon: PhosphorIconsFill.moon,
              title: ft('watch_settings_quiet_title', 'Sakit saatlarda push '
                  'göndərmə'),
              subtitle: ft(
                'watch_settings_quiet_hint',
                'Tətbiqin içində yenə görünəcək',
              ),
              value: _quietEnabled,
              last: !_quietEnabled,
              onChanged: _toggleQuiet,
            ),
            if (_quietEnabled)
              FRow(
                ft('watch_settings_quiet_range', 'Vaxt aralığı'),
                value: '${_quietStart ?? '—'} — ${_quietEnd ?? '—'}',
                last: true,
                onTap: _pickQuietRange,
              ),
          ],
        ),
      ),
      if (!_flights)
        FInfoNote(
          ft(
            'watch_settings_flights_off',
            'Uçuş bildirişləri sönülüdür — izlədiyin uçuşlar dəyişsə də '
                'xəbər gəlməyəcək.',
          ),
          icon: PhosphorIconsBold.bellSlash,
        ),
    ];
  }

  Future<void> _toggleQuiet(bool value) async {
    if (value) {
      const start = '23:00';
      const end = '08:00';
      await _save(
        const NotificationSettings(quietHoursStart: start, quietHoursEnd: end),
        () {
          _quietStart = start;
          _quietEnd = end;
        },
      );
      return;
    }
    // Оба ключа пустыми — так тихие часы снимаются; по одному сервер не берёт.
    await _save(
      const NotificationSettings(clearQuietHours: true),
      () {
        _quietStart = null;
        _quietEnd = null;
      },
    );
  }

  Future<void> _pickQuietRange() async {
    final start = await _pickTime(_quietStart ?? '23:00');
    if (!mounted || start == null) return;
    final end = await _pickTime(_quietEnd ?? '08:00');
    if (!mounted || end == null) return;
    await _save(
      NotificationSettings(quietHoursStart: start, quietHoursEnd: end),
      () {
        _quietStart = start;
        _quietEnd = end;
      },
    );
  }

  Future<String?> _pickTime(String current) async {
    final parts = current.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 23,
        minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      ),
    );
    if (picked == null) return null;
    return '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';
  }

  /// Отправляется только изменённый ключ: остальные настройки человека
  /// трогать нельзя, а все поля у эндпоинта необязательные.
  Future<void> _save(NotificationSettings body, VoidCallback apply) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      apply();
    });
    try {
      await _repository.notificationsProfile(body);
      await _repository.customersMe();
      if (!mounted) return;
      setState(() => _saving = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      fToast(
        context,
        FlightError.from(e).display(
          ft('watch_settings_failed', 'Ayar saxlanmadı'),
        ),
      );
      // Вернуть экран к тому, что реально лежит на сервере.
      await _load();
    }
  }
}
