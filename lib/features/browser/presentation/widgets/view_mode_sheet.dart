import 'package:flutter/material.dart';

import '../../../../core/services/explorer_settings_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/gakoken_options_sheet.dart';
import '../../../../l10n/app_localizations.dart';

IconData viewModeIcon(BrowserViewMode mode) => switch (mode) {
  BrowserViewMode.list => Icons.view_list_rounded,
  BrowserViewMode.details => Icons.table_rows_rounded,
  BrowserViewMode.grid => Icons.grid_view_rounded,
  BrowserViewMode.gallery => Icons.photo_library_rounded,
};

/// Elegir vista: Lista, Detalles, Cuadrícula o Galería, con [current]
/// marcada.
void showViewModeSheet(
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
  showGakokenOptionsSheet(
    context: context,
    header: Text(l10n.browserViewTitle, style: context.typography.modalTitle),
    options: [
      for (final mode in BrowserViewMode.values)
        GakokenSheetOption(
          icon: viewModeIcon(mode),
          label: labels[mode]!,
          selected: mode == current,
          onTap: () => onSelected(mode),
        ),
    ],
  );
}
