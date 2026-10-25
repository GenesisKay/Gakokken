import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'dart:ui' as ui;

import '../storage/hive_bootstrap.dart';

class LocaleService extends ChangeNotifier {
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();

  static const String _key = 'locale';

  Locale _locale = const Locale('en', 'US');

  Locale get currentLocale => _locale;

  Future<void> initialize() async {
    final box = Hive.box(HiveBootstrap.settingsBox);
    final String? savedLocaleCode = box.get(_key);

    if (savedLocaleCode != null) {
      _locale = _parseLocale(savedLocaleCode);
      // Migrate removed locales (de/it) to English.
      if (_locale.languageCode == 'de' || _locale.languageCode == 'it') {
        _locale = const Locale('en', 'US');
        await box.put(_key, 'en_US');
      }
    } else {
      final systemLocale = ui.PlatformDispatcher.instance.locale;

      // Use device language when supported; otherwise fallback to English.
      if (systemLocale.languageCode == 'en') {
        _locale = const Locale('en');
      } else if (systemLocale.languageCode == 'es') {
        // If the device is set to Mexico, prefer es_MX; otherwise use generic Spanish.
        _locale = systemLocale.countryCode == 'MX'
            ? const Locale('es', 'MX')
            : const Locale('es');
      } else if (['ja', 'fr'].contains(systemLocale.languageCode)) {
        _locale = Locale(systemLocale.languageCode);
      } else {
        _locale = const Locale('en', 'US');
      }
    }
    notifyListeners();
  }

  Future<void> changeLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    final box = Hive.box(HiveBootstrap.settingsBox);
    // Guardar código completo (ej: es_MX o en_US)
    String codeToSave = locale.languageCode;
    if (locale.countryCode != null) {
      codeToSave += '_${locale.countryCode}';
    }
    await box.put(_key, codeToSave);
    notifyListeners();
  }

  Locale _parseLocale(String code) {
    if (code == 'es') return const Locale('es', 'MX');
    if (code == 'en') return const Locale('en', 'US');

    if (code.contains('_')) {
      final parts = code.split('_');
      return Locale(parts[0], parts[1]);
    }
    return Locale(code);
  }
}
