import 'package:flutter/material.dart';
import 'color_extensions.dart';
import 'icon_extensions.dart';
import '../exceptions/gakoken_exception.dart';
import 'typography.dart';

/// Extension para acceder fácilmente a los colores personalizados desde el BuildContext
extension ThemeExtensions on BuildContext {
  /// Acceso rápido a los colores personalizados de la app
  /// Uso: context.colors.textPrimary
  AppColorExtension get colors {
    return Theme.of(this).extension<AppColorExtension>() ??
        AppColorExtension.defaultTheme;
  }

  /// Acceso centralizado a tipografía semántica (mobile styles).
  AppTypography get typography {
    final extension = Theme.of(this).extension<AppTypography>()!;
    return extension.copyWith(
      pageTitle: extension.mobilePageTitle,
      modalTitle: extension.mobileModalTitle,
      sectionHeader: extension.mobileSectionHeader,
    );
  }

  /// Acceso rápido a los iconos de la app
  /// Uso: context.icons.delete
  AppIcons get icons {
    return AppIcons.standard;
  }

  /// Acceso rápido al ColorScheme de Material
  /// Uso: context.colorScheme.primary
  ColorScheme get colorScheme {
    return Theme.of(this).colorScheme;
  }

  /// Acceso rápido al TextTheme
  /// Uso: context.textTheme.titleLarge
  TextTheme get textTheme {
    return Theme.of(this).textTheme;
  }

  /// Verifica si el tema actual es oscuro
  bool get isDarkMode {
    return Theme.of(this).brightness == Brightness.dark;
  }

  /// Muestra un SnackBar de éxito estandarizado
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: colorScheme.primary),
    );
  }

  /// Muestra un SnackBar de excepción estandarizado (Error o Atención)
  void showExceptionSnackBar(dynamic e) {
    final isWarning = e is GakokenException && e.isWarning;
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text('${isWarning ? 'Atención: ' : 'Error: '}${e.toString()}'),
        backgroundColor: isWarning ? colors.stateWarning : colors.stateError,
      ),
    );
  }
}
