import 'package:flutter/widgets.dart';

import '../../services/localization_service.dart';

mixin LocaleAwareRefetch<T extends StatefulWidget> on State<T> {
  final LocalizationService _localeService = LocalizationService.instance;
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

  void onLocaleChanged();
}
