import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../../core/engine/file_engine.dart';
import '../../../../core/files/file_entry.dart';
import '../../../../core/files/file_kind.dart';
import '../../../../core/services/explorer_settings_service.dart';
import '../../../../core/services/storage_volumes_service.dart';
import '../../../../core/services/view_prefs.dart';
import 'selection.dart';

export '../../../../core/services/explorer_settings_service.dart'
    show BrowserViewMode, SortField;

/// Vista, orden, agrupar por fecha y filtro por tipo de una pestaña. Se
/// guarda junto con su carpeta para que vuelva igual al abrir la app.
class TabListOptions {
  const TabListOptions({
    this.viewMode = BrowserViewMode.list,
    this.sortField = SortField.name,
    this.ascending = true,
    this.groupByDate = false,
    this.kinds = const {},
  });

  final BrowserViewMode viewMode;
  final SortField sortField;
  final bool ascending;
  final bool groupByDate;
  final Set<FileKind> kinds;

  Map<String, Object> toMap() => {
    'view': viewMode.name,
    'sort': sortField.name,
    'ascending': ascending,
    'group': groupByDate,
    'kinds': [for (final kind in kinds) kind.name],
  };

  /// Lo que no se entienda (un tipo que ya no existe) toma el valor de
  /// [fallback].
  factory TabListOptions.fromMap(
    Map<dynamic, dynamic> map,
    TabListOptions fallback,
  ) {
    final kinds = map['kinds'];
    return TabListOptions(
      viewMode:
          BrowserViewMode.values.asNameMap()[map['view']] ?? fallback.viewMode,
      sortField:
          SortField.values.asNameMap()[map['sort']] ?? fallback.sortField,
      ascending: map['ascending'] as bool? ?? fallback.ascending,
      groupByDate: map['group'] as bool? ?? fallback.groupByDate,
      kinds: kinds is List
          ? {
              for (final name in kinds)
                if (FileKind.values.asNameMap()[name] case final kind?) kind,
            }
          : fallback.kinds,
    );
  }
}

/// Una pestaña de Explorar: carpeta actual, su contenido, historial atrás y
/// adelante, y su propia vista, orden y filtro por tipo (pedido el
/// 2026-11-13). Los ocultos son de [ExplorerSettingsService] y valen para
/// todas.
class BrowserController extends ChangeNotifier
    with Selection
    implements KindFilterChoice, SortChoice, ViewChoice {
  /// Sin [options] toma la última vista y orden que se usaron.
  BrowserController({
    required String path,
    FileEngine? engine,
    ExplorerSettingsService? settings,
    StorageVolumesService? volumes,
    TabListOptions? options,
  }) : _engine = engine ?? FileEngine.instance,
       _settings = settings ?? ExplorerSettingsService(),
       _volumes = volumes ?? StorageVolumesService(),
       _path = path {
    _settings.addListener(_onSettings);
    _showHidden = _settings.showHidden;
    final start =
        options ??
        TabListOptions(
          viewMode: _settings.viewMode,
          sortField: _settings.sortField,
          ascending: _settings.ascending,
          groupByDate: _settings.groupByDate,
        );
    _viewMode = start.viewMode;
    _sortField = start.sortField;
    _ascending = start.ascending;
    _groupByDate = start.groupByDate;
    _kindFilter.addAll(start.kinds);
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
  String? _justCreated;
  Timer? _justCreatedTimer;
  late BrowserViewMode _viewMode;
  late SortField _sortField;
  late bool _ascending;
  late bool _groupByDate;

  String get path => _path;

  @override
  BrowserViewMode get viewMode => _viewMode;
  @override
  SortField get sortField => _sortField;
  @override
  bool get ascending => _ascending;
  @override
  bool get groupByDate => _groupByDate;

  /// Lo que se guarda de esta pestaña, además de su carpeta.
  TabListOptions get options => TabListOptions(
    viewMode: _viewMode,
    sortField: _sortField,
    ascending: _ascending,
    groupByDate: _groupByDate,
    kinds: Set.of(_kindFilter),
  );

  @override
  void setViewMode(BrowserViewMode mode) {
    if (mode == _viewMode) return;
    _viewMode = mode;
    _optionsChanged();
  }

  /// Un toque: ese criterio de menor a mayor. Otro toque al mismo: de mayor
  /// a menor. Igual en la hoja y en Detalles.
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
    _optionsChanged();
  }

  @override
  void setGroupByDate(bool value) {
    final (sortField, ascending) = groupSortRule(value, _sortField, _ascending);
    _sortField = sortField;
    _ascending = ascending;
    _groupByDate = value;
    _optionsChanged();
  }

  // La última que se usó queda de base para lo que no tiene la suya.
  void _optionsChanged() {
    _settings.rememberLast(
      viewMode: _viewMode,
      sortField: _sortField,
      ascending: _ascending,
      groupByDate: _groupByDate,
    );
    _refresh();
  }

  /// Lo que se acaba de crear aquí: parpadea en la lista un momento.
  String? get justCreated => _justCreated;

  /// Hace parpadear [path] en la lista; después de un rato se olvida, para
  /// que no vuelva a parpadear al recorrer la lista.
  void markCreated(String path) {
    _justCreated = path;
    _justCreatedTimer?.cancel();
    _justCreatedTimer = Timer(const Duration(seconds: 2), () {
      _justCreated = null;
      notifyListeners();
    });
    notifyListeners();
  }

  /// Memoria (interna, SD o USB) donde está la carpeta actual.
  StorageVolume get volume => _volumes.volumeOf(_path);

  /// Hasta donde se puede subir: la raíz del sistema en Android, así que
  /// Interno, SD y USB se ven como carpetas de la ruta.
  String get root => _volumes.treeRootOf(_path);

  /// La carpeta actual es el inicio de su memoria (Interno, una SD...).
  bool get atVolumeRoot => p.equals(_path, volume.path);

  /// Contenido visible: filtrado por tipo y ordenado.
  List<FileEntry> get entries => _entries;

  /// Cuántos elementos tiene la carpeta antes de filtrar.
  int get totalCount => _byPath.length;
  bool get loading => _loading;

  /// La carpeta actual no se pudo leer (por ejemplo `Android/data`).
  bool get failed => _failed;

  /// Tipos de archivo que se muestran; vacío es todos. Las carpetas siempre
  /// se muestran, para poder seguir navegando.
  @override
  Set<FileKind> get kindFilter => Set.unmodifiable(_kindFilter);
  bool get canGoUp => !p.equals(_path, root);

  /// La selección (ver [Selection]) va por rutas, en el orden de [entries].
  /// Navegar la suelta.
  @override
  List<String> get selectionKeys => [for (final e in _entries) e.path];

  List<FileEntry> get selectedEntries => [
    for (final path in selected)
      if (_byPath[path] != null) _byPath[path]!,
  ];

  /// El botón atrás del sistema tiene algo que hacer en esta pestaña.
  bool get canHandleBack => selecting || canGoBack || canGoUp;
  bool get canGoBack => _back.isNotEmpty;
  bool get canGoForward => _forward.isNotEmpty;

  /// Carpetas desde [root] hasta la actual, para el menú del título.
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

  /// Sube una carpeta. false si ya está en [root].
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
            retainSelection(fresh.containsKey);
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
    retainSelection((_) => false);
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

  @override
  void toggleKind(FileKind kind) {
    if (!_kindFilter.remove(kind)) _kindFilter.add(kind);
    _refresh();
  }

  @override
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
    _entries = sortEntries(visible, this);
    notifyListeners();
  }

  @override
  void dispose() {
    _listing?.cancel();
    _justCreatedTimer?.cancel();
    _settings.removeListener(_onSettings);
    super.dispose();
  }
}
