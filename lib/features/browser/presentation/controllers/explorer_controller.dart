import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;

import '../../../../core/engine/file_engine.dart';
import '../../../../core/services/file_changes.dart';
import '../../../../core/services/folder_watch_service.dart';
import '../../../../core/services/storage_permission_service.dart';
import '../../../../core/services/storage_volumes_service.dart';
import '../../../../core/storage/hive_bootstrap.dart';
import 'browser_controller.dart';

/// La pestaña Explorar completa: permiso y pestañas abiertas, como el
/// Explorador de Windows (pedido el 2026-10-20). Las pestañas se guardan y
/// vuelven al abrir la app. Vive en `MainScreen` para que el botón atrás del
/// sistema navegue en la pestaña activa. La carpeta de la pestaña activa se
/// vigila: si otra app cambia algo ahí, la lista se pone al día sola.
class ExplorerController extends ChangeNotifier {
  ExplorerController({
    this.onPermissionGranted,
    FileEngine? engine,
    StorageVolumesService? volumes,
    FolderWatchService? watcher,
    bool? permissionGranted,
  }) : _engine = engine,
       _volumes = volumes ?? StorageVolumesService(),
       _watcher = watcher ?? FolderWatchService(),
       _permissionGranted = permissionGranted {
    _tabs.add(_newTab(_volumes.home));
    _changes = FileChanges.stream.listen(_onFilesChanged);
    _outside = _watcher.changes.listen(_onOutsideChanges);
  }

  static const _tabsKey = 'explorerTabs';
  static const _activeKey = 'explorerActiveTab';

  /// Se llama una vez que hay permiso (por ejemplo, para empezar a indexar).
  final VoidCallback? onPermissionGranted;
  final FileEngine? _engine;
  final StorageVolumesService _volumes;
  final FolderWatchService _watcher;

  final _tabs = <BrowserController>[];
  int _active = 0;
  bool? _permissionGranted;
  AppLifecycleListener? _lifecycle;
  StreamSubscription<Set<String>>? _changes;
  StreamSubscription<Set<String>>? _outside;

  List<BrowserController> get tabs => List.unmodifiable(_tabs);
  int get activeIndex => _active;
  BrowserController get active => _tabs[_active];

  /// null mientras se revisa.
  bool? get permissionGranted => _permissionGranted;

  BrowserController _newTab(String path) =>
      BrowserController(path: path, engine: _engine, volumes: _volumes)
        ..addListener(_onTabChanged);

  Future<void> init() async {
    final saved = _box?.get(_tabsKey);
    if (saved is List && saved.isNotEmpty) {
      for (final tab in _tabs) {
        tab.dispose();
      }
      _tabs
        ..clear()
        ..addAll(saved.cast<String>().map(_newTab));
      final active = _box?.get(_activeKey) as int? ?? 0;
      _active = active.clamp(0, _tabs.length - 1);
    }
    // El permiso se concede fuera de la app: se revisa de nuevo al volver.
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    _permissionGranted ??= await StoragePermissionService.isGranted();
    notifyListeners();
    if (_permissionGranted!) _granted();
  }

  Future<void> requestPermission() async {
    _permissionGranted = await StoragePermissionService.request();
    notifyListeners();
    if (_permissionGranted!) _granted();
  }

  // Mientras la app no se veía pudo cambiar cualquier cosa.
  void _onResume() {
    if (_permissionGranted == true) {
      active.refreshQuietly();
      return;
    }
    _recheckPermission();
  }

  Future<void> _recheckPermission() async {
    if (_permissionGranted != false) return;
    if (await StoragePermissionService.isGranted()) {
      _permissionGranted = true;
      notifyListeners();
      _granted();
    }
  }

  void _granted() {
    onPermissionGranted?.call();
    active.reload();
    _watcher.watch({active.path});
  }

  /// Abre una pestaña nueva en [path] (la raíz del sistema si no se da) y la
  /// activa.
  void newTab([String? path]) {
    _tabs.add(_newTab(path ?? _volumes.home));
    select(_tabs.length - 1);
  }

  void select(int index) {
    if (index == _active && active.entries.isNotEmpty) return;
    if (index != _active) active.suspend();
    _active = index;
    if (_permissionGranted == true) active.reload();
    _save();
    notifyListeners();
  }

  /// Cierra una pestaña; siempre queda al menos una.
  void close(int index) {
    if (_tabs.length == 1) return;
    final closing = _tabs.removeAt(index);
    closing
      ..removeListener(_onTabChanged)
      ..dispose();
    if (index < _active || _active >= _tabs.length) {
      _active = (_active - 1).clamp(0, _tabs.length - 1);
    }
    if (_permissionGranted == true) active.reload();
    _save();
    notifyListeners();
  }

  // La pantalla y el botón atrás dependen de la carpeta de la pestaña activa.
  // Se copió, movió o borró algo: la pestaña activa se recarga si muestra
  // una de esas carpetas; las demás se recargan al activarse.
  void _onFilesChanged(Set<String> dirs) {
    if (_permissionGranted != true) return;
    if (dirs.any((d) => p.equals(d, active.path))) active.refreshQuietly();
  }

  // Otra app creó, borró o cambió algo en la carpeta vigilada.
  void _onOutsideChanges(Set<String> paths) {
    if (_permissionGranted != true) return;
    final here = paths.any(
      (path) =>
          p.equals(path, active.path) || p.equals(p.dirname(path), active.path),
    );
    if (here) active.refreshQuietly();
  }

  void _onTabChanged() {
    _save();
    if (_permissionGranted == true) _watcher.watch({active.path});
    notifyListeners();
  }

  // Solo escribe si cambió algo: las pestañas avisan en cada parte del listado.
  String _saved = '';

  void _save() {
    final paths = [for (final tab in _tabs) tab.path];
    final key = '$_active|${paths.join('|')}';
    if (key == _saved) return;
    _saved = key;
    _box
      ?..put(_tabsKey, paths)
      ..put(_activeKey, _active);
  }

  Box? get _box => Hive.isBoxOpen(HiveBootstrap.settingsBox)
      ? Hive.box(HiveBootstrap.settingsBox)
      : null;

  @override
  void dispose() {
    for (final tab in _tabs) {
      tab.dispose();
    }
    _lifecycle?.dispose();
    _changes?.cancel();
    _outside?.cancel();
    super.dispose();
  }
}
