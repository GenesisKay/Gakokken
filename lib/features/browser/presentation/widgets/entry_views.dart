import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/files/date_groups.dart';
import '../../../../core/files/file_entry.dart';
import '../../../../core/files/file_format.dart';
import '../../../../core/files/file_kind.dart';
import '../../../../core/services/haptics_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/file_kind_icon.dart';
import '../../../../core/widgets/file_thumbnail.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/browser_controller.dart';
import 'drag_select.dart';

export 'drag_select.dart' show DragSelectCallbacks;

/// Contenido de una carpeta en la vista elegida. Todas son listas
/// virtualizadas: solo se dibujan las filas visibles. Agrupadas por fecha,
/// cada grupo lleva un encabezado que se queda arriba mientras se recorre.
class EntryViews extends StatelessWidget {
  const EntryViews({
    super.key,
    required this.entries,
    required this.mode,
    required this.onTap,
    required this.sortField,
    required this.ascending,
    required this.onSortColumn,
    this.onLongPress,
    this.dragSelect,
    this.selected = const {},
    this.detailOf,
    this.detailEndOf,
    this.groupByDate = false,
    this.onSelectGroup,
    this.showSize = true,
    this.dateLabel,
    this.faded,
    this.blink,
    this.onViewMode,
  });

  /// Con esto, pellizcar o Ctrl + rueda cambian de vista (ver [zoomOrder]).
  final ValueChanged<BrowserViewMode>? onViewMode;

  /// Lo que va después del tamaño en Lista; sin esto, la fecha. Los
  /// archivos de un tipo en Espacio muestran dónde está cada uno.
  final String Function(FileEntry)? detailOf;

  /// Lo que va al final del detalle en Lista y siempre se ve completo: si el
  /// detalle es largo, se recorta el detalle y no esto. En Papelera, los
  /// días que quedan cuando la ruta de origen es muy larga.
  final String Function(FileEntry)? detailEndOf;

  final List<FileEntry> entries;
  final BrowserViewMode mode;
  final ValueChanged<FileEntry> onTap;

  /// Mantener presionado un elemento. Con [dragSelect] no se usa: el gesto
  /// es de toda la lista.
  final ValueChanged<FileEntry>? onLongPress;

  /// Mantener presionado y deslizar selecciona un tramo.
  final DragSelectCallbacks? dragSelect;

  /// Orden actual, para marcar la columna en Detalles.
  final SortField sortField;
  final bool ascending;
  final ValueChanged<SortField> onSortColumn;

  /// Rutas seleccionadas: se marcan con fondo y una palomita.
  final Set<String> selected;

  /// Encabezados por fecha ([FileEntry.modified]). [entries] ya viene
  /// ordenada por grupo (ver `sortEntries`).
  final bool groupByDate;

  /// Tocar el encabezado de un grupo: las posiciones [start, end).
  final void Function(int start, int end)? onSelectGroup;

  /// Favoritos y la Papelera no saben el tamaño: sin columna ni texto.
  final bool showSize;

  /// Nombre de la columna de fecha en Detalles; sin esto, Modificado.
  final String? dateLabel;

  /// Elementos que se ven apagados (un favorito que ya no existe).
  final bool Function(FileEntry)? faded;

  /// Ruta que parpadea una vez (la carpeta recién creada).
  final String? blink;

  Widget _blinkIf(int index, Widget child) =>
      entries[index].path == blink ? _Blink(child: child) : child;

  Widget _select(int index, Widget child, {bool fade = true}) {
    final isSelected = selected.contains(entries[index].path);
    return DragSelectItem(
      index: index,
      child: _Selected(
        value: isSelected,
        child: Builder(
          builder: (context) => _blinkIf(
            index,
            DecoratedBox(
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.primary.withValues(alpha: 0.12)
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: fade ? _fade(index, child) : child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _fade(int index, Widget child) => faded?.call(entries[index]) ?? false
      ? Opacity(opacity: 0.45, child: child)
      : child;

  /// Los elementos [start, end) en la vista elegida.
  Widget _items(
    int start,
    int end,
    ValueChanged<FileEntry> onTap,
    ValueChanged<FileEntry>? longPress,
  ) {
    final count = end - start;
    return switch (mode) {
      BrowserViewMode.list => SliverList.builder(
        itemCount: count,
        itemBuilder: (context, j) => _select(
          start + j,
          _ListRow(
            entry: entries[start + j],
            detail: detailOf?.call(entries[start + j]),
            detailEnd: detailEndOf?.call(entries[start + j]),
            showSize: showSize,
            faded: faded?.call(entries[start + j]) ?? false,
            onTap: onTap,
            onLongPress: longPress,
          ),
          fade: false,
        ),
      ),
      BrowserViewMode.details => SliverFixedExtentList.builder(
        itemExtent: 48,
        itemCount: count,
        itemBuilder: (context, j) => _select(
          start + j,
          _DetailsRow(
            entry: entries[start + j],
            showSize: showSize,
            onTap: onTap,
            onLongPress: longPress,
          ),
        ),
      ),
      BrowserViewMode.grid => SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 112,
          mainAxisExtent: 116,
        ),
        itemCount: count,
        itemBuilder: (context, j) => _select(
          start + j,
          _GridCell(
            entry: entries[start + j],
            selected: selected.contains(entries[start + j].path),
            onTap: onTap,
            onLongPress: longPress,
          ),
        ),
      ),
      BrowserViewMode.gallery => SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 128,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: count,
        itemBuilder: (context, j) => DragSelectItem(
          index: start + j,
          child: _blinkIf(
            start + j,
            _fade(
              start + j,
              _GalleryCell(
                entry: entries[start + j],
                selected: selected.contains(entries[start + j].path),
                onTap: onTap,
                onLongPress: longPress,
              ),
            ),
          ),
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final onSelectGroup = this.onSelectGroup;
    final longPress = dragSelect == null ? onLongPress : null;
    // Con selección, tocar marca o desmarca: vibra poquito.
    final tap = selected.isEmpty
        ? onTap
        : (FileEntry e) {
            HapticsService().tick();
            onTap(e);
          };
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    Widget padded(Widget sliver) => SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      sliver: sliver,
    );

    final slivers = <Widget>[
      if (!groupByDate)
        padded(_items(0, entries.length, tap, longPress))
      else
        for (final run in dateRuns([
          for (final e in entries) e.modified,
        ], DateTime.now()))
          SliverMainAxisGroup(
            slivers: [
              PinnedHeaderSliver(
                child: _GroupHeader(
                  label: run.group.label(l10n, locale),
                  // Mientras hay selección, el círculo dice si el grupo
                  // está completo.
                  check: selected.isEmpty || onSelectGroup == null
                      ? null
                      : [
                          for (var i = run.start; i < run.end; i++)
                            entries[i].path,
                        ].every(selected.contains),
                  onTap: onSelectGroup == null
                      ? null
                      : () {
                          HapticsService().tick();
                          onSelectGroup(run.start, run.end);
                        },
                ),
              ),
              padded(_items(run.start, run.end, tap, longPress)),
            ],
          ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
    ];

    final onViewMode = this.onViewMode;
    final list = DragSelectArea(
      callbacks: dragSelect,
      swipe: selected.isNotEmpty,
      builder: (context, controller) => CustomScrollView(
        controller: controller,
        // Con Ctrl la rueda cambia de vista y no desplaza.
        physics: onViewMode == null ? null : const _NoScrollWithCtrl(),
        slivers: slivers,
      ),
    );

    final view = mode != BrowserViewMode.details
        ? list
        : Column(
            children: [
              _DetailsHeader(
                sortField: sortField,
                ascending: ascending,
                onSort: onSortColumn,
                showSize: showSize,
                dateLabel: dateLabel,
              ),
              Expanded(child: list),
            ],
          );
    if (onViewMode == null) return view;
    return _ViewZoom(mode: mode, onChanged: onViewMode, child: view);
  }
}

/// Las vistas de la más densa a la más visual: acercar avanza, alejar
/// regresa, como Ctrl + rueda en el Explorador de Windows.
const zoomOrder = [
  BrowserViewMode.details,
  BrowserViewMode.list,
  BrowserViewMode.grid,
  BrowserViewMode.gallery,
];

/// La vista que sigue al acercar ([zoomIn]) o alejar desde [mode]; null si
/// ya está en la punta.
BrowserViewMode? zoomStep(BrowserViewMode mode, {required bool zoomIn}) {
  final next = zoomOrder.indexOf(mode) + (zoomIn ? 1 : -1);
  return next < 0 || next >= zoomOrder.length ? null : zoomOrder[next];
}

/// Pellizcar con dos dedos o Ctrl + rueda cambia de vista (pedido el
/// 2026-11-13). Un paso por gesto, con una vibración chiquita. Solo
/// escucha los dedos, sin competir con el desplazamiento ni con la
/// selección al deslizar, que usan uno.
class _ViewZoom extends StatefulWidget {
  const _ViewZoom({
    required this.mode,
    required this.onChanged,
    required this.child,
  });

  final BrowserViewMode mode;
  final ValueChanged<BrowserViewMode> onChanged;
  final Widget child;

  @override
  State<_ViewZoom> createState() => _ViewZoomState();
}

class _ViewZoomState extends State<_ViewZoom> {
  /// Cuánto hay que abrir o cerrar los dedos para cambiar de vista.
  static const _pinchIn = 1.25;
  static const _pinchOut = 0.8;

  /// Pausa entre pasos de la rueda, para que un panel táctil no se brinque
  /// todas las vistas de un jalón.
  static const _wheelPause = Duration(milliseconds: 300);

  final _pointers = <int, Offset>{};
  double? _startDistance;
  bool _stepped = false;
  DateTime _lastWheel = DateTime(0);

  double get _distance {
    final points = _pointers.values.take(2).toList();
    return (points[0] - points[1]).distance;
  }

  void _step({required bool zoomIn}) {
    final next = zoomStep(widget.mode, zoomIn: zoomIn);
    if (next == null) return;
    HapticsService().tick();
    widget.onChanged(next);
  }

  void _down(PointerDownEvent event) {
    _pointers[event.pointer] = event.position;
    if (_pointers.length == 2) {
      _startDistance = _distance;
      _stepped = false;
    }
  }

  void _move(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers[event.pointer] = event.position;
    final start = _startDistance;
    if (_pointers.length != 2 || start == null || start == 0 || _stepped) {
      return;
    }
    final ratio = _distance / start;
    if (ratio >= _pinchIn || ratio <= _pinchOut) {
      _stepped = true;
      _step(zoomIn: ratio > 1);
    }
  }

  void _up(PointerEvent event) {
    _pointers.remove(event.pointer);
    if (_pointers.length < 2) _startDistance = null;
  }

  void _signal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent ||
        !HardwareKeyboard.instance.isControlPressed ||
        event.scrollDelta.dy == 0) {
      return;
    }
    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      final now = DateTime.now();
      if (now.difference(_lastWheel) < _wheelPause) return;
      _lastWheel = now;
      // Rueda hacia arriba acerca, como en Windows.
      _step(zoomIn: (event as PointerScrollEvent).scrollDelta.dy < 0);
    });
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: _down,
    onPointerMove: _move,
    onPointerUp: _up,
    onPointerCancel: _up,
    onPointerSignal: _signal,
    child: widget.child,
  );
}

/// No desplaza con la rueda mientras Ctrl está presionado, para que la
/// rueda cambie de vista.
class _NoScrollWithCtrl extends ScrollPhysics {
  const _NoScrollWithCtrl({super.parent});

  @override
  _NoScrollWithCtrl applyTo(ScrollPhysics? ancestor) =>
      _NoScrollWithCtrl(parent: buildParent(ancestor));

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) =>
      !HardwareKeyboard.instance.isControlPressed &&
      super.shouldAcceptUserOffset(position);
}

/// Encabezado de un grupo por fecha. Tocarlo marca o desmarca el grupo.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label, this.check, this.onTap});

  final String label;

  /// null: sin círculo (no hay selección).
  final bool? check;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final check = this.check;
    return Material(
      color: colors.bgPrimary,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.body.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (check != null)
                Icon(
                  check
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 22,
                  color: check ? colors.primary : colors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tamaño de un archivo o cuántos elementos tiene una carpeta.
String _sizeOrCount(BuildContext context, FileEntry entry) {
  if (!entry.isDir) {
    return formatBytes(entry.size, Localizations.localeOf(context).toString());
  }
  final count = entry.childCount;
  return count == null
      ? ''
      : AppLocalizations.of(context)!.browserItemCount(count);
}

/// En Detalles la columna es Tamaño: las carpetas muestran lo que pesan
/// cuando el índice ya lo sabe (es por lo que se ordenan) y si no, cuántos
/// elementos tienen.
String _detailsSize(BuildContext context, FileEntry entry) =>
    entry.isDir && entry.size > 0
    ? formatBytes(entry.size, Localizations.localeOf(context).toString())
    : _sizeOrCount(context, entry);

/// Miniatura o logo; si el elemento está seleccionado, una marca en su lugar.
class _Leading extends StatelessWidget {
  const _Leading({required this.entry, this.size = 40});

  final FileEntry entry;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (!_Selected.of(context)) {
      return FileThumbnail(
        path: entry.path,
        name: entry.name,
        isDir: entry.isDir,
        size: size,
      );
    }
    final colors = context.colors;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(size * 0.22),
        ),
        child: Icon(
          Icons.check_rounded,
          color: colors.textInverse,
          size: size * 0.6,
        ),
      ),
    );
  }
}

/// Círculo con palomita en la esquina de arriba a la izquierda de una celda
/// de Cuadrícula o Galería seleccionada; las no seleccionadas no llevan nada
/// (pedido el 2026-10-30).
class _SelectedMark extends StatelessWidget {
  const _SelectedMark();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Positioned(
      top: 6,
      left: 6,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
          // Borde claro para que se vea sobre cualquier foto.
          border: Border.all(color: colors.textInverse, width: 2),
        ),
        child: Icon(Icons.check_rounded, size: 16, color: colors.textInverse),
      ),
    );
  }
}

/// Si el elemento de debajo está seleccionado.
class _Selected extends InheritedWidget {
  const _Selected({required this.value, required super.child});

  final bool value;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Selected>()?.value ?? false;

  @override
  bool updateShouldNotify(_Selected old) => old.value != value;
}

String _date(BuildContext context, FileEntry entry) =>
    formatDate(entry.modified, Localizations.localeOf(context).toString());

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.entry,
    required this.onTap,
    this.onLongPress,
    this.detail,
    this.detailEnd,
    this.showSize = true,
    this.faded = false,
  });

  final FileEntry entry;
  final String? detail;
  final String? detailEnd;
  final bool showSize;

  /// Ya no existe: logo apagado, nombre gris y el detalle como aviso.
  final bool faded;
  final ValueChanged<FileEntry> onTap;
  final ValueChanged<FileEntry>? onLongPress;

  @override
  Widget build(BuildContext context) {
    final sizeOrCount = showSize ? _sizeOrCount(context, entry) : '';
    final date = detail ?? _date(context, entry);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Opacity(
        opacity: faded ? 0.4 : 1,
        child: _Leading(entry: entry),
      ),
      title: Text(
        entry.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.typography.body.copyWith(
          color: faded
              ? context.colors.textSecondary
              : context.colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Builder(
        builder: (context) {
          final style = context.typography.small.copyWith(
            color: faded
                ? context.colors.stateError
                : context.colors.textSecondary,
          );
          final main = Text(
            sizeOrCount.isEmpty ? date : '$sizeOrCount  ·  $date',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          );
          if (detailEnd == null) return main;
          return Row(
            children: [
              Flexible(child: main),
              Text('  ·  $detailEnd', maxLines: 1, style: style),
            ],
          );
        },
      ),
      onTap: () => onTap(entry),
      onLongPress: onLongPress == null ? null : () => onLongPress!(entry),
    );
  }
}

const _sizeColumnWidth = 84.0;
const _dateColumnWidth = 96.0;

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({
    required this.sortField,
    required this.ascending,
    required this.onSort,
    required this.showSize,
    this.dateLabel,
  });

  final SortField sortField;
  final bool ascending;
  final ValueChanged<SortField> onSort;
  final bool showSize;
  final String? dateLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    // Tocar un encabezado ordena por esa columna; la flecha marca la actual.
    Widget column(String label, SortField field, {bool end = true}) {
      final active = field == sortField;
      final style = context.typography.small.copyWith(
        color: active ? colors.textPrimary : colors.textSecondary,
        fontWeight: FontWeight.w600,
      );
      return InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => onSort(field),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: end
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: style,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (active)
                Icon(
                  ascending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: colors.textPrimary,
                ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(child: column(l10n.columnName, SortField.name, end: false)),
          if (showSize)
            SizedBox(
              width: _sizeColumnWidth,
              child: column(l10n.columnSize, SortField.size),
            ),
          SizedBox(
            width: _dateColumnWidth,
            child: column(dateLabel ?? l10n.columnModified, SortField.modified),
          ),
        ],
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({
    required this.entry,
    required this.onTap,
    this.onLongPress,
    this.showSize = true,
  });

  final FileEntry entry;
  final bool showSize;
  final ValueChanged<FileEntry> onTap;
  final ValueChanged<FileEntry>? onLongPress;

  @override
  Widget build(BuildContext context) {
    final secondary = context.typography.small.copyWith(
      color: context.colors.textSecondary,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onTap(entry),
      onLongPress: onLongPress == null ? null : () => onLongPress!(entry),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _Leading(entry: entry, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.body.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            if (showSize)
              SizedBox(
                width: _sizeColumnWidth,
                child: Text(
                  _detailsSize(context, entry),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: secondary,
                ),
              ),
            SizedBox(
              width: _dateColumnWidth,
              child: Text(
                _date(context, entry),
                maxLines: 1,
                textAlign: TextAlign.end,
                style: secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cuadrícula: la miniatura o el logo no cambia al seleccionar; la marca es
/// el fondo y el círculo de la esquina.
class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.entry,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  final FileEntry entry;
  final bool selected;
  final ValueChanged<FileEntry> onTap;
  final ValueChanged<FileEntry>? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onTap(entry),
      onLongPress: onLongPress == null ? null : () => onLongPress!(entry),
      // Ocupa toda la celda: si no, se encoge al ancho del nombre y queda
      // pegada a la izquierda, y las columnas no se alinean.
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                FileThumbnail(
                  path: entry.path,
                  name: entry.name,
                  isDir: entry.isDir,
                  size: 56,
                ),
                const SizedBox(height: 8),
                Text(
                  entry.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.typography.small.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (selected) const _SelectedMark(),
        ],
      ),
    );
  }
}

/// Galería: la miniatura ocupa toda la celda y el nombre no se repite encima.
/// Lo que no tiene miniatura (carpetas, documentos) muestra logo y nombre.
class _GalleryCell extends StatelessWidget {
  const _GalleryCell({
    required this.entry,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  final FileEntry entry;
  final bool selected;
  final ValueChanged<FileEntry> onTap;
  final ValueChanged<FileEntry>? onLongPress;

  static const _radius = 8.0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(_radius),
      onTap: () => onTap(entry),
      onLongPress: onLongPress == null ? null : () => onLongPress!(entry),
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          fit: StackFit.expand,
          children: [
            FileThumbnail(
              path: entry.path,
              name: entry.name,
              isDir: entry.isDir,
              size: constraints.maxWidth,
              radius: _radius,
              fallback: _GalleryFallback(entry: entry),
            ),
            // Seleccionada: la miniatura un poco más oscura, para notarla
            // entre muchas fotos, y el círculo.
            if (selected) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(_radius),
                ),
              ),
              const _SelectedMark(),
            ],
          ],
        ),
      ),
    );
  }
}

class _GalleryFallback extends StatelessWidget {
  const _GalleryFallback({required this.entry});

  final FileEntry entry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.bgSecondary,
        borderRadius: BorderRadius.circular(_GalleryCell._radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FileKindIcon(
              kind: entry.kind,
              size: 40,
              extension: FileKind.extensionOf(entry.name),
            ),
            const SizedBox(height: 8),
            Text(
              entry.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.typography.small.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Parpadeo de un elemento recién creado (pedido el 2026-10-30): el color
/// principal se enciende y se apaga dos veces encima del elemento. Sin
/// animaciones en el teléfono no hace nada.
class _Blink extends StatefulWidget {
  const _Blink({required this.child});

  final Widget child;

  @override
  State<_Blink> createState() => _BlinkState();
}

class _BlinkState extends State<_Blink> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  static const _times = 2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context) && !_controller.isAnimating) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        // 0 → 1 → 0, [_times] veces; al terminar queda en 0.
        final glow = t == 0 || t == 1
            ? 0.0
            : (1 - cos(2 * pi * _times * t)) / 2;
        return DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3 * glow),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        );
      },
    );
  }
}
