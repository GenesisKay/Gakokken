import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../../features/trash/presentation/pages/trash_screen.dart';
import '../../l10n/app_localizations.dart';
import '../services/favorites_service.dart';
import '../services/file_actions_service.dart';
import '../services/file_ops_service.dart';
import '../services/scaffold_messenger_service.dart';
import '../services/trash_service.dart';
import '../theme/theme_extensions.dart';
import 'file_dialogs.dart';
import 'file_thumbnail.dart';
import 'gakoken_options_sheet.dart';

/// Abre un archivo con el selector "Abrir con" del sistema y avisa si no se
/// pudo.
Future<void> openFileWithFeedback(BuildContext context, String path) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    final outcome = await FileActionsService.open(
      path,
      chooserTitle: l10n.openWithTitle,
    );
    switch (outcome) {
      case OpenOutcome.opened:
        break;
      case OpenOutcome.noApp:
        ScaffoldMessengerService.showInfo(l10n.fileNoApp);
      case OpenOutcome.missing:
        ScaffoldMessengerService.showInfo(l10n.fileMissing);
      case OpenOutcome.error:
        ScaffoldMessengerService.showInfo(l10n.fileOpenError);
    }
  } catch (_) {
    ScaffoldMessengerService.showInfo(l10n.fileOpenError);
  }
}

/// Comparte archivos con el menú del sistema.
Future<void> shareFiles(List<String> paths) => FileActionsService.share(
  paths,
).catchError((Object e) => ScaffoldMessengerService.showException(e));

/// Pide el nombre nuevo y renombra. Avisa si no se pudo.
Future<void> renameWithFeedback(
  BuildContext context, {
  required String path,
  required String name,
  required bool isDir,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final newName = await showRenameDialog(context, name: name, isDir: isDir);
  if (newName == null) return;
  try {
    await FileOpsService().rename(path, newName);
  } catch (_) {
    ScaffoldMessengerService.showInfo(l10n.renameError(newName));
  }
}

/// Pide el nombre y crea la carpeta dentro de [parentDir]. Devuelve su ruta,
/// o null si se canceló. Los errores (ya existe, solo lectura) se muestran
/// en el mismo diálogo.
Future<String?> createFolderWithFeedback(
  BuildContext context, {
  required String parentDir,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final name = await showNewFolderDialog(
    context,
    onCreate: (name) async {
      try {
        return switch (await FileOpsService().createFolder(parentDir, name)) {
          NewFolderStatus.created => null,
          NewFolderStatus.invalid => l10n.newFolderInvalid,
          NewFolderStatus.exists => l10n.newFolderExists,
          NewFolderStatus.denied => l10n.newFolderDenied,
          NewFolderStatus.failed => l10n.newFolderFailed,
        };
      } catch (_) {
        return l10n.newFolderFailed;
      }
    },
  );
  if (name == null) return null;
  ScaffoldMessengerService.showInfo(l10n.newFolderCreated(name));
  return p.join(parentDir, name);
}

/// Manda a la papelera y ofrece Deshacer.
Future<void> trashWithUndo(
  BuildContext context,
  Map<String, bool> pathsAndIsDir,
) async {
  final l10n = AppLocalizations.of(context)!;
  final navigator = Navigator.of(context);
  final trash = TrashService();
  final done = await trash.trash(pathsAndIsDir);
  final failed = pathsAndIsDir.length - done.length;
  if (done.isNotEmpty) {
    ScaffoldMessengerService.showWithAction(
      l10n.trashMoved(done.length),
      action: l10n.actionUndo,
      onAction: () => trash.restore(done),
      secondAction: l10n.trashOpen,
      onSecondAction: () => navigator.push(
        MaterialPageRoute<void>(builder: (_) => const TrashScreen()),
      ),
    );
  }
  if (failed > 0) ScaffoldMessengerService.showInfo(l10n.trashFailed(failed));
}

/// Copia o mueve con la pregunta de nombres repetidos y avisa al terminar.
/// Sin [sources] pega el portapapeles.
Future<void> transferWithFeedback(
  BuildContext context, {
  required String destDir,
  List<String>? sources,
  bool isMove = false,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final ops = FileOpsService();
  Future<ConflictPolicy?> resolve(List<String> names) =>
      showConflictDialog(context, names);
  final result = sources == null
      ? await ops.paste(destDir, resolve)
      : await ops.transfer(sources, destDir, isMove: isMove, resolve: resolve);
  if (result == null) return;
  if (result.cancelled) {
    ScaffoldMessengerService.showInfo(l10n.jobCancelled);
  } else if (result.failed.isNotEmpty) {
    ScaffoldMessengerService.showInfo(
      l10n.jobFailed(result.failed.length, result.failed.join(', ')),
    );
  } else {
    ScaffoldMessengerService.showInfo(l10n.jobDone(result.done));
  }
}

/// Opciones de un archivo o carpeta. El encabezado solo identifica el
/// elemento: miniatura o logo y nombre; el resto ya se ve en la fila.
/// [onShowUsage] agrega "Espacio usado" y [onOpenInNewTab] "Abrir en pestaña
/// nueva" a las carpetas. Sin [exists] solo queda Quitar de favoritos.
Future<void> showFileActionsSheet(
  BuildContext context, {
  required String path,
  required String name,
  required bool isDir,
  bool exists = true,
  VoidCallback? onShowUsage,
  VoidCallback? onOpenInNewTab,
}) {
  final l10n = AppLocalizations.of(context)!;
  final favorites = FavoritesService();
  final isFavorite = favorites.contains(path);

  return showGakokenOptionsSheet(
    context: context,
    header: Row(
      children: [
        FileThumbnail(path: path, name: name, isDir: isDir),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.typography.cardTitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
    options: [
      if (!isDir && exists) ...[
        GakokenSheetOption(
          icon: Icons.open_in_new_rounded,
          label: l10n.actionOpen,
          onTap: () => openFileWithFeedback(context, path),
        ),
        GakokenSheetOption(
          icon: Icons.share_rounded,
          label: l10n.actionShare,
          onTap: () => shareFiles([path]),
        ),
      ],
      if (isDir && exists && onOpenInNewTab != null)
        GakokenSheetOption(
          icon: Icons.tab_rounded,
          label: l10n.tabOpenNew,
          onTap: onOpenInNewTab,
        ),
      if (isDir && exists && onShowUsage != null)
        GakokenSheetOption(
          icon: Icons.pie_chart_outline_rounded,
          label: l10n.usageTitle,
          onTap: onShowUsage,
        ),
      // La ruta completa al portapapeles del sistema (pedido el 2026-10-23).
      GakokenSheetOption(
        icon: Icons.link_rounded,
        label: l10n.actionCopyPath,
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: path));
          ScaffoldMessengerService.showInfo(l10n.pathCopied);
        },
      ),
      isFavorite
          ? GakokenSheetOption(
              icon: Icons.star_rounded,
              label: l10n.actionRemoveFavorite,
              onTap: () => favorites.remove(path),
            )
          : GakokenSheetOption(
              icon: Icons.star_outline_rounded,
              label: l10n.actionAddFavorite,
              onTap: () => favorites.add(path, isDir: isDir),
            ),
      if (exists) ...[
        GakokenSheetOption(
          icon: Icons.drive_file_rename_outline_rounded,
          label: l10n.actionRename,
          onTap: () =>
              renameWithFeedback(context, path: path, name: name, isDir: isDir),
        ),
        GakokenSheetOption(
          icon: Icons.delete_outline_rounded,
          label: l10n.actionDelete,
          onTap: () => trashWithUndo(context, {path: isDir}),
        ),
      ],
    ],
  );
}
