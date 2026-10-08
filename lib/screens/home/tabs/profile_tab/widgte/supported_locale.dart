import 'dart:ui';
import 'package:buking/services/localization_service.dart';
import 'package:flutter/material.dart';

class SupportedLocale {
  final Locale locale;
  final String image;
  final String name;

  SupportedLocale(this.locale, this.image, this.name);
}

List<SupportedLocale> getSupportedLocales(BuildContext context) {
  return [
    SupportedLocale(Locale("ru"), "🇷🇺", t('common.lang_ru')),
    SupportedLocale(Locale("uk"), "🇺🇦", t('common.lang_ua')),
    SupportedLocale(Locale("az"), "🇦🇿", t('common.lang_az')),
    SupportedLocale(Locale("en"), "🇬🇧", t('common.lang_en')),
    SupportedLocale(Locale("tr"), "🇹🇷", t('common.lang_tr')),
  ];
}
