import 'package:flutter/material.dart';

/// Extensión de tema personalizada - Sistema Dinámico de 22 Colores
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  // --- 19 Variables UI Core ---
  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgElevated;
  final Color overlay;

  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color textInverse;

  final Color borderSubtle;
  final Color borderFocus;

  final Color primary;
  final Color primaryHover;
  final Color primaryActive;

  final Color surfaceHover;
  final Color surfaceActive;

  final Color stateSuccess;
  final Color stateWarning;
  final Color stateError;
  final Color stateInfo;

  // --- 3 Variables UI Secondary (Nullable/Optional) ---
  final Color? _secondary;
  final Color? _secondaryHover;
  final Color? _secondaryActive;

  // Getters inteligentes con Fallback
  // Si no se define un secundario, usa el primario (Compatibilidad con sistema de 19 colores)
  Color get secondary => _secondary ?? primary;
  Color get secondaryHover => _secondaryHover ?? primaryHover;
  Color get secondaryActive => _secondaryActive ?? primaryActive;

  // Getters raw para serialización (saber si realmente se definió)
  Color? get rawSecondary => _secondary;
  Color? get rawSecondaryHover => _secondaryHover;
  Color? get rawSecondaryActive => _secondaryActive;

  // Charts - Derivado de colores UI
  // No guardamos colores específicos de charts para mantener el tema agnóstico
  List<Color> get chartPalette => [
    primary,
    secondary, // Ahora usamos secondary si existe
    stateSuccess,
    stateWarning,
    stateError,
    stateInfo,
    primaryHover,
    textSecondary,
    borderFocus,
  ];

  const AppColorExtension({
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgElevated,
    required this.overlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textInverse,
    required this.borderSubtle,
    required this.borderFocus,
    required this.primary,
    required this.primaryHover,
    required this.primaryActive,
    required this.surfaceHover,
    required this.surfaceActive,
    required this.stateSuccess,
    required this.stateWarning,
    required this.stateError,
    required this.stateInfo,
    Color? secondary,
    Color? secondaryHover,
    Color? secondaryActive,
  }) : _secondary = secondary,
       _secondaryHover = secondaryHover,
       _secondaryActive = secondaryActive;

  /// Tema por defecto (Gakoken: gato naranja, crema + naranja atigrado).
  static const defaultTheme = AppColorExtension(
    bgPrimary: Color(0xFFFFFCF8),
    bgSecondary: Color(0xFFFFF4E8),
    bgElevated: Color(0xFFFFFFFF),
    overlay: Color.fromRGBO(43, 26, 14, 0.45),
    textPrimary: Color(0xFF2B1A0E),
    textSecondary: Color(0xFF6E4A2C),
    textDisabled: Color(0xFFB89A7E),
    textInverse: Color(0xFFFFFFFF),
    borderSubtle: Color(0xFFF7E3CC),
    borderFocus: Color(0xFFFF8A1F),
    primary: Color(0xFFE65C00),
    primaryHover: Color(0xFFCC5200),
    primaryActive: Color(0xFFB34700),
    surfaceHover: Color(0xFFFFF0E0),
    surfaceActive: Color(0xFFFFE3C7),
    stateSuccess: Color(0xFF3F7A3B),
    stateWarning: Color(0xFFB7800F),
    stateError: Color(0xFFC2412F),
    stateInfo: Color(0xFF3F72AF),
  );

  /// Tema Nekokag (oscuro; inverso de Gakoken: gato naranja de noche).
  static const nekokagTheme = AppColorExtension(
    bgPrimary: Color(0xFF0F0A06),
    bgSecondary: Color(0xFF1A120B),
    bgElevated: Color(0xFF2A1E14),
    overlay: Color.fromRGBO(10, 6, 3, 0.75),
    textPrimary: Color(0xFFFFF3E0),
    textSecondary: Color(0xFFE3C49F),
    textDisabled: Color(0xFF8F7358),
    textInverse: Color(0xFF2B1A0E),
    borderSubtle: Color(0xFF3A2A1C),
    borderFocus: Color(0xFFFFA94D),
    primary: Color(0xFFF59A2F),
    primaryHover: Color(0xFFFFAD52),
    primaryActive: Color(0xFFFFC079),
    surfaceHover: Color(0xFF24180F),
    surfaceActive: Color(0xFF33241A),
    stateSuccess: Color(0xFF7CC47A),
    stateWarning: Color(0xFFF2C94C),
    stateError: Color(0xFFF07A62),
    stateInfo: Color(0xFF7FB2E5),
  );

  /// Tema Eloisa (colibrí, esmeralda + magenta).
  static const eloisaTheme = AppColorExtension(
    bgPrimary: Color(0xFFF7FCFA),
    bgSecondary: Color(0xFFEEF8F3),
    bgElevated: Color(0xFFFFFFFF),
    overlay: Color.fromRGBO(10, 47, 36, 0.45),
    textPrimary: Color(0xFF0A2F24),
    textSecondary: Color(0xFF3D6B5C),
    textDisabled: Color(0xFF8FAEA3),
    textInverse: Color(0xFFFFFFFF),
    borderSubtle: Color(0xFFD4EBE2),
    borderFocus: Color(0xFF12B886),
    primary: Color(0xFF0F9F6E),
    primaryHover: Color(0xFF0B8A5E),
    primaryActive: Color(0xFF097A52),
    surfaceHover: Color(0xFFE5F6EF),
    surfaceActive: Color(0xFFD5F0E4),
    stateSuccess: Color(0xFF0F9F6E),
    stateWarning: Color(0xFFE6A817),
    stateError: Color(0xFFD64545),
    stateInfo: Color(0xFF1C9BB8),
    secondary: Color(0xFFE64980),
    secondaryHover: Color(0xFFD63D73),
    secondaryActive: Color(0xFFC23466),
  );

  /// Tema Asiole (oscuro; inverso de Eloisa: bosque, esmeralda + magenta).
  static const asioleTheme = AppColorExtension(
    bgPrimary: Color(0xFF071512),
    bgSecondary: Color(0xFF0C221C),
    bgElevated: Color(0xFF16382C),
    overlay: Color.fromRGBO(7, 21, 18, 0.75),
    textPrimary: Color(0xFFF7FCFA),
    textSecondary: Color(0xFFB8D4C8),
    textDisabled: Color(0xFF6B9084),
    textInverse: Color(0xFF0A2F24),
    borderSubtle: Color(0xFF1E4A3C),
    borderFocus: Color(0xFF12B886),
    primary: Color(0xFF0F9F6E),
    primaryHover: Color(0xFF12B886),
    primaryActive: Color(0xFF2EC99A),
    surfaceHover: Color(0xFF123328),
    surfaceActive: Color(0xFF1A4336),
    stateSuccess: Color(0xFF0F9F6E),
    stateWarning: Color(0xFFE6A817),
    stateError: Color(0xFFEB6A6A),
    stateInfo: Color(0xFF4DB8D0),
    secondary: Color(0xFFE64980),
    secondaryHover: Color(0xFFF0659A),
    secondaryActive: Color(0xFFF78BB4),
  );

  /// Tema Ajoruto (claro púrpura; antes Lavanda).
  static const ajorutoTheme = AppColorExtension(
    bgPrimary: Color(0xFFFFFFFF),
    bgSecondary: Color(0xFFFAFAFA),
    bgElevated: Color(0xFFFFFFFF),
    overlay: Color.fromRGBO(0, 0, 0, 0.4),
    textPrimary: Color(0xFF0D0C0D),
    textSecondary: Color(0xFF5E526F),
    textDisabled: Color(0xFF9A92A8),
    textInverse: Color(0xFFFFFFFF),
    borderSubtle: Color(0xFFE3DFEA),
    borderFocus: Color(0xFF7B5EA7),
    primary: Color(0xFF7B5EA7),
    primaryHover: Color(0xFF6A4F94),
    primaryActive: Color(0xFF5A437F),
    surfaceHover: Color(0xFFF0ECF6),
    surfaceActive: Color(0xFFE6E0F0),
    stateSuccess: Color(0xFF4F8F6A),
    stateWarning: Color(0xFFC2A14D),
    stateError: Color(0xFFB84A4A),
    stateInfo: Color(0xFF6B7FB8),
  );

  /// Tema Oturoja (oscuro púrpura)
  static const oturojaTheme = AppColorExtension(
    bgPrimary: Color(0xFF0E0B04),
    bgSecondary: Color(0xFF161618),
    bgElevated: Color(0xFF221F29),
    overlay: Color.fromRGBO(0, 0, 0, 0.4),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFC9C2D6),
    textDisabled: Color(0xFF8F88A3),
    textInverse: Color(0xFF0E0B14),
    borderSubtle: Color(0xFF272433),
    borderFocus: Color(0xFFB198E1),
    primary: Color(0xFF7A5EB3),
    primaryHover: Color(0xFF8A6EC4),
    primaryActive: Color(0xFF9A7FD1),
    surfaceHover: Color(0xFF262139),
    surfaceActive: Color(0xFF312C47),
    stateSuccess: Color(0xFF6FCF9E),
    stateWarning: Color(0xFFE2C56B),
    stateError: Color(0xFFEB6A6A),
    stateInfo: Color(0xFF8FA7E3),
  );

  /// Tema Morobu (claro, ballena gris: neutros cálidos, acento carbón).
  static const manubuTheme = AppColorExtension(
    bgPrimary: Color(0xFFFFFFFF),
    bgSecondary: Color(0xFFF5F5F4),
    bgElevated: Color(0xFFFFFFFF),
    overlay: Color.fromRGBO(20, 20, 20, 0.45),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF6B6B6B),
    textDisabled: Color(0xFFABABAB),
    textInverse: Color(0xFFFFFFFF),
    borderSubtle: Color(0xFFE3E3E2),
    borderFocus: Color(0xFF2C2C2A),
    primary: Color(0xFF2C2C2A),
    primaryHover: Color(0xFF3F3F3D),
    primaryActive: Color(0xFF525250),
    surfaceHover: Color(0xFFEFEFEE),
    surfaceActive: Color(0xFFE4E4E2),
    stateSuccess: Color(0xFF3A7D57),
    stateWarning: Color(0xFFA87928),
    stateError: Color(0xFFB03A30),
    stateInfo: Color(0xFF4A7FA8),
  );

  /// Tema Uborom (orca: grises neutros, buen contraste).
  /// primary más claro que textSecondary para que en la barra el ítem seleccionado destaque.
  /// primary como fondo de card de saldo y FAB (gris medio; texto blanco legible).
  static const ubunamTheme = AppColorExtension(
    bgPrimary: Color(0xFF0D0E10),
    bgSecondary: Color(0xFF141619),
    bgElevated: Color(0xFF1C1F24),
    overlay: Color.fromRGBO(0, 0, 0, 0.6),
    textPrimary: Color(0xFFF2F3F5),
    textSecondary: Color(0xFF5C6370),
    textDisabled: Color(0xFF4A5059),
    textInverse: Color(0xFF0D0E10),
    borderSubtle: Color(0xFF2A2E35),
    borderFocus: Color(0xFF8B9199),
    primary: Color(0xFF6B7280),
    primaryHover: Color(0xFF7D838E),
    primaryActive: Color(0xFF8B9199),
    surfaceHover: Color(0xFF22262C),
    surfaceActive: Color(0xFF2A2E35),
    stateSuccess: Color(0xFF34C759),
    stateWarning: Color(0xFFFFCC00),
    stateError: Color(0xFFFF453A),
    stateInfo: Color(0xFF5AC8FA),
  );

  /// Tema Zontle (claro: neutros cálidos con acento dorado).
  static const zontleTheme = AppColorExtension(
    bgPrimary: Color(0xFFF9F9F8),
    bgSecondary: Color(0xFFEBEAE8),
    bgElevated: Color(0xFFFFFFFF),
    overlay: Color.fromRGBO(45, 45, 43, 0.5),
    textPrimary: Color(0xFF2D2D2B),
    textSecondary: Color(0xFF706E6A),
    textDisabled: Color(0xFFA8A6A2),
    textInverse: Color(0xFFF9F9F8),
    borderSubtle: Color(0xFFD1D0CC),
    borderFocus: Color(0xFF424240),
    primary: Color(0xFF424240),
    primaryHover: Color(0xFFC29221),
    primaryActive: Color(0xFFA67B1A),
    surfaceHover: Color(0xFFE2E1DE),
    surfaceActive: Color(0xFFD6D5D1),
    stateSuccess: Color(0xFF5B7C66),
    stateWarning: Color(0xFFD4A328),
    stateError: Color(0xFFA3524E),
    stateInfo: Color(0xFF6B8FA8),
  );

  /// Tema Eltnoz (oscuro: neutros cálidos con acento dorado).
  static const eltnozTheme = AppColorExtension(
    bgPrimary: Color(0xFF1E1E1D),
    bgSecondary: Color(0xFF282826),
    bgElevated: Color(0xFF333331),
    overlay: Color.fromRGBO(10, 10, 9, 0.75),
    textPrimary: Color(0xFFF9F9F8),
    textSecondary: Color(0xFFC7C6C2),
    textDisabled: Color(0xFF7A7874),
    textInverse: Color(0xFF2D2D2B),
    borderSubtle: Color(0xFF3F3E3B),
    borderFocus: Color(0xFFF9F9F8),
    primary: Color(0xFFA8A6A2),
    primaryHover: Color(0xFFD9A931),
    primaryActive: Color(0xFFC29221),
    surfaceHover: Color(0xFF3D3D3A),
    surfaceActive: Color(0xFF4F4F4A),
    stateSuccess: Color(0xFF6A9679),
    stateWarning: Color(0xFFD4A328),
    stateError: Color(0xFFC26762),
    stateInfo: Color(0xFF7CA6C1),
  );

  /// Tema Bioka (claro; biota, la Tierra vista desde el espacio:
  /// blanco nube, azul océano + verde de los continentes).
  static const biokaTheme = AppColorExtension(
    bgPrimary: Color(0xFFF6FAFB),
    bgSecondary: Color(0xFFEAF2F4),
    bgElevated: Color(0xFFFFFFFF),
    overlay: Color.fromRGBO(10, 37, 56, 0.45),
    textPrimary: Color(0xFF0B2638),
    textSecondary: Color(0xFF44606E),
    textDisabled: Color(0xFF94A8B2),
    textInverse: Color(0xFFFFFFFF),
    borderSubtle: Color(0xFFD3E2E7),
    borderFocus: Color(0xFF1F6FA8),
    primary: Color(0xFF1F6FA8),
    primaryHover: Color(0xFF195E90),
    primaryActive: Color(0xFF144E78),
    surfaceHover: Color(0xFFE1EEF2),
    surfaceActive: Color(0xFFD0E4EB),
    stateSuccess: Color(0xFF2E8B57),
    stateWarning: Color(0xFFD49A1E),
    stateError: Color(0xFFC8473D),
    stateInfo: Color(0xFF2A86B8),
    secondary: Color(0xFF3A8F4A),
    secondaryHover: Color(0xFF317C40),
    secondaryActive: Color(0xFF286836),
  );

  /// Tema Akoib (oscuro; inverso de Bioka: la Tierra de noche, azul océano +
  /// verde de los continentes).
  static const akoibTheme = AppColorExtension(
    bgPrimary: Color(0xFF07121B),
    bgSecondary: Color(0xFF0B1A26),
    bgElevated: Color(0xFF132A3A),
    overlay: Color.fromRGBO(3, 8, 12, 0.75),
    textPrimary: Color(0xFFEEF5F8),
    textSecondary: Color(0xFFA9C1CC),
    textDisabled: Color(0xFF5E7784),
    textInverse: Color(0xFF0B2638),
    borderSubtle: Color(0xFF1E3A4D),
    borderFocus: Color(0xFF5AB0E6),
    primary: Color(0xFF3D93D1),
    primaryHover: Color(0xFF56A6DE),
    primaryActive: Color(0xFF72B9E8),
    surfaceHover: Color(0xFF10283A),
    surfaceActive: Color(0xFF183449),
    stateSuccess: Color(0xFF5DBB7A),
    stateWarning: Color(0xFFE8B64C),
    stateError: Color(0xFFE8776B),
    stateInfo: Color(0xFF5AB0E6),
    secondary: Color(0xFF5DB56B),
    secondaryHover: Color(0xFF74C381),
    secondaryActive: Color(0xFF8DD198),
  );

  /// Map de temas built-in para resolver por id sin repetir lógica
  static const Map<String, AppColorExtension> builtInThemes = {
    'default': defaultTheme,
    'nekokag': nekokagTheme,
    'eloisa': eloisaTheme,
    'asiole': asioleTheme,
    'ajoruto': ajorutoTheme,
    'oturoja': oturojaTheme,
    'manubu': manubuTheme,
    'ubunam': ubunamTheme,
    'zontle': zontleTheme,
    'eltnoz': eltnozTheme,
    'bioka': biokaTheme,
    'akoib': akoibTheme,
  };

  @override
  ThemeExtension<AppColorExtension> copyWith({
    Color? bgPrimary,
    Color? bgSecondary,
    Color? bgElevated,
    Color? overlay,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? textInverse,
    Color? borderSubtle,
    Color? borderFocus,
    Color? primary,
    Color? primaryHover,
    Color? primaryActive,
    Color? surfaceHover,
    Color? surfaceActive,
    Color? stateSuccess,
    Color? stateWarning,
    Color? stateError,
    Color? stateInfo,
    Color? secondary,
    Color? secondaryHover,
    Color? secondaryActive,
  }) {
    return AppColorExtension(
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgElevated: bgElevated ?? this.bgElevated,
      overlay: overlay ?? this.overlay,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      textInverse: textInverse ?? this.textInverse,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderFocus: borderFocus ?? this.borderFocus,
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryActive: primaryActive ?? this.primaryActive,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      surfaceActive: surfaceActive ?? this.surfaceActive,
      stateSuccess: stateSuccess ?? this.stateSuccess,
      stateWarning: stateWarning ?? this.stateWarning,
      stateError: stateError ?? this.stateError,
      stateInfo: stateInfo ?? this.stateInfo,
      secondary: secondary ?? _secondary,
      secondaryHover: secondaryHover ?? _secondaryHover,
      secondaryActive: secondaryActive ?? _secondaryActive,
    );
  }

  @override
  ThemeExtension<AppColorExtension> lerp(
    covariant ThemeExtension<AppColorExtension>? other,
    double t,
  ) {
    if (other is! AppColorExtension) return this;

    return AppColorExtension(
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgElevated: Color.lerp(bgElevated, other.bgElevated, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryActive: Color.lerp(primaryActive, other.primaryActive, t)!,
      surfaceHover: Color.lerp(surfaceHover, other.surfaceHover, t)!,
      surfaceActive: Color.lerp(surfaceActive, other.surfaceActive, t)!,
      stateSuccess: Color.lerp(stateSuccess, other.stateSuccess, t)!,
      stateWarning: Color.lerp(stateWarning, other.stateWarning, t)!,
      stateError: Color.lerp(stateError, other.stateError, t)!,
      stateInfo: Color.lerp(stateInfo, other.stateInfo, t)!,
      // Nullability handling for lerp:
      // If both are null, result is null.
      // If one is null, we assume it equals its primary counterpart for the interpolation.
      secondary: Color.lerp(
        _secondary ?? primary,
        other._secondary ?? other.primary,
        t,
      ),
      secondaryHover: Color.lerp(
        _secondaryHover ?? primaryHover,
        other._secondaryHover ?? other.primaryHover,
        t,
      ),
      secondaryActive: Color.lerp(
        _secondaryActive ?? primaryActive,
        other._secondaryActive ?? other.primaryActive,
        t,
      ),
    );
  }
}

/// Colores de categorías - Océano Sereno
/// Mantenemos esto por compatibilidad, aunque se recomienda usar chartPalette o colores de usuario
class AppCategoryColors {
  static const List<Color> values = [
    Color(0xFF356A94), // Azul acero
    Color(0xFF4B8FB7), // Azul petróleo
    Color(0xFF6BB5D7), // Azul claro elegante
    Color(0xFFD0A24C), // Dorado ámbar
    Color(0xFFD66A5B), // Terracota suave
    Color(0xFF6C7D8A), // Gris azulado
    Color(0xFF9DB2BF), // Azul gris claro
    Color(0xFFBCA177), // Beige neutro
    Color(0xFF1E2D35), // Azul profundo
    Color(0xFF8ABBD2), // Azul menta tenue
  ];
}

extension AppColorRecurring on AppColorExtension {
  Color get recurringScopeInfo => stateInfo;
  Color get recurringScopeWarning => stateWarning;
}
