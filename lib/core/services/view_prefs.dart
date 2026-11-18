import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../files/file_entry.dart';
import '../files/file_kind.dart';
import '../storage/hive_bootstrap.dart';
import 'explorer_settings_service.dart';

/// Vista, orden y agrupar por fecha de una lista que no es Explorar:
/// Favoritos y la Papelera guardan los suyos aparte (pedido el 2026-10-29),
/// los archivos de un tipo los tienen solo mientras están abiertos.
class ViewPrefs extends ChangeNotifier implements SortChoice, ViewChoice {
  /// Con [key], se guarda en la caja `settings` con ese prefijo; sin ella,
  /// vive solo en memoria.
  ViewPrefs({
    this.key,
    BrowserViewMode viewMode = BrowserViewMode.list,
    SortField sortField = SortField.name,
    bool ascending = true,
    bool groupByDate = false,
  }) : _viewMode = viewMode,
       _sortField = sortField,
       _ascending = ascending,
       _groupByDate = groupByDate {
    final box = _box;
    if (box == null) return;
    _viewMode =
        BrowserViewMode.values.asNameMap()[box.get('${key}ViewMode')] ??
        _viewMode;
    _sortField =
        SortField.values.asNameMap()[box.get('${key}SortField')] ?? _sortField;
    _ascending = box.get('${key}SortAscending') as bool? ?? _ascending;
    _groupByDate = box.get('${key}GroupByDate') as bool? ?? _groupByDate;
  }

  final String? key;

  BrowserViewMode _viewMode;
  SortField _sortField;
  bool _ascending;
  bool _groupByDate;

  @override
  BrowserViewMode get viewMode => _viewMode;
  @override
  SortField get sortField => _sortField;
  @override
  bool get ascending => _ascending;
  @override
  bool get groupByDate => _groupByDate;

  Box? get _box => key != null && Hive.isBoxOpen(HiveBootstrap.settingsBox)
      ? Hive.box(HiveBootstrap.settingsBox)
      : null;

  @override
  void setViewMode(BrowserViewMode mode) {
    if (mode == _viewMode) return;
    _viewMode = mode;
    _save();
  }

  @override
  void tapSort(SortField field) {
    final (sortField, ascending, grouped) = tapSortRule(
      field,
      _sortField,
      _ascending,
      _groupByDate,
    );
    _sortField = sortField;
    _ascending = ascending;
    _groupByDate = grouped;
    _save();
  }

  @override
  void setGroupByDate(bool value) {
    final (sortField, ascending) = groupSortRule(value, _sortField, _ascending);
    _groupByDate = value;
    _sortField = sortField;
    _ascending = ascending;
    _save();
  }

  void _save() {
    _box
      ?..put('${key}ViewMode', _viewMode.name)
      ..put('${key}SortField', _sortField.name)
      ..put('${key}SortAscending', _ascending)
      ..put('${key}GroupByDate', _groupByDate);
    notifyListeners();
  }
}

/// Filtro por tipo que se cambia desde la hoja de ordenar: el de una pestaña
/// de Explorar o uno propio, como el de Favoritos o la Papelera.
abstract interface class KindFilterChoice implements Listenable {
  /// Tipos que se muestran; vacío es todos.
  Set<FileKind> get kindFilter;
  void toggleKind(FileKind kind);
  void clearKinds();
}

/// Filtro por tipo que vive mientras la pantalla está abierta.
class KindFilterState extends ChangeNotifier implements KindFilterChoice {
  final _kinds = <FileKind>{};

  @override
  Set<FileKind> get kindFilter => Set.unmodifiable(_kinds);

  /// Las carpetas pasan siempre, igual que en Explorar.
  bool matches(FileEntry entry) =>
      _kinds.isEmpty || entry.isDir || _kinds.contains(entry.kind);

  @override
  void toggleKind(FileKind kind) {
    if (!_kinds.remove(kind)) _kinds.add(kind);
    notifyListeners();
  }

  @override
  void clearKinds() {
    _kinds.clear();
    notifyListeners();
  }
}
