import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const supported = ['kk', 'ru', 'en'];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _strings = {
    'ru': {
      'title': 'Undeme',
      'sos_title': 'Экстренный SOS',
      'sos_hint': 'Нажмите, чтобы отправить местоположение экстренным контактам',
      'your_contacts': 'Ваши экстренные контакты:',
      'no_contacts': 'Контакты не добавлены. Добавьте их в профиле.',
      'add_contacts': 'Добавить контакты',
      'info_location': 'Ваше местоположение будет автоматически отправлено при активации SOS.',
      'settings': 'Настройки приложения',
      'language': 'Язык / Тіл / Language',
      'add_contact': 'Добавить контакт',
      'edit': 'Изменить',
      'remove': 'Удалить',
    },
    'kk': {
      'title': 'Undeme',
      'sos_title': 'Шұғыл SOS',
      'sos_hint': 'Орныңызды төтенше контактарға жіберу үшін басыңыз',
      'your_contacts': 'Сіздің төтенше контактарыңыз:',
      'no_contacts': 'Контакттар жоқ. Профильде қосыңыз.',
      'add_contacts': 'Контакттар қосу',
      'info_location': 'SOS белсендірілгенде орналасу автоматты түрде жіберіледі.',
      'settings': 'Қолданба баптаулары',
      'language': 'Тіл / Язык / Language',
      'add_contact': 'Контакт қосу',
      'edit': 'Өңдеу',
      'remove': 'Жою',
    },
    'en': {
      'title': 'Undeme',
      'sos_title': 'Emergency SOS',
      'sos_hint': 'Tap to send your location to emergency contacts',
      'your_contacts': 'Your emergency contacts:',
      'no_contacts': 'No contacts yet. Add them in Profile.',
      'add_contacts': 'Add contacts',
      'info_location': 'Your location will be sent automatically when SOS is activated.',
      'settings': 'App settings',
      'language': 'Language / Тіл / Язык',
      'add_contact': 'Add contact',
      'edit': 'Edit',
      'remove': 'Remove',
    },
  };

  String t(String key) {
    final lang = locale.languageCode;
    final map = _strings[lang] ?? _strings['en']!;
    return map[key] ?? key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supported.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
