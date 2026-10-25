import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Acceso a todo el almacenamiento (decidido en Vault/Proyectos/Gakoken.md).
/// Android 11 o más usa "acceso a todos los archivos"; Android 10 o menos, el
/// permiso de almacenamiento clásico. En escritorio no hace falta permiso.
class StoragePermissionService {
  /// Raíz que se indexa: el almacenamiento interno en Android y la carpeta
  /// personal en escritorio.
  static String get storageRoot {
    if (Platform.isAndroid) return '/storage/emulated/0';
    return Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        Directory.current.path;
  }

  static Future<bool> isGranted() async {
    if (!Platform.isAndroid) return true;
    return (await _permission()).isGranted;
  }

  static Future<bool> request() async {
    if (!Platform.isAndroid) return true;
    return (await (await _permission()).request()).isGranted;
  }

  static Future<Permission> _permission() async {
    final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    return sdk >= 30 ? Permission.manageExternalStorage : Permission.storage;
  }
}
