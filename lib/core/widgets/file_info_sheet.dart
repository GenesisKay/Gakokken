import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../l10n/app_localizations.dart';
import '../files/file_entry.dart';
import '../files/file_format.dart';
import '../files/file_kind.dart';
import '../files/file_labels.dart';
import '../theme/theme_extensions.dart';
import 'file_thumbnail.dart';
import 'gakoken_bottom_sheet.dart';
import 'modal_drag_handle.dart';

/// Información de lo seleccionado. Con uno: tipo, tamaño, contenido (si es
/// carpeta), fecha y ubicación. Con varios: tamaño total, cuántos archivos y
/// carpetas, y la ubicación. El nombre solo va en el encabezado.
void showEntryInfoSheet(BuildContext context, List<FileEntry> entries) {
  if (entries.isEmpty) return;
  showGakokenBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    builder: (_) => _InfoSheet(entries: entries),
  );
}

class _InfoSheet extends StatelessWidget {
  const _InfoSheet({required this.entries});

  final List<FileEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final single = entries.length == 1 ? entries.first : null;
    // Las carpetas pesan lo que dice el índice; 0 si todavía no lo sabe.
    final bytes = entries.fold<int>(0, (sum, e) => sum + e.size);
    final rows = <(String, String)>[];

    if (single != null) {
      final ext = FileKind.extensionOf(single.name);
      final kind = kindLabel(l10n, single.kind);
      rows.add((
        l10n.sortKind,
        single.isDir || ext.isEmpty ? kind : '$kind (.$ext)',
      ));
      if (!single.isDir || single.size > 0) {
        rows.add((l10n.columnSize, formatBytes(single.size, locale)));
      }
      if (single.isDir && single.childCount != null) {
        rows.add((
          l10n.infoContents,
          l10n.browserItemCount(single.childCount!),
        ));
      }
      rows.add((
        l10n.columnModified,
        DateFormat.yMMMd(locale).add_Hm().format(single.modified),
      ));
    } else {
      final number = NumberFormat.decimalPattern(locale);
      final dirs = entries.where((e) => e.isDir).length;
      if (bytes > 0) rows.add((l10n.columnSize, formatBytes(bytes, locale)));
      rows.add((
        l10n.infoContents,
        l10n.usageCounts(
          number.format(entries.length - dirs),
          number.format(dirs),
        ),
      ));
    }
    rows.add((l10n.infoLocation, p.dirname(entries.first.path)));

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + gakokenSheetBottomInset(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ModalDragHandle(),
          if (single != null)
            Row(
              children: [
                FileThumbnail(
                  path: single.path,
                  name: single.name,
                  isDir: single.isDir,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    single.name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.cardTitle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              l10n.selectionCount(entries.length),
              style: context.typography.modalTitle,
            ),
          const SizedBox(height: 16),
          for (final (label, value) in rows) _Row(label: label, value: value),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: context.typography.small.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            // Se puede seleccionar para copiar la ruta.
            child: SelectableText(
              value,
              style: context.typography.body.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
