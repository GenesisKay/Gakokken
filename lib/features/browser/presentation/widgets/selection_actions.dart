import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/files/file_entry.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/services/file_ops_service.dart';
import '../../../../core/services/haptics_service.dart';
import '../../../../core/services/scaffold_messenger_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/file_actions.dart';
import '../../../../core/widgets/file_info_sheet.dart';
import '../../../../core/widgets/gakoken_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import 'file_ops_bars.dart';

/// Barra de arriba mientras hay selección: cuántos, la X para soltarla,
/// [actions] y seleccionar todo. Igual en Explorar, Favoritos, la Papelera
/// y los archivos de un tipo.
PreferredSizeWidget selectionAppBar(
  BuildContext context, {
  required int count,
  required VoidCallback onClose,
  required VoidCallback onSelectAll,
  List<Widget> actions = const [],
  bool busy = false,
}) {
  final l10n = AppLocalizations.of(context)!;
  final colors = context.colors;
  return GakokenAppBar(
    title: l10n.selectionCount(count),
    busy: busy,
    leading: IconButton(
      tooltip: l10n.btnCancel,
      icon: Icon(Icons.close_rounded, color: colors.textPrimary),
      onPressed: onClose,
    ),
    actions: [
      ...actions,
      IconButton(
        tooltip: l10n.selectAll,
        icon: Icon(Icons.select_all_rounded, color: colors.textPrimary),
        onPressed: () {
          HapticsService().tick();
          onSelectAll();
        },
      ),
    ],
  );
}

/// Información y favorito de los archivos seleccionados, para la barra de
/// arriba. [clear] suelta la selección. Sin [info] no hay Información
/// (Favoritos no sabe tamaño ni fecha).
List<Widget> fileSelectionTopActions(
  BuildContext context,
  List<FileEntry> entries, {
  required VoidCallback clear,
  bool info = true,
}) {
  final l10n = AppLocalizations.of(context)!;
  final colors = context.colors;
  final favorites = FavoritesService();
  final allFavorite = entries.every((e) => favorites.contains(e.path));
  return [
    if (info)
      IconButton(
        tooltip: l10n.actionInfo,
        icon: Icon(Icons.info_outline_rounded, color: colors.textPrimary),
        onPressed: () => showEntryInfoSheet(context, entries),
      ),
    IconButton(
      tooltip: allFavorite ? l10n.actionRemoveFavorite : l10n.actionAddFavorite,
      icon: Icon(
        allFavorite ? Icons.star_rounded : Icons.star_border_rounded,
        color: allFavorite ? colors.primary : colors.textPrimary,
      ),
      onPressed: () => _toggleFavorites(entries, allFavorite, l10n, clear),
    ),
  ];
}

/// Agrega todo lo seleccionado a favoritos, o lo quita si ya estaba todo.
Future<void> _toggleFavorites(
  List<FileEntry> entries,
  bool remove,
  AppLocalizations l10n,
  VoidCallback clear,
) async {
  final favorites = FavoritesService();
  clear();
  for (final entry in entries) {
    if (remove) {
      await favorites.remove(entry.path);
    } else {
      await favorites.add(entry.path, isDir: entry.isDir);
    }
  }
  ScaffoldMessengerService.showInfo(
    remove
        ? l10n.favoritesRemovedMany(entries.length)
        : l10n.favoritesAddedMany(entries.length),
  );
}

/// Copiar, cortar, compartir, renombrar, eliminar y más, para la barra de
/// abajo. Con uno solo, "Más" abre un menú con Abrir y Copiar ruta; [onShowUsage] y
/// [onOpenInNewTab] las agregan para carpetas. [exists] dice si un favorito
/// sigue en su lugar (si no, "Más" solo ofrece quitarlo).
List<SelectionAction> fileSelectionActions(
  BuildContext context,
  List<FileEntry> entries, {
  required VoidCallback clear,
  ValueChanged<String>? onShowUsage,
  ValueChanged<String>? onOpenInNewTab,
  bool Function(String path)? exists,
}) {
  final l10n = AppLocalizations.of(context)!;
  final paths = [for (final e in entries) e.path];
  final files = [
    for (final e in entries)
      if (!e.isDir) e.path,
  ];
  final single = entries.length == 1 ? entries.first : null;
  void toClipboard(ClipboardMode mode) {
    FileOpsService().setClipboard(paths, mode);
    clear();
  }

  return [
    SelectionAction(
      Icons.content_copy_rounded,
      l10n.actionCopy,
      () => toClipboard(ClipboardMode.copy),
    ),
    SelectionAction(
      Icons.content_cut_rounded,
      l10n.actionCut,
      () => toClipboard(ClipboardMode.cut),
    ),
    SelectionAction(
      Icons.share_rounded,
      l10n.actionShare,
      // Solo archivos: las carpetas no se pueden compartir.
      files.isEmpty ? null : () => shareFiles(files),
    ),
    SelectionAction(
      Icons.drive_file_rename_outline_rounded,
      l10n.actionRename,
      single == null
          ? null
          : () {
              clear();
              renameWithFeedback(
                context,
                path: single.path,
                name: single.name,
                isDir: single.isDir,
              );
            },
    ),
    SelectionAction(Icons.delete_outline_rounded, l10n.actionDelete, () {
      clear();
      trashWithUndo(context, {for (final e in entries) e.path: e.isDir});
    }),
    // Solo lo que no está ya a la vista: compartir, renombrar y eliminar van
    // en esta barra; información y favorito, arriba. La selección se suelta
    // al elegir una opción, no al abrir el menú.
    SelectionAction.menu(
      Icons.more_horiz_rounded,
      l10n.actionMore,
      single == null
          ? const []
          : _moreItems(
              context,
              single,
              clear: clear,
              exists: exists?.call(single.path) ?? true,
              onShowUsage: onShowUsage,
              onOpenInNewTab: onOpenInNewTab,
            ),
    ),
  ];
}

List<SelectionAction> _moreItems(
  BuildContext context,
  FileEntry entry, {
  required VoidCallback clear,
  required bool exists,
  ValueChanged<String>? onShowUsage,
  ValueChanged<String>? onOpenInNewTab,
}) {
  final l10n = AppLocalizations.of(context)!;
  final path = entry.path;
  VoidCallback then(VoidCallback action) => () {
    clear();
    action();
  };
  return [
    if (!entry.isDir && exists)
      SelectionAction(
        Icons.open_in_new_rounded,
        l10n.actionOpen,
        then(() => openFileWithFeedback(context, path)),
      ),
    if (entry.isDir && exists && onOpenInNewTab != null)
      SelectionAction(
        Icons.tab_rounded,
        l10n.tabOpenNew,
        then(() => onOpenInNewTab(path)),
      ),
    if (entry.isDir && exists && onShowUsage != null)
      SelectionAction(
        Icons.pie_chart_outline_rounded,
        l10n.usageTitle,
        then(() => onShowUsage(path)),
      ),
    SelectionAction(
      Icons.link_rounded,
      l10n.actionCopyPath,
      then(() async {
        await Clipboard.setData(ClipboardData(text: path));
        ScaffoldMessengerService.showInfo(l10n.pathCopied);
      }),
    ),
  ];
}
