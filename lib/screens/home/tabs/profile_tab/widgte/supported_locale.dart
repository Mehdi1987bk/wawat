import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../generated/l10n.dart';

class SupportedLocale {
  final Locale locale;
  final String image;
  final String name;

  SupportedLocale(this.locale, this.image, this.name);
}

List<SupportedLocale> getSupportedLocales(BuildContext context) {
  return [
    SupportedLocale(Locale("ru"), "🇷🇺", S.of(context).rudssian),
    SupportedLocale(Locale("uk"), "🇺🇦", S.of(context).ukrainskiy),
    SupportedLocale(Locale("az"), "🇦🇿", S.of(context).azrbaycan),
    SupportedLocale(Locale("en"), "🇬🇧", S.of(context).english),
    SupportedLocale(Locale("tr"), "🇹🇷", S.of(context).turkish),
  ];
}
