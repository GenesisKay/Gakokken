import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/files/file_entry.dart';
import '../../../../core/files/file_kind.dart';
import '../../../../core/files/file_labels.dart';
import '../../../../core/services/explorer_settings_service.dart';
import '../../../../core/services/index_service.dart';
import '../../../../core/services/view_prefs.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/file_actions.dart';
import '../../../../core/widgets/gakoken_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../browser/presentation/controllers/selection.dart';
import '../../../browser/presentation/widgets/entry_views.dart';
import '../../../browser/presentation/widgets/file_ops_bars.dart';
import '../../../browser/presentation/widgets/selection_actions.dart';
import '../../../browser/presentation/widgets/sort_filter_sheet.dart';
import '../../../browser/presentation/widgets/view_mode_sheet.dart';

/// Todos los archivos de un tipo dentro de la carpeta de Espacio (con sus
/// subcarpetas). Se abre al tocar un tipo en Por tipo (pedido el
/// 2026-10-21). Tiene su propio orden (del más pesado al más ligero al
/// abrir), su propia vista (empieza en la de Explorar) y busca por nombre
/// dentro de la lista; nada de eso cambia Explorar. Selección múltiple como
/// en Explorar (pedida el 2026-10-29).
class KindFilesScreen extends StatefulWidget {
  const KindFilesScreen({
    super.key,
    required this.path,
    required this.kind,
    required this.extensions,
  });

  final String path;
  final FileKind kind;

  /// Extensiones de este tipo que hay en la carpeta, como las cuenta Espacio.
  final List<String> extensions;

  @override
  State<KindFilesScreen> createState() => _KindFilesScreenState();
}

class _KindFilesScreenState extends State<KindFilesScreen> {
  static const _limit = 500;

  final _index = IndexService();
  // Al abrir, del más pesado al más ligero, en la vista de Explorar.
  final _sort = ViewPrefs(
    viewMode: ExplorerSettingsService().viewMode,
    sortField: SortField.size,
    ascending: false,
  );
  final _selection = SelectionController();
  String _query = '';
  List<FileEntry>? _files;
  int _seenRevision = -1;

  @override
  void initState() {
    super.initState();
    _index.addListener(_onIndex);
    _sort.addListener(_onSort);
    _selection.addListener(_onSort);
    _load();
  }

  @override
  void dispose() {
    _index.removeListener(_onIndex);
    _sort.dispose();
    _selection.dispose();
    super.dispose();
  }

  // Renombrar o borrar desde aquí cambia el índice: se vuelve a pedir.
  void _onIndex() {
    if (!_index.indexing && _index.revision != _seenRevision) _load();
  }

  void _onSort() => setState(() {});

  Future<void> _load() async {
    _seenRevision = _index.revision;
    final files = await _index.filesOfExtensions(
      widget.path,
      widget.extensions,
      limit: _limit,
    );
    if (!mounted) return;
    setState(() => _files = files);
  }

  /// Lo que coincide con la búsqueda, en el orden elegido.
  List<FileEntry> _visible(List<FileEntry> files) {
    final query = _query.trim().toLowerCase();
    return sortEntries([
      for (final file in files)
        if (query.isEmpty || file.name.toLowerCase().contains(query)) file,
    ], _sort);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final files = _files;
    final visible = files == null ? const <FileEntry>[] : _visible(files);
    _selection
      ..keys = [for (final file in visible) file.path]
      ..retainVisible();
    final selected = [
      for (final file in visible)
        if (_selection.selected.contains(file.path)) file,
    ];

    Widget message(String text) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              ),
            )
          : GakokenAppBar(
              title: kindLabel(l10n, widget.kind),
              isSearchable: true,
              onSearch: (query) => setState(() => _query = query),
              onFilterPressed: () => showSortSheet(context, _sort),
              actions: [
                IconButton(
                  tooltip: l10n.browserViewTitle,
                  icon: Icon(
                    viewModeIcon(_sort.viewMode),
                    color: colors.textPrimary,
                  ),
                  onPressed: () => showViewModeSheet(
                    context,
                    current: _sort.viewMode,
                    onSelected: _sort.setViewMode,
                  ),
                ),
              ],
            ),
      body: files == null
          ? const Center(child: CircularProgressIndicator())
          : files.isEmpty
          ? message(l10n.browserEmpty)
          : visible.isEmpty
          ? message(l10n.searchNoResults)
          : Column(
              children: [
                Expanded(
                  child: EntryViews(
                    entries: visible,
                    mode: _sort.viewMode,
                    onViewMode: _sort.setViewMode,
                    sortField: _sort.sortField,
                    ascending: _sort.ascending,
                    onSortColumn: _sort.tapSort,
                    groupByDate: _sort.groupByDate,
                    selected: _selection.selected,
                    onSelectGroup: _selection.toggleRange,
                    detailOf: (file) => locationOf(l10n, file.path),
                    onTap: (file) => _selection.selecting
                        ? _selection.toggleSelection(file.path)
                        : openFileWithFeedback(context, file.path),
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
                    ),
                  )
                else if (files.length == _limit && _query.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Text(
                      l10n.kindFilesLimit(
                        NumberFormat.decimalPattern(locale).format(_limit),
                      ),
                      textAlign: TextAlign.center,
                      style: context.typography.small.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
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
}
