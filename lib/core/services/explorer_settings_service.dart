import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

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
}

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

/// Ajustes de Explorar que comparten todas las pestañas: vista, orden y
/// archivos ocultos. Se guardan en Hive; sin la caja abierta (pruebas) viven
/// solo en memoria.
class ExplorerSettingsService extends ChangeNotifier implements SortChoice {
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
    _showHidden = box.get(_showHiddenKey) as bool? ?? _showHidden;
    _searchHidden = box.get(_searchHiddenKey) as bool? ?? _searchHidden;
  }

  static const _viewModeKey = 'browserViewMode';
  static const _sortFieldKey = 'browserSortField';
  static const _ascendingKey = 'browserSortAscending';
  static const _showHiddenKey = 'showHidden';
  static const _searchHiddenKey = 'searchHidden';

  BrowserViewMode _viewMode = BrowserViewMode.list;
  SortField _sortField = SortField.name;
  bool _ascending = true;
  bool _showHidden = false;
  bool _searchHidden = false;

  BrowserViewMode get viewMode => _viewMode;
  SortField get sortField => _sortField;
  bool get ascending => _ascending;

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

  void setViewMode(BrowserViewMode mode) {
    if (mode == _viewMode) return;
    _viewMode = mode;
    _save(_viewModeKey, mode.name);
  }

  /// Un toque: ese criterio de menor a mayor. Otro toque al mismo: de mayor
  /// a menor (pedido el 2026-10-20). Igual en la hoja y en Detalles.
  void tapSort(SortField field) {
    _ascending = field == _sortField ? !_ascending : true;
    _sortField = field;
    _box
      ?..put(_sortFieldKey, field.name)
      ..put(_ascendingKey, _ascending);
    notifyListeners();
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
    _showHidden = false;
    _searchHidden = false;
  }
}
