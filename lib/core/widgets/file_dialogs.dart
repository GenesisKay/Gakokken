import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../services/file_ops_service.dart';
import '../theme/theme_extensions.dart';

/// Pide el nombre nuevo. El nombre llega seleccionado sin la extensión, para
/// escribir encima sin perderla. null si se cancela o no cambia.
Future<String?> showRenameDialog(
  BuildContext context, {
  required String name,
  required bool isDir,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final dot = name.lastIndexOf('.');
  final controller = TextEditingController(text: name)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: !isDir && dot > 0 ? dot : name.length,
    );
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      void submit() => Navigator.pop(dialogContext, controller.text.trim());
      return AlertDialog(
        backgroundColor: dialogContext.colors.bgElevated,
        title: Text(
          l10n.renameTitle,
          style: dialogContext.typography.modalTitle,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: dialogContext.typography.body,
          onSubmitted: (_) => submit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(onPressed: submit, child: Text(l10n.renameAction)),
        ],
      );
    },
  );
  controller.dispose();
  if (result == null || result.isEmpty || result == name) return null;
  return result;
}

/// Pide el nombre de una carpeta nueva. [onCreate] la crea y devuelve el
/// error a mostrar, o null si salió bien; con error el diálogo sigue abierto
/// para corregir el nombre. Devuelve el nombre creado, o null si se cancela.
Future<String?> showNewFolderDialog(
  BuildContext context, {
  required Future<String?> Function(String name) onCreate,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();
  String? error;
  var busy = false;
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) {
        Future<void> submit() async {
          final name = controller.text.trim();
          if (busy) return;
          if (name.isEmpty) {
            setState(() => error = l10n.newFolderInvalid);
            return;
          }
          setState(() => busy = true);
          final message = await onCreate(name);
          if (!dialogContext.mounted) return;
          if (message == null) {
            Navigator.pop(dialogContext, name);
          } else {
            setState(() {
              busy = false;
              error = message;
            });
          }
        }

        return AlertDialog(
          backgroundColor: dialogContext.colors.bgElevated,
          title: Text(
            l10n.newFolderTitle,
            style: dialogContext.typography.modalTitle,
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: dialogContext.typography.body,
            decoration: InputDecoration(
              hintText: l10n.newFolderHint,
              errorText: error,
              errorMaxLines: 3,
            ),
            onChanged: (_) {
              if (error != null) setState(() => error = null);
            },
            onSubmitted: (_) => submit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.btnCancel),
            ),
            FilledButton(
              onPressed: busy ? null : submit,
              child: Text(l10n.newFolderCreate),
            ),
          ],
        );
      },
    ),
  );
  controller.dispose();
  return result;
}

/// Ya hay elementos con el mismo nombre en el destino: reemplazar, mantener
/// los dos (`nombre (1)`) u omitirlos. null es cancelar todo.
Future<ConflictPolicy?> showConflictDialog(
  BuildContext context,
  List<String> names,
) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<ConflictPolicy>(
    context: context,
    builder: (dialogContext) {
      final colors = dialogContext.colors;
      final shown = names.take(5).join('\n');
      final more = names.length > 5 ? '\n…' : '';
      Widget option(String label, ConflictPolicy policy) => SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.pop(dialogContext, policy),
          child: Text(label),
        ),
      );
      return AlertDialog(
        backgroundColor: colors.bgElevated,
        title: Text(
          l10n.conflictTitle(names.length),
          style: dialogContext.typography.modalTitle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$shown$more',
              style: dialogContext.typography.body.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            option(l10n.conflictKeepBoth, ConflictPolicy.keepBoth),
            const SizedBox(height: 8),
            option(l10n.conflictReplace, ConflictPolicy.replace),
            const SizedBox(height: 8),
            option(l10n.conflictSkip, ConflictPolicy.skip),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.btnCancel),
          ),
        ],
      );
    },
  );
}

/// Confirmación para lo que no se puede deshacer.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirm,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: dialogContext.colors.bgElevated,
      title: Text(title, style: dialogContext.typography.modalTitle),
      content: Text(message, style: dialogContext.typography.body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.btnCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: dialogContext.colors.stateError,
            foregroundColor: dialogContext.colors.textInverse,
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirm),
        ),
      ],
    ),
  );
  return ok ?? false;
}
