import 'package:flutter/material.dart';

import '../../../../core/files/file_labels.dart';
import '../../../../core/services/scaffold_messenger_service.dart';
import '../../../../core/services/trash_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/file_dialogs.dart';
import '../../../../core/widgets/file_thumbnail.dart';
import '../../../../core/widgets/gakoken_app_bar.dart';
import '../../../../core/widgets/gakoken_options_sheet.dart';
import '../../../../l10n/app_localizations.dart';

/// Papelera: lo borrado de las memorias conectadas, con de dónde venía y
/// cuántos días le quedan. Se restaura o se borra para siempre.
class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final trash = TrashService();

    return ListenableBuilder(
      listenable: trash,
      builder: (context, _) {
        final items = trash.items;
        final now = DateTime.now();
        return Scaffold(
          backgroundColor: colors.bgPrimary,
          appBar: GakokenAppBar(
            title: l10n.trashTitle,
            actions: [
              if (items.isNotEmpty)
                TextButton(
                  onPressed: () => _empty(context, items.length),
                  child: Text(l10n.trashEmptyAction),
                ),
            ],
          ),
          body: items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l10n.trashEmpty(trash.retentionDays),
                      textAlign: TextAlign.center,
                      style: context.typography.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: FileThumbnail(
                        path: item.trashedPath,
                        name: item.name,
                        isDir: item.isDir,
                      ),
                      title: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.body.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${locationOf(l10n, item.originalPath)} · '
                        '${l10n.trashDaysLeft(item.daysLeft(now, trash.retentionDays))}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.small.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      onTap: () => _options(context, item),
                    );
                  },
                ),
        );
      },
    );
  }

  void _options(BuildContext context, TrashItem item) {
    final l10n = AppLocalizations.of(context)!;
    final trash = TrashService();
    showGakokenOptionsSheet(
      context: context,
      header: Row(
        children: [
          FileThumbnail(
            path: item.trashedPath,
            name: item.name,
            isDir: item.isDir,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.cardTitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      options: [
        GakokenSheetOption(
          icon: Icons.restore_rounded,
          label: l10n.trashRestore,
          onTap: () async {
            final restored = await trash.restore([item]);
            ScaffoldMessengerService.showInfo(
              restored > 0 ? l10n.trashRestored : l10n.trashRestoreFailed,
            );
          },
        ),
        GakokenSheetOption(
          icon: Icons.delete_forever_rounded,
          label: l10n.trashDeleteForever,
          onTap: () async {
            final ok = await showConfirmDialog(
              context,
              title: l10n.trashDeleteForever,
              message: l10n.trashDeleteForeverMessage(1),
              confirm: l10n.actionDelete,
            );
            if (ok) await trash.deleteForever([item]);
          },
        ),
      ],
    );
  }

  Future<void> _empty(BuildContext context, int count) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showConfirmDialog(
      context,
      title: l10n.trashEmptyAction,
      message: l10n.trashDeleteForeverMessage(count),
      confirm: l10n.actionDelete,
    );
    if (ok) await TrashService().empty();
  }
}
