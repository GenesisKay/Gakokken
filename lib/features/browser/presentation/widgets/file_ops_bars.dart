import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/files/file_format.dart';
import '../../../../core/services/file_ops_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';

/// Contenedor común de las barras de abajo de Explorar.
class _Bar extends StatelessWidget {
  const _Bar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.bgElevated,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: child,
    );
  }
}

class SelectionAction {
  const SelectionAction(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;

  /// null la muestra desactivada.
  final VoidCallback? onTap;
}

/// Acciones sobre lo seleccionado: copiar, cortar, compartir, renombrar,
/// eliminar y más.
class SelectionBar extends StatelessWidget {
  const SelectionBar({super.key, required this.actions});

  final List<SelectionAction> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _Bar(
      child: Row(
        children: [
          for (final action in actions)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: action.onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        action.icon,
                        color: action.onTap == null
                            ? colors.textDisabled
                            : colors.textPrimary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.small.copyWith(
                          color: action.onTap == null
                              ? colors.textDisabled
                              : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Lo que está en el portapapeles, con Nueva carpeta y Pegar aquí. Sirve en
/// cualquier pestaña y carpeta.
class PasteBar extends StatelessWidget {
  const PasteBar({super.key, required this.onPaste, required this.onNewFolder});

  final VoidCallback? onPaste;

  /// Crea la carpeta destino sin perder el portapapeles.
  final VoidCallback? onNewFolder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ops = FileOpsService();
    final count = ops.clipboard.length;
    return _Bar(
      child: Row(
        children: [
          Icon(
            ops.clipboardMode == ClipboardMode.cut
                ? Icons.content_cut_rounded
                : Icons.content_copy_rounded,
            color: context.colors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ops.clipboardMode == ClipboardMode.cut
                  ? l10n.clipboardCut(count)
                  : l10n.clipboardCopied(count),
              style: context.typography.body,
            ),
          ),
          TextButton(
            onPressed: ops.clearClipboard,
            child: Text(l10n.btnCancel),
          ),
          IconButton(
            tooltip: l10n.newFolderTitle,
            icon: const Icon(Icons.create_new_folder_outlined),
            color: context.colors.textPrimary,
            disabledColor: context.colors.textDisabled,
            onPressed: onNewFolder,
          ),
          FilledButton(onPressed: onPaste, child: Text(l10n.pasteHere)),
        ],
      ),
    );
  }
}

/// Progreso de la tarea de copiar o mover, con Cancelar.
class JobPanel extends StatelessWidget {
  const JobPanel({super.key, required this.job});

  final FileJob job;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final progress = job.progress;
    final done = (progress?.doneItems ?? 0) + 1;
    final title = job.isMove
        ? l10n.jobMoving(done.clamp(1, job.total), job.total)
        : l10n.jobCopying(done.clamp(1, job.total), job.total);
    final detail = progress == null
        ? ''
        : '${progress.current} · ${formatBytes(progress.doneBytes, locale)} / '
              '${formatBytes(progress.totalBytes, locale)}';
    final percent = NumberFormat.percentPattern(locale).format(job.fraction);

    return _Bar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: context.typography.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(percent, style: context.typography.small),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: job.fraction,
                      minHeight: 6,
                      color: colors.primary,
                      backgroundColor: colors.surfaceHover,
                    ),
                  ),
                  if (detail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.small.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: FileOpsService().cancel,
              child: Text(l10n.btnCancel),
            ),
          ],
        ),
      ),
    );
  }
}
