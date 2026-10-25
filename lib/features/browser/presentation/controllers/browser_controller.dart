import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../../core/engine/file_engine.dart';
import '../../../../core/files/file_entry.dart';
import '../../../../core/files/file_kind.dart';
import '../../../../core/services/explorer_settings_service.dart';
import '../../../../core/services/storage_volumes_service.dart';

export '../../../../core/services/explorer_settings_service.dart'
    show BrowserViewMode, SortField;

/// Una pestaña de Explorar: carpeta actual, su contenido, filtro por tipo e
/// historial atrás y adelante. La vista, el orden y los ocultos son de
/// [ExplorerSettingsService] y valen para todas las pestañas.
class BrowserController extends ChangeNotifier {
  BrowserController({
    required String path,
    FileEngine? engine,
    ExplorerSettingsService? settings,
    StorageVolumesService? volumes,
  }) : _engine = engine ?? FileEngine.instance,
       _settings = settings ?? ExplorerSettingsService(),
       _volumes = volumes ?? StorageVolumesService(),
       _path = path {
    _settings.addListener(_onSettings);
    _showHidden = _settings.showHidden;
  }

  final FileEngine _engine;
  final ExplorerSettingsService _settings;
  final StorageVolumesService _volumes;

  String _path;
  final _back = <String>[];
  final _forward = <String>[];
  final _byPath = <String, FileEntry>{};
  List<FileEntry> _entries = const [];
  StreamSubscription<List<FileEntry>>? _listing;
  bool _loading = false;
  bool _failed = false;
  // Hay un listado cargado o cargando (no suspendido).
  bool _loaded = false;
  late bool _showHidden;
  final Set<FileKind> _kindFilter = {};
  final _selected = <String>{};

  String get path => _path;

  /// Memoria (interna, SD o USB) donde está la carpeta actual.
  StorageVolume get volume => _volumes.volumeOf(_path);
  String get root => volume.path;

  /// Contenido visible: filtrado por tipo y ordenado.
  List<FileEntry> get entries => _entries;

  /// Cuántos elementos tiene la carpeta antes de filtrar.
  int get totalCount => _byPath.length;
  bool get loading => _loading;

  /// La carpeta actual no se pudo leer (por ejemplo `Android/data`).
  bool get failed => _failed;

  /// Tipos de archivo que se muestran; vacío es todos. Las carpetas siempre
  /// se muestran, para poder seguir navegando.
  Set<FileKind> get kindFilter => Set.unmodifiable(_kindFilter);
  bool get canGoUp => !p.equals(_path, root);

  /// Rutas seleccionadas (mantener presionado). Navegar las suelta.
  Set<String> get selected => Set.unmodifiable(_selected);
  bool get selecting => _selected.isNotEmpty;
  List<FileEntry> get selectedEntries => [
    for (final path in _selected)
      if (_byPath[path] != null) _byPath[path]!,
  ];

  /// El botón atrás del sistema tiene algo que hacer en esta pestaña.
  bool get canHandleBack => selecting || canGoBack || canGoUp;
  bool get canGoBack => _back.isNotEmpty;
  bool get canGoForward => _forward.isNotEmpty;

  /// Carpetas desde la raíz de la memoria hasta la actual, para el breadcrumb.
  List<String> get trail {
    final trail = [root];
    if (!canGoUp) return trail;
    for (final part in p.split(p.relative(_path, from: root))) {
      trail.add(p.join(trail.last, part));
    }
    return trail;
  }

  /// Va a [path] y lo agrega al historial. Si ya no existe la memoria, va a
  /// la interna.
  void open(String path) {
    final target = _volumes.isAvailable(path)
        ? _volumes.resolve(path)
        : _volumes.volumes.first.path;
    if (p.equals(target, _path)) {
      reload();
      return;
    }
    _back.add(_path);
    _forward.clear();
    _show(target);
  }

  /// Sube una carpeta. false si ya está en la raíz de la memoria.
  bool goUp() {
    if (!canGoUp) return false;
    open(p.dirname(_path));
    return true;
  }

  bool goBack() {
    if (_back.isEmpty) return false;
    _forward.add(_path);
    _show(_back.removeLast());
    return true;
  }

  bool goForward() {
    if (_forward.isEmpty) return false;
    _back.add(_path);
    _show(_forward.removeLast());
    return true;
  }

  /// Botón atrás del sistema: suelta la selección, luego historial y luego
  /// subir de carpeta. false si no queda adónde ir (entonces sale de la app).
  bool handleSystemBack() {
    if (selecting) {
      clearSelection();
      return true;
    }
    return goBack() || goUp();
  }

  void toggleSelection(String path) {
    if (!_selected.remove(path)) _selected.add(path);
    notifyListeners();
  }

  /// Selecciona todo lo visible (respeta el filtro).
  void selectAll() {
    _selected.addAll(_entries.map((e) => e.path));
    notifyListeners();
  }

  void clearSelection() {
    if (_selected.isEmpty) return;
    _selected.clear();
    notifyListeners();
  }

  void reload() => _show(_path);

  /// Vuelve a leer la carpeta sin vaciar la lista mientras tanto: lo nuevo
  /// reemplaza a lo anterior al terminar y la selección sigue (sin lo que ya
  /// no existe). Para cambios que llegan solos, sin que el usuario navegue.
  void refreshQuietly() {
    if (!_loaded || _loading) {
      if (_loaded) reload();
      return;
    }
    _listing?.cancel();
    final fresh = <String, FileEntry>{};
    _listing = _engine
        .list(_path, showHidden: _showHidden)
        .listen(
          (batch) {
            for (final entry in batch) {
              fresh[entry.path] = entry;
            }
          },
          // La carpeta ya no se puede leer (por ejemplo, la borraron).
          onError: (Object _) => reload(),
          onDone: () {
            _byPath
              ..clear()
              ..addAll(fresh);
            _selected.removeWhere((path) => !fresh.containsKey(path));
            _refresh();
          },
        );
  }

  /// Suelta el listado de una pestaña que no se ve; [reload] lo vuelve a leer.
  void suspend() {
    _listing?.cancel();
    _listing = null;
    _byPath.clear();
    _entries = const [];
    _loaded = false;
  }

  void _show(String path) {
    _path = _volumes.isAvailable(path) ? path : _volumes.volumes.first.path;
    _listing?.cancel();
    _byPath.clear();
    _selected.clear();
    _entries = const [];
    _failed = false;
    _loading = true;
    _loaded = true;
    notifyListeners();

    _listing = _engine
        .list(_path, showHidden: _showHidden)
        .listen(
          (batch) {
            for (final entry in batch) {
              _byPath[entry.path] = entry;
            }
            _refresh();
          },
          onError: (Object _) {
            _failed = true;
            notifyListeners();
          },
          onDone: () {
            _loading = false;
            notifyListeners();
          },
        );
  }

  void toggleKind(FileKind kind) {
    if (!_kindFilter.remove(kind)) _kindFilter.add(kind);
    _refresh();
  }

  void clearKinds() {
    _kindFilter.clear();
    _refresh();
  }

  void _onSettings() {
    if (_settings.showHidden != _showHidden) {
      _showHidden = _settings.showHidden;
      if (_loaded) reload();
      return;
    }
    _refresh();
  }

  void _refresh() {
    final visible = _kindFilter.isEmpty
        ? _byPath.values
        : _byPath.values.where((e) => e.isDir || _kindFilter.contains(e.kind));
    _entries = visible.toList()..sort(_compare);
    notifyListeners();
  }

  int _compare(FileEntry a, FileEntry b) =>
      compareEntries(a, b, _settings.sortField, _settings.ascending);

  @override
  void dispose() {
    _listing?.cancel();
    _settings.removeListener(_onSettings);
    super.dispose();
  }
}
