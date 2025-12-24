import 'dart:ui';

class SupportedLocale {
  final Locale locale;
  final String image;
  final String name;

  SupportedLocale(this.locale, this.image, this.name);
}


final supportedLocales = [
  SupportedLocale(Locale("az"), "🇦🇿","Azərbaycan"),
  SupportedLocale(Locale("ru"), "🇷🇺","Русский"),
  SupportedLocale(Locale("en"), "🇬🇧", "English"),
];
// SupportedLocale(Locale("tr"), "🇹🇷", "Turkish"),
