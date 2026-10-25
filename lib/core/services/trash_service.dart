import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;

import '../../src/rust/api/ops.dart' as ops;
import '../storage/hive_bootstrap.dart';
import 'file_changes.dart';
import 'index_service.dart';
import 'storage_volumes_service.dart';

class TrashItem {
  const TrashItem({
    required this.id,
    required this.originalPath,
    required this.trashedPath,
    required this.deletedAt,
    required this.isDir,
  });

  final String id;
  final String originalPath;

  /// Dónde está ahora: `.gakoken-trash/<id>` en la raíz de su memoria.
  final String trashedPath;
  final DateTime deletedAt;
  final bool isDir;

  String get name => p.basename(originalPath);

  /// Días que faltan para que se borre solo (0 el último día), si se guarda
  /// [retentionDays] días.
  int daysLeft(DateTime now, int retentionDays) {
    final expires = deletedAt.add(Duration(days: retentionDays));
    return expires.difference(now).inDays.clamp(0, retentionDays);
  }
}

/// Papelera propia de Gakoken (decidida el 2026-10-20): borrar mueve a
/// `.gakoken-trash` en la raíz de la misma memoria (un renombrado, instantáneo
/// aunque sea una carpeta grande) y guarda en Hive de dónde venía. La de
/// Android solo cubre fotos, videos y audio.
class TrashService extends ChangeNotifier {
  static final TrashService _instance = TrashService._internal();
  factory TrashService() => _instance;
  TrashService._internal();

  /// Días que se guarda algo antes de borrarse solo: 30 de fábrica y el
  /// usuario elige otro número en la Papelera (pedido el 2026-10-23).
  static const defaultDays = 30;
  static const maxDays = 999;
  static const _daysKey = 'trashDays';

  Box? get _settings => Hive.isBoxOpen(HiveBootstrap.settingsBox)
      ? Hive.box(HiveBootstrap.settingsBox)
      : null;

  int get retentionDays =>
      _settings?.get(_daysKey, defaultValue: defaultDays) as int? ??
      defaultDays;

  /// Guarda los días y borra al momento lo que ya lleve más que eso.
  Future<void> setRetentionDays(int days) async {
    await _settings?.put(_daysKey, days.clamp(1, maxDays));
    notifyListeners();
    await purgeExpired();
  }

  Box get _box => Hive.box(HiveBootstrap.trashBox);
  int _counter = 0;

  /// Lo que está en la papelera de las memorias conectadas, del más reciente
  /// al más viejo.
  List<TrashItem> get items {
    final volumes = StorageVolumesService();
    return [
        for (final value in _box.values) _itemOf(value as Map),
      ].where((item) => volumes.isAvailable(item.trashedPath)).toList()
      ..sort((a, b) => b.deletedAt.compareTo(a.deletedAt));
  }

  static TrashItem _itemOf(Map value) => TrashItem(
    id: value['id'] as String,
    originalPath: value['originalPath'] as String,
    trashedPath: value['trashedPath'] as String,
    deletedAt: DateTime.fromMillisecondsSinceEpoch(value['deletedAt'] as int),
    isDir: value['isDir'] as bool,
  );

  /// Manda [paths] a la papelera. Devuelve lo que sí se movió (para
  /// Deshacer) y deja fuera lo que falló.
  Future<List<TrashItem>> trash(Map<String, bool> pathsAndIsDir) async {
    final volumes = StorageVolumesService();
    final done = <TrashItem>[];
    final trashDirs = <String>{};
    for (final MapEntry(key: path, value: isDir) in pathsAndIsDir.entries) {
      final id = '${DateTime.now().microsecondsSinceEpoch}_${_counter++}';
      final trashDir = p.join(volumes.volumeOf(path).path, ops.trashDirName());
      final item = TrashItem(
        id: id,
        originalPath: path,
        trashedPath: p.join(trashDir, id),
        deletedAt: DateTime.now(),
        isDir: isDir,
      );
      try {
        await ops.moveExact(from: path, to: item.trashedPath);
      } catch (_) {
        continue;
      }
      await _box.put(id, {
        'id': id,
        'originalPath': path,
        'trashedPath': item.trashedPath,
        'deletedAt': item.deletedAt.millisecondsSinceEpoch,
        'isDir': isDir,
      });
      trashDirs.add(trashDir);
      done.add(item);
    }
    _changed([for (final i in done) i.originalPath], trashDirs);
    return done;
  }

  /// Regresa cada uno a su lugar. Si ahí ya hay algo con ese nombre, queda
  /// como `nombre (1)`.
  Future<int> restore(List<TrashItem> items) async {
    final restored = <String>[];
    for (final item in items) {
      final target = ops.uniquePath(path: item.originalPath);
      try {
        await ops.moveExact(from: item.trashedPath, to: target);
      } catch (_) {
        continue;
      }
      await _box.delete(item.id);
      restored.add(target);
    }
    _changed(restored, {for (final i in items) p.dirname(i.trashedPath)});
    return restored.length;
  }

  Future<void> deleteForever(List<TrashItem> items) async {
    final failed = (await ops.deletePaths(
      paths: [for (final i in items) i.trashedPath],
    )).toSet();
    for (final item in items) {
      if (!failed.contains(item.trashedPath)) await _box.delete(item.id);
    }
    _changed(const [], {for (final i in items) p.dirname(i.trashedPath)});
  }

  Future<void> empty() => deleteForever(items);

  /// Borra lo que lleva más de [retentionDays] días. Se llama al abrir la app.
  Future<void> purgeExpired() async {
    final now = DateTime.now();
    final retentionDays = this.retentionDays;
    final expired = items
        .where((i) => now.difference(i.deletedAt).inDays >= retentionDays)
        .toList();
    if (expired.isNotEmpty) await deleteForever(expired);
  }

  void _changed(List<String> paths, Set<String> trashDirs) {
    FileChanges.notify(paths.map(p.dirname));
    IndexService().refreshPaths([...paths, ...trashDirs]);
    notifyListeners();
  }
}
