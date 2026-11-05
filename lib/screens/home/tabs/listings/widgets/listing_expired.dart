import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../data/network/response/listing_response.dart';
import '../../../../../presentation/resourses/wawat_dark.dart';
import '../../../../../services/localization_service.dart';

/// Вид просроченного объявления (`is_expired == true`) — общий для карточки
/// в ленте и экрана деталей.
///
/// Просроченное объявление не прячется и не пересортировывается: сервер сам
/// ставит его после живых. Клиент только приглушает его и убирает кнопку
/// предложения — на просроченное сервер предложение всё равно не примет.

/// Подпись плашки. Текст всегда серверный: `status_label`, а в первые
/// минуты после вылета, пока крон ещё не перевёл `status` в `expired`
/// (и `status_label` всё ещё «Активно»), — CMS-ключ того же статуса.
String listingExpiredLabel(Listing listing) {
  final serverLabel = listing.statusLabel?.trim() ?? '';
  if (listing.status == 'expired' && serverLabel.isNotEmpty) {
    return serverLabel;
  }
  return tr('enum.listing_status.expired', 'Vaxtı keçib');
}

/// Запасные переводы для полосы «срок истёк», пока бэкенд не добавил
/// ключ `listing.expired_notice` в CMS (заявка — docs/i18n-new-keys.json).
/// Как только ключ появится в `/content`, `tr()` отдаст текст из CMS.
const Map<String, String> _expiredNoticeFallbacks = {
  'az': 'Bu elanın vaxtı keçib',
  'en': 'This listing has expired',
  'ru': 'Срок этого объявления истёк',
  'tr': 'Bu ilanın süresi doldu',
  'ua': 'Термін цього оголошення минув',
  'es': 'Este anuncio ha caducado',
};

/// Текст неактивной полосы на экране деталей вместо кнопки предложения.
String listingExpiredNotice() {
  final locale = LocalizationService.instance.locale;
  return tr(
    'listing.expired_notice',
    _expiredNoticeFallbacks[locale] ?? _expiredNoticeFallbacks['az']!,
  );
}

/// Обесцвечивание фото и аватара (коэффициенты яркости Rec. 709).
const ColorFilter listingGrayscaleFilter = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
]);

/// Оборачивает [child] в обесцвечивание, когда [enabled].
class ListingGrayscale extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const ListingGrayscale({
    super.key,
    required this.enabled,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return ColorFiltered(colorFilter: listingGrayscaleFilter, child: child);
  }
}

/// Плашка статуса просроченного объявления: часы с обратным отсчётом +
/// подпись с сервера. Всегда в полную непрозрачность — приглушается
/// содержимое карточки, а не сама плашка.
class ListingExpiredPill extends StatelessWidget {
  final String label;

  const ListingExpiredPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? WawatDark.textSecondary : const Color(0xFF475569);
    final background = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFF0F172A).withValues(alpha: 0.10);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIconsFill.clockCountdown, color: foreground, size: 13),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 10.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
