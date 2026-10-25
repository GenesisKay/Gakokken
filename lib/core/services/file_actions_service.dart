import 'dart:io';

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

enum OpenOutcome { opened, noApp, missing, error }

/// Lo que se hace con un archivo fuera de Gakoken: abrirlo con otra app y
/// compartirlo. Es código propio de cada sistema, por eso no pasa por el motor.
class FileActionsService {
  static const _channel = MethodChannel('gakoken/system');

  /// En Android muestra siempre el selector "Abrir con" del sistema
  /// ([chooserTitle] es su título). En escritorio usa la app predeterminada.
  static Future<OpenOutcome> open(
    String path, {
    required String chooserTitle,
  }) async {
    if (Platform.isAndroid) {
      final result = await _channel.invokeMethod<String>('openWith', {
        'path': path,
        'title': chooserTitle,
      });
      return switch (result) {
        'opened' => OpenOutcome.opened,
        'noApp' => OpenOutcome.noApp,
        'missing' => OpenOutcome.missing,
        _ => OpenOutcome.error,
      };
    }
    if (await FileSystemEntity.type(path) == FileSystemEntityType.notFound) {
      return OpenOutcome.missing;
    }
    final result = Platform.isWindows
        ? await Process.run('cmd', ['/c', 'start', '', path])
        : await Process.run(Platform.isMacOS ? 'open' : 'xdg-open', [path]);
    return result.exitCode == 0 ? OpenOutcome.opened : OpenOutcome.noApp;
  }

  static Future<void> share(List<String> paths) => SharePlus.instance.share(
    ShareParams(files: [for (final path in paths) XFile(path)]),
  );
}
