import 'package:flutter/material.dart';
import 'color_extensions.dart';

/// Generador de temas basado en una semilla de color.
/// Crea una paleta completa de 22 colores coherentes.
class ThemeGenerator {
  /// Genera una extensión de colores basada en un color semilla y brillo.
  static AppColorExtension generateFromSeed({
    required Color seed,
    required Brightness brightness,
    bool highContrast = false,
  }) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );

    // Colores base derivados del esquema Material 3
    final primary = scheme.primary;
    final primaryHover = _adjustColor(primary, isDark ? 0.1 : -0.1);
    final primaryActive = _adjustColor(primary, isDark ? 0.2 : -0.2);

    // Fondo
    final bgPrimary = scheme.surface;
    final bgSecondary = scheme.surfaceContainerLow;
    final bgElevated = scheme.surfaceContainerHigh;

    // Texto
    final textPrimary = scheme.onSurface;
    final textSecondary = scheme.onSurfaceVariant;
    final textDisabled = scheme.onSurface.withOpacity(0.38);
    final textInverse =
        scheme.onInverseSurface; // O scheme.onPrimary si es botón

    // Bordes
    final borderSubtle = scheme.outlineVariant;
    final borderFocus = primary;

    // Estados (Mantenemos semántica universal pero ajustada ligeramente al brillo)
    final stateSuccess = isDark
        ? const Color(0xFF81C995)
        : const Color(0xFF1E8E3E);
    final stateWarning = isDark
        ? const Color(0xFFFDD663)
        : const Color(0xFFE37400); // 0xFFF9AB00
    final stateError = scheme.error;
    final stateInfo = isDark
        ? const Color(0xFF8AB4F8)
        : const Color(0xFF1967D2);

    // Superficie Hover/Active (ligeramente tintada con primary)
    final surfaceHover = Color.alphaBlend(
      primary.withOpacity(0.08),
      bgSecondary,
    );
    final surfaceActive = Color.alphaBlend(
      primary.withOpacity(0.12),
      bgSecondary,
    );

    // Overlay
    final overlay = isDark ? Colors.black54 : Colors.black26;

    return AppColorExtension(
      bgPrimary: bgPrimary,
      bgSecondary: bgSecondary,
      bgElevated: bgElevated,
      overlay: overlay,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textDisabled: textDisabled,
      textInverse: scheme.onPrimary, // Texto sobre el color primario
      borderSubtle: borderSubtle,
      borderFocus: borderFocus,
      primary: primary,
      primaryHover: primaryHover,
      primaryActive: primaryActive,
      surfaceHover: surfaceHover,
      surfaceActive: surfaceActive,
      stateSuccess: stateSuccess,
      stateWarning: stateWarning,
      stateError: stateError,
      stateInfo: stateInfo,
      // Secondary por defecto sigue al primario en generación simple
      // Para generar secundario distinto, se llamaría con otro seed pero eso es avanzado
      secondary: null,
      secondaryHover: null,
      secondaryActive: null,
    );
  }

  static Color _adjustColor(Color color, double amount) {
    assert(amount >= -1 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
