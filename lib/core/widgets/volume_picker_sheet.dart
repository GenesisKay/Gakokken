import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../l10n/app_localizations.dart';
import '../files/file_format.dart';
import '../files/file_labels.dart';
import '../services/storage_volumes_service.dart';
import '../theme/theme_extensions.dart';
import 'gakoken_bottom_sheet.dart';
import 'modal_drag_handle.dart';

IconData volumeIcon(VolumeKind kind) => switch (kind) {
  VolumeKind.internal => Icons.smartphone_rounded,
  VolumeKind.sd => Icons.sd_card_outlined,
  VolumeKind.usb => Icons.usb_rounded,
  VolumeKind.system => Icons.account_tree_outlined,
};

/// Elegir memoria: Interno, tarjetas SD y USB conectados, con su espacio
/// libre, y al final la raíz del sistema si [withSystem]. [current] es la
/// ruta de la que está abierta.
void showVolumePickerSheet(
  BuildContext context, {
  required String current,
  required ValueChanged<StorageVolume> onSelected,
  bool withSystem = true,
}) {
  final volumes = StorageVolumesService();
  volumes.refresh();
  showGakokenBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext)!;
      final locale = Localizations.localeOf(sheetContext).toString();
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(sheetContext).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          16 + gakokenSheetBottomInset(sheetContext),
        ),
        child: ListenableBuilder(
          listenable: volumes,
          builder: (_, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ModalDragHandle(),
              Text(
                l10n.volumesTitle,
                style: sheetContext.typography.modalTitle,
              ),
              const SizedBox(height: 8),
              for (final volume in volumes.volumes)
                if (withSystem || volume.kind != VolumeKind.system)
                  _VolumeTile(
                    volume: volume,
                    selected: p.equals(
                      volumes.volumeOf(current).path,
                      volume.path,
                    ),
                    label: volumeLabel(l10n, volume),
                    detail: [
                      if (volume.totalBytes > 0)
                        l10n.volumeFree(
                          formatBytes(volume.freeBytes, locale),
                          formatBytes(volume.totalBytes, locale),
                        ),
                      if (volume.kind == VolumeKind.system)
                        l10n.volumeSystemNote
                      else if (!volume.indexed)
                        l10n.volumeNotIndexed,
                    ].join(' · '),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      onSelected(volume);
                    },
                  ),
            ],
          ),
        ),
      );
    },
  );
}

class _VolumeTile extends StatelessWidget {
  const _VolumeTile({
    required this.volume,
    required this.selected,
    required this.label,
    required this.detail,
    required this.onTap,
  });

  final StorageVolume volume;
  final bool selected;
  final String label;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final used = volume.totalBytes > 0
        ? 1 - volume.freeBytes / volume.totalBytes
        : 0.0;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        volumeIcon(volume.kind),
        color: selected ? colors.primary : colors.textSecondary,
      ),
      title: Text(
        label,
        style: context.typography.body.copyWith(
          color: selected ? colors.primary : colors.textPrimary,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (volume.totalBytes > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: used,
                  minHeight: 6,
                  color: colors.primary,
                  backgroundColor: colors.surfaceHover,
                ),
              ),
            ),
          if (detail.isNotEmpty)
            Text(
              detail,
              style: context.typography.small.copyWith(
                color: colors.textSecondary,
              ),
            ),
        ],
      ),
      trailing: selected ? Icon(Icons.check, color: colors.primary) : null,
      onTap: onTap,
    );
  }
}
