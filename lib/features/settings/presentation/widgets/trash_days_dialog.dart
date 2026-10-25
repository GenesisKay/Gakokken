import 'package:flutter/material.dart';

import '../../../../core/services/trash_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';

/// Cuántos días se guarda lo borrado (Ajustes, Días en la papelera). Bajar
/// el número borra al guardar lo que ya lleve más tiempo; el diálogo lo dice.
Future<void> showTrashDaysDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final trash = TrashService();
  final controller = TextEditingController(text: '${trash.retentionDays}');
  final days = await showDialog<int>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) {
        final value = int.tryParse(controller.text.trim());
        final valid =
            value != null && value >= 1 && value <= TrashService.maxDays;
        void submit() {
          if (valid) Navigator.pop(dialogContext, value);
        }

        return AlertDialog(
          backgroundColor: dialogContext.colors.bgElevated,
          title: Text(
            l10n.trashDaysTitle,
            style: dialogContext.typography.modalTitle,
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: dialogContext.typography.body,
            decoration: InputDecoration(
              suffixText: l10n.trashDaysUnit,
              helperText: l10n.trashDaysHelp(TrashService.maxDays),
              helperMaxLines: 3,
              errorText: valid ? null : l10n.trashDaysInvalid,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => submit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.btnCancel),
            ),
            FilledButton(
              onPressed: valid ? submit : null,
              child: Text(l10n.btnSave),
            ),
          ],
        );
      },
    ),
  );
  controller.dispose();
  if (days != null && days != trash.retentionDays) {
    await trash.setRetentionDays(days);
  }
}
