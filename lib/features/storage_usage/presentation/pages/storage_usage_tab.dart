import 'package:gakoken/core/tutorial/gakoken_tours.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../../core/engine/rust_file_engine.dart';
import '../../../../core/files/file_entry.dart';
import '../../../../core/files/file_format.dart';
import '../../../../core/files/file_kind.dart';
import '../../../../core/files/file_labels.dart';
import '../../../../core/services/index_service.dart';
import '../../../../core/services/storage_volumes_service.dart';
import '../../../../core/storage/hive_bootstrap.dart';
import '../../../../core/theme/color_extensions.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/file_actions.dart';
import '../../../../core/widgets/file_kind_icon.dart';
import '../../../../core/widgets/file_thumbnail.dart';
import '../../../../core/widgets/gakoken_app_bar.dart';
import '../../../../core/widgets/volume_picker_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import 'kind_files_screen.dart';
import '../../../../src/rust/api/engine.dart' as rust;
import '../../../browser/presentation/widgets/folder_title.dart';
import '../controllers/usage_tab_controller.dart';

/// Pestaña Espacio (en la barra inferior por ahora; pedido el 2026-10-20):
/// espacio usado por una carpeta con sus subcarpetas, por tipo de archivo y
/// por lo que contiene. Lo indexado sale del índice; un USB se recorre en el
/// momento.
class StorageUsageTab extends StatefulWidget {
  const StorageUsageTab({
    super.key,
    required this.controller,
    required this.onOpenInExplore,
  });

  final UsageTabController controller;

  /// Abre una carpeta en Explorar.
  final ValueChanged<String> onOpenInExplore;

  @override
  State<StorageUsageTab> createState() => _StorageUsageTabState();
}

class _KindUsage {
  _KindUsage(this.kind);

  final FileKind kind;
  final extensions = <String>[];
  int bytes = 0;
  int files = 0;
}

/// Cómo se ordena la lista Por tipo (pedido el 2026-11-05). La barra sigue
/// del que más ocupa al que menos.
enum _KindSort { size, name, files }

class _StorageUsageTabState extends State<StorageUsageTab> {
  static const _maxChildren = 50;
  static const _sortKey = 'usageKindSort';
  static const _ascendingKey = 'usageKindSortAscending';

  final _index = IndexService();
  final _volumes = StorageVolumesService();
  rust.StorageUsage? _usage;
  bool _loading = false;
  String? _loadedPath;
  int _seenRevision = -1;
  _KindSort _kindSort = _KindSort.size;
  bool _kindAscending = false;

  UsageTabController get _tab => widget.controller;

  Box? get _settings => Hive.isBoxOpen(HiveBootstrap.settingsBox)
      ? Hive.box(HiveBootstrap.settingsBox)
      : null;

  /// Tocar el orden actual le da la vuelta; uno nuevo empieza en su sentido
  /// natural: nombre de la A a la Z, tamaño y archivos del mayor al menor.
  void _setKindSort(_KindSort sort) {
    setState(() {
      _kindAscending = sort == _kindSort
          ? !_kindAscending
          : sort == _KindSort.name;
      _kindSort = sort;
    });
    _settings
      ?..put(_sortKey, sort.name)
      ..put(_ascendingKey, _kindAscending);
  }

  List<_KindUsage> _sortedKinds(AppLocalizations l10n, List<_KindUsage> kinds) {
    int compare(_KindUsage a, _KindUsage b) => switch (_kindSort) {
      _KindSort.size => a.bytes.compareTo(b.bytes),
      _KindSort.files => a.files.compareTo(b.files),
      _KindSort.name => kindLabel(
        l10n,
        a.kind,
      ).toLowerCase().compareTo(kindLabel(l10n, b.kind).toLowerCase()),
    };
    return [...kinds]
      ..sort((a, b) => _kindAscending ? compare(a, b) : compare(b, a));
  }

  @override
  void initState() {
    super.initState();
    _index.addListener(_onIndex);
    _tab.addListener(_onPath);
    _volumes.addListener(_onVolumes);
    final box = _settings;
    if (box != null) {
      _kindSort = _KindSort.values.asNameMap()[box.get(_sortKey)] ?? _kindSort;
      _kindAscending = box.get(_ascendingKey) as bool? ?? _kindAscending;
    }
    _load();
  }

  @override
  void dispose() {
    _index.removeListener(_onIndex);
    _tab.removeListener(_onPath);
    _volumes.removeListener(_onVolumes);
    super.dispose();
  }

  // Al volver a la app (por ejemplo, de dar Acceso al uso) llegan el libre y
  // las apps al día.
  void _onVolumes() {
    if (mounted) setState(() {});
  }

  void _onPath() {
    if (_tab.path != _loadedPath) _load();
  }

  void _onIndex() {
    // Al terminar un indexado, o al copiar o borrar algo, los números cambian.
    if (!_index.indexing && _index.revision != _seenRevision) _load();
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    final path = _tab.path;
    _seenRevision = _index.revision;
    setState(() {
      _loadedPath = path;
      _loading = true;
      _usage = null;
    });
    final usage = await _index.usage(path);
    if (!mounted || path != _tab.path) return;
    setState(() {
      _usage = usage;
      _loading = false;
    });
  }

  /// Junta las extensiones por tipo, del que más ocupa al que menos.
  List<_KindUsage> _byKind(rust.StorageUsage usage) {
    final kinds = <FileKind, _KindUsage>{};
    for (final ext in usage.byExtension) {
      final kind = FileKind.fromName(
        ext.extension_.isEmpty ? 'x' : 'x.${ext.extension_}',
      );
      final slot = kinds.putIfAbsent(kind, () => _KindUsage(kind));
      slot.extensions.add(ext.extension_);
      slot.bytes += ext.bytes;
      slot.files += ext.files;
    }
    return kinds.values.where((k) => k.bytes > 0).toList()
      ..sort((a, b) => b.bytes.compareTo(a.bytes));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final usage = _usage;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: GakokenAppBar(
        // La barra de abajo ya dice Espacio: el título es la carpeta.
        titleWidget: FolderTitle(
          trail: _tab.trail,
          onOpen: _tab.show,
          actions: [
            FolderMenuAction(
              Icons.sd_storage_outlined,
              l10n.volumesTitle,
              () => showVolumePickerSheet(
                context,
                current: _tab.path,
                onSelected: (volume) => _tab.show(volume.path),
                // Recorrer todo `/` en el momento sería enorme (incluye /proc).
                withSystem: false,
              ),
            ),
          ],
        ),
        isRootScreen: true,
        actions: [
          IconButton(
            tooltip: l10n.usageOpenInExplore,
            icon: Icon(Icons.folder_open_rounded, color: colors.textPrimary),
            onPressed: () => widget.onOpenInExplore(_tab.path),
          ),
        ],
      ),
      body: usage == null ? _waiting(l10n) : _content(context, l10n, usage),
    );
  }

  Widget _waiting(AppLocalizations l10n) {
    final indexing = _index.indexing && _tab.volume.indexed;
    final count = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    ).format(_index.scanned);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loading || indexing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
            ],
            Text(
              indexing
                  ? l10n.indexingProgress(count)
                  : _loading
                  ? l10n.usageCalculating
                  : l10n.indexNotReady,
              textAlign: TextAlign.center,
              style: context.typography.body.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    AppLocalizations l10n,
    rust.StorageUsage usage,
  ) {
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final number = NumberFormat.decimalPattern(locale);
    final total = usage.totalBytes;
    final kinds = _byKind(usage);
    // En la raíz de una memoria la barra muestra también lo libre.
    final atRoot = p.equals(_tab.path, _tab.volume.path);
    final volume = atRoot && _tab.volume.totalBytes > 0 ? _tab.volume : null;
    final children = usage.children.take(_maxChildren).toList();

    Widget section(String text, {Widget? trailing}) => Padding(
      padding: EdgeInsets.fromLTRB(16, 24, trailing == null ? 16 : 4, 8),
      child: Row(
        children: [
          Expanded(child: Text(text, style: context.typography.sectionHeader)),
          ?trailing,
        ],
      ),
    );

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En la raíz de una memoria, lo usado de todo el teléfono
                // sobre el total, como en Ajustes de Android (pedido el
                // 2026-10-29); en una carpeta, lo que pesa.
                Text.rich(
                  TextSpan(
                    text: formatBytes(
                      volume == null
                          ? total
                          : volume.totalBytes - volume.freeBytes,
                      locale,
                    ),
                    children: [
                      if (volume != null)
                        TextSpan(
                          text: ' / ${formatBytes(volume.totalBytes, locale)}',
                          style: TextStyle(
                            fontSize: 20,
                            color: colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  style: context.typography.pageTitle.copyWith(
                    fontSize: 32,
                    color: colors.textPrimary,
                  ),
                ),
                // Sin texto de conteo debajo: no aportaba (quitado el
                // 2026-10-30).
                // Mientras el índice se pone al día, la ruedita de arriba lo
                // dice (antes era un texto aquí).
                if (kinds.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  KeyedSubtree(key: GakokenTourKeys.usageBar, child: _UsageBar(
                    kinds: kinds,
                    total: total,
                    volume: volume,
                    onOpenKind: (k) => _openKind(k),
                  )),
                ],
                if (volume != null) ...[
                  const SizedBox(height: 8),
                  // El total ya está en el número grande: aquí solo lo libre.
                  Text(
                    l10n.usageFreeOnly(formatBytes(volume.freeBytes, locale)),
                    style: context.typography.small.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  // Sin Acceso al uso, apps y sistema van juntos.
                  if (volume.kind == VolumeKind.internal &&
                      volume.appsBytes == null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: StorageVolumesService().requestUsageAccess,
                        icon: const Icon(Icons.apps_rounded, size: 18),
                        label: Text(l10n.usageAppsAccess),
                      ),
                    ),
                ],
              ],
            ),
          ),
          if (kinds.isNotEmpty) ...[
            section(
              l10n.usageByKind,
              trailing: kinds.length > 1 ? _kindSortButton(l10n) : null,
            ),
            for (final k in _sortedKinds(l10n, kinds))
              _UsageRow(
                leading: FileKindIcon(kind: k.kind, size: 32),
                title: kindLabel(l10n, k.kind),
                subtitle: l10n.usageFiles(number.format(k.files)),
                bytes: k.bytes,
                total: total,
                barColor: k.kind.color ?? colors.primary,
                onTap: () => _openKind(k),
              ),
          ],
          if (children.isNotEmpty) ...[
            section(l10n.usageLargest),
            for (final item in children)
              Builder(
                builder: (row) => _UsageRow(
                leading: FileThumbnail(
                  path: item.path,
                  name: item.name,
                  isDir: item.isDir,
                  size: 32,
                ),
                title: item.name,
                bytes: item.size,
                total: total,
                barColor: colors.primary,
                onTap: () => _onTap(fileEntryOf(item)),
                onLongPress: () => showFileActionsMenu(
                  context,
                  anchor: row,
                  path: item.path,
                  name: item.name,
                  isDir: item.isDir,
                ),
              ),
              ),
          ],
          if (total == 0)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                l10n.browserEmpty,
                textAlign: TextAlign.center,
                style: context.typography.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Ordenar Por tipo: tamaño, nombre o número de archivos. El orden actual
  /// lleva una flecha con su sentido.
  Widget _kindSortButton(AppLocalizations l10n) {
    final colors = context.colors;
    String label(_KindSort sort) => switch (sort) {
      _KindSort.size => l10n.columnSize,
      _KindSort.name => l10n.columnName,
      _KindSort.files => l10n.usageSortFiles,
    };
    return PopupMenuButton<_KindSort>(
      tooltip: l10n.sortBy,
      color: colors.bgElevated,
      onSelected: _setKindSort,
      itemBuilder: (context) => [
        for (final sort in _KindSort.values)
          PopupMenuItem(
            value: sort,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label(sort),
                    style: context.typography.body.copyWith(
                      color: sort == _kindSort
                          ? colors.primary
                          : colors.textPrimary,
                      fontWeight: sort == _kindSort ? FontWeight.w600 : null,
                    ),
                  ),
                ),
                if (sort == _kindSort)
                  Icon(
                    _kindAscending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 18,
                    color: colors.primary,
                    semanticLabel: _kindAscending
                        ? l10n.sortAscending
                        : l10n.sortDescending,
                  ),
              ],
            ),
          ),
      ],
      icon: Icon(Icons.sort_rounded, color: colors.textSecondary),
    );
  }

  void _openKind(_KindUsage k) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => KindFilesScreen(
        path: _tab.path,
        kind: k.kind,
        extensions: k.extensions,
      ),
    ),
  );

  void _onTap(FileEntry entry) {
    if (entry.isDir) {
      _tab.open(entry.path);
    } else {
      openFileWithFeedback(context, entry.path);
    }
  }
}

/// Fila con logo, nombre, tamaño, porcentaje y una barra proporcional. Cada
/// fila lleva su nombre y su logo: la barra no depende solo del color.
class _UsageRow extends StatelessWidget {
  const _UsageRow({
    required this.leading,
    required this.title,
    required this.bytes,
    required this.total,
    required this.barColor,
    this.subtitle,
    this.onTap,
    this.onLongPress,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final int bytes;
  final int total;
  final Color barColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final share = total > 0 ? bytes / total : 0.0;
    final percent = NumberFormat.percentPattern(locale).format(share);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.typography.body.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatBytes(bytes, locale),
                        style: context.typography.body.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: share,
                            minHeight: 6,
                            color: barColor,
                            backgroundColor: colors.surfaceHover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        child: Text(
                          percent,
                          textAlign: TextAlign.end,
                          style: context.typography.small.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: context.typography.small.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un tramo de la barra de Espacio.
class _Segment {
  const _Segment({
    required this.label,
    required this.color,
    required this.bytes,
    this.usage,
  });

  final String label;
  final Color color;
  final int bytes;

  /// El tipo de este tramo, para abrir sus archivos. null en Sistema y
  /// otros, Libre y en Otros cuando junta varios tipos.
  final _KindUsage? usage;
}

/// Todo en una sola barra (pedida el 2026-10-29): un tramo por tipo con su
/// color y, en la raíz de una memoria, lo que la app no ve (sistema, apps,
/// carpetas protegidas) y lo libre. Los tipos que ocupan muy poco se juntan
/// en Otros para que se puedan tocar. Tocar un tramo dice qué es; tocar el
/// de un tipo otra vez (o el aviso) abre sus archivos.
class _UsageBar extends StatefulWidget {
  const _UsageBar({
    required this.kinds,
    required this.total,
    required this.onOpenKind,
    this.volume,
  });

  final List<_KindUsage> kinds;

  /// Lo que suman los archivos de la carpeta.
  final int total;

  /// Solo en la raíz de una memoria con espacio conocido.
  final StorageVolume? volume;
  final ValueChanged<_KindUsage> onOpenKind;

  @override
  State<_UsageBar> createState() => _UsageBarState();
}

class _UsageBarState extends State<_UsageBar> {
  /// Menos que esto de la barra se junta en Otros.
  static const _minShare = 0.015;

  int? _selected;

  List<_Segment> _segments(AppLocalizations l10n, AppColorExtension colors) {
    final volume = widget.volume;
    final whole = volume != null ? volume.totalBytes : widget.total;
    final segments = <_Segment>[];
    var otherBytes = 0;
    _KindUsage? otherKind;
    var merged = 0;
    for (final k in widget.kinds) {
      if (k.kind == FileKind.other || k.bytes / whole < _minShare) {
        otherBytes += k.bytes;
        otherKind = k;
        merged++;
      } else {
        segments.add(
          _Segment(
            label: kindLabel(l10n, k.kind),
            color: k.kind.color ?? colors.primary,
            bytes: k.bytes,
            usage: k,
          ),
        );
      }
    }
    if (otherBytes > 0) {
      // Si solo cayó uno, el tramo es ese tipo con su nombre y color.
      final single = merged == 1 ? otherKind : null;
      segments.add(
        _Segment(
          label: single == null ? l10n.kindOther : kindLabel(l10n, single.kind),
          color: single?.kind.color ?? FileKind.other.color!,
          bytes: otherBytes,
          usage: single,
        ),
      );
    }
    if (volume != null) {
      final kindsBytes = widget.kinds.fold(0, (sum, k) => sum + k.bytes);
      // Con Acceso al uso, las apps van aparte y lo que queda es el sistema.
      final apps = volume.appsBytes ?? 0;
      if (apps > 0) {
        segments.add(
          _Segment(label: l10n.usageApps, color: colors.primary, bytes: apps),
        );
      }
      final system = volume.totalBytes - volume.freeBytes - kindsBytes - apps;
      if (system > 0) {
        segments.add(
          _Segment(
            label: volume.appsBytes == null
                ? l10n.usageSystemOther
                : l10n.usageSystem,
            color: colors.textSecondary,
            bytes: system,
          ),
        );
      }
      segments.add(
        _Segment(
          label: l10n.usageFreeSegment,
          color: colors.surfaceHover,
          bytes: volume.freeBytes,
        ),
      );
    }
    return segments.where((s) => s.bytes > 0).toList();
  }

  void _tap(int index, _Segment segment) {
    if (_selected == index && segment.usage != null) {
      widget.onOpenKind(segment.usage!);
      return;
    }
    setState(() => _selected = _selected == index ? null : index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final segments = _segments(l10n, colors);
    if (segments.isEmpty) return const SizedBox.shrink();
    final whole = segments.fold(0, (sum, s) => sum + s.bytes);
    final selected = _selected != null && _selected! < segments.length
        ? segments[_selected!]
        : null;

    String detail(_Segment segment) {
      // En una carpeta el porcentaje de cada tipo ya está en su fila; en la
      // raíz es sobre toda la memoria y es otro dato.
      if (widget.volume == null && segment.usage != null) return segment.label;
      final share = segment.bytes / whole;
      final percent = NumberFormat.decimalPercentPattern(
        locale: locale,
        decimalDigits: share < 0.01 ? 1 : 0,
      ).format(share);
      return '${segment.label} · $percent';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 16,
            child: Row(
              children: [
                for (final (i, segment) in segments.indexed)
                  Expanded(
                    flex: (segment.bytes / whole * 1000).ceil(),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _tap(i, segment),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: selected == null || selected == segment
                            ? 1
                            : 0.35,
                        child: Container(
                          margin: EdgeInsets.only(
                            right: i == segments.length - 1 ? 0 : 1.5,
                          ),
                          color: segment.color,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.topLeft,
          child: selected == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Material(
                    color: colors.bgElevated,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: selected.usage == null
                          ? null
                          : () => widget.onOpenKind(selected.usage!),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: selected.color,
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.borderSubtle),
                              ),
                              child: const SizedBox.square(dimension: 10),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              detail(selected),
                              style: context.typography.small.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (selected.usage != null) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: colors.textSecondary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
