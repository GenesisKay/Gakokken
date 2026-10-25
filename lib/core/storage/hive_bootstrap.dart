import 'package:hive_ce_flutter/hive_flutter.dart';

import '../theme/models/app_theme_data.dart';

/// Registers Hive adapters and opens boxes used by Gakoken (themes, settings,
/// favorites, trash).
/// Boxes are opened only here, before `runApp`; services use `Hive.box`.
class HiveBootstrap {
  static const String themesBox = 'themes';
  static const String settingsBox = 'settings';
  static const String favoritesBox = 'favorites';
  static const String trashBox = 'trash';

  static bool _adaptersRegistered = false;

  static void registerAdapters() {
    if (_adaptersRegistered) return;
    _adaptersRegistered = true;
    Hive.registerAdapter(AppThemeDataAdapter());
  }

  static Future<void> openCoreBoxes() async {
    if (!Hive.isBoxOpen(themesBox)) {
      await Hive.openBox<AppThemeData>(themesBox);
    }
    if (!Hive.isBoxOpen(settingsBox)) {
      await Hive.openBox(settingsBox);
    }
    if (!Hive.isBoxOpen(favoritesBox)) {
      await Hive.openBox(favoritesBox);
    }
    if (!Hive.isBoxOpen(trashBox)) {
      await Hive.openBox(trashBox);
    }
  }
}
