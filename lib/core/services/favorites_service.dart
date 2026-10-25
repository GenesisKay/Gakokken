import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;

import '../storage/hive_bootstrap.dart';

class Favorite {
  const Favorite({
    required this.path,
    required this.isDir,
    required this.addedAt,
  });

  final String path;
  final bool isDir;
  final DateTime addedAt;

  String get name => p.basename(path);
}

/// Archivos y carpetas marcados como favoritos, guardados en Hive.
/// Cada favorito es un mapa con clave automática: las rutas pueden pasar de
/// los 255 caracteres que Hive acepta como clave.
class FavoritesService extends ChangeNotifier {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  Box get _box => Hive.box(HiveBootstrap.favoritesBox);

  /// Del más reciente al más viejo.
  List<Favorite> get all {
    final favorites = [
      for (final value in _box.values)
        Favorite(
          path: value['path'] as String,
          isDir: value['isDir'] as bool,
          addedAt: DateTime.fromMillisecondsSinceEpoch(value['addedAt'] as int),
        ),
    ];
    favorites.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return favorites;
  }

  bool contains(String path) => _keyOf(path) != null;

  Future<void> add(String path, {required bool isDir}) async {
    if (contains(path)) return;
    await _box.add({
      'path': path,
      'isDir': isDir,
      'addedAt': DateTime.now().millisecondsSinceEpoch,
    });
    notifyListeners();
  }

  Future<void> remove(String path) async {
    final key = _keyOf(path);
    if (key == null) return;
    await _box.delete(key);
    notifyListeners();
  }

  /// Un archivo o carpeta cambió de lugar o de nombre: sus favoritos (y los
  /// de lo que tenía dentro) apuntan a la ruta nueva.
  Future<void> relocate(String from, String to) async {
    var changed = false;
    for (final key in _box.keys.toList()) {
      final value = Map<dynamic, dynamic>.from(_box.get(key) as Map);
      final path = value['path'] as String;
      final String? moved = path == from
          ? to
          : path.startsWith('$from${p.separator}')
          ? to + path.substring(from.length)
          : null;
      if (moved == null) continue;
      value['path'] = moved;
      await _box.put(key, value);
      changed = true;
    }
    if (changed) notifyListeners();
  }

  dynamic _keyOf(String path) {
    for (final key in _box.keys) {
      if (_box.get(key)['path'] == path) return key;
    }
    return null;
  }
}
