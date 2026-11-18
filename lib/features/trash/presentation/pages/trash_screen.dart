import 'package:flutter/material.dart';

import '../../../../core/files/file_entry.dart';
import '../../../../core/files/file_labels.dart';
import '../../../../core/services/explorer_settings_service.dart';
import '../../../../core/services/scaffold_messenger_service.dart';
import '../../../../core/services/trash_service.dart';
import '../../../../core/services/view_prefs.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/file_dialogs.dart';
import '../../../../core/widgets/file_thumbnail.dart';
import '../../../../core/widgets/gakoken_app_bar.dart';
import '../../../../core/widgets/gakoken_options_sheet.dart';
import '../../../../core/widgets/kind_filter_chips.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../browser/presentation/controllers/selection.dart';
import '../../../browser/presentation/widgets/entry_views.dart';
import '../../../browser/presentation/widgets/file_ops_bars.dart';
import '../../../browser/presentation/widgets/selection_actions.dart';
import '../../../browser/presentation/widgets/sort_filter_sheet.dart';

/// Papelera: lo borrado de las memorias conectadas, con de dónde venía y
/// cuántos días le quedan. Se restaura o se borra para siempre, uno por uno
/// o varios con la selección. Como Explorar: buscar, vista, orden, agrupar
/// por fecha de borrado y filtro por tipo, guardados aparte de Explorar
/// (pedidos el 2026-10-29).
class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final _trash = TrashService();
  // Al abrir, de lo último borrado a lo primero (el orden de siempre).
  final _prefs = ViewPrefs(
    key: 'trash',
    sortField: SortField.modified,
    ascending: false,
  );
  final _filter = KindFilterState();
  final _selection = SelectionController();
  String _query = '';

  @override
  void dispose() {
    _prefs.dispose();
    _filter.dispose();
    _selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_trash, _prefs, _filter, _selection]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final items = _trash.items;
    final now = DateTime.now();

    // Cada elemento como fila de lista: la ruta es donde está ahora (para la
    // miniatura), el nombre el de antes y la fecha cuándo se borró.
    final byPath = {for (final item in items) item.trashedPath: item};
    final query = _query.trim().toLowerCase();
    final visible = sortEntries(
      [
        for (final item in items)
          if (query.isEmpty || item.name.toLowerCase().contains(query))
            FileEntry(
              path: item.trashedPath,
              name: item.name,
              isDir: item.isDir,
              size: 0,
              modified: item.deletedAt,
            ),
      ].where(_filter.matches),
      _prefs,
    );
    _selection
      ..keys = [for (final e in visible) e.path]
      ..retainVisible();
    final selected = [
      for (final e in visible)
        if (_selection.selected.contains(e.path)) byPath[e.path]!,
    ];

    Widget message(String text) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: context.typography.body.copyWith(color: colors.textSecondary),
        ),
      ),
    );

    final scaffold = Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: _selection.selecting
          ? selectionAppBar(
              context,
              count: selected.length,
              onClose: _selection.clearSelection,
              onSelectAll: _selection.selectAll,
            )
          : GakokenAppBar(
              title: l10n.trashTitle,
              isSearchable: items.isNotEmpty,
              onSearch: (query) => setState(() => _query = query),
              actions: [
                if (items.isNotEmpty) ...[
                  IconButton(
                    tooltip: l10n.browserDisplayTitle,
                    icon: Icon(Icons.tune_rounded, color: colors.textPrimary),
                    onPressed: () => showListOptionsSheet(
                      context,
                      sort: _prefs,
                      view: _prefs,
                      filter: _filter,
                      dateLabel: l10n.sortDeleted,
                      sizes: false,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _empty(context, items.length),
                    child: Text(l10n.trashEmptyAction),
                  ),
                ],
              ],
            ),
      body: items.isEmpty
          ? message(l10n.trashEmpty(_trash.retentionDays))
          : Column(
              children: [
                if (_filter.kindFilter.isNotEmpty)
                  ActiveKindFilters(filter: _filter),
                Expanded(
                  child: visible.isEmpty
                      ? message(
                          query.isEmpty
                              ? l10n.browserNoMatches
                              : l10n.searchNoResults,
                        )
                      : EntryViews(
                          key: PageStorageKey(
                            'trash|${_prefs.viewMode.name}'
                            '|${_prefs.groupByDate}',
                          ),
                          entries: visible,
                          mode: _prefs.viewMode,
                          onViewMode: _prefs.setViewMode,
                          sortField: _prefs.sortField,
                          ascending: _prefs.ascending,
                          onSortColumn: _prefs.tapSort,
                          groupByDate: _prefs.groupByDate,
                          showSize: false,
                          dateLabel: l10n.sortDeleted,
                          selected: _selection.selected,
                          onSelectGroup: _selection.toggleRange,
                          // Los días van aparte para que una ruta larga no
                          // los recorte.
                          detailOf: (e) =>
                              locationOf(l10n, byPath[e.path]!.originalPath),
                          detailEndOf: (e) => l10n.trashDaysLeft(
                            byPath[e.path]!.daysLeft(now, _trash.retentionDays),
                          ),
                          onTap: (e) => _selection.selecting
                              ? _selection.toggleSelection(e.path)
                              : _options(context, byPath[e.path]!),
                          dragSelect: DragSelectCallbacks(
                            onStart: _selection.startDragSelection,
                            onUpdate: _selection.updateDragSelection,
                            onEnd: _selection.endDragSelection,
                          ),
                        ),
                ),
                if (_selection.selecting)
                  SelectionBar(
                    actions: [
                      SelectionAction(
                        Icons.restore_rounded,
                        l10n.trashRestore,
                        () => _restore(selected),
                      ),
                      SelectionAction(
                        Icons.delete_forever_rounded,
                        l10n.trashDeleteForever,
                        () => _deleteForever(context, selected),
                      ),
                    ],
                  ),
              ],
            ),
    );
    // Atrás suelta la selección antes de salir.
    return PopScope(
      canPop: !_selection.selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _selection.clearSelection();
      },
      child: scaffold,
    );
  }

  Future<void> _restore(List<TrashItem> items) async {
    final l10n = AppLocalizations.of(context)!;
    _selection.clearSelection();
    final restored = await _trash.restore(items);
    ScaffoldMessengerService.showInfo(
      restored == 0
          ? l10n.trashRestoreFailed
          : items.length == 1
          ? l10n.trashRestored
          : l10n.trashRestoredMany(restored),
    );
  }

  Future<void> _deleteForever(
    BuildContext context,
    List<TrashItem> items,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showConfirmDialog(
      context,
      title: l10n.trashDeleteForever,
      message: l10n.trashDeleteForeverMessage(items.length),
      confirm: l10n.actionDelete,
    );
    if (!ok) return;
    _selection.clearSelection();
    await _trash.deleteForever(items);
  }

  void _options(BuildContext context, TrashItem item) {
    final l10n = AppLocalizations.of(context)!;
    showGakokenOptionsSheet(
      context: context,
      header: Row(
        children: [
          FileThumbnail(
            path: item.trashedPath,
            name: item.name,
            isDir: item.isDir,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              item.name,
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
        GakokenSheetOption(
          icon: Icons.restore_rounded,
          label: l10n.trashRestore,
          onTap: () => _restore([item]),
        ),
        GakokenSheetOption(
          icon: Icons.delete_forever_rounded,
          label: l10n.trashDeleteForever,
          onTap: () => _deleteForever(context, [item]),
        ),
      ],
    );
  }

  Future<void> _empty(BuildContext context, int count) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showConfirmDialog(
      context,
      title: l10n.trashEmptyAction,
      message: l10n.trashDeleteForeverMessage(count),
      confirm: l10n.actionDelete,
    );
    if (ok) await _trash.empty();
  }
}
