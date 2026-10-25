import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/files/file_entry.dart';
import '../../../../core/files/file_labels.dart';
import '../../../../core/services/explorer_settings_service.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/services/file_ops_service.dart';
import '../../../../core/services/index_service.dart';
import '../../../../core/services/scaffold_messenger_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/file_actions.dart';
import '../../../../core/widgets/file_info_sheet.dart';
import '../../../../core/widgets/gakoken_app_bar.dart';
import '../../../../core/widgets/volume_picker_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../search/presentation/pages/search_screen.dart';
import '../controllers/browser_controller.dart';
import '../controllers/explorer_controller.dart';
import '../widgets/entry_views.dart';
import '../widgets/explorer_tab_strip.dart';
import '../widgets/file_ops_bars.dart';
import '../widgets/sort_filter_sheet.dart';
import '../widgets/folder_title.dart';

/// Pestaña Explorar: carpetas y archivos de las memorias, en una o varias
/// pestañas.
class BrowserScreen extends StatelessWidget {
  const BrowserScreen({
    super.key,
    required this.explorer,
    required this.onShowUsage,
  });

  final ExplorerController explorer;

  /// Abre el espacio usado de una carpeta (pestaña Espacio de la barra).
  final ValueChanged<String> onShowUsage;

  @override
  Widget build(BuildContext context) {
    final settings = ExplorerSettingsService();
    return ListenableBuilder(
      listenable: Listenable.merge([explorer, settings, FileOpsService()]),
      builder: (context, _) => ListenableBuilder(
        listenable: explorer.active,
        builder: (context, _) => _build(context, explorer.active, settings),
      ),
    );
  }

  Widget _build(
    BuildContext context,
    BrowserController tab,
    ExplorerSettingsService settings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final granted = explorer.permissionGranted;

    final ops = FileOpsService();
    final job = ops.job;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: tab.selecting
          ? _selectionAppBar(context, tab)
          : GakokenAppBar(
              // Sin permiso todavía no hay carpeta: el título es Explorar.
              title: granted == true ? null : l10n.navExplore,
              titleWidget: granted == true
                  ? FolderTitle(
                      trail: tab.trail,
                      volume: tab.volume,
                      onOpen: tab.open,
                      actions: [
                        FolderMenuAction(
                          Icons.create_new_folder_outlined,
                          l10n.newFolderTitle,
                          tab.failed ? null : () => _newFolder(context, tab),
                        ),
                        FolderMenuAction(
                          Icons.sd_storage_outlined,
                          l10n.volumesTitle,
                          () => showVolumePickerSheet(
                            context,
                            current: tab.path,
                            onSelected: (volume) => tab.open(volume.path),
                          ),
                        ),
                        FolderMenuAction(
                          Icons.add_rounded,
                          l10n.tabNew,
                          () => explorer.newTab(),
                        ),
                      ],
                    )
                  : null,
              isRootScreen: true,
              // Atrás y adelante del historial, arriba a la izquierda.
              leading: granted == true ? _HistoryButtons(tab: tab) : null,
              leadingWidth: granted == true ? _HistoryButtons.width : null,
              actions: [
                if (granted == true) ...[
                  IconButton(
                    tooltip: l10n.searchTitle,
                    icon: Icon(context.icons.search, color: colors.textPrimary),
                    onPressed: () => _openSearch(context, tab),
                  ),
                  // Vista, orden y filtro en una sola hoja. Los filtros
                  // activos se ven como chips arriba de la lista.
                  IconButton(
                    tooltip: l10n.browserDisplayTitle,
                    icon: Icon(Icons.tune_rounded, color: colors.textPrimary),
                    onPressed: () => showSortFilterSheet(context, tab),
                  ),
                ],
              ],
            ),
      body: switch (granted) {
        null => const SizedBox.shrink(),
        false => _PermissionView(onGrant: explorer.requestPermission),
        true => Column(
          children: [
            if (explorer.tabs.length > 1)
              ExplorerTabStrip(controller: explorer),
            if (tab.kindFilter.isNotEmpty) _ActiveFilters(tab: tab),
            const _FirstIndexBanner(),
            SizedBox(
              height: 2,
              child: tab.loading && tab.entries.isNotEmpty
                  ? LinearProgressIndicator(color: colors.primary)
                  : null,
            ),
            Expanded(child: _content(context, tab, settings)),
            if (job != null) JobPanel(job: job),
            if (tab.selecting)
              SelectionBar(actions: _selectionActions(context, tab))
            else if (ops.clipboard.isNotEmpty)
              PasteBar(
                onPaste: tab.failed
                    ? null
                    : () => transferWithFeedback(context, destDir: tab.path),
                onNewFolder: tab.failed ? null : () => _newFolder(context, tab),
              ),
          ],
        ),
      },
    );
  }

  Widget _content(
    BuildContext context,
    BrowserController tab,
    ExplorerSettingsService settings,
  ) {
    final entries = tab.entries;
    final l10n = AppLocalizations.of(context)!;
    if (entries.isEmpty) {
      if (tab.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return _Message(
        tab.failed
            ? l10n.browserCannotRead
            : tab.totalCount > 0
            ? l10n.browserNoMatches
            : l10n.browserEmpty,
      );
    }
    return RefreshIndicator(
      onRefresh: () async => tab.reload(),
      child: EntryViews(
        // La llave por pestaña, carpeta y vista guarda la posición de scroll.
        key: PageStorageKey(
          '${identityHashCode(tab)}|${tab.path}|${settings.viewMode.name}',
        ),
        entries: entries,
        mode: settings.viewMode,
        sortField: settings.sortField,
        ascending: settings.ascending,
        onSortColumn: settings.tapSort,
        selected: tab.selected,
        onTap: (entry) => tab.selecting
            ? tab.toggleSelection(entry.path)
            : _onTap(context, tab, entry),
        // Mantener presionado selecciona; con uno solo, "Más" abre sus opciones.
        onLongPress: (entry) => tab.toggleSelection(entry.path),
      ),
    );
  }

  PreferredSizeWidget _selectionAppBar(
    BuildContext context,
    BrowserController tab,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final favorites = FavoritesService();
    final allFavorite = tab.selected.every(favorites.contains);
    return GakokenAppBar(
      title: l10n.selectionCount(tab.selected.length),
      leading: IconButton(
        tooltip: l10n.btnCancel,
        icon: Icon(Icons.close_rounded, color: colors.textPrimary),
        onPressed: tab.clearSelection,
      ),
      actions: [
        IconButton(
          tooltip: l10n.actionInfo,
          icon: Icon(Icons.info_outline_rounded, color: colors.textPrimary),
          onPressed: () => showEntryInfoSheet(context, tab.selectedEntries),
        ),
        IconButton(
          tooltip: allFavorite
              ? l10n.actionRemoveFavorite
              : l10n.actionAddFavorite,
          icon: Icon(
            allFavorite ? Icons.star_rounded : Icons.star_border_rounded,
            color: allFavorite ? colors.primary : colors.textPrimary,
          ),
          onPressed: () => _toggleFavorites(tab, allFavorite, l10n),
        ),
        IconButton(
          tooltip: l10n.selectAll,
          icon: Icon(Icons.select_all_rounded, color: colors.textPrimary),
          onPressed: tab.selectAll,
        ),
      ],
    );
  }

  /// Agrega todo lo seleccionado a favoritos, o lo quita si ya estaba todo.
  Future<void> _toggleFavorites(
    BrowserController tab,
    bool remove,
    AppLocalizations l10n,
  ) async {
    final entries = tab.selectedEntries;
    final favorites = FavoritesService();
    tab.clearSelection();
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

  List<SelectionAction> _selectionActions(
    BuildContext context,
    BrowserController tab,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final entries = tab.selectedEntries;
    final paths = [for (final e in entries) e.path];
    final files = [
      for (final e in entries)
        if (!e.isDir) e.path,
    ];
    final single = entries.length == 1 ? entries.first : null;
    void toClipboard(ClipboardMode mode) {
      FileOpsService().setClipboard(paths, mode);
      tab.clearSelection();
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
                tab.clearSelection();
                renameWithFeedback(
                  context,
                  path: single.path,
                  name: single.name,
                  isDir: single.isDir,
                );
              },
      ),
      SelectionAction(Icons.delete_outline_rounded, l10n.actionDelete, () {
        tab.clearSelection();
        trashWithUndo(context, {for (final e in entries) e.path: e.isDir});
      }),
      SelectionAction(
        Icons.more_horiz_rounded,
        l10n.actionMore,
        single == null
            ? null
            : () {
                tab.clearSelection();
                showFileActionsSheet(
                  context,
                  path: single.path,
                  name: single.name,
                  isDir: single.isDir,
                  onShowUsage: () => onShowUsage(single.path),
                  onOpenInNewTab: () => explorer.newTab(single.path),
                );
              },
      ),
    ];
  }

  void _onTap(BuildContext context, BrowserController tab, FileEntry entry) {
    if (entry.isDir) {
      tab.open(entry.path);
    } else {
      openFileWithFeedback(context, entry.path);
    }
  }

  /// Crea una carpeta aquí. Si hay algo copiado o cortado, entra a ella para
  /// pegarlo ahí; el portapapeles no se toca.
  Future<void> _newFolder(BuildContext context, BrowserController tab) async {
    final created = await createFolderWithFeedback(
      context,
      parentDir: tab.path,
    );
    if (created != null && FileOpsService().clipboard.isNotEmpty) {
      tab.open(created);
    }
  }

  void _openSearch(BuildContext context, BrowserController tab) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          // Solo se limita a la carpeta si su memoria está indexada (no USB).
          currentPath: tab.canGoUp && tab.volume.indexed ? tab.path : null,
          onOpenFolder: tab.open,
        ),
      ),
    );
  }
}

/// Atrás y adelante del historial de la pestaña.
class _HistoryButtons extends StatelessWidget {
  const _HistoryButtons({required this.tab});

  final BrowserController tab;

  static const width = 96.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    Widget button(IconData icon, String tooltip, VoidCallback? onPressed) =>
        IconButton(
          tooltip: tooltip,
          icon: Icon(icon),
          color: colors.textPrimary,
          disabledColor: colors.textDisabled,
          onPressed: onPressed,
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        button(
          Icons.arrow_back_rounded,
          l10n.navBack,
          tab.canGoBack ? tab.goBack : null,
        ),
        button(
          Icons.arrow_forward_rounded,
          l10n.navForward,
          tab.canGoForward ? tab.goForward : null,
        ),
      ],
    );
  }
}

/// Tipos filtrados en esta pestaña, siempre a la vista para que no parezca
/// que faltan archivos. La X de cada uno lo quita.
class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({required this.tab});

  final BrowserController tab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          for (final kind in tab.kindFilter)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InputChip(
                label: Text(kindLabel(l10n, kind)),
                labelStyle: context.typography.small.copyWith(
                  color: colors.textPrimary,
                ),
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                side: BorderSide(color: colors.primary),
                deleteIcon: const Icon(Icons.close_rounded, size: 16),
                deleteButtonTooltipMessage: l10n.filterClear,
                onDeleted: () => tab.toggleKind(kind),
              ),
            ),
        ],
      ),
    );
  }
}

/// Aviso del primer indexado, el único que tarda: después la búsqueda y el
/// espacio usado funcionan con el índice guardado mientras se actualiza.
class _FirstIndexBanner extends StatelessWidget {
  const _FirstIndexBanner();

  @override
  Widget build(BuildContext context) {
    final index = IndexService();
    return ListenableBuilder(
      listenable: index,
      builder: (context, _) {
        if (index.ready || !index.indexing) return const SizedBox.shrink();
        final l10n = AppLocalizations.of(context)!;
        final count = NumberFormat.decimalPattern(
          Localizations.localeOf(context).toString(),
        ).format(index.scanned);
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.colors.bgElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.borderSubtle),
          ),
          child: Row(
            children: [
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.indexingProgress(count),
                  style: context.typography.small.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PermissionView extends StatelessWidget {
  const _PermissionView({required this.onGrant});

  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_rounded, size: 64, color: colors.primary),
            const SizedBox(height: 16),
            Text(
              l10n.browserPermissionText,
              textAlign: TextAlign.center,
              style: context.typography.body.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onGrant,
              child: Text(l10n.btnGrantPermission),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: context.typography.body.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
