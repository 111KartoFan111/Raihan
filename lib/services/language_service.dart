import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const _prefsKey = 'app_locale_code';
  static final ValueNotifier<Locale?> localeNotifier = ValueNotifier<Locale?>(null);

  static const supportedLocales = [
    Locale('kk'),
    Locale('ru'),
    Locale('en'),
  ];

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null) {
      localeNotifier.value = Locale(code);
    }
  }

  static Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
    localeNotifier.value = locale;
  }
}
