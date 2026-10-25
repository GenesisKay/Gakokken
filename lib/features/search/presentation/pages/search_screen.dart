import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../../core/files/file_entry.dart';
import '../../../../core/files/file_kind.dart';
import '../../../../core/files/file_labels.dart';
import '../../../../core/services/index_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/file_actions.dart';
import '../../../../core/widgets/file_thumbnail.dart';
import '../../../../core/widgets/kind_filter_chips.dart';
import '../../../../l10n/app_localizations.dart';

/// Buscar archivos por nombre en todo el teléfono, sobre el índice. Los
/// resultados salen mientras se escribe y toleran errores de escritura.
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.currentPath,
    required this.onOpenFolder,
  });

  /// Carpeta abierta en Explorar, para limitar la búsqueda a ella. null en
  /// la raíz (ahí no hace falta la opción).
  final String? currentPath;
  final ValueChanged<String> onOpenFolder;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _index = IndexService();
  final _query = TextEditingController();
  final Set<FileKind> _kinds = {};
  bool _onlyHere = false;
  List<FileEntry> _results = const [];
  int _searchId = 0;
  bool _wasReady = false;

  @override
  void initState() {
    super.initState();
    _wasReady = _index.ready;
    _index.addListener(_onIndex);
  }

  @override
  void dispose() {
    _index.removeListener(_onIndex);
    _query.dispose();
    super.dispose();
  }

  // Cuando termina un indexado, la misma búsqueda puede traer más.
  void _onIndex() {
    if (_index.ready && (!_wasReady || !_index.indexing)) _search();
    _wasReady = _index.ready;
    if (mounted) setState(() {});
  }

  Future<void> _search() async {
    final id = ++_searchId;
    final query = _query.text;
    final results = query.trim().isEmpty
        ? const <FileEntry>[]
        : await _index.search(
            query,
            within: _onlyHere ? widget.currentPath : null,
          );
    if (!mounted || id != _searchId) return;
    setState(() => _results = results);
  }

  List<FileEntry> get _visible => _kinds.isEmpty
      ? _results
      : _results.where((e) => !e.isDir && _kinds.contains(e.kind)).toList();

  void _onTap(FileEntry entry) {
    if (entry.isDir) {
      widget.onOpenFolder(entry.path);
      Navigator.of(context).pop();
    } else {
      openFileWithFeedback(context, entry.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final here = widget.currentPath;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        backgroundColor: colors.bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleSpacing: 0,
        title: TextField(
          controller: _query,
          autofocus: true,
          textInputAction: TextInputAction.search,
          style: context.typography.body,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            hintStyle: context.typography.body.copyWith(
              color: colors.textSecondary.withValues(alpha: 0.6),
            ),
            border: InputBorder.none,
          ),
          onChanged: (_) => _search(),
        ),
        actions: [
          if (_query.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: colors.textSecondary),
              onPressed: () {
                _query.clear();
                _search();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (here != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Row(
                children: [
                  _scopeChip(l10n.searchEverywhere, !_onlyHere, false),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _scopeChip(
                      l10n.searchOnlyIn(p.basename(here)),
                      _onlyHere,
                      true,
                    ),
                  ),
                ],
              ),
            ),
          KindFilterChips(
            selected: _kinds,
            scrollable: true,
            onToggle: (kind) => setState(() {
              if (!_kinds.remove(kind)) _kinds.add(kind);
            }),
          ),
          if (_index.indexing && _index.ready)
            LinearProgressIndicator(minHeight: 2, color: colors.primary)
          else
            const SizedBox(height: 2),
          Expanded(child: _body(l10n)),
        ],
      ),
    );
  }

  Widget _scopeChip(String label, bool selected, bool onlyHere) {
    final colors = context.colors;
    return ChoiceChip(
      label: Text(label, overflow: TextOverflow.ellipsis),
      labelStyle: context.typography.small.copyWith(color: colors.textPrimary),
      selected: selected,
      showCheckmark: false,
      selectedColor: colors.primary.withValues(alpha: 0.16),
      side: BorderSide(color: selected ? colors.primary : colors.borderSubtle),
      onSelected: (_) {
        setState(() => _onlyHere = onlyHere);
        _search();
      },
    );
  }

  Widget _body(AppLocalizations l10n) {
    final colors = context.colors;
    String? message;
    if (!_index.ready) {
      final count = NumberFormat.decimalPattern(
        Localizations.localeOf(context).toString(),
      ).format(_index.scanned);
      message = _index.indexing
          ? l10n.indexingProgress(count)
          : l10n.indexNotReady;
    } else if (_query.text.trim().isEmpty) {
      message = l10n.searchIntro;
    } else if (_visible.isEmpty) {
      message = l10n.searchNoResults;
    }
    if (message != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: context.typography.body.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      );
    }

    final results = _visible;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: results.length,
      itemBuilder: (context, i) {
        final entry = results[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: FileThumbnail(
            path: entry.path,
            name: entry.name,
            isDir: entry.isDir,
          ),
          title: Text(
            entry.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.body.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            locationOf(l10n, entry.path),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.small.copyWith(
              color: colors.textSecondary,
            ),
          ),
          onTap: () => _onTap(entry),
          onLongPress: () => showFileActionsSheet(
            context,
            path: entry.path,
            name: entry.name,
            isDir: entry.isDir,
          ),
        );
      },
    );
  }
}
