import 'package:flutter/widgets.dart';

import '../../services/localization_service.dart';

/// Mix into a kept-alive tab's [State] to re-pull backend-localized data when
/// the user switches the app language.
///
/// The bottom-nav tabs live in an IndexedStack and are never rebuilt on a
/// language change, so any backend text they already fetched (feed labels,
/// package-type names, profile stats, …) would otherwise stay in the old
/// language until a full app restart. This mixin listens to
/// [LocalizationService] and calls [onLocaleChanged] once per genuine switch —
/// not on the initial load or the background ETag refresh (those keep the same
/// locale).
mixin LocaleAwareRefetch<T extends StatefulWidget> on State<T> {
  final LocalizationService _localeService = LocalizationService.instance;
  // Captured at State construction, so the first real switch is detected.
  String _localeSeen = LocalizationService.instance.locale;

  @override
  void initState() {
    super.initState();
    _localeService.addListener(_handleLocaleTick);
  }

  @override
  void dispose() {
    _localeService.removeListener(_handleLocaleTick);
    super.dispose();
  }

  void _handleLocaleTick() {
    final current = _localeService.locale;
    if (current == _localeSeen) return;
    _localeSeen = current;
    if (mounted) onLocaleChanged();
  }

  /// Refetch this tab's backend-localized data. Runs once per language switch.
  void onLocaleChanged();
}
