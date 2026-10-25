import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Extension para centralizar tipografía semántica.
/// Permite definir estilos por USO (pageTitle) en lugar de tamaño (headlineLarge).
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  // Main Page Headers
  final TextStyle pageTitle;
  final TextStyle mobilePageTitle;

  // Modal/Dialog Headers
  final TextStyle modalTitle;
  final TextStyle mobileModalTitle;

  // Section Headers (e.g. "Presupuesto Mensual")
  final TextStyle sectionHeader;
  final TextStyle mobileSectionHeader;

  // Card Titles (e.g. Wallet Name)
  final TextStyle cardTitle;

  // Input Labels (e.g. "Nombre", "Monto")
  final TextStyle inputLabel;

  // Body Text
  final TextStyle body;

  // Secondary/Small Text
  final TextStyle small;

  // Badges/Chips
  final TextStyle badge;

  const AppTypography({
    required this.pageTitle,
    required this.mobilePageTitle,
    required this.modalTitle,
    required this.mobileModalTitle,
    required this.sectionHeader,
    required this.mobileSectionHeader,
    required this.cardTitle,
    required this.inputLabel,
    required this.body,
    required this.small,
    required this.badge,
  });

  /// Define la tipografía base (Montserrat) y escala
  factory AppTypography.regular() {
    final base = GoogleFonts.montserrat();

    return AppTypography(
      // Page Titles
      pageTitle: base.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
      mobilePageTitle: base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ), // Ultra-Compact Mobile
      // Modal Titles
      modalTitle: base.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
      mobileModalTitle: base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ), // Match Mobile Page Title
      // Section Headers
      sectionHeader: base.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      mobileSectionHeader: base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ), // Match Card Title
      // Components
      cardTitle: base.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      inputLabel: base.copyWith(fontSize: 14, fontWeight: FontWeight.w500),

      // Content
      body: base.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      small: base.copyWith(fontSize: 12, fontWeight: FontWeight.w400),
      badge: base.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
    );
  }

  @override
  AppTypography copyWith({
    TextStyle? pageTitle,
    TextStyle? mobilePageTitle,
    TextStyle? modalTitle,
    TextStyle? mobileModalTitle,
    TextStyle? sectionHeader,
    TextStyle? mobileSectionHeader,
    TextStyle? cardTitle,
    TextStyle? inputLabel,
    TextStyle? body,
    TextStyle? small,
    TextStyle? badge,
  }) {
    return AppTypography(
      pageTitle: pageTitle ?? this.pageTitle,
      mobilePageTitle: mobilePageTitle ?? this.mobilePageTitle,
      modalTitle: modalTitle ?? this.modalTitle,
      mobileModalTitle: mobileModalTitle ?? this.mobileModalTitle,
      sectionHeader: sectionHeader ?? this.sectionHeader,
      mobileSectionHeader: mobileSectionHeader ?? this.mobileSectionHeader,
      cardTitle: cardTitle ?? this.cardTitle,
      inputLabel: inputLabel ?? this.inputLabel,
      body: body ?? this.body,
      small: small ?? this.small,
      badge: badge ?? this.badge,
    );
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      pageTitle: TextStyle.lerp(pageTitle, other.pageTitle, t)!,
      mobilePageTitle: TextStyle.lerp(
        mobilePageTitle,
        other.mobilePageTitle,
        t,
      )!,
      modalTitle: TextStyle.lerp(modalTitle, other.modalTitle, t)!,
      mobileModalTitle: TextStyle.lerp(
        mobileModalTitle,
        other.mobileModalTitle,
        t,
      )!,
      sectionHeader: TextStyle.lerp(sectionHeader, other.sectionHeader, t)!,
      mobileSectionHeader: TextStyle.lerp(
        mobileSectionHeader,
        other.mobileSectionHeader,
        t,
      )!,
      cardTitle: TextStyle.lerp(cardTitle, other.cardTitle, t)!,
      inputLabel: TextStyle.lerp(inputLabel, other.inputLabel, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      small: TextStyle.lerp(small, other.small, t)!,
      badge: TextStyle.lerp(badge, other.badge, t)!,
    );
  }
}

extension AppTypographyRecurring on AppTypography {
  TextStyle get recurringScopeTitle =>
      small.copyWith(fontWeight: FontWeight.w700);
  TextStyle get recurringScopeOption =>
      body.copyWith(fontWeight: FontWeight.w500);
}
