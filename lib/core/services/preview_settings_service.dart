import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../files/file_kind.dart';
import '../storage/hive_bootstrap.dart';

/// Qué tipos de archivo muestran una miniatura en lugar de su logo. Se elige
/// en Ajustes y se guarda en Hive. Por defecto, todos los que la tienen.
class PreviewSettingsService extends ChangeNotifier {
  static final PreviewSettingsService _instance =
      PreviewSettingsService._internal();
  factory PreviewSettingsService() => _instance;
  PreviewSettingsService._internal();

  /// Tipos que pueden tener miniatura.
  static const kinds = [FileKind.image, FileKind.video, FileKind.pdf];

  static String _key(FileKind kind) => 'preview_${kind.name}';

  Box? get _box => Hive.isBoxOpen(HiveBootstrap.settingsBox)
      ? Hive.box(HiveBootstrap.settingsBox)
      : null;

  bool isEnabled(FileKind kind) =>
      kinds.contains(kind) && (_box?.get(_key(kind)) as bool? ?? true);

  Future<void> setEnabled(FileKind kind, bool enabled) async {
    await _box?.put(_key(kind), enabled);
    notifyListeners();
  }
}
