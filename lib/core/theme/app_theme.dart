import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_extensions.dart';

import 'typography.dart';

class AppTheme {
  /// Construye el tema basado en la extensión de colores proporcionada
  static ThemeData createTheme(AppColorExtension colorExtension) {
    // Determinar brillo basado en el color de fondo
    // Si el fondo es oscuro, el brillo es dark
    final brightness = ThemeData.estimateBrightnessForColor(
      colorExtension.bgPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colorExtension.bgSecondary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colorExtension.primary,
        brightness: brightness,
        surface: colorExtension.bgSecondary,
        onSurface: colorExtension.textPrimary,
        primary: colorExtension.primary,
        secondary: colorExtension
            .secondary, // Usamos el color secundario (o su fallback)
        error: colorExtension.stateError,
      ),
      textTheme: _buildTextTheme(isDark: brightness == Brightness.dark),
      appBarTheme: _buildAppBarTheme(colorExtension),
      extensions: [colorExtension, AppTypography.regular()],
      // Ajustes adicionales para componentes
      // Ajustes adicionales para componentes
      cardTheme: CardThemeData(
        color: colorExtension.bgElevated,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorExtension.borderSubtle, width: 1),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorExtension.bgElevated,
        modalBackgroundColor: colorExtension.bgElevated,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorExtension.bgElevated,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  /// Construye el TextTheme con Google Fonts
  static TextTheme _buildTextTheme({bool isDark = false}) {
    final baseTheme = isDark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    final montserrat = GoogleFonts.montserratTextTheme(baseTheme);

    return montserrat.copyWith(
      // Display - Para números grandes o textos de impacto
      displayLarge: GoogleFonts.montserrat(
        fontSize: 32, // Compacto
        fontWeight: FontWeight.w400,
        height: 1.1,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 28, // Compacto
        fontWeight: FontWeight.w400,
        height: 1.15,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 24, // Compacto
        fontWeight: FontWeight.w400,
        height: 1.2,
      ),

      // Headline - Para encabezados principales de secciones
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 20, // Reducido
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 18, // Page Title (Ultra-Compact)
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),

      // Title - Para títulos de tarjetas y subdivisiones
      titleLarge: GoogleFonts.montserrat(
        fontSize: 16, // Section Header (Matches Card Title)
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 16, // Card Title (Reference)
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        height: 1.5,
        letterSpacing: 0.1,
      ),

      // Label - Para botones y textos funcionales pequeños
      labelLarge: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.montserrat(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
      ),

      // Body - Para texto de lectura
      bodyLarge: GoogleFonts.montserrat(
        fontSize:
            14, // Reduced body size slightly for compact feel? No, keep 16 or 14? Let's try 14 as default for bodyLarge if 16 feels big. Standard is 16. Let's keep 16 but maybe lighter weight? Regular is fine.
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.4,
      ),
    );
  }

  /// Construye el AppBarTheme - Estilo moderno con fondo transparente
  static AppBarTheme _buildAppBarTheme(AppColorExtension colors) {
    return AppBarTheme(
      backgroundColor: colors.bgSecondary, // Mismo color que el fondo
      foregroundColor: colors.textPrimary, // Texto principal para contraste
      elevation: 0, // Sin sombra para efecto limpio
      scrolledUnderElevation: 0, // Sin sombra al hacer scroll
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary, // Usar color del texto principal
      ),
      iconTheme: IconThemeData(
        color: colors.textPrimary, // Iconos del mismo color que el texto
      ),
      actionsIconTheme: IconThemeData(color: colors.textPrimary),
    );
  }
}
