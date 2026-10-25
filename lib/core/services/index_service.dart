import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../src/rust/api/engine.dart' as rust;
import '../../src/rust/api/ops.dart' as ops;
import '../engine/rust_file_engine.dart';
import '../files/file_entry.dart';
import 'explorer_settings_service.dart';
import 'folder_watch_service.dart';
import 'storage_volumes_service.dart';

/// Índice del almacenamiento interno y las tarjetas SD, en el motor Rust (los
/// USB no se indexan). Al abrir la app se carga el guardado (la búsqueda
/// funciona de inmediato) y se pone al día en segundo plano: solo se leen
/// las carpetas que cambiaron ([update]), y si el último recorrido completo
/// tiene más de [fullEvery], se recorre todo ([rebuild]). También se pone al
/// día al volver a la app y con lo que avisa [FolderWatchService]. Si se pone
/// o se quita una SD, se indexa de nuevo.
class IndexService extends ChangeNotifier {
  static final IndexService _instance = IndexService._internal();
  factory IndexService() => _instance;
  IndexService._internal();

  /// Cada cuánto se recorre todo, para lo que cambia sin tocar su carpeta
  /// (un archivo que se reescribe en su lugar).
  static const fullEvery = Duration(days: 1);

  /// Volver a la app antes de esto no revisa nada.
  static const _resumeGap = Duration(seconds: 30);

  bool _started = false;
  bool _updating = false;
  DateTime? _fullAt;
  DateTime _checkedAt = DateTime.fromMillisecondsSinceEpoch(0);
  Duration? _took;
  List<String> _roots = const [];
  String? _dbPath;
  // Rutas que cambiaron durante un indexado completo; se ponen al día al terminar.
  final _pending = <String>{};
  bool _indexing = false;
  int _scanned = 0;
  int _entries = 0;
  DateTime? _indexedAt;
  Object? _error;
  int _revision = 0;

  bool get indexing => _indexing;

  /// Archivos y carpetas vistos en el indexado en curso.
  int get scanned => _scanned;

  /// Archivos y carpetas en el índice listo.
  int get entries => _entries;

  /// null si nunca se ha terminado un indexado.
  DateTime? get indexedAt => _indexedAt;
  bool get ready => _indexedAt != null;

  /// Cuánto tardó la última puesta al día de esta sesión (completa o no).
  Duration? get took => _took;
  Object? get error => _error;

  /// Cambia cada vez que el índice cambia (indexado completo o parcial).
  int get revision => _revision;

  /// Carga el índice guardado y lo actualiza. Solo la primera vez; requiere
  /// el permiso de almacenamiento.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    final volumes = StorageVolumesService();
    await volumes.start();
    volumes.addListener(_onVolumes);
    _dbPath = p.join((await getApplicationSupportDirectory()).path, 'index.db');
    FolderWatchService().changes.listen(refreshPaths);
    AppLifecycleListener(onResume: _onResume);
    await _open(volumes.indexedRoots);
  }

  void _onResume() {
    if (DateTime.now().difference(_checkedAt) < _resumeGap) return;
    _catchUp();
  }

  // Completo si hace falta; si no, solo lo que cambió.
  Future<void> _catchUp() {
    final fullAt = _fullAt;
    final stale =
        fullAt == null || DateTime.now().difference(fullAt) > fullEvery;
    return stale ? rebuild() : update();
  }

  Future<void> _open(List<String> roots) async {
    _roots = roots;
    try {
      _apply(await rust.engineOpen(dbPath: _dbPath!, roots: roots));
      notifyListeners();
    } catch (e) {
      _error = e;
      notifyListeners();
      return;
    }
    await _catchUp();
  }

  // Se puso o se quitó una tarjeta SD: el índice cubre otras raíces.
  void _onVolumes() {
    final roots = StorageVolumesService().indexedRoots;
    if (_indexing || listEquals(roots, _roots)) return;
    _open(roots);
  }

  /// Indexa todo desde cero. Mientras tanto la búsqueda usa el índice anterior.
  Future<void> rebuild() async {
    if (_indexing || _updating || !_started) return;
    _checkedAt = DateTime.now();
    _indexing = true;
    _scanned = 0;
    _error = null;
    notifyListeners();
    try {
      await for (final progress in rust.indexBuild()) {
        _scanned = progress.scanned;
        if (progress.info != null) _apply(progress.info!);
        notifyListeners();
      }
    } catch (e) {
      _error = e;
    } finally {
      _indexing = false;
      notifyListeners();
    }
    await _afterBusy();
  }

  /// Lee solo las carpetas cuya fecha cambió desde la última vez. Sin
  /// progreso en pantalla: suele tardar menos de un segundo.
  Future<void> update() async {
    if (_indexing || _updating || !_started || !ready) return;
    _checkedAt = DateTime.now();
    _updating = true;
    try {
      final info = await rust.indexUpdate();
      if (info != null) {
        _apply(info);
        notifyListeners();
      }
    } catch (e) {
      _error = e;
      notifyListeners();
    } finally {
      _updating = false;
    }
    await _afterBusy();
  }

  Future<void> _afterBusy() async {
    // Si cambió una memoria mientras indexaba, vuelve a empezar con ella.
    _onVolumes();
    if (_pending.isNotEmpty) {
      final paths = _pending.toList();
      _pending.clear();
      await refreshPaths(paths);
    }
  }

  void _apply(rust.IndexInfo info) {
    DateTime? date(int secs) =>
        secs == 0 ? null : DateTime.fromMillisecondsSinceEpoch(secs * 1000);
    _revision++;
    _entries = info.entries;
    _indexedAt = date(info.indexedAt);
    _fullAt = date(info.fullAt);
    if (info.tookMs > 0) _took = Duration(milliseconds: info.tookMs);
  }

  /// Pone al día solo [paths] después de copiar, mover, renombrar o borrar,
  /// o cuando otra app cambia algo en una carpeta abierta.
  Future<void> refreshPaths(Iterable<String> paths) async {
    if (!_started || _dbPath == null || paths.isEmpty) return;
    if (_indexing || _updating) {
      _pending.addAll(paths);
      return;
    }
    try {
      final info = await ops.indexRefresh(
        dbPath: _dbPath!,
        paths: paths.toList(),
      );
      if (info != null) {
        _apply(info);
        notifyListeners();
      }
    } catch (_) {
      // El siguiente indexado completo lo corrige.
    }
  }

  /// Busca por nombre en todo lo indexado o solo dentro de [within].
  /// Tolera errores de escritura. Los ocultos según Ajustes.
  Future<List<FileEntry>> search(String query, {String? within}) async {
    final items = await rust.search(
      query: query,
      within: within,
      includeHidden: ExplorerSettingsService().searchHidden,
      limit: 300,
    );
    return items.map(fileEntryOf).toList();
  }

  /// null si [path] se indexa y todavía no hay índice. Lo que no se indexa
  /// (USB) se recorre en el momento.
  Future<rust.StorageUsage?> usage(String path) =>
      rust.storageUsage(path: path);

  /// Archivos dentro de [path] con alguna de [extensions], del más pesado al
  /// más ligero (hasta [limit]). Igual que [usage]: null sin índice.
  Future<List<FileEntry>?> filesOfExtensions(
    String path,
    List<String> extensions, {
    int limit = 500,
  }) async {
    final items = await rust.filesByExtension(
      path: path,
      extensions: extensions,
      limit: limit,
    );
    return items?.map(fileEntryOf).toList();
  }
}
