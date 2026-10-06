import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../presentation/resourses/wawat_dark.dart';
import 'localization_service.dart';
import 'push_notification_service.dart';

/// Запрос разрешения на уведомления — после осмысленного действия, а не на
/// первом экране.
///
/// На iOS отказ необратим: без разрешения нет APNs-токена, без APNs-токена
/// `getToken()` возвращает null, и устройство навсегда остаётся без пушей
/// (16 живых ios-токенов против 400 android — это именно он). Поэтому диалог
/// показывается только когда пользователю уже понятно, зачем ему уведомления:
/// он разместил объявление, отправил предложение или открыл переписку. Перед
/// системным
/// диалогом показываем свой экран с объяснением — после него соглашаются
/// заметно чаще, а если человек отказал нашему экрану, системный диалог не
/// тратится и его можно будет предложить позже.

/// Повод, по которому спрашиваем — от него зависит текст объяснения.
enum PushPromptTrigger { listingCreated, proposalSent, messageSent }

const _brand = Color(0xFF0271EB);
const _ink900 = Color(0xFF0F172A);
const _ink800 = Color(0xFF1E293B);
const _ink600 = Color(0xFF475569);
const _amber = Color(0xFFB67C00);
const _amber50 = Color(0xFFFEF6E7);

const _promptCountKey = 'push_prompt_count';
const _promptLastMsKey = 'push_prompt_last_ms';

/// Не больше трёх предложений за всю жизнь установки и не чаще раза в 3 дня:
/// иначе это превращается в попрошайничество, и человек жмёт «нет» уже на
/// системном диалоге — то есть навсегда.
const _maxPrompts = 3;
const _promptCooldown = Duration(days: 3);

/// Спрашивает разрешение, если это уместно. Безопасно вызывать часто — сама
/// решает, промолчать или показать объяснение.
Future<void> maybeAskPushPermission(
  BuildContext context,
  PushPromptTrigger trigger,
) async {
  final service = PushNotificationService();
  final status = await service.permissionStatus();

  // Уже разрешено — токен ушёл на бэкенд на старте, делать нечего.
  if (status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional) {
    return;
  }

  // Отказано: системный диалог больше не покажется, что бы мы ни делали.
  // Подсказка со ссылкой в настройки телефона живёт на экране настроек
  // уведомлений — здесь молчим, чтобы не раздражать.
  if (status == AuthorizationStatus.denied) return;

  if (!await _mayAskAgain()) return;
  await _recordAsk();
  if (!context.mounted) return;

  final agreed = await _showExplainer(context, trigger);
  if (agreed != true) return;

  final granted = await service.requestPermission();
  if (granted) {
    // Разрешение только что получено — на iOS это первый момент, когда вообще
    // появляется APNs-токен, поэтому токен отправляем сразу.
    await service.syncToken(reason: 'permission_granted');
  }
}

/// Пользователь отказал в системном диалоге — экран настроек показывает
/// подсказку со ссылкой в настройки телефона.
Future<bool> pushPermissionDenied() async {
  final status = await PushNotificationService().permissionStatus();
  return status == AuthorizationStatus.denied;
}

/// Открывает системные настройки уведомлений приложения.
Future<void> openSystemNotificationSettings() async {
  if (Platform.isIOS) {
    // iOS: единственный разрешённый Apple путь — свой раздел в Настройках.
    await launchUrl(Uri.parse('app-settings:'));
    return;
  }
  try {
    await const MethodChannel('az.buking.buking/notification_settings')
        .invokeMethod<void>('open');
  } on PlatformException catch (_) {
    // Нет такого экрана (очень старый Android) — молча ничего не делаем.
  } on MissingPluginException catch (_) {}
}

/// Системные уведомления выключены — тумблеры в настройках приложения уже
/// ничего не изменят, пока человек не включит их в настройках телефона.
/// Показывается на экране настроек уведомлений, когда [pushPermissionDenied].
class PushPermissionDeniedBanner extends StatelessWidget {
  const PushPermissionDeniedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? WawatDark.warning : _amber;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 14, 12, 2),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A2A12) : _amber50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(PhosphorIconsFill.bellSlash, size: 20, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('notification.system_off_title',
                          'Bildirişlər telefonda söndürülüb'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? WawatDark.textPrimary : _ink800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr(
                        'notification.system_off_body',
                        'Aşağıdaki ayarlar işləməyəcək. Telefonun ayarlarında '
                            'Wawat Air üçün bildirişlərə icazə verin.',
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? WawatDark.textSecondary : _ink600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: openSystemNotificationSettings,
              style: TextButton.styleFrom(
                foregroundColor: accent,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 36),
              ),
              child: Text(
                tr('notification.system_off_action', 'Ayarları aç'),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Только для dev-точки входа lib/dev_push_prompt.dart: забывает, сколько раз
/// мы уже предлагали включить уведомления, чтобы лист можно было показать
/// снова. В обычных экранах не вызывается.
Future<void> resetPushPromptHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_promptCountKey);
  await prefs.remove(_promptLastMsKey);
}

Future<bool> _mayAskAgain() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getInt(_promptCountKey) ?? 0) >= _maxPrompts) return false;
    final last = prefs.getInt(_promptLastMsKey);
    if (last == null) return true;
    final since = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(last));
    return since >= _promptCooldown;
  } catch (_) {
    // Без prefs лучше спросить один раз, чем не спросить никогда.
    return true;
  }
}

Future<void> _recordAsk() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_promptCountKey, (prefs.getInt(_promptCountKey) ?? 0) + 1);
    await prefs.setInt(_promptLastMsKey, DateTime.now().millisecondsSinceEpoch);
  } catch (_) {}
}

String _bodyFor(PushPromptTrigger trigger) {
  switch (trigger) {
    case PushPromptTrigger.listingCreated:
      return tr(
        'push.prompt_body_listing',
        'Elanınıza təklif gələn kimi xəbər verək — cavabı gözləyib səhifəni '
            'yeniləməyə ehtiyac qalmayacaq.',
      );
    case PushPromptTrigger.proposalSent:
      return tr(
        'push.prompt_body_proposal',
        'Təklifinizə cavab gələn kimi xəbər verək — razılaşmanı qaçırmayın.',
      );
    case PushPromptTrigger.messageSent:
      return tr(
        'push.prompt_body_chat',
        'Cavab gələn kimi xəbər verək — mesajı qaçırmayın.',
      );
  }
}

Future<bool?> _showExplainer(
  BuildContext context,
  PushPromptTrigger trigger,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final surface = isDark ? WawatDark.surface : Colors.white;
  final titleColor = isDark ? WawatDark.textPrimary : _ink900;
  final bodyColor = isDark ? WawatDark.textSecondary : _ink600;

  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? WawatDark.divider : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: isDark
                      ? WawatDark.brandChip
                      : const Color(0xFFEAF3FE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsFill.bell,
                  size: 28,
                  color: isDark ? WawatDark.brandText : _brand,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tr('push.prompt_title', 'Bildirişləri aktiv edək?'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _bodyFor(trigger),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.45, color: bodyColor),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(sheetContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? WawatDark.brand : _brand,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  tr('push.prompt_allow', 'Bildirişlərə icazə ver'),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 46,
              child: TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(false),
                child: Text(
                  tr('push.prompt_later', 'Sonra'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: bodyColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
