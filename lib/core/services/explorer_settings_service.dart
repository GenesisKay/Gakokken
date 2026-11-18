import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../files/date_groups.dart';
import '../files/file_entry.dart';
import '../storage/hive_bootstrap.dart';

/// Cómo se ve el listado. Una sola para todas las carpetas y pestañas
/// (decidido el 2026-10-20). Galería son miniaturas grandes sin nombre.
/// Lista compacta se quitó el 2026-10-21; quien la tenía guardada vuelve a Lista.
enum BrowserViewMode { list, details, grid, gallery }

/// Por qué se ordena el listado. Las carpetas siempre van primero.
enum SortField { name, modified, size, kind }

/// Un orden que se cambia desde la hoja de ordenar: el de Explorar (para
/// todas las pestañas) o uno propio, como el de los archivos de un tipo.
abstract interface class SortChoice implements Listenable {
  SortField get sortField;
  bool get ascending;
  void tapSort(SortField field);

  /// Encabezados por fecha (Hoy, Ayer, por mes). Solo con orden por fecha:
  /// activarlo ordena por fecha y elegir otro orden lo apaga.
  bool get groupByDate;
  void setGroupByDate(bool value);
}

/// Una vista que se cambia desde la hoja de ordenar.
abstract interface class ViewChoice implements Listenable {
  BrowserViewMode get viewMode;
  void setViewMode(BrowserViewMode mode);
}

/// El cambio de orden de [SortChoice.tapSort], con la regla de agrupar por
/// fecha: devuelve (campo, ascendente, agrupar).
(SortField, bool, bool) tapSortRule(
  SortField field,
  SortField current,
  bool ascending,
  bool grouped,
) => (
  field,
  field == current ? !ascending : true,
  grouped && field == SortField.modified,
);

/// Lo que queda al encender o apagar agrupar por fecha: al encenderlo ordena
/// por fecha, de lo más nuevo a lo más viejo si no estaba ya por fecha.
(SortField, bool) groupSortRule(
  bool group,
  SortField current,
  bool ascending,
) => group && current != SortField.modified
    ? (SortField.modified, false)
    : (current, ascending);

/// Carpetas primero; luego por [field] y, si empatan, por nombre.
int compareEntries(FileEntry a, FileEntry b, SortField field, bool ascending) {
  if (a.isDir != b.isDir) return a.isDir ? -1 : 1;
  final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
  final byField = switch (field) {
    SortField.name => byName,
    SortField.modified => a.modified.compareTo(b.modified),
    SortField.size => a.size.compareTo(b.size),
    SortField.kind => a.kind.index.compareTo(b.kind.index),
  };
  final ordered = ascending ? byField : -byField;
  return ordered != 0 ? ordered : byName;
}

/// [entries] en el orden de [sort]. Agrupado por fecha, primero va el grupo
/// (Hoy, Ayer...) y dentro de cada uno las carpetas primero, como siempre.
List<FileEntry> sortEntries(Iterable<FileEntry> entries, SortChoice sort) {
  final field = sort.sortField;
  final ascending = sort.ascending;
  if (!sort.groupByDate || field != SortField.modified) {
    return entries.toList()
      ..sort((a, b) => compareEntries(a, b, field, ascending));
  }
  final now = DateTime.now();
  final groups = <FileEntry, int>{
    for (final e in entries) e: DateGroup.of(e.modified, now).rank,
  };
  return groups.keys.toList()..sort((a, b) {
    final byGroup = groups[a]!.compareTo(groups[b]!);
    if (byGroup != 0) return ascending ? byGroup : -byGroup;
    return compareEntries(a, b, field, ascending);
  });
}

/// Ajustes de Explorar que comparten todas las pestañas: archivos ocultos.
/// La vista y el orden son de cada pestaña (pedido el 2026-11-13); aquí
/// queda el último que se usó, de base para la primera pestaña y para los
/// archivos de un tipo. Se guardan en Hive; sin la caja abierta (pruebas)
/// viven solo en memoria.
class ExplorerSettingsService extends ChangeNotifier
    implements SortChoice, ViewChoice {
  static final ExplorerSettingsService _instance =
      ExplorerSettingsService._internal();
  factory ExplorerSettingsService() => _instance;
  ExplorerSettingsService._internal() {
    final box = _box;
    if (box == null) return;
    _viewMode =
        BrowserViewMode.values.asNameMap()[box.get(_viewModeKey)] ?? _viewMode;
    _sortField =
        SortField.values.asNameMap()[box.get(_sortFieldKey)] ?? _sortField;
    _ascending = box.get(_ascendingKey) as bool? ?? _ascending;
    _groupByDate = box.get(_groupByDateKey) as bool? ?? _groupByDate;
    _showHidden = box.get(_showHiddenKey) as bool? ?? _showHidden;
    _searchHidden = box.get(_searchHiddenKey) as bool? ?? _searchHidden;
  }

  static const _viewModeKey = 'browserViewMode';
  static const _sortFieldKey = 'browserSortField';
  static const _ascendingKey = 'browserSortAscending';
  static const _groupByDateKey = 'browserGroupByDate';
  static const _showHiddenKey = 'showHidden';
  static const _searchHiddenKey = 'searchHidden';

  BrowserViewMode _viewMode = BrowserViewMode.list;
  SortField _sortField = SortField.name;
  bool _ascending = true;
  bool _groupByDate = false;
  bool _showHidden = false;
  bool _searchHidden = false;

  @override
  BrowserViewMode get viewMode => _viewMode;
  @override
  SortField get sortField => _sortField;
  @override
  bool get ascending => _ascending;
  @override
  bool get groupByDate => _groupByDate;

  /// Explorar muestra los nombres que empiezan con punto.
  bool get showHidden => _showHidden;

  /// Buscar incluye los ocultos. Ajuste aparte de [showHidden] (pedido el
  /// 2026-10-20).
  bool get searchHidden => _searchHidden;

  Box? get _box => Hive.isBoxOpen(HiveBootstrap.settingsBox)
      ? Hive.box(HiveBootstrap.settingsBox)
      : null;

  void _save(String key, Object value) {
    _box?.put(key, value);
    notifyListeners();
  }

  @override
  void setViewMode(BrowserViewMode mode) {
    if (mode == _viewMode) return;
    _viewMode = mode;
    _save(_viewModeKey, mode.name);
  }

  /// Un toque: ese criterio de menor a mayor. Otro toque al mismo: de mayor
  /// a menor (pedido el 2026-10-20). Igual en la hoja y en Detalles.
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
    _saveSort();
  }

  @override
  void setGroupByDate(bool value) {
    final (sortField, ascending) = groupSortRule(value, _sortField, _ascending);
    _groupByDate = value;
    _sortField = sortField;
    _ascending = ascending;
    _saveSort();
  }

  void _saveSort() {
    _box
      ?..put(_sortFieldKey, _sortField.name)
      ..put(_ascendingKey, _ascending)
      ..put(_groupByDateKey, _groupByDate);
    notifyListeners();
  }

  /// Guarda la vista y el orden que se acaban de usar en una pestaña, sin
  /// avisar: las pestañas tienen los suyos.
  void rememberLast({
    required BrowserViewMode viewMode,
    required SortField sortField,
    required bool ascending,
    required bool groupByDate,
  }) {
    _viewMode = viewMode;
    _sortField = sortField;
    _ascending = ascending;
    _groupByDate = groupByDate;
    _box
      ?..put(_viewModeKey, viewMode.name)
      ..put(_sortFieldKey, sortField.name)
      ..put(_ascendingKey, ascending)
      ..put(_groupByDateKey, groupByDate);
  }

  void setShowHidden(bool value) {
    _showHidden = value;
    _save(_showHiddenKey, value);
  }

  void setSearchHidden(bool value) {
    _searchHidden = value;
    _save(_searchHiddenKey, value);
  }

  /// Para pruebas: vuelve a los valores de fábrica.
  @visibleForTesting
  void reset() {
    _viewMode = BrowserViewMode.list;
    _sortField = SortField.name;
    _ascending = true;
    _groupByDate = false;
    _showHidden = false;
    _searchHidden = false;
  }
}
