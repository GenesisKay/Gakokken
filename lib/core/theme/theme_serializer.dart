import '../theme/models/app_theme_data.dart';
import 'color_extensions.dart';

class ThemeSerializer {
  static const String _version = "1.0";

  /// Convierte un AppThemeData a un Map JSON-serializable
  static Map<String, dynamic> toJson(AppThemeData theme) {
    final colors = <String, String>{};

    // Función auxiliar para convertir Color a Hex String
    String toHex(int value) =>
        '#${value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

    // Rellenar mapa de colores
    theme.colors.forEach((key, value) {
      colors[key] = toHex(value);
    });

    return {
      "version": _version,
      "metadata": {
        "id": theme.id,
        "name": theme.name,
        "description": theme.description,
        "isSystem": theme.isSystem,
        "createdAt": DateTime.now().toIso8601String(),
      },
      "colors": colors,
    };
  }

  /// Convierte un Map JSON en AppThemeData
  /// Lanza excepción si el formato es inválido
  static AppThemeData fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('colors') || !json.containsKey('metadata')) {
      throw FormatException("JSON Inválido: faltan campos requeridos.");
    }

    final metadata = json['metadata'] as Map<String, dynamic>;
    final colorsMap = json['colors'] as Map<String, dynamic>;

    final Map<String, int> parsedColors = {};

    colorsMap.forEach((key, value) {
      if (value is String) {
        // Parse #RRGGBB o RRGGBB
        String hex = value.replaceAll('#', '');
        if (hex.length == 6) hex = 'FF$hex'; // Agregar alpha si falta
        parsedColors[key] = int.parse(hex, radix: 16);
      }
    });

    // Validar existencia de colores críticos (19 core)
    // Si faltan, rellenamos con defaults para evitar crash
    _ensureCoreColors(parsedColors);

    return AppThemeData(
      id:
          metadata['id'] ??
          DateTime.now().millisecondsSinceEpoch
              .toString(), // ID nuevo si falta, aunque idealmente generamos uno nuevo al importar
      name: metadata['name'] ?? 'Tema Importado',
      description: metadata['description'] ?? '',
      isSystem: false, // Nunca importar como system
      colors: parsedColors,
    );
  }

  static void _ensureCoreColors(Map<String, int> colors) {
    final defaultTheme = AppColorExtension.defaultTheme;

    void check(String key, int defaultValue) {
      if (!colors.containsKey(key)) {
        colors[key] = defaultValue;
      }
    }

    check('bgPrimary', defaultTheme.bgPrimary.value);
    check('bgSecondary', defaultTheme.bgSecondary.value);
    check('bgElevated', defaultTheme.bgElevated.value);
    check('overlay', defaultTheme.overlay.value);
    check('textPrimary', defaultTheme.textPrimary.value);
    check('textSecondary', defaultTheme.textSecondary.value);
    check('textDisabled', defaultTheme.textDisabled.value);
    check('textInverse', defaultTheme.textInverse.value);
    check('borderSubtle', defaultTheme.borderSubtle.value);
    check('borderFocus', defaultTheme.borderFocus.value);
    check('primary', defaultTheme.primary.value);
    check('primaryHover', defaultTheme.primaryHover.value);
    check('primaryActive', defaultTheme.primaryActive.value);
    check('surfaceHover', defaultTheme.surfaceHover.value);
    check('surfaceActive', defaultTheme.surfaceActive.value);
    check('stateSuccess', defaultTheme.stateSuccess.value);
    check('stateWarning', defaultTheme.stateWarning.value);
    check('stateError', defaultTheme.stateError.value);
    check('stateInfo', defaultTheme.stateInfo.value);
  }
}
