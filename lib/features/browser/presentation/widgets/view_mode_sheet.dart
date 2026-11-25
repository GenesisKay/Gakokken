import 'package:flutter/material.dart';

import '../../../../core/services/explorer_settings_service.dart';
import '../../../../core/widgets/anchored_menu.dart';
import '../../../../l10n/app_localizations.dart';

IconData viewModeIcon(BrowserViewMode mode) => switch (mode) {
  BrowserViewMode.list => Icons.view_list_rounded,
  BrowserViewMode.details => Icons.table_rows_rounded,
  BrowserViewMode.grid => Icons.grid_view_rounded,
  BrowserViewMode.gallery => Icons.photo_library_rounded,
};

/// Elegir vista: Lista, Detalles, Cuadrícula o Galería, con [current]
/// marcada, en una lista flotante pegada al botón [context] (G-13).
void showViewModeMenu(
  BuildContext context, {
  required BrowserViewMode current,
  required ValueChanged<BrowserViewMode> onSelected,
}) {
  final l10n = AppLocalizations.of(context)!;
  final labels = {
    BrowserViewMode.list: l10n.viewList,
    BrowserViewMode.details: l10n.viewDetails,
    BrowserViewMode.grid: l10n.viewGrid,
    BrowserViewMode.gallery: l10n.viewGallery,
  };
  showAnchoredMenu(
    anchor: context,
    options: [
      for (final mode in BrowserViewMode.values)
        AnchoredMenuOption(
          icon: viewModeIcon(mode),
          label: labels[mode]!,
          selected: mode == current,
          onTap: () => onSelected(mode),
        ),
    ],
  );
}
