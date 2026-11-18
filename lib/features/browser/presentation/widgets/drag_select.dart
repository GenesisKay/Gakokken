import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/services/haptics_service.dart';

/// Qué hacer al mantener presionado y deslizar sobre la lista. Los números
/// son posiciones en la lista visible.
class DragSelectCallbacks {
  const DragSelectCallbacks({
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
  });

  /// El dedo se quedó quieto sobre [index]: empieza el tramo.
  final ValueChanged<int> onStart;

  /// El dedo llegó a [index]: el tramo va del primero a este.
  final ValueChanged<int> onUpdate;
  final VoidCallback onEnd;
}

/// Mantener presionado y deslizar selecciona un tramo, como en Google Fotos.
/// Con [swipe] (ya hay selección) no hace falta mantener presionado:
/// deslizar empezando de lado o en diagonal sigue seleccionando, y recto
/// hacia arriba o abajo hace scroll, como en las galerías (pedido el
/// 2026-10-30). Cerca del borde de arriba o de abajo la lista avanza sola. Cada elemento
/// va en un [DragSelectItem] para saber cuál queda bajo el dedo, así que
/// sirve igual con filas, celdas o encabezados en medio.
class DragSelectArea extends StatefulWidget {
  const DragSelectArea({
    super.key,
    required this.callbacks,
    required this.builder,
    this.swipe = false,
  });

  /// Deslizar de lado selecciona sin mantener presionado.
  final bool swipe;

  /// null: sin gesto, cada elemento maneja su propio mantener presionado.
  final DragSelectCallbacks? callbacks;

  /// La lista, que debe usar este controlador para poder avanzar sola.
  final Widget Function(BuildContext context, ScrollController controller)
  builder;

  @override
  State<DragSelectArea> createState() => _DragSelectAreaState();
}

class _DragSelectAreaState extends State<DragSelectArea> {
  final _scroll = ScrollController();
  Timer? _autoScroll;
  Offset? _finger;
  int? _last;

  /// Franja de arriba y de abajo donde la lista avanza sola; más adentro de
  /// la franja, más rápido.
  static const _edge = 64.0;
  static const _maxStep = 20.0;

  int? _indexAt(Offset local) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    // Fuera de la lista (al avanzar sola) cuenta el elemento del borde.
    final point = Offset(
      local.dx.clamp(1.0, box.size.width - 1),
      local.dy.clamp(1.0, box.size.height - 1),
    );
    final result = BoxHitTestResult();
    box.hitTest(result, position: point);
    for (final entry in result.path) {
      final target = entry.target;
      if (target is RenderMetaData && target.metaData is _ItemIndex) {
        return (target.metaData as _ItemIndex).index;
      }
    }
    return null;
  }

  void _start(Offset local, {bool strong = true}) {
    final index = _indexAt(local);
    if (index == null) return;
    _finger = local;
    _last = index;
    strong ? HapticsService().start() : HapticsService().tick();
    widget.callbacks?.onStart(index);
    _autoScroll = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _tick(),
    );
  }

  void _move(Offset local) {
    if (_last == null) return;
    _finger = local;
    _follow();
  }

  void _follow() {
    final finger = _finger;
    if (finger == null) return;
    final index = _indexAt(finger);
    if (index == null || index == _last) return;
    _last = index;
    HapticsService().tick();
    widget.callbacks?.onUpdate(index);
  }

  void _tick() {
    final finger = _finger;
    final box = context.findRenderObject() as RenderBox?;
    if (finger == null || box == null || !_scroll.hasClients) return;
    // Primero lo que quedó bajo el dedo con el avance anterior, que ya se
    // dibujó; luego el avance de este cuadro.
    _follow();
    final height = box.size.height;
    double depth = 0;
    if (finger.dy < _edge) {
      depth = -(_edge - finger.dy) / _edge;
    } else if (finger.dy > height - _edge) {
      depth = (finger.dy - (height - _edge)) / _edge;
    }
    if (depth == 0) return;
    final position = _scroll.position;
    final target = (position.pixels + depth.clamp(-1.0, 1.0) * _maxStep).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target != position.pixels) _scroll.jumpTo(target);
  }

  void _end() {
    _autoScroll?.cancel();
    _autoScroll = null;
    if (_last != null) widget.callbacks?.onEnd();
    _last = null;
    _finger = null;
  }

  @override
  void dispose() {
    _autoScroll?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.builder(context, _scroll);
    if (widget.callbacks == null) return list;
    final swipe = widget.swipe;
    return GestureDetector(
      // El tramo empieza donde se tocó, no donde se notó el deslizamiento.
      dragStartBehavior: DragStartBehavior.down,
      onLongPressStart: (d) => _start(d.localPosition),
      onLongPressMoveUpdate: (d) => _move(d.localPosition),
      onLongPressEnd: (_) => _end(),
      // Gana el arrastre de lado si el dedo se movió más de lado que hacia
      // arriba o abajo; si no, gana el scroll de la lista.
      onHorizontalDragStart: swipe
          ? (d) => _start(d.localPosition, strong: false)
          : null,
      onHorizontalDragUpdate: swipe ? (d) => _move(d.localPosition) : null,
      onHorizontalDragEnd: swipe ? (_) => _end() : null,
      onHorizontalDragCancel: swipe ? _end : null,
      child: list,
    );
  }
}

/// Marca el elemento [index] para [DragSelectArea]. No cambia cómo se ve.
class DragSelectItem extends StatelessWidget {
  const DragSelectItem({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) => MetaData(
    metaData: _ItemIndex(index),
    behavior: HitTestBehavior.translucent,
    child: child,
  );
}

class _ItemIndex {
  const _ItemIndex(this.index);

  final int index;
}
