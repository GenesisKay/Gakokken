import 'package:flutter/material.dart';

import '../../../../core/services/explorer_settings_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/gakoken_bottom_sheet.dart';
import '../../../../core/widgets/modal_drag_handle.dart';
import '../../../../l10n/app_localizations.dart';

/// Archivos y carpetas ocultos (los que empiezan con punto): verlos en
/// Explorar y, aparte, incluirlos en Buscar (pedido el 2026-10-20).
void showHiddenFilesSheet(BuildContext context) {
  showGakokenBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    builder: (_) => const _HiddenFilesSheet(),
  );
}

/// Texto del valor en la fila de Ajustes.
String hiddenFilesLabel(AppLocalizations l10n) {
  final settings = ExplorerSettingsService();
  if (settings.showHidden && settings.searchHidden) {
    return l10n.hiddenEverywhere;
  }
  if (settings.showHidden) return l10n.hiddenInExplore;
  if (settings.searchHidden) return l10n.hiddenInSearch;
  return l10n.hiddenOff;
}

class _HiddenFilesSheet extends StatelessWidget {
  const _HiddenFilesSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final settings = ExplorerSettingsService();

    Widget toggle(String title, bool value, ValueChanged<bool> onChanged) =>
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: context.typography.body.copyWith(color: colors.textPrimary),
          ),
          value: value,
          activeThumbColor: colors.primary,
          onChanged: onChanged,
        );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + gakokenSheetBottomInset(context),
      ),
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModalDragHandle(),
            Text(l10n.hiddenTitle, style: context.typography.modalTitle),
            const SizedBox(height: 8),
            Text(
              l10n.hiddenDescription,
              style: context.typography.body.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            toggle(
              l10n.hiddenShowInExplore,
              settings.showHidden,
              settings.setShowHidden,
            ),
            toggle(
              l10n.hiddenIncludeInSearch,
              settings.searchHidden,
              settings.setSearchHidden,
            ),
          ],
        ),
      ),
    );
  }
}
