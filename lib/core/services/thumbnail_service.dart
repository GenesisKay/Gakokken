import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import '../files/file_kind.dart';

/// Miniaturas de archivos. En Android las hace el sistema (imágenes, un
/// cuadro de los videos y la primera página de los PDF) y quedan en un caché
/// en disco, así la segunda vez solo se lee un JPEG chico. En escritorio las
/// imágenes se decodifican ya reducidas.
class ThumbnailService {
  static const _channel = MethodChannel('gakoken/system');

  /// Formatos de imagen que se saben reducir.
  static const _images = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
    'heic',
    'heif',
    'ico',
  };

  // Una sola petición por archivo y tamaño, aunque se dibuje varias veces.
  static final _requests = <String, Future<String?>>{};

  static bool supports(FileKind kind, String extension) => switch (kind) {
    FileKind.image => _images.contains(extension),
    FileKind.pdf || FileKind.video => Platform.isAndroid,
    _ => false,
  };

  /// [pixels] es el ancho de la miniatura en píxeles físicos. null si no hay.
  static Future<ImageProvider?> of(
    String path,
    FileKind kind,
    int pixels,
  ) async {
    if (!Platform.isAndroid) {
      if (kind != FileKind.image) return null;
      return ResizeImage(
        FileImage(File(path)),
        width: pixels,
        policy: ResizeImagePolicy.fit,
      );
    }
    final key = '$path|$pixels';
    if (_requests.length > 500) _requests.clear();
    final jpeg = await (_requests[key] ??= _channel
        .invokeMethod<String>('thumbnail', {
          'path': path,
          'kind': kind.name,
          'size': pixels,
        })
        .catchError((Object _) => null));
    return jpeg == null ? null : FileImage(File(jpeg));
  }
}
