import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../presentation/resourses/theme_colors.dart';
import '../data/flight_error.dart';
import '../flight_text.dart';
import 'flight_tokens.dart';
import 'flight_widgets.dart';

/// Заголовок на небе: крупная строка и пояснение под ней.
class FHeroIntro extends StatelessWidget {
  const FHeroIntro({super.key, required this.title, this.message});

  final String title;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 18, bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 7),
            Text(
              message!,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: FT.onHero(.68),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Общий вид состояния: круглая иконка, строка, объяснение, кнопки.
/// Из него собраны все пустые и ошибочные экраны раздела.
class FStateBlock extends StatelessWidget {
  const FStateBlock({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.tone = FTone.mute,
    this.actions = const [],
    this.extra,
    this.padding = const EdgeInsets.fromLTRB(24, 34, 24, 20),
  });

  final IconData icon;
  final String title;
  final String? message;
  final FTone tone;
  final List<Widget> actions;
  final Widget? extra;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: tone.bg(d),
              borderRadius: FT.rIcon,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 26, color: tone.fg(d)),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: cText(d),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: cText3(d),
              ),
            ),
          ],
          if (extra != null) ...[
            const SizedBox(height: 16),
            extra!,
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 18),
            for (var i = 0; i < actions.length; i++) ...[
              if (i != 0) const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: actions[i]),
            ],
          ],
        ],
      ),
    );
  }
}

/// §4.3 — `data: null` + `meta.unavailable_reason`.
///
/// Это **не** ошибка: такого вида данных у этого аэропорта или рейса нет в
/// принципе. Экран спокойный, своей фразой; английский текст провайдера
/// пользователю не показывается — он только в журнале.
class FCalmEmpty extends StatelessWidget {
  const FCalmEmpty({
    super.key,
    required this.title,
    this.message,
    this.icon = PhosphorIconsFill.cloudSlash,
    this.onFeeds,
  });

  final String title;
  final String? message;
  final IconData icon;

  /// «Какой источник не работает?» → `GET /airports/{code}/feeds`.
  final VoidCallback? onFeeds;

  @override
  Widget build(BuildContext context) {
    return FStateBlock(
      icon: icon,
      title: title,
      message: message,
      actions: [
        if (onFeeds != null)
          FGhostButton(
            label: ft('which_source', 'Hansı mənbə işləmir?'),
            icon: PhosphorIconsBold.pulse,
            onTap: onFeeds,
          ),
      ],
    );
  }
}

/// `200` + `data: []` — ничего не найдено. Тоже не ошибка.
class FEmptyResult extends StatelessWidget {
  const FEmptyResult({
    super.key,
    required this.title,
    this.message,
    this.icon = PhosphorIconsFill.magnifyingGlass,
    this.actions = const [],
  });

  final String title;
  final String? message;
  final IconData icon;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => FStateBlock(
        icon: icon,
        title: title,
        message: message,
        actions: actions,
      );
}

/// `503 FLIGHT_DATA_UNAVAILABLE` — единственная настоящая ошибка данных.
/// Кэша в этом случае нет, поэтому «продолжить с кэшем» не предлагается.
class FServiceDown extends StatelessWidget {
  const FServiceDown({
    super.key,
    this.onRetry,
    this.onFeeds,
    this.title,
    this.message,
    this.extra,
  });

  final VoidCallback? onRetry;
  final VoidCallback? onFeeds;
  final String? title;
  final String? message;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return FStateBlock(
      icon: PhosphorIconsFill.cloudWarning,
      tone: FTone.bad,
      title: title ?? ft('service_down_title', 'Uçuş məlumatı hazırda gəlmir'),
      message: message ??
          ft(
            'service_down_text',
            'Mənbə cavab vermir və yaddaşda da heç nə yoxdur. '
                'Bir neçə dəqiqə sonra yenidən yoxla.',
          ),
      extra: extra,
      actions: [
        if (onRetry != null)
          FPrimaryButton(
            label: ft('retry', 'Yenidən cəhd et'),
            icon: PhosphorIconsBold.arrowsClockwise,
            onTap: onRetry,
          ),
        if (onFeeds != null)
          FGhostButton(
            label: ft('which_source', 'Hansı mənbə işləmir?'),
            icon: PhosphorIconsBold.pulse,
            onTap: onFeeds,
          ),
      ],
    );
  }
}

/// `429 RATE_LIMITED` — отсчёт из `retry_after`; кнопка заблокирована до нуля.
///
/// Кнопка «продолжить с прошлым ответом» появляется только если приложение
/// само его держит: в самом 429 ни данных, ни кэша нет.
class FThrottled extends StatefulWidget {
  const FThrottled({
    super.key,
    required this.seconds,
    this.onRetry,
    this.onBack,
    this.onUseCache,
  });

  final int seconds;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;
  final VoidCallback? onUseCache;

  @override
  State<FThrottled> createState() => _FThrottledState();
}

class _FThrottledState extends State<FThrottled> {
  late int _left = widget.seconds < 0 ? 0 : widget.seconds;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(FThrottled old) {
    super.didUpdateWidget(old);
    if (old.seconds != widget.seconds) {
      _left = widget.seconds < 0 ? 0 : widget.seconds;
      _start();
    }
  }

  void _start() {
    _ticker?.cancel();
    if (_left <= 0) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _left = _left > 0 ? _left - 1 : 0);
      if (_left == 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = _left <= 0;
    return FStateBlock(
      icon: PhosphorIconsFill.hourglassMedium,
      tone: FTone.warn,
      title: ft('throttled_title', 'Çox tez sorğu göndərilir'),
      message: ready
          ? ft('throttled_ready', 'Artıq yenidən cəhd edə bilərsən.')
          : ft(
              'throttled_text',
              'Limit bərpa olunana qədər {n} saniyə qalıb. '
                  'Bu müddətdə yeni sorğu göndərilmir.',
              {'n': '$_left'},
            ),
      actions: [
        FPrimaryButton(
          label: ready
              ? ft('retry', 'Yenidən cəhd et')
              : ft('throttled_retry_in', '{n} san sonra yenidən cəhd et',
                  {'n': '$_left'}),
          icon: PhosphorIconsBold.clock,
          onTap: ready ? widget.onRetry : null,
        ),
        if (widget.onUseCache != null)
          FGhostButton(
            label: ft('use_cached', 'Əvvəlki cavabla davam et'),
            icon: PhosphorIconsBold.clockCounterClockwise,
            onTap: widget.onUseCache,
          ),
        if (widget.onBack != null)
          FSecondaryButton(
            label: ft('go_back', 'Geri qayıt'),
            icon: PhosphorIconsBold.arrowLeft,
            onTap: widget.onBack,
          ),
      ],
    );
  }
}

/// `401 UNAUTHENTICATED` — приходит только на эндпоинтах слежения.
class FSignInRequired extends StatelessWidget {
  const FSignInRequired({
    super.key,
    required this.onSignIn,
    this.title,
    this.message,
  });

  final VoidCallback onSignIn;
  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) => FStateBlock(
        icon: PhosphorIconsFill.userCircle,
        tone: FTone.info,
        title: title ?? ft('signin_title', 'Hesaba daxil ol'),
        message: message ??
            ft(
              'signin_text',
              'Uçuş izləmək və xəbərdarlıq qurmaq üçün hesab lazımdır.',
            ),
        actions: [
          FPrimaryButton(
            label: ft('signin_action', 'Daxil ol'),
            icon: PhosphorIconsBold.signIn,
            onTap: onSignIn,
          ),
        ],
      );
}

/// `404 NOT_FOUND` — мягкая ошибка: проверить номер и дату.
class FNotFound extends StatelessWidget {
  const FNotFound({
    super.key,
    required this.title,
    this.message,
    this.actions = const [],
  });

  final String title;
  final String? message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => FStateBlock(
        icon: PhosphorIconsFill.magnifyingGlassMinus,
        title: title,
        message: message,
        actions: actions,
      );
}

/// Нет связи или таймаут. По правилу приложения это предупреждение, а не
/// ошибка: источник тут не при чём.
class FNoConnection extends StatelessWidget {
  const FNoConnection({super.key, this.onRetry, this.message});

  final VoidCallback? onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) => FStateBlock(
        icon: PhosphorIconsFill.wifiSlash,
        tone: FTone.warn,
        title: ft('offline_title', 'Bağlantı yoxdur'),
        message: message ??
            ft('offline_text', 'İnternet bağlantısını yoxla və yenidən cəhd et.'),
        actions: [
          if (onRetry != null)
            FPrimaryButton(
              label: ft('retry', 'Yenidən cəhd et'),
              icon: PhosphorIconsBold.arrowsClockwise,
              onTap: onRetry,
            ),
        ],
      );
}

/// Разводит [FlightError] по экранам §12 — одной строкой на каждом экране,
/// чтобы ни один не придумал свою трактовку.
class FErrorView extends StatelessWidget {
  const FErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.onSignIn,
    this.onFeeds,
    this.onBack,
    this.onUseCache,
    this.notFoundTitle,
    this.notFoundMessage,
    this.notFoundActions = const [],
  });

  final FlightError error;
  final VoidCallback? onRetry;
  final VoidCallback? onSignIn;
  final VoidCallback? onFeeds;
  final VoidCallback? onBack;
  final VoidCallback? onUseCache;
  final String? notFoundTitle;
  final String? notFoundMessage;
  final List<Widget> notFoundActions;

  @override
  Widget build(BuildContext context) {
    if (error.isRateLimited) {
      return FThrottled(
        seconds: error.retrySeconds,
        onRetry: onRetry,
        onBack: onBack,
        onUseCache: onUseCache,
      );
    }
    if (error.isUnauthenticated && onSignIn != null) {
      return FSignInRequired(onSignIn: onSignIn!);
    }
    if (error.isNotFound) {
      return FNotFound(
        title: notFoundTitle ?? ft('not_found_title', 'Tapılmadı'),
        message: notFoundMessage ??
            (error.api.hasMessage
                ? error.api.message
                : ft('not_found_text', 'Nömrəni və tarixi yoxla.')),
        actions: notFoundActions,
      );
    }
    if (error.isNetwork) {
      return FNoConnection(onRetry: onRetry);
    }
    if (error.isServiceDown) {
      return FServiceDown(onRetry: onRetry, onFeeds: onFeeds);
    }
    // Остальное — сообщение сервера как есть, без своей выдумки.
    return FStateBlock(
      icon: PhosphorIconsFill.warningCircle,
      tone: FTone.bad,
      title: ft('error_title', 'Alınmadı'),
      message: error.display(),
      actions: [
        if (onRetry != null)
          FPrimaryButton(
            label: ft('retry', 'Yenidən cəhd et'),
            icon: PhosphorIconsBold.arrowsClockwise,
            onTap: onRetry,
          ),
      ],
    );
  }
}

/// Скелет списка — пока идёт первый запрос.
class FListSkeleton extends StatelessWidget {
  const FListSkeleton({super.key, this.rows = 4});

  final int rows;

  @override
  Widget build(BuildContext context) {
    final d = fDark(context);
    return Column(
      children: [
        for (var i = 0; i < rows; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == rows - 1 ? 0 : 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: cCard(d),
                borderRadius: FT.rField,
                border: Border.all(color: cLine(d)),
              ),
              child: Row(
                children: [
                  const FSkeleton(height: 36, width: 36, radius: 14),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        FSkeleton(height: 12, width: 140),
                        SizedBox(height: 7),
                        FSkeleton(height: 10, width: 90),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Скелет карточки.
class FCardSkeleton extends StatelessWidget {
  const FCardSkeleton({super.key, this.rows = 4});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: Column(
        children: [
          for (var i = 0; i < rows; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: const [
                  FSkeleton(height: 11, width: 90),
                  Spacer(),
                  FSkeleton(height: 11, width: 60),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
