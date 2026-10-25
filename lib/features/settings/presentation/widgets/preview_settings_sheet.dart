import 'package:flutter/material.dart';

import '../../../../core/files/file_kind.dart';
import '../../../../core/files/file_labels.dart';
import '../../../../core/services/preview_settings_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/file_kind_icon.dart';
import '../../../../core/widgets/gakoken_bottom_sheet.dart';
import '../../../../core/widgets/modal_drag_handle.dart';
import '../../../../l10n/app_localizations.dart';

/// Elegir, por tipo de archivo, si se ve una miniatura o el logo del tipo.
void showPreviewSettingsSheet(BuildContext context) {
  showGakokenBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    builder: (_) => const _PreviewSettingsSheet(),
  );
}

/// Texto del valor en la fila de Ajustes: los tipos con miniatura.
String previewSettingsLabel(AppLocalizations l10n) {
  final enabled = PreviewSettingsService.kinds
      .where(PreviewSettingsService().isEnabled)
      .map((kind) => kindLabel(l10n, kind))
      .toList();
  return enabled.isEmpty ? l10n.previewOff : enabled.join(', ');
}

class _PreviewSettingsSheet extends StatelessWidget {
  const _PreviewSettingsSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final settings = PreviewSettingsService();

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
            Text(l10n.previewTitle, style: context.typography.modalTitle),
            const SizedBox(height: 8),
            Text(
              l10n.previewDescription,
              style: context.typography.body.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            for (final kind in PreviewSettingsService.kinds)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: FileKindIcon(kind: kind, size: 32),
                title: Text(
                  kindLabel(l10n, kind),
                  style: context.typography.body.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                subtitle: switch (_note(l10n, kind)) {
                  final note? => Text(
                    note,
                    style: context.typography.small.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  null => null,
                },
                value: settings.isEnabled(kind),
                activeThumbColor: colors.primary,
                onChanged: (value) => settings.setEnabled(kind, value),
              ),
          ],
        ),
      ),
    );
  }
}

/// Qué muestra la miniatura cuando no es obvio.
String? _note(AppLocalizations l10n, FileKind kind) => switch (kind) {
  FileKind.pdf => l10n.previewPdfNote,
  FileKind.video => l10n.previewVideoNote,
  _ => null,
};
