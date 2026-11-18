import 'dart:math';

import 'package:flutter/foundation.dart';

/// Selección múltiple de una lista: tocar marca o desmarca, mantener
/// presionado y deslizar marca un tramo y tocar el encabezado de un grupo
/// marca el grupo. La usan Explorar, Favoritos, la Papelera y los archivos de
/// un tipo (pedido el 2026-10-29). Las claves son las rutas.
mixin Selection on ChangeNotifier {
  final _selected = <String>{};
  // Tramo de mantener presionado y deslizar: la selección de antes, dónde
  // empezó y si marca o desmarca. null fuera del gesto.
  Set<String>? _dragBase;
  int _dragAnchor = 0;
  bool _dragAdds = true;

  /// Las claves en el orden en que se ven: los números de los gestos son
  /// posiciones en esta lista.
  List<String> get selectionKeys;

  Set<String> get selected => Set.unmodifiable(_selected);
  bool get selecting => _selected.isNotEmpty;

  void toggleSelection(String key) {
    if (!_selected.remove(key)) _selected.add(key);
    notifyListeners();
  }

  /// Empieza un tramo de mantener presionado y deslizar en [index]. Si ese
  /// ya estaba seleccionado, el tramo desmarca.
  void startDragSelection(int index) {
    final keys = selectionKeys;
    if (index >= keys.length) return;
    _dragBase = Set.of(_selected);
    _dragAnchor = index;
    _dragAdds = !_selected.contains(keys[index]);
    updateDragSelection(index);
  }

  /// El tramo va del primero a [index]; lo que quedó fuera al regresar el
  /// dedo vuelve a como estaba antes del tramo.
  void updateDragSelection(int index) {
    final base = _dragBase;
    final keys = selectionKeys;
    if (base == null || keys.isEmpty) return;
    final last = keys.length - 1;
    final from = min(_dragAnchor, index).clamp(0, last);
    final to = max(_dragAnchor, index).clamp(0, last);
    _selected
      ..clear()
      ..addAll(base);
    for (var i = from; i <= to; i++) {
      _dragAdds ? _selected.add(keys[i]) : _selected.remove(keys[i]);
    }
    notifyListeners();
  }

  void endDragSelection() => _dragBase = null;

  /// Las posiciones [start, end) (un grupo por fecha): si ya estaban todas
  /// marcadas las desmarca; si no, las marca.
  void toggleRange(int start, int end) {
    final keys = selectionKeys.sublist(start, end);
    if (keys.every(_selected.contains)) {
      _selected.removeAll(keys);
    } else {
      _selected.addAll(keys);
    }
    notifyListeners();
  }

  /// Selecciona todo lo visible (respeta filtro y búsqueda).
  void selectAll() {
    _selected.addAll(selectionKeys);
    notifyListeners();
  }

  void clearSelection() {
    if (_selected.isEmpty) return;
    _selected.clear();
    notifyListeners();
  }

  /// Suelta lo que ya no está (sin avisar: quien llama avisa).
  @protected
  void retainSelection(bool Function(String key) keep) =>
      _selected.removeWhere((key) => !keep(key));
}

/// Selección de una pantalla que arma su lista en cada `build`: la pantalla
/// pone [keys] con lo visible antes de dibujar.
class SelectionController extends ChangeNotifier with Selection {
  List<String> keys = const [];

  @override
  List<String> get selectionKeys => keys;

  /// Suelta lo que ya no se ve (borrado, restaurado o filtrado).
  void retainVisible() {
    final visible = keys.toSet();
    retainSelection(visible.contains);
  }
}
