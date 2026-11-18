// Motor del tutorial guiado de la serie Herramientas Origami (OR-14).
// Mismo archivo en todas las apps; solo cambia el import del tema.
// Diseño: Origami-Base/diseno/tutorial.md.

import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';

/// Un paso del recorrido: resalta [target] (si está en pantalla) y explica.
/// Sin [target], la burbuja va al centro.
class TourStep {
  const TourStep({this.target, required this.title, required this.body});

  final GlobalKey? target;
  final String title;
  final String body;
}

/// Un recorrido: una función de la app, corto y que se puede repetir.
class TourDef {
  const TourDef({required this.id, required this.title, required this.steps});

  final String id;
  final String title;
  final List<TourStep> steps;
}

/// Textos de los botones, desde los `.arb` de la app.
class TourLabels {
  const TourLabels({
    required this.skip,
    required this.next,
    required this.done,
    required this.stepCount,
  });

  final String skip;
  final String next;
  final String done;
  final String Function(int current, int total) stepCount;
}

/// Dónde guarda la app qué recorridos ya se hicieron.
abstract class TourStore {
  Future<bool> isDone(String id);
  Future<void> setDone(String id, bool done);
}

class OrigamiTour {
  OrigamiTour._();

  static TourStore? store;

  /// Recorrido pedido desde Ajustes > Tutorial. La pantalla principal lo
  /// escucha, va a su pestaña y lo muestra.
  static final ValueNotifier<String?> requested = ValueNotifier(null);

  static bool _showing = false;

  /// Lo muestra solo si no se ha hecho. Para la primera visita a una pantalla.
  static Future<void> maybeShow(
    BuildContext context,
    TourDef tour,
    TourLabels labels,
  ) async {
    final s = store;
    if (s == null || _showing || await s.isDone(tour.id)) return;
    if (!context.mounted) return;
    await show(context, tour, labels);
  }

  /// Pasos cuyo elemento está en pantalla (o que no tienen elemento).
  static List<TourStep> _visibleSteps(TourDef tour) => tour.steps
      .where((s) => s.target == null || _rectOf(s.target!) != null)
      .toList();

  static Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    if (box.size.isEmpty) return null;
    final origin = box.localToGlobal(Offset.zero);
    return origin & box.size;
  }

  /// Espera a que la pantalla termine de cargar: revisa cada 250 ms (hasta
  /// unos 4 s) hasta que los elementos a resaltar estén y dejen de cambiar.
  static Future<List<TourStep>> _waitForTargets(
    BuildContext context,
    TourDef tour,
  ) async {
    final targeted = tour.steps.where((s) => s.target != null).length;
    var steps = _visibleSteps(tour);
    if (targeted == 0) return steps;
    var last = -1;
    var stable = 0;
    for (var i = 0; i < 16; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!context.mounted) return const [];
      steps = _visibleSteps(tour);
      final found = steps.where((s) => s.target != null).length;
      if (found == targeted) break;
      if (found > 0 && found == last) {
        if (++stable >= 3) break;
      } else {
        stable = 0;
        last = found;
      }
    }
    return steps;
  }

  /// Lo muestra siempre. Al terminar o saltar queda marcado como hecho. Si
  /// la pantalla no tiene todavía ningún elemento que resaltar, no se muestra
  /// ni se marca, para que salga la siguiente vez.
  static Future<void> show(
    BuildContext context,
    TourDef tour,
    TourLabels labels,
  ) async {
    if (_showing) return;
    _showing = true;
    try {
      await WidgetsBinding.instance.endOfFrame;
      if (!context.mounted) return;
      final steps = await _waitForTargets(context, tour);
      if (!context.mounted || steps.isEmpty) return;
      final hasTargets = tour.steps.any((s) => s.target != null);
      if (hasTargets && steps.every((s) => s.target == null)) return;
      // Otra pantalla encima (un resumen que se abrió solo, un diálogo): los
      // elementos siguen existiendo debajo y el recorrido los marcaría sobre
      // ella. No se muestra ni se marca; sale la siguiente vez.
      if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
      await Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder<void>(
          opaque: false,
          barrierDismissible: false,
          transitionDuration:
              MediaQuery.of(context).disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
          reverseTransitionDuration:
              MediaQuery.of(context).disableAnimations
                  ? Duration.zero
                  : const Duration(milliseconds: 160),
          pageBuilder: (_, __, ___) => _TourView(steps: steps, labels: labels),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          ),
        ),
      );
      await store?.setDone(tour.id, true);
    } finally {
      _showing = false;
    }
  }
}

class _TourView extends StatefulWidget {
  const _TourView({required this.steps, required this.labels});

  final List<TourStep> steps;
  final TourLabels labels;

  @override
  State<_TourView> createState() => _TourViewState();
}

class _TourViewState extends State<_TourView> {
  // Solo los pasos cuyo elemento estaba en pantalla al empezar.
  List<TourStep> get _steps => widget.steps;
  int _index = 0;

  /// Rectángulo del elemento del paso actual, en coordenadas de esta vista.
  Rect? _target;

  /// Ya se midió el paso actual (antes no se dibuja nada, para que no
  /// brinque la burbuja del centro al elemento).
  bool _measured = false;

  /// El elemento medido relativo a esta vista, no a la pantalla: si la app
  /// está dentro de un margen (la muesca de la cámara en horizontal) o la
  /// ruta no empieza en la esquina, el hueco cae justo sobre el elemento.
  /// Antes se usaba la posición en pantalla y el hueco salía corrido a la
  /// derecha o a la izquierda en teléfonos con muesca.
  Rect? _measure() {
    final key = _steps[_index].target;
    if (key == null) return null;
    final me = context.findRenderObject();
    final box = key.currentContext?.findRenderObject();
    if (me is! RenderBox || !me.attached || !me.hasSize) return null;
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    if (box.size.isEmpty) return null;
    final origin = box.localToGlobal(Offset.zero, ancestor: me);
    return origin & box.size;
  }

  /// Mide después del layout del cuadro, cuando las posiciones ya son las
  /// nuevas (al girar, al ocultarse las barras del sistema o al cambiar de
  /// paso). Medir durante el build daba las posiciones del cuadro anterior.
  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final rect = _measure();
      if (!_measured || rect != _target) {
        setState(() {
          _target = rect;
          _measured = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cambió el tamaño, la orientación o los márgenes de la pantalla.
    _scheduleMeasure();
  }

  /// Rectángulos que tocan la orilla (la barra de secciones de abajo): el
  /// resaltado se queda dentro de la pantalla y fuera de las barras del
  /// sistema, con sus esquinas a la vista. Antes salía de la pantalla y
  /// abarcaba la zona de gestos debajo de la barra, que no es parte de ella.
  static Rect _fitToScreen(Rect hole, Size size, EdgeInsets padding) {
    const margin = 4.0;
    final area = Rect.fromLTRB(
      margin,
      padding.top + margin,
      size.width - margin,
      size.height - padding.bottom - margin,
    );
    final fitted = hole.intersect(area);
    return fitted.width > 0 && fitted.height > 0 ? fitted : hole;
  }

  void _next() {
    if (_index < _steps.length - 1) {
      setState(() {
        _index++;
        _measured = false;
      });
      _scheduleMeasure();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) => _buildStep(context, constraints),
    );
  }

  Widget _buildStep(BuildContext context, BoxConstraints constraints) {
    final step = _steps[_index];
    if (step.target != null && !_measured) {
      // Primer cuadro del paso: solo el fondo, sin hueco ni burbuja.
      return Material(
        type: MaterialType.transparency,
        child: ColoredBox(color: Colors.black.withValues(alpha: 0.62)),
      );
    }
    final target = step.target == null ? null : _target;
    // El resaltado se ajusta al control: círculo para botones de ícono
    // (chicos y casi cuadrados), rectángulo de esquinas suaves para lo demás.
    final circle = target != null &&
        target.longestSide <= 96 &&
        target.shortestSide / target.longestSide >= 0.7;
    // El tamaño de esta vista, no el de la pantalla: pueden ser distintos
    // si la app vive dentro de un margen.
    final size = constraints.biggest;
    final padding = MediaQuery.of(context).padding;
    final hole = target == null
        ? null
        : circle
            ? Rect.fromCircle(
                center: target.center,
                radius: target.longestSide / 2 + 6,
              )
            : _fitToScreen(target.inflate(6), size, padding);
    final reduce = MediaQuery.of(context).disableAnimations;
    final last = _index == _steps.length - 1;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Fondo oscuro con el hueco; tocar el hueco avanza.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                if (hole != null && hole.contains(d.localPosition)) _next();
              },
              child: TweenAnimationBuilder<Rect?>(
                tween: RectTween(end: hole ?? Rect.zero),
                duration:
                    reduce ? Duration.zero : const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                builder: (_, rect, __) => CustomPaint(
                  painter: _ScrimPainter(
                    hole: hole == null ? null : rect,
                    circle: circle,
                    color: Colors.black.withValues(alpha: 0.62),
                  ),
                ),
              ),
            ),
          ),
          _Bubble(
            key: ValueKey(_index),
            hole: hole,
            screen: size,
            padding: padding,
            title: step.title,
            body: step.body,
            count: widget.labels.stepCount(_index + 1, _steps.length),
            skip: last ? null : widget.labels.skip,
            next: last ? widget.labels.done : widget.labels.next,
            onSkip: () => Navigator.of(context).pop(),
            onNext: _next,
            reduce: reduce,
          ),
        ],
      ),
    );
  }
}

class _ScrimPainter extends CustomPainter {
  _ScrimPainter({
    required this.hole,
    required this.circle,
    required this.color,
  });

  final Rect? hole;
  final bool circle;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addRect(Offset.zero & size);
    if (hole != null && !hole!.isEmpty) {
      if (circle) {
        path.addOval(hole!);
      } else {
        path.addRRect(RRect.fromRectAndRadius(hole!, const Radius.circular(12)));
      }
      path.fillType = PathFillType.evenOdd;
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ScrimPainter old) =>
      old.hole != hole || old.circle != circle || old.color != color;
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    super.key,
    required this.hole,
    required this.screen,
    required this.padding,
    required this.title,
    required this.body,
    required this.count,
    required this.skip,
    required this.next,
    required this.onSkip,
    required this.onNext,
    required this.reduce,
  });

  final Rect? hole;
  final Size screen;
  final EdgeInsets padding;
  final String title;
  final String body;
  final String count;
  final String? skip;
  final String next;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final bool reduce;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const side = 16.0;
    const gap = 12.0;
    final width = (screen.width - side * 2).clamp(0.0, 420.0);
    final left = (screen.width - width) / 2;

    // Abajo del elemento si cabe; si no, arriba; sin elemento, al centro.
    double? top;
    double? bottom;
    if (hole == null) {
      top = null;
    } else if (hole!.center.dy < screen.height / 2) {
      top = hole!.bottom + gap;
    } else {
      bottom = screen.height - hole!.top + gap;
    }

    final card = Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      decoration: BoxDecoration(
        color: colors.bgElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.typography.cardTitle
                .copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: context.typography.body
                .copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                count,
                maxLines: 1,
                softWrap: false,
                style: context.typography.small.copyWith(
                  color: colors.textSecondary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              if (skip != null)
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    skip!,
                    maxLines: 1,
                    softWrap: false,
                    style: context.typography.body
                        .copyWith(color: colors.textSecondary),
                  ),
                ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.textInverse,
                ),
                child: Text(next, maxLines: 1, softWrap: false),
              ),
            ],
          ),
        ],
      ),
    );

    final animated = TweenAnimationBuilder<double>(
      tween: Tween(begin: reduce ? 1 : 0.95, end: 1),
      duration: reduce ? Duration.zero : const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(
        opacity: ((v - 0.95) / 0.05).clamp(0.0, 1.0),
        child: Transform.scale(scale: v, child: child),
      ),
      child: card,
    );

    if (top == null && bottom == null) {
      return Center(child: animated);
    }
    return Positioned(
      left: left,
      top: top?.clamp(padding.top + side, screen.height - 200),
      bottom: bottom?.clamp(padding.bottom + side, screen.height - 200),
      child: animated,
    );
  }
}

/// Fila de la pantalla Tutorial.
class TourEntry {
  const TourEntry({
    required this.id,
    required this.title,
    required this.icon,
    this.onNextVisit = false,
  });

  final String id;
  final String title;
  final IconData icon;

  /// Recorrido de una pantalla que no se puede abrir sola (por ejemplo, un
  /// editor que necesita un archivo): se reinicia y sale la próxima vez que
  /// se entre a esa pantalla.
  final bool onNextVisit;
}

/// Ajustes > Tutorial: lista de recorridos, marca los hechos y repite el que
/// se toque (regresa a la pantalla principal, que escucha [OrigamiTour.requested]).
class OrigamiTutorialScreen extends StatefulWidget {
  const OrigamiTutorialScreen({
    super.key,
    required this.appBar,
    required this.entries,
    required this.doneLabel,
  });

  final PreferredSizeWidget appBar;
  final List<TourEntry> entries;
  final String doneLabel;

  @override
  State<OrigamiTutorialScreen> createState() => _OrigamiTutorialScreenState();
}

class _OrigamiTutorialScreenState extends State<OrigamiTutorialScreen> {
  Set<String>? _done;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final done = <String>{};
    for (final e in widget.entries) {
      if (await OrigamiTour.store?.isDone(e.id) ?? false) done.add(e.id);
    }
    if (mounted) setState(() => _done = done);
  }

  Future<void> _open(TourEntry entry) async {
    if (entry.onNextVisit) {
      await OrigamiTour.store?.setDone(entry.id, false);
    } else {
      OrigamiTour.requested.value = entry.id;
    }
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final done = _done;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: widget.appBar,
      body: done == null
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 32,
              ),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colors.bgElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.borderSubtle),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < widget.entries.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            indent: 52,
                            color: colors.borderSubtle,
                          ),
                        _TutorialRow(
                          entry: widget.entries[i],
                          done: done.contains(widget.entries[i].id),
                          doneLabel: widget.doneLabel,
                          onTap: () => _open(widget.entries[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _TutorialRow extends StatelessWidget {
  const _TutorialRow({
    required this.entry,
    required this.done,
    required this.doneLabel,
    required this.onTap,
  });

  final TourEntry entry;
  final bool done;
  final String doneLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            Icon(entry.icon, color: colors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                entry.title,
                style: context.typography.body
                    .copyWith(color: colors.textPrimary),
              ),
            ),
            if (done)
              Text(
                doneLabel,
                style: context.typography.small
                    .copyWith(color: colors.textSecondary),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
