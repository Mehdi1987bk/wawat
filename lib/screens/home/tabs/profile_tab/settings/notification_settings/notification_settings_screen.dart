import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../../data/network/request/notification_settings.dart';
import '../../../../../../data/network/response/notifications.dart';
import '../../../../../../domain/repositories/auth_repository.dart';
import '../../../../../../main.dart';

const _brand = Color(0xFF0271EB);
const _brand50 = Color(0xFFEAF3FE);
const _ink900 = Color(0xFF0F172A);
const _ink800 = Color(0xFF1E293B);
const _ink700 = Color(0xFF334155);
const _ink600 = Color(0xFF475569);
const _ink500 = Color(0xFF64748B);
const _ink400 = Color(0xFF94A3B8);
const _screenBg = Color(0xFFF6F8FB);
const _amber = Color(0xFFB67C00);
const _amber50 = Color(0xFFFEF6E7);

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final AuthRepository _repository = sl.get<AuthRepository>();
  bool _loading = true;
  bool _saving = false;

  bool notifyPush = true;
  bool notifyEmail = true;
  bool notifyNewMessages = true;
  bool notifyShipments = true;
  bool notifyListings = true;
  bool notifyReviews = true;
  bool notifyFollows = true;
  bool notifySavedSearch = true;
  bool notifyMarketing = false;
  String? quietHoursStart;
  String? quietHoursEnd;

  bool get quietEnabled => quietHoursStart != null && quietHoursEnd != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await _repository.customersMe();
      final user = await _repository.userDetails.first;
      _apply(user.notifications);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _apply(Notifications? settings) {
    notifyPush = settings?.notifyPush ?? true;
    notifyEmail = settings?.notifyEmail ?? true;
    notifyNewMessages = settings?.notifyNewMessages ?? true;
    notifyShipments = settings?.notifyShipments ?? true;
    notifyListings = settings?.notifyListings ?? true;
    notifyReviews = settings?.notifyReviews ?? true;
    notifyFollows = settings?.notifyFollows ?? true;
    notifySavedSearch = settings?.notifySavedSearch ?? true;
    notifyMarketing = settings?.notifyMarketing ?? false;
    quietHoursStart = settings?.quietHoursStart;
    quietHoursEnd = settings?.quietHoursEnd;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _screenBg,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(onBack: () => Navigator.of(context).maybePop()),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: _brand),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 26),
                        children: [
                          const _GroupHeader('Kanallar'),
                          _SettingsCard(
                            children: [
                              _SettingRow(
                                icon: PhosphorIconsFill.deviceMobile,
                                title: 'Push bildirişlər',
                                subtitle: 'Telefona anında bildiriş',
                                value: notifyPush,
                                onChanged: (value) =>
                                    _update(notifyPush: value),
                              ),
                              _SettingRow(
                                icon: PhosphorIconsFill.envelopeSimple,
                                title: 'E-poçt',
                                subtitle: 'Vacib yeniliklər e-poçtla',
                                value: notifyEmail,
                                onChanged: (value) =>
                                    _update(notifyEmail: value),
                                isLast: true,
                              ),
                            ],
                          ),
                          const _GroupHeader('Kateqoriyalar'),
                          _SettingsCard(
                            children: [
                              _SettingRow(
                                icon: PhosphorIconsFill.handshake,
                                title: 'Sövdələşmə & təkliflər',
                                subtitle: 'Təklif, çatdırılma, sifariş',
                                value: notifyShipments,
                                onChanged: (value) =>
                                    _update(notifyShipments: value),
                              ),
                              _SettingRow(
                                icon: PhosphorIconsFill.airplaneTilt,
                                title: 'Elanlar',
                                subtitle: 'Təsdiq, rədd, vaxt, uyğun elan',
                                value: notifyListings,
                                onChanged: (value) =>
                                    _update(notifyListings: value),
                              ),
                              _SettingRow(
                                icon: PhosphorIconsFill.chatCircle,
                                title: 'Mesajlar',
                                subtitle: 'Yeni və cavabsız mesajlar',
                                value: notifyNewMessages,
                                onChanged: (value) =>
                                    _update(notifyNewMessages: value),
                              ),
                              _SettingRow(
                                icon: PhosphorIconsFill.star,
                                iconColor: _amber,
                                iconBg: _amber50,
                                title: 'Rəylər',
                                subtitle: 'Yeni rəy və xatırlatma',
                                value: notifyReviews,
                                onChanged: (value) =>
                                    _update(notifyReviews: value),
                              ),
                              _SettingRow(
                                icon: PhosphorIconsFill.userPlus,
                                title: 'İzləmə',
                                subtitle: 'Yeni izləyici və elanları',
                                value: notifyFollows,
                                onChanged: (value) =>
                                    _update(notifyFollows: value),
                              ),
                              _SettingRow(
                                icon: PhosphorIconsFill.bookmarkSimple,
                                title: 'Saxlanan axtarışlar',
                                subtitle: 'Axtarışınıza uyğun yeni elan',
                                value: notifySavedSearch,
                                onChanged: (value) =>
                                    _update(notifySavedSearch: value),
                              ),
                              _SettingRow(
                                icon: PhosphorIconsFill.megaphone,
                                title: 'Yeniliklər & təkliflər',
                                subtitle: 'Kampaniya və elanlar',
                                value: notifyMarketing,
                                onChanged: (value) =>
                                    _update(notifyMarketing: value),
                                isLast: true,
                              ),
                            ],
                          ),
                          const _GroupHeader('Sakit saatlar'),
                          _SettingsCard(
                            children: [
                              _SettingRow(
                                icon: PhosphorIconsFill.moon,
                                iconColor: _ink500,
                                iconBg: _ink900.withValues(alpha: 0.05),
                                title: 'Push-u sakitləşdir',
                                subtitle: 'Seçilən saatlarda push gəlməz',
                                value: quietEnabled,
                                onChanged: (value) => value
                                    ? _update(
                                        quietHoursStart: quietHoursStart ??
                                            const _TimeOfDay(23, 0).label,
                                        quietHoursEnd: quietHoursEnd ??
                                            const _TimeOfDay(8, 0).label,
                                      )
                                    : _update(
                                        quietHoursStart: '',
                                        quietHoursEnd: '',
                                        clearQuietHours: true,
                                      ),
                              ),
                              _QuietHoursRow(
                                start: quietHoursStart ?? '23:00',
                                end: quietHoursEnd ?? '08:00',
                                enabled: quietEnabled,
                                onStartTap: () => _pickQuietTime(true),
                                onEndTap: () => _pickQuietTime(false),
                              ),
                            ],
                          ),
                          const _CriticalNote(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickQuietTime(bool isStart) async {
    if (!quietEnabled) return;
    final current = _parseTime(isStart ? quietHoursStart : quietHoursEnd) ??
        (isStart
            ? const TimeOfDay(hour: 23, minute: 0)
            : const TimeOfDay(hour: 8, minute: 0));
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _brand),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: _brand),
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked == null) return;
    final value = _formatTime(picked);
    if (isStart) {
      await _update(quietHoursStart: value);
    } else {
      await _update(quietHoursEnd: value);
    }
  }

  Future<void> _update({
    bool? notifyPush,
    bool? notifyEmail,
    bool? notifyNewMessages,
    bool? notifyShipments,
    bool? notifyListings,
    bool? notifyReviews,
    bool? notifyFollows,
    bool? notifySavedSearch,
    bool? notifyMarketing,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool clearQuietHours = false,
  }) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      if (notifyPush != null) this.notifyPush = notifyPush;
      if (notifyEmail != null) this.notifyEmail = notifyEmail;
      if (notifyNewMessages != null) this.notifyNewMessages = notifyNewMessages;
      if (notifyShipments != null) this.notifyShipments = notifyShipments;
      if (notifyListings != null) this.notifyListings = notifyListings;
      if (notifyReviews != null) this.notifyReviews = notifyReviews;
      if (notifyFollows != null) this.notifyFollows = notifyFollows;
      if (notifySavedSearch != null) this.notifySavedSearch = notifySavedSearch;
      if (notifyMarketing != null) this.notifyMarketing = notifyMarketing;
      if (clearQuietHours) {
        this.quietHoursStart = null;
        this.quietHoursEnd = null;
      } else {
        this.quietHoursStart = quietHoursStart ?? this.quietHoursStart;
        this.quietHoursEnd = quietHoursEnd ?? this.quietHoursEnd;
      }
    });

    try {
      await _repository.notificationsProfile(
        NotificationSettings(
          notifyPush: notifyPush,
          notifyEmail: notifyEmail,
          notifyNewMessages: notifyNewMessages,
          notifyShipments: notifyShipments,
          notifyListings: notifyListings,
          notifyReviews: notifyReviews,
          notifyFollows: notifyFollows,
          notifySavedSearch: notifySavedSearch,
          notifyMarketing: notifyMarketing,
          quietHoursStart: clearQuietHours ? null : quietHoursStart,
          quietHoursEnd: clearQuietHours ? null : quietHoursEnd,
          clearQuietHours: clearQuietHours,
        ),
      );
      await _repository.customersMe();
      _showSaved();
    } catch (e) {
      _showError(e.toString());
      await _load();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSaved() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ayarlar saxlandı.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1200),
        backgroundColor: const Color(0xFF10B981),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onBack,
            child: const Icon(
              PhosphorIconsBold.arrowLeft,
              color: _ink700,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Bildiriş ayarları',
              style: TextStyle(
                color: _ink900,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;

  const _GroupHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: _ink400,
          fontSize: 11,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _ink900.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool value;
  final bool isLast;
  final ValueChanged<bool> onChanged;

  const _SettingRow({
    required this.icon,
    this.iconColor = _brand,
    this.iconBg = _brand50,
    required this.title,
    required this.subtitle,
    required this.value,
    this.isLast = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: _ink900.withValues(alpha: 0.05)),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _ink900,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _ink400,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            _Switch(value: value),
          ],
        ),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final bool value;

  const _Switch({required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 44,
      height: 24,
      padding: const EdgeInsets.all(2),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: value ? _brand : _ink900.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _QuietHoursRow extends StatelessWidget {
  final String start;
  final String end;
  final bool enabled;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;

  const _QuietHoursRow({
    required this.start,
    required this.end,
    required this.enabled,
    required this.onStartTap,
    required this.onEndTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Başlanğıc — son',
                style: TextStyle(
                  color: _ink600,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _TimeChip(label: start, onTap: onStartTap),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('—', style: TextStyle(color: _ink400)),
            ),
            _TimeChip(label: end, onTap: onEndTap),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TimeChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _ink900.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: _ink800,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CriticalNote extends StatelessWidget {
  const _CriticalNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ink900.withValues(alpha: 0.06)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIconsFill.lockSimple, color: _ink400, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hesab və təhlükəsizlik bildirişləri (giriş, parol, təsdiq, xəbərdarlıq) həmişə göndərilir və söndürülə bilməz.',
              style: TextStyle(
                color: _ink500,
                fontSize: 12.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeOfDay {
  final int hour;
  final int minute;

  const _TimeOfDay(this.hour, this.minute);

  String get label =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

TimeOfDay? _parseTime(String? value) {
  if (value == null || !value.contains(':')) return null;
  final parts = value.split(':');
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

String _formatTime(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
