import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

/// Avisa cuando algo cambia dentro de las carpetas vigiladas, aunque lo haga
/// otra app (en Android con `FileObserver`). Los avisos se juntan: llega uno
/// por ráfaga, con las rutas que cambiaron. Fuera de Android no avisa nada.
class FolderWatchService {
  static final FolderWatchService _instance = FolderWatchService._internal();
  factory FolderWatchService() => _instance;
  FolderWatchService._internal();

  static const _channel = MethodChannel('gakoken/system');
  static const _events = EventChannel('gakoken/changes');

  /// Espera desde el último aviso antes de mandar la ráfaga: copiar muchos
  /// archivos no debe recargar la carpeta por cada uno.
  static const quiet = Duration(milliseconds: 600);

  final _controller = StreamController<Set<String>>.broadcast();
  StreamSubscription<dynamic>? _native;
  final _pending = <String>{};
  Timer? _timer;
  Set<String> _watched = const {};

  /// Rutas que cambiaron (lo creado, borrado, movido o escrito).
  Stream<Set<String>> get changes => _controller.stream;

  /// Vigila exactamente [dirs]; lo que vigilaba antes y no está, se suelta.
  Future<void> watch(Set<String> dirs) async {
    if (!Platform.isAndroid) return;
    final normalized = dirs.map(p.normalize).toSet();
    if (_sameSet(normalized, _watched)) return;
    _watched = normalized;
    _native ??= _events.receiveBroadcastStream().listen(_onNative);
    try {
      await _channel.invokeMethod('watch', {'paths': normalized.toList()});
    } catch (_) {
      // Sin aviso la carpeta se pone al día al volver a abrirla.
    }
  }

  void _onNative(dynamic path) {
    if (path is! String) return;
    _pending.add(path);
    _timer?.cancel();
    _timer = Timer(quiet, () {
      _controller.add(Set.of(_pending));
      _pending.clear();
    });
  }

  /// Para pruebas: un aviso como si viniera de Android.
  @visibleForTesting
  void emit(Set<String> paths) => _controller.add(paths);

  static bool _sameSet(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}
