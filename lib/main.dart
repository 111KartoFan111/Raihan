import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/law_code_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'services/language_service.dart';
import 'services/settings_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Инициализируем AuthService и LanguageService (не блокируем запуск)
  try {
    await Future.wait([
      AuthService.init(),
      LanguageService.load(),
      SettingsService.load(),
    ]).timeout(const Duration(milliseconds: 500));
  } catch (_) {}
  runApp(const UndemeApp());
}

class UndemeApp extends StatelessWidget {
  const UndemeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: LanguageService.localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'Undeme',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
            useMaterial3: true,
          ),
          locale: locale,
          supportedLocales: const [Locale('kk'), Locale('ru'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            AppLocalizations.delegate,
          ],
          routes: {
            '/': (_) => const HomeScreen(),
            '/map': (_) => const MapScreen(),
            '/chat': (_) => const ChatScreen(),
            '/laws': (_) => const LawCodeScreen(),
            '/profile': (_) => const ProfileScreen(),
          },
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      },
    );
  }

Future<void> openExternalMaps(String query) async {
  final encoded = Uri.encodeComponent(query);
  final google = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
  if (await canLaunchUrl(google)) {
    await launchUrl(google, mode: LaunchMode.externalApplication);
  }
}
}