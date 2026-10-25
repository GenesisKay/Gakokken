import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/files/file_entry.dart';
import '../../../../core/files/file_kind.dart';
import '../../../../core/files/file_labels.dart';
import '../../../../core/services/explorer_settings_service.dart';
import '../../../../core/services/index_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/file_actions.dart';
import '../../../../core/widgets/gakoken_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../browser/presentation/widgets/entry_views.dart';
import '../../../browser/presentation/widgets/sort_filter_sheet.dart';
import '../../../browser/presentation/widgets/view_mode_sheet.dart';

/// Todos los archivos de un tipo dentro de la carpeta de Espacio (con sus
/// subcarpetas). Se abre al tocar un tipo en Por tipo (pedido el
/// 2026-10-21). Tiene su propio orden (del más pesado al más ligero al
/// abrir), su propia vista (empieza en la de Explorar) y busca por nombre
/// dentro de la lista; nada de eso cambia Explorar.
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
  final _sort = _KindSort();
  late BrowserViewMode _mode = ExplorerSettingsService().viewMode;
  String _query = '';
  List<FileEntry>? _files;
  int _seenRevision = -1;

  @override
  void initState() {
    super.initState();
    _index.addListener(_onIndex);
    _sort.addListener(_onSort);
    _load();
  }

  @override
  void dispose() {
    _index.removeListener(_onIndex);
    _sort.dispose();
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
    return [
      for (final file in files)
        if (query.isEmpty || file.name.toLowerCase().contains(query)) file,
    ]..sort((a, b) => compareEntries(a, b, _sort.sortField, _sort.ascending));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final files = _files;
    final visible = files == null ? const <FileEntry>[] : _visible(files);

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

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: GakokenAppBar(
        title: kindLabel(l10n, widget.kind),
        isSearchable: true,
        onSearch: (query) => setState(() => _query = query),
        onFilterPressed: () => showSortSheet(context, _sort),
        actions: [
          IconButton(
            tooltip: l10n.browserViewTitle,
            icon: Icon(viewModeIcon(_mode), color: colors.textPrimary),
            onPressed: () => showViewModeSheet(
              context,
              current: _mode,
              onSelected: (mode) => setState(() => _mode = mode),
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
                    mode: _mode,
                    sortField: _sort.sortField,
                    ascending: _sort.ascending,
                    onSortColumn: _sort.tapSort,
                    detailOf: (file) => locationOf(l10n, file.path),
                    onTap: (file) => openFileWithFeedback(context, file.path),
                    onLongPress: (file) => showFileActionsSheet(
                      context,
                      path: file.path,
                      name: file.name,
                      isDir: false,
                    ),
                  ),
                ),
                if (files.length == _limit && _query.isEmpty)
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
  }
}

/// Orden propio de la lista: al abrir, del más pesado al más ligero. Igual
/// que en Explorar, un toque ordena de menor a mayor y otro lo invierte.
class _KindSort extends ChangeNotifier implements SortChoice {
  @override
  SortField sortField = SortField.size;
  @override
  bool ascending = false;

  @override
  void tapSort(SortField field) {
    ascending = field == sortField ? !ascending : true;
    sortField = field;
    notifyListeners();
  }
}
