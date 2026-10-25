import 'package:flutter/material.dart';

import '../../../../core/files/file_entry.dart';
import '../../../../core/files/file_format.dart';
import '../../../../core/files/file_kind.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/file_kind_icon.dart';
import '../../../../core/widgets/file_thumbnail.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/browser_controller.dart';

/// Contenido de una carpeta en la vista elegida. Todas son listas
/// virtualizadas: solo se dibujan las filas visibles.
class EntryViews extends StatelessWidget {
  const EntryViews({
    super.key,
    required this.entries,
    required this.mode,
    required this.onTap,
    required this.onLongPress,
    required this.sortField,
    required this.ascending,
    required this.onSortColumn,
    this.selected = const {},
    this.detailOf,
  });

  /// Lo que va después del tamaño en Lista; sin esto, la fecha. Los
  /// archivos de un tipo en Espacio muestran dónde está cada uno.
  final String Function(FileEntry)? detailOf;

  final List<FileEntry> entries;
  final BrowserViewMode mode;
  final ValueChanged<FileEntry> onTap;
  final ValueChanged<FileEntry> onLongPress;

  /// Orden actual, para marcar la columna en Detalles.
  final SortField sortField;
  final bool ascending;
  final ValueChanged<SortField> onSortColumn;

  /// Rutas seleccionadas: se marcan con fondo y una palomita.
  final Set<String> selected;

  Widget _select(FileEntry entry, Widget child) {
    final isSelected = selected.contains(entry.path);
    return _Selected(
      value: isSelected,
      child: Builder(
        builder: (context) => DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.primary.withValues(alpha: 0.12)
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.fromLTRB(8, 0, 8, 16);
    return switch (mode) {
      BrowserViewMode.list => ListView.builder(
        padding: padding,
        itemCount: entries.length,
        itemBuilder: (context, i) => _select(
          entries[i],
          _ListRow(
            entry: entries[i],
            detail: detailOf?.call(entries[i]),
            onTap: onTap,
            onLongPress: onLongPress,
          ),
        ),
      ),
      BrowserViewMode.details => Column(
        children: [
          _DetailsHeader(
            sortField: sortField,
            ascending: ascending,
            onSort: onSortColumn,
          ),
          Expanded(
            child: ListView.builder(
              padding: padding,
              itemExtent: 48,
              itemCount: entries.length,
              itemBuilder: (context, i) => _select(
                entries[i],
                _DetailsRow(
                  entry: entries[i],
                  onTap: onTap,
                  onLongPress: onLongPress,
                ),
              ),
            ),
          ),
        ],
      ),
      BrowserViewMode.grid => GridView.builder(
        padding: padding,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 112,
          mainAxisExtent: 116,
        ),
        itemCount: entries.length,
        itemBuilder: (context, i) => _select(
          entries[i],
          _GridCell(entry: entries[i], onTap: onTap, onLongPress: onLongPress),
        ),
      ),
      BrowserViewMode.gallery => GridView.builder(
        padding: padding,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 128,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: entries.length,
        itemBuilder: (context, i) => _GalleryCell(
          entry: entries[i],
          selected: selected.contains(entries[i].path),
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    };
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
    required this.onLongPress,
    this.detail,
  });

  final FileEntry entry;
  final String? detail;
  final ValueChanged<FileEntry> onTap;
  final ValueChanged<FileEntry> onLongPress;

  @override
  Widget build(BuildContext context) {
    final sizeOrCount = _sizeOrCount(context, entry);
    final date = detail ?? _date(context, entry);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: _Leading(entry: entry),
      title: Text(
        entry.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.typography.body.copyWith(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        sizeOrCount.isEmpty ? date : '$sizeOrCount  ·  $date',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.typography.small.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
      onTap: () => onTap(entry),
      onLongPress: () => onLongPress(entry),
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
  });

  final SortField sortField;
  final bool ascending;
  final ValueChanged<SortField> onSort;

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
          SizedBox(
            width: _sizeColumnWidth,
            child: column(l10n.columnSize, SortField.size),
          ),
          SizedBox(
            width: _dateColumnWidth,
            child: column(l10n.columnModified, SortField.modified),
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
    required this.onLongPress,
  });

  final FileEntry entry;
  final ValueChanged<FileEntry> onTap;
  final ValueChanged<FileEntry> onLongPress;

  @override
  Widget build(BuildContext context) {
    final secondary = context.typography.small.copyWith(
      color: context.colors.textSecondary,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onTap(entry),
      onLongPress: () => onLongPress(entry),
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

class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.entry,
    required this.onTap,
    required this.onLongPress,
  });

  final FileEntry entry;
  final ValueChanged<FileEntry> onTap;
  final ValueChanged<FileEntry> onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onTap(entry),
      onLongPress: () => onLongPress(entry),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            _Leading(entry: entry, size: 56),
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

/// Galería: la miniatura ocupa toda la celda y el nombre no se repite encima.
/// Lo que no tiene miniatura (carpetas, documentos) muestra logo y nombre.
class _GalleryCell extends StatelessWidget {
  const _GalleryCell({
    required this.entry,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final FileEntry entry;
  final bool selected;
  final ValueChanged<FileEntry> onTap;
  final ValueChanged<FileEntry> onLongPress;

  static const _radius = 8.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(_radius),
      onTap: () => onTap(entry),
      onLongPress: () => onLongPress(entry),
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
            if (selected) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(color: colors.primary, width: 2),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: colors.textInverse,
                  ),
                ),
              ),
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
