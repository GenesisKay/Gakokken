import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/engine/file_engine.dart';
import '../../../../core/files/file_entry.dart';
import '../../../../core/files/file_labels.dart';
import '../../../../core/services/explorer_settings_service.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../../core/services/file_changes.dart';
import '../../../../core/services/scaffold_messenger_service.dart';
import '../../../../core/services/trash_service.dart';
import '../../../../core/services/view_prefs.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/file_actions.dart';
import '../../../../core/widgets/gakoken_app_bar.dart';
import '../../../../core/widgets/kind_filter_chips.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../browser/presentation/controllers/selection.dart';
import '../../../browser/presentation/widgets/entry_views.dart';
import '../../../browser/presentation/widgets/file_ops_bars.dart';
import '../../../browser/presentation/widgets/selection_actions.dart';
import '../../../browser/presentation/widgets/sort_filter_sheet.dart';

/// Pestaña Favoritos. Los que ya no existen se marcan y se pueden quitar.
/// Lo que está en la papelera no se ve; si se restaura, vuelve a aparecer
/// (pedido el 2026-11-05).
/// Como Explorar: buscar por nombre, vista, orden, agrupar por fecha,
/// filtro por tipo y selección múltiple (pedidos el 2026-10-29). Vista y
/// orden se guardan aparte de Explorar; la fecha es cuándo se agregó.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    required this.visible,
    required this.onOpenFolder,
  });

  /// Si la pestaña está a la vista; al entrar se revisa qué sigue existiendo.
  final bool visible;
  final ValueChanged<String> onOpenFolder;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favorites = FavoritesService();
  final _trash = TrashService();
  // Al abrir, del último agregado al primero (el orden de siempre).
  final _prefs = ViewPrefs(
    key: 'favorites',
    sortField: SortField.modified,
    ascending: false,
  );
  final _filter = KindFilterState();
  final _selection = SelectionController();
  String _query = '';
  Set<String> _missing = const {};
  // Borrar o mover un favorito desde otra pestaña lo deja marcado al momento.
  StreamSubscription<Set<String>>? _changes;

  @override
  void initState() {
    super.initState();
    _favorites.addListener(_checkMissing);
    _changes = FileChanges.stream.listen((_) => _checkMissing());
    _checkMissing();
  }

  @override
  void didUpdateWidget(FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) _checkMissing();
    // Al cambiar de pestaña la selección se suelta: si no, el botón atrás
    // de las otras pestañas la seguiría soltando aquí.
    if (!widget.visible && oldWidget.visible) _selection.clearSelection();
  }

  @override
  void dispose() {
    _favorites.removeListener(_checkMissing);
    _changes?.cancel();
    _prefs.dispose();
    _filter.dispose();
    _selection.dispose();
    super.dispose();
  }

  Future<void> _checkMissing() async {
    final engine = FileEngine.instance;
    final missing = <String>{};
    for (final favorite in _favorites.all) {
      if (!await engine.exists(favorite.path)) missing.add(favorite.path);
    }
    if (mounted) setState(() => _missing = missing);
  }

  void _onTap(FileEntry entry) {
    if (_selection.selecting) {
      _selection.toggleSelection(entry.path);
    } else if (_missing.contains(entry.path)) {
      ScaffoldMessengerService.showInfo(
        AppLocalizations.of(context)!.fileMissing,
      );
    } else if (entry.isDir) {
      widget.onOpenFolder(entry.path);
    } else {
      openFileWithFeedback(context, entry.path);
    }
  }

  /// Los favoritos que no están en la papelera.
  List<Favorite> _shown() => [
    for (final favorite in _favorites.all)
      if (!_trash.isTrashed(favorite.path)) favorite,
  ];

  /// Los favoritos como elementos de lista: la fecha es cuándo se agregó y
  /// el tamaño no se sabe.
  List<FileEntry> _visible(List<Favorite> shown) {
    final query = _query.trim().toLowerCase();
    return sortEntries(
      [
        for (final favorite in shown)
          if (query.isEmpty || favorite.name.toLowerCase().contains(query))
            FileEntry(
              path: favorite.path,
              name: favorite.name,
              isDir: favorite.isDir,
              size: 0,
              modified: favorite.addedAt,
            ),
      ].where(_filter.matches),
      _prefs,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _favorites,
        _trash,
        _prefs,
        _filter,
        _selection,
      ]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final shown = _shown();
    final empty = shown.isEmpty;
    final visible = _visible(shown);
    _selection
      ..keys = [for (final e in visible) e.path]
      ..retainVisible();
    final selected = [
      for (final e in visible)
        if (_selection.selected.contains(e.path)) e,
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
              actions: fileSelectionTopActions(
                context,
                selected,
                clear: _selection.clearSelection,
                info: false,
              ),
            )
          : GakokenAppBar(
              title: l10n.navFavorites,
              isRootScreen: true,
              isSearchable: !empty,
              onSearch: (query) => setState(() => _query = query),
              actions: [
                if (!empty)
                  IconButton(
                    tooltip: l10n.browserDisplayTitle,
                    icon: Icon(Icons.tune_rounded, color: colors.textPrimary),
                    onPressed: () => showListOptionsSheet(
                      context,
                      sort: _prefs,
                      view: _prefs,
                      filter: _filter,
                      dateLabel: l10n.sortAdded,
                      sizes: false,
                    ),
                  ),
              ],
            ),
      body: empty
          ? message(l10n.favoritesEmpty)
          : Column(
              children: [
                if (_filter.kindFilter.isNotEmpty)
                  ActiveKindFilters(filter: _filter),
                Expanded(
                  child: visible.isEmpty
                      ? message(
                          _query.trim().isEmpty
                              ? l10n.browserNoMatches
                              : l10n.searchNoResults,
                        )
                      : EntryViews(
                          key: PageStorageKey(
                            'favorites|${_prefs.viewMode.name}'
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
                          dateLabel: l10n.sortAdded,
                          selected: _selection.selected,
                          onSelectGroup: _selection.toggleRange,
                          faded: (e) => _missing.contains(e.path),
                          detailOf: (e) => _missing.contains(e.path)
                              ? l10n.fileMissing
                              : locationOf(l10n, e.path),
                          onTap: _onTap,
                          dragSelect: DragSelectCallbacks(
                            onStart: _selection.startDragSelection,
                            onUpdate: _selection.updateDragSelection,
                            onEnd: _selection.endDragSelection,
                          ),
                        ),
                ),
                if (_selection.selecting)
                  SelectionBar(
                    actions: fileSelectionActions(
                      context,
                      selected,
                      clear: _selection.clearSelection,
                      exists: (path) => !_missing.contains(path),
                    ),
                  ),
              ],
            ),
    );
    // Atrás suelta la selección antes de salir de la app.
    return PopScope(
      canPop: !_selection.selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _selection.clearSelection();
      },
      child: scaffold,
    );
  }
}
