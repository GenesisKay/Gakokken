import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../theme/color_extensions.dart';
import '../theme/models/app_theme_data.dart';
import '../theme/theme_serializer.dart';
import '../storage/hive_bootstrap.dart';

class ThemeService extends ChangeNotifier {
  static ThemeService? _instance;

  factory ThemeService() {
    _instance ??= ThemeService._internal();
    return _instance!;
  }

  ThemeService._internal();

  Box<AppThemeData>? _themesBox;
  Box? _settingsBox;

  // El tema activo actualmente (objeto Flutter)
  ThemeData _currentThemeData = AppTheme.createTheme(
    AppColorExtension.defaultTheme,
  );

  // La extensión de colores activa (para acceso directo si es necesario)
  AppColorExtension _currentColors = AppColorExtension.defaultTheme;

  bool _isInitialized = false;

  ThemeData get currentThemeData => _currentThemeData;
  AppColorExtension get currentColors => _currentColors;
  bool get isInitialized => _isInitialized;
  String get activeThemeId => _settingsBox?.get('active_theme_id') ?? 'default';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Las cajas ya las abrió HiveBootstrap en main.
      _themesBox = Hive.box<AppThemeData>(HiveBootstrap.themesBox);
      _settingsBox = Hive.box(HiveBootstrap.settingsBox);

      await _loadActiveTheme();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing ThemeService: $e');
      // Fallback seguro
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadActiveTheme() async {
    if (_settingsBox == null) return;

    final activeThemeId =
        _settingsBox!.get('active_theme_id', defaultValue: 'default') as String;
    final builtIn = AppColorExtension.builtInThemes[activeThemeId];
    if (builtIn != null) {
      _setThemeData(builtIn);
      return;
    }
    final themeData = _themesBox!.get(activeThemeId);
    if (themeData != null) {
      _setThemeData(_mapModelToExtension(themeData));
    } else {
      // Si el tema guardado ya no existe, volver al default
      await _settingsBox!.put('active_theme_id', 'default');
      _setThemeData(AppColorExtension.defaultTheme);
    }
  }

  void _setThemeData(AppColorExtension extension) {
    _currentColors = extension;
    _currentThemeData = AppTheme.createTheme(extension);
  }

  Future<void> selectTheme(String themeId) async {
    if (!_isInitialized) await initialize();
    final builtIn = AppColorExtension.builtInThemes[themeId];
    if (builtIn != null) {
      _setThemeData(builtIn);
      await _settingsBox?.put('active_theme_id', themeId);
    } else {
      final themeData = _themesBox?.get(themeId);
      if (themeData != null) {
        _setThemeData(_mapModelToExtension(themeData));
        await _settingsBox?.put('active_theme_id', themeId);
      }
    }
    notifyListeners();
  }

  /// Convierte el modelo de datos (Map<String, int>) a la extensión de colores de Flutter
  AppColorExtension _mapModelToExtension(AppThemeData model) {
    Color getColor(String key, Color fallback) {
      if (model.colors.containsKey(key)) {
        return Color(model.colors[key]!);
      }
      return fallback;
    }

    Color? getOptionalColor(String key) {
      if (model.colors.containsKey(key)) {
        return Color(model.colors[key]!);
      }
      return null;
    }

    final defaults = AppColorExtension.defaultTheme;

    return AppColorExtension(
      bgPrimary: getColor('bgPrimary', defaults.bgPrimary),
      bgSecondary: getColor('bgSecondary', defaults.bgSecondary),
      bgElevated: getColor('bgElevated', defaults.bgElevated),
      overlay: getColor('overlay', defaults.overlay),
      textPrimary: getColor('textPrimary', defaults.textPrimary),
      textSecondary: getColor('textSecondary', defaults.textSecondary),
      textDisabled: getColor('textDisabled', defaults.textDisabled),
      textInverse: getColor('textInverse', defaults.textInverse),
      borderSubtle: getColor('borderSubtle', defaults.borderSubtle),
      borderFocus: getColor('borderFocus', defaults.borderFocus),
      primary: getColor('primary', defaults.primary),
      primaryHover: getColor('primaryHover', defaults.primaryHover),
      primaryActive: getColor('primaryActive', defaults.primaryActive),
      surfaceHover: getColor('surfaceHover', defaults.surfaceHover),
      surfaceActive: getColor('surfaceActive', defaults.surfaceActive),
      stateSuccess: getColor('stateSuccess', defaults.stateSuccess),
      stateWarning: getColor('stateWarning', defaults.stateWarning),
      stateError: getColor('stateError', defaults.stateError),
      stateInfo: getColor('stateInfo', defaults.stateInfo),

      // Secondary Colors (Nullable)
      secondary: getOptionalColor('secondary'),
      secondaryHover: getOptionalColor('secondaryHover'),
      secondaryActive: getOptionalColor('secondaryActive'),
    );
  }

  Future<void> saveTheme(AppThemeData themeData) async {
    if (!_isInitialized) await initialize();
    await _themesBox?.put(themeData.id, themeData);

    // Si el usuario está editando el theme activo, necesitamos recalcular el
    // ThemeData inmediatamente; si no, el resto de la app no reflejará
    // los cambios hasta que seleccione otro theme y vuelva a aplicar este.
    if (activeThemeId == themeData.id) {
      _setThemeData(_mapModelToExtension(themeData));
    }

    notifyListeners();
  }

  Future<void> deleteTheme(String id) async {
    if (!_isInitialized) await initialize();
    await _themesBox?.delete(id);

    // Si borramos el tema actual, volver al default
    final activeId = _settingsBox?.get('active_theme_id');
    if (activeId == id) {
      await selectTheme('default');
    } else {
      notifyListeners();
    }
  }

  List<AppThemeData> getAvailableThemes() {
    if (_themesBox == null) return [];
    return _themesBox!.values.toList();
  }

  // --- Import / Export ---

  /// Importa un tema desde un archivo seleccionado
  Future<bool> pickFileAndImport() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String jsonString = await file.readAsString();
        await importThemeFromJson(jsonString);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error picking file: $e');
      rethrow;
    }
  }

  static const _builtInExportNames =
      <String, ({String name, String description})>{
        'default': (
          name: 'Gakoken',
          description: 'Tema gato naranja: crema y naranja atigrado',
        ),
        'nekokag': (name: 'Nekokag', description: 'Tema gato naranja oscuro'),
        'eloisa': (
          name: 'Eloisa',
          description: 'Tema colibrí: esmeralda y magenta',
        ),
        'asiole': (
          name: 'Asiole',
          description: 'Tema colibrí oscuro: esmeralda y magenta',
        ),
        'ajoruto': (name: 'Ajoruto', description: 'Tema claro púrpura'),
        'oturoja': (name: 'Oturoja', description: 'Tema oscuro púrpura'),
        'manubu': (
          name: 'Morobu',
          description: 'Tema claro gris, neutros cálidos',
        ),
        'ubunam': (name: 'Uborom', description: 'Tema oscuro neutro'),
        'zontle': (
          name: 'Zontle',
          description: 'Tema claro neutro, acento dorado',
        ),
        'eltnoz': (
          name: 'Eltnoz',
          description: 'Tema oscuro neutro, acento dorado',
        ),
        'bioka': (
          name: 'Bioka',
          description: 'Tema Tierra: azul océano y verde',
        ),
        'akoib': (
          name: 'Akoib',
          description: 'Tema Tierra de noche: azul océano y verde',
        ),
      };

  /// Exporta un tema a JSON String
  String exportThemeToJson(String themeId) {
    AppThemeData? data;
    final builtIn = AppColorExtension.builtInThemes[themeId];
    if (builtIn != null) {
      final pair = _builtInExportNames[themeId]!;
      data = AppThemeData(
        id: themeId,
        name: pair.name,
        description: pair.description,
        isSystem: true,
        colors: _extensionToMap(builtIn),
      );
    } else {
      data = _themesBox?.get(themeId);
    }

    if (data == null) throw Exception("Tema no encontrado");

    final map = ThemeSerializer.toJson(data);
    return jsonEncode(map);
  }

  /// Importa un tema desde JSON String y lo guarda
  Future<String> importThemeFromJson(String jsonString) async {
    try {
      final map = jsonDecode(jsonString);
      final importedTheme = ThemeSerializer.fromJson(map);

      // Generar nuevo ID para evitar conflictos con el original si se importa en la misma app
      // O mantener si es restore. Por seguridad, generamos nuevo ID si ya existe uno.
      String newId = importedTheme.id;
      if (_themesBox!.containsKey(newId)) {
        newId = const Uuid().v4();
      }

      final themeToSave = AppThemeData(
        id: newId,
        name: importedTheme.name, // Podríamos añadir "(Importado)"
        description: importedTheme.description,
        isSystem: false,
        colors: importedTheme.colors,
      );

      await saveTheme(themeToSave);
      return newId;
    } catch (e) {
      debugPrint('Error importando tema: $e');
      throw Exception('Formato de tema inválido');
    }
  }

  Map<String, int> _extensionToMap(AppColorExtension ext) {
    final m = <String, int>{
      'bgPrimary': ext.bgPrimary.value,
      'bgSecondary': ext.bgSecondary.value,
      'bgElevated': ext.bgElevated.value,
      'overlay': ext.overlay.value,
      'textPrimary': ext.textPrimary.value,
      'textSecondary': ext.textSecondary.value,
      'textDisabled': ext.textDisabled.value,
      'textInverse': ext.textInverse.value,
      'borderSubtle': ext.borderSubtle.value,
      'borderFocus': ext.borderFocus.value,
      'primary': ext.primary.value,
      'primaryHover': ext.primaryHover.value,
      'primaryActive': ext.primaryActive.value,
      'surfaceHover': ext.surfaceHover.value,
      'surfaceActive': ext.surfaceActive.value,
      'stateSuccess': ext.stateSuccess.value,
      'stateWarning': ext.stateWarning.value,
      'stateError': ext.stateError.value,
      'stateInfo': ext.stateInfo.value,
    };
    if (ext.rawSecondary != null) m['secondary'] = ext.rawSecondary!.value;
    if (ext.rawSecondaryHover != null)
      m['secondaryHover'] = ext.rawSecondaryHover!.value;
    if (ext.rawSecondaryActive != null)
      m['secondaryActive'] = ext.rawSecondaryActive!.value;
    return m;
  }
}
