import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/engine/rust_file_engine.dart';
import '../../../../core/files/file_entry.dart';
import '../../../../core/files/file_format.dart';
import '../../../../core/files/file_kind.dart';
import '../../../../core/files/file_labels.dart';
import '../../../../core/services/index_service.dart';
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

class _StorageUsageTabState extends State<StorageUsageTab> {
  static const _maxChildren = 50;

  final _index = IndexService();
  rust.StorageUsage? _usage;
  bool _loading = false;
  String? _loadedPath;
  int _seenRevision = -1;

  UsageTabController get _tab => widget.controller;

  @override
  void initState() {
    super.initState();
    _index.addListener(_onIndex);
    _tab.addListener(_onPath);
    _load();
  }

  @override
  void dispose() {
    _index.removeListener(_onIndex);
    _tab.removeListener(_onPath);
    super.dispose();
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
          volume: _tab.volume,
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
    final children = usage.children.take(_maxChildren).toList();

    Widget section(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(text, style: context.typography.sectionHeader),
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
                Text(
                  formatBytes(total, locale),
                  style: context.typography.pageTitle.copyWith(
                    fontSize: 32,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.usageCounts(
                    number.format(usage.files),
                    number.format(usage.dirs),
                  ),
                  style: context.typography.small.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (_index.indexing && _tab.volume.indexed) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.usageUpdating,
                    style: context.typography.small.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (kinds.isNotEmpty) ...[
            section(l10n.usageByKind),
            for (final k in kinds)
              _UsageRow(
                leading: FileKindIcon(kind: k.kind, size: 32),
                title: kindLabel(l10n, k.kind),
                subtitle: l10n.usageFiles(number.format(k.files)),
                bytes: k.bytes,
                total: total,
                barColor: k.kind.color ?? colors.primary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => KindFilesScreen(
                      path: _tab.path,
                      kind: k.kind,
                      extensions: k.extensions,
                    ),
                  ),
                ),
              ),
          ],
          if (children.isNotEmpty) ...[
            section(l10n.usageLargest),
            for (final item in children)
              _UsageRow(
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
                onLongPress: () => showFileActionsSheet(
                  context,
                  path: item.path,
                  name: item.name,
                  isDir: item.isDir,
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
