import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../storage/hive_bootstrap.dart';

/// Vibración corta al seleccionar (pedida el 2026-10-30). Se apaga en
/// Ajustes y se guarda en Hive; por defecto está prendida. Además, Android
/// no vibra si el teléfono tiene apagada la respuesta táctil.
class HapticsService extends ChangeNotifier {
  static final HapticsService _instance = HapticsService._internal();
  factory HapticsService() => _instance;
  HapticsService._internal();

  static const _key = 'haptics';

  Box? get _box => Hive.isBoxOpen(HiveBootstrap.settingsBox)
      ? Hive.box(HiveBootstrap.settingsBox)
      : null;

  bool get enabled => _box?.get(_key) as bool? ?? true;

  Future<void> setEnabled(bool enabled) async {
    await _box?.put(_key, enabled);
    notifyListeners();
  }

  /// Empieza una selección (mantener presionado).
  void start() {
    if (enabled) HapticFeedback.mediumImpact();
  }

  /// Marca o desmarca un elemento, un grupo o todo. `lightImpact` y no
  /// `selectionClick`, que en muchos teléfonos no se siente.
  void tick() {
    if (enabled) HapticFeedback.lightImpact();
  }
}
