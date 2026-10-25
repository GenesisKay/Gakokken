import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/services/locale_service.dart';
import 'core/services/scaffold_messenger_service.dart';
import 'core/services/theme_service.dart';
import 'l10n/app_localizations.dart';
import 'screens/main_screen.dart';

class GakokenApp extends StatefulWidget {
  const GakokenApp({super.key});

  @override
  State<GakokenApp> createState() => _GakokenAppState();
}

class _GakokenAppState extends State<GakokenApp> {
  final ThemeService _themeService = ThemeService();
  final LocaleService _localeService = LocaleService();

  @override
  void initState() {
    super.initState();
    _themeService.initialize();
    _localeService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_themeService, _localeService]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Gakoken',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.light,
          theme: _themeService.currentThemeData,
          scaffoldMessengerKey: ScaffoldMessengerService.messengerKey,
          locale: _localeService.currentLocale,
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            if (deviceLocale == null) {
              return const Locale('en');
            }
            for (final locale in supportedLocales) {
              if (locale.languageCode == deviceLocale.languageCode &&
                  locale.countryCode == deviceLocale.countryCode) {
                return locale;
              }
            }
            for (final locale in supportedLocales) {
              if (locale.languageCode == deviceLocale.languageCode) {
                return locale;
              }
            }
            return const Locale('en');
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'MX'),
            Locale('es'),
            Locale('en', 'US'),
            Locale('en'),
            Locale('ja'),
            Locale('fr'),
          ],
          home: const MainScreen(),
        );
      },
    );
  }
}
