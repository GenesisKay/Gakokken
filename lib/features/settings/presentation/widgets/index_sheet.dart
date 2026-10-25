import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/index_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/gakoken_bottom_sheet.dart';
import '../../../../core/widgets/modal_drag_handle.dart';
import '../../../../l10n/app_localizations.dart';

/// Estado del índice y botón para volver a indexar.
void showIndexSheet(BuildContext context) {
  showGakokenBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    builder: (_) => const _IndexSheet(),
  );
}

/// Texto del valor en la fila de Ajustes.
String indexLabel(BuildContext context, AppLocalizations l10n) {
  final index = IndexService();
  if (index.indexing && !index.ready) return l10n.indexingShort;
  if (!index.ready) return l10n.indexNever;
  final count = NumberFormat.decimalPattern(
    Localizations.localeOf(context).toString(),
  ).format(index.entries);
  return l10n.indexEntries(count);
}

class _IndexSheet extends StatelessWidget {
  const _IndexSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final index = IndexService();
    final locale = Localizations.localeOf(context).toString();

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
      child: ListenableBuilder(
        listenable: index,
        builder: (context, _) {
          final at = index.indexedAt;
          final status = index.indexing
              ? l10n.indexingProgress(
                  NumberFormat.decimalPattern(locale).format(index.scanned),
                )
              : at == null
              ? l10n.indexNever
              : l10n.indexLastRun(DateFormat.yMMMd(locale).add_Hm().format(at));
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ModalDragHandle(),
              Text(l10n.indexTitle, style: context.typography.modalTitle),
              const SizedBox(height: 8),
              Text(
                l10n.indexDescription,
                style: context.typography.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(status, style: context.typography.body),
              if (!index.indexing && index.took != null) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.indexTook(_duration(index.took!, locale)),
                  style: context.typography.small.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
              if (index.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.indexError,
                  style: context.typography.small.copyWith(
                    color: colors.stateError,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: index.indexing ? null : index.rebuild,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.indexRebuild),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// "350 ms" o "1,2 s" según el idioma.
String _duration(Duration took, String locale) {
  final ms = took.inMilliseconds;
  if (ms < 1000) return '${NumberFormat.decimalPattern(locale).format(ms)} ms';
  return '${NumberFormat('0.0', locale).format(ms / 1000)} s';
}
