import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;

import 'storage_permission_service.dart';

/// [system] es la raíz de Android (`/`): va al final y se agregó el
/// 2026-10-21 a pedido del usuario.
enum VolumeKind { internal, sd, usb, system }

class StorageVolume {
  const StorageVolume({
    required this.path,
    required this.label,
    required this.kind,
    this.totalBytes = 0,
    this.freeBytes = 0,
    this.appsBytes,
  });

  final String path;

  /// Nombre que da Android ("Tarjeta SD de SanDisk"). En la interna la app
  /// usa su propio texto (Interno).
  final String label;
  final VolumeKind kind;
  final int totalBytes;
  final int freeBytes;

  /// Lo que ocupan las apps con sus datos. Solo en la interna y con Acceso
  /// al uso (Android lo pide para saberlo); null si no.
  final int? appsBytes;

  /// Interno y SD se indexan; USB no, porque se conecta y se desconecta
  /// (decidido el 2026-10-20). La raíz del sistema tampoco.
  bool get indexed => kind == VolumeKind.internal || kind == VolumeKind.sd;

  bool contains(String other) =>
      p.equals(path, other) || p.isWithin(path, other);
}

/// Memorias montadas: la interna, tarjetas SD y USB. Se actualiza al volver
/// a la app (por si se conectó o se quitó una).
class StorageVolumesService extends ChangeNotifier {
  static final StorageVolumesService _instance =
      StorageVolumesService._internal();
  factory StorageVolumesService() => _instance;
  StorageVolumesService._internal();

  static const _channel = MethodChannel('gakoken/system');

  static const _system = StorageVolume(
    path: '/',
    label: '',
    kind: VolumeKind.system,
  );

  AppLifecycleListener? _lifecycle;
  List<StorageVolume> _volumes = [
    StorageVolume(
      path: StoragePermissionService.storageRoot,
      label: '',
      kind: VolumeKind.internal,
    ),
    if (Platform.isAndroid) _system,
  ];

  /// La interna siempre va primero.
  List<StorageVolume> get volumes => _volumes;

  /// Donde abre Explorar recién instalada y cada pestaña nueva: la interna
  /// (pedido el 2026-11-06; del 2026-10-21 a esa fecha abría en la raíz).
  String get home => _volumes.first.path;

  /// Donde empieza la ruta de [path] en Explorar. En Android es la raíz del
  /// sistema (`/`): las memorias son carpetas dentro de ella, no lugares
  /// aparte (pedido el 2026-11-06). Sin raíz, la memoria de [path].
  String treeRootOf(String path) => _volumes
      .firstWhere(
        (v) => v.kind == VolumeKind.system,
        orElse: () => volumeOf(path),
      )
      .path;

  /// La memoria que empieza justo en [path], si hay una.
  StorageVolume? volumeAt(String path) {
    for (final v in _volumes) {
      if (p.equals(v.path, path)) return v;
    }
    return null;
  }

  /// Un enlace de la raíz del sistema que lleva a una memoria (como
  /// `/sdcard`) se abre en esa memoria, para que el breadcrumb diga cuál es.
  String resolve(String path) {
    if (volumeOf(path).kind != VolumeKind.system) return path;
    try {
      final real = Directory(path).resolveSymbolicLinksSync();
      return volumeOf(real).kind == VolumeKind.system ? path : real;
    } on FileSystemException {
      return path;
    }
  }

  List<String> get indexedRoots => [
    for (final v in _volumes)
      if (v.indexed) v.path,
  ];

  /// Memoria que contiene [path]; la interna si ninguna. Las memorias van
  /// antes que la raíz del sistema, que las contiene a todas.
  StorageVolume volumeOf(String path) => _volumes.firstWhere(
    (v) => v.contains(path),
    orElse: () => _volumes.first,
  );

  /// Si [path] está en alguna memoria conectada. En la raíz del sistema, si
  /// la carpeta existe (la de una SD o USB quitada ya no).
  bool isAvailable(String path) {
    final volume = volumeOf(path);
    if (!volume.contains(path)) return false;
    return volume.kind != VolumeKind.system || Directory(path).existsSync();
  }

  Future<void> start() async {
    _lifecycle ??= AppLifecycleListener(onResume: refresh);
    await refresh();
  }

  Future<void> refresh() async {
    if (!Platform.isAndroid) return;
    try {
      final raw = await _channel.invokeListMethod<Map>('storageVolumes');
      if (raw == null || raw.isEmpty) return;
      final volumes = [
        for (final v in raw)
          StorageVolume(
            path: v['path'] as String,
            label: v['label'] as String,
            kind: VolumeKind.values.asNameMap()[v['kind']] ?? VolumeKind.sd,
            totalBytes: v['total'] as int,
            freeBytes: v['free'] as int,
            appsBytes: v['apps'] as int?,
          ),
      ]..sort((a, b) => a.kind.index.compareTo(b.kind.index));
      if (volumes.first.kind != VolumeKind.internal) return;
      _volumes = [...volumes, _system];
      notifyListeners();
    } on PlatformException {
      // Se queda con lo que tenía.
    }
  }

  /// Abre Acceso al uso en Ajustes de Android. Al volver a la app las
  /// memorias se vuelven a leer solas.
  Future<void> requestUsageAccess() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('requestUsageAccess');
    } on PlatformException {
      // Sin Ajustes que abrir: Espacio sigue juntando apps y sistema.
    }
  }

  /// Para pruebas.
  @visibleForTesting
  set volumes(List<StorageVolume> volumes) {
    _volumes = volumes;
    notifyListeners();
  }
}
