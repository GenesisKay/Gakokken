import 'package:gakoken/core/tutorial/gakoken_tours.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/files/file_entry.dart';
import '../../../../core/services/explorer_settings_service.dart';
import '../../../../core/services/file_ops_service.dart';
import '../../../../core/services/index_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/file_actions.dart';
import '../../../../core/widgets/gakoken_app_bar.dart';
import '../../../../core/widgets/kind_filter_chips.dart';
import '../../../../core/widgets/storage_permission_view.dart';
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
import '../widgets/selection_actions.dart';

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
              busy: _busy(tab),
              // Sin permiso todavía no hay carpeta: el título es Explorar.
              title: granted == true ? null : l10n.navExplore,
              titleWidget: granted == true
                  ? FolderTitle(
                      trail: tab.trail,
                      onOpen: tab.open,
                      actions: [
                        FolderMenuAction(
                          Icons.sd_storage_outlined,
                          l10n.volumesTitle,
                          () => showVolumePickerSheet(
                            context,
                            current: tab.path,
                            onSelected: (volume) => tab.open(volume.path),
                          ),
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
                  // Siempre a la vista, haya o no algo copiado (pedido el
                  // 2026-10-30).
                  IconButton(
                    tooltip: l10n.newFolderTitle,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.create_new_folder_outlined),
                    color: colors.textPrimary,
                    disabledColor: colors.textDisabled,
                    onPressed: tab.failed
                        ? null
                        : () => _newFolder(context, tab),
                  ),
                  KeyedSubtree(key: GakokenTourKeys.search, child: IconButton(
                    tooltip: l10n.searchTitle,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(context.icons.search, color: colors.textPrimary),
                    onPressed: () => _openSearch(context, tab),
                  )),
                  // Vista, orden y filtro en una sola hoja. Los filtros
                  // activos se ven como chips arriba de la lista.
                  KeyedSubtree(key: GakokenTourKeys.display, child: IconButton(
                    tooltip: l10n.browserDisplayTitle,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.tune_rounded, color: colors.textPrimary),
                    onPressed: () => showSortFilterSheet(context, tab),
                  )),
                  // Pestaña nueva a la vista con una sola pestaña; con dos o
                  // más la tira ya muestra su "+" y este se quita (pedido el
                  // 2026-11-10; antes estaba en el menú del título).
                  if (explorer.tabs.length == 1)
                    IconButton(
                      tooltip: l10n.tabNew,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.add_rounded, color: colors.textPrimary),
                      onPressed: () => explorer.newTab(),
                    ),
                ],
              ],
            ),
      body: switch (granted) {
        null => const SizedBox.shrink(),
        false => StoragePermissionView(onGrant: explorer.requestPermission),
        true => Column(
          children: [
            if (explorer.tabs.length > 1)
              ExplorerTabStrip(controller: explorer),
            if (tab.kindFilter.isNotEmpty) ActiveKindFilters(filter: tab),
            const _FirstIndexBanner(),
            Expanded(child: _content(context, tab, settings)),
            if (job != null) JobPanel(job: job),
            if (tab.selecting)
              SelectionBar(
                actions: fileSelectionActions(
                  context,
                  tab.selectedEntries,
                  clear: tab.clearSelection,
                  onShowUsage: onShowUsage,
                  onOpenInNewTab: explorer.newTab,
                ),
              )
            else if (ops.clipboard.isNotEmpty)
              PasteBar(
                onPaste: tab.failed
                    ? null
                    : () => transferWithFeedback(context, destDir: tab.path),
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
        // La llave por pestaña, carpeta, vista y agrupar guarda la posición
        // de scroll.
        key: PageStorageKey(
          '${identityHashCode(tab)}|${tab.path}|${tab.viewMode.name}'
          '|${tab.groupByDate}',
        ),
        entries: entries,
        mode: tab.viewMode,
        onViewMode: tab.setViewMode,
        sortField: tab.sortField,
        ascending: tab.ascending,
        onSortColumn: tab.tapSort,
        selected: tab.selected,
        blink: tab.justCreated,
        groupByDate: tab.groupByDate,
        onSelectGroup: tab.toggleRange,
        onTap: (entry) => tab.selecting
            ? tab.toggleSelection(entry.path)
            : _onTap(context, tab, entry),
        // Mantener presionado selecciona y, al deslizar, marca el tramo; con
        // uno solo, "Más" abre sus opciones.
        dragSelect: DragSelectCallbacks(
          onStart: tab.startDragSelection,
          onUpdate: tab.updateDragSelection,
          onEnd: tab.endDragSelection,
        ),
      ),
    );
  }

  PreferredSizeWidget _selectionAppBar(
    BuildContext context,
    BrowserController tab,
  ) => selectionAppBar(
    context,
    count: tab.selected.length,
    onClose: tab.clearSelection,
    onSelectAll: tab.selectAll,
    busy: _busy(tab),
    actions: fileSelectionTopActions(
      context,
      tab.selectedEntries,
      clear: tab.clearSelection,
    ),
  );

  /// Se vuelve a leer una carpeta que ya se ve: la ruedita de arriba.
  bool _busy(BrowserController tab) => tab.loading && tab.entries.isNotEmpty;

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
    if (created == null) return;
    // Con algo copiado o cortado entra a la carpeta nueva; si no, la carpeta
    // parpadea en la lista.
    if (FileOpsService().clipboard.isNotEmpty) {
      tab.open(created);
    } else {
      tab.markCreated(created);
    }
  }

  void _openSearch(BuildContext context, BrowserController tab) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          // Solo se limita a la carpeta si su memoria está indexada (no USB).
          currentPath: !tab.atVolumeRoot && tab.volume.indexed
              ? tab.path
              : null,
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

  // Botones compactos de los dos lados de la barra, para que el título
  // quepa centrado con las tres acciones de la derecha.
  static const width = 80.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    Widget button(IconData icon, String tooltip, VoidCallback? onPressed) =>
        IconButton(
          tooltip: tooltip,
          visualDensity: VisualDensity.compact,
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
