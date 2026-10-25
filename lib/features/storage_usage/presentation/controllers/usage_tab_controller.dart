import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../../../core/services/storage_volumes_service.dart';

/// Carpeta que muestra la pestaña Espacio y las anteriores, para que el botón
/// atrás suba dentro de la pestaña. Vive en `MainScreen`.
class UsageTabController extends ChangeNotifier {
  UsageTabController({StorageVolumesService? volumes})
    : _volumes = volumes ?? StorageVolumesService() {
    _stack.add(_volumes.volumes.first.path);
  }

  final StorageVolumesService _volumes;
  final _stack = <String>[];

  String get path => _stack.last;
  StorageVolume get volume => _volumes.volumeOf(path);
  bool get canGoBack => _stack.length > 1;

  /// Carpetas desde la raíz de la memoria hasta la actual, para el breadcrumb.
  List<String> get trail {
    final root = volume.path;
    final trail = [root];
    if (p.equals(path, root)) return trail;
    for (final part in p.split(p.relative(path, from: root))) {
      trail.add(p.join(trail.last, part));
    }
    return trail;
  }

  /// Entra a una subcarpeta.
  void open(String path) {
    _stack.add(path);
    notifyListeners();
  }

  /// Muestra [path] con sus carpetas de arriba como camino de regreso (desde
  /// Explorar, el breadcrumb o el selector de memoria).
  void show(String path) {
    final root = _volumes.volumeOf(path).path;
    _stack
      ..clear()
      ..add(root);
    if (!p.equals(path, root)) {
      for (final part in p.split(p.relative(path, from: root))) {
        _stack.add(p.join(_stack.last, part));
      }
    }
    notifyListeners();
  }

  bool goBack() {
    if (!canGoBack) return false;
    _stack.removeLast();
    notifyListeners();
    return true;
  }
}
