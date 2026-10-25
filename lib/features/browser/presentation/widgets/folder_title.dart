import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../../core/files/file_labels.dart';
import '../../../../core/services/storage_volumes_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/volume_picker_sheet.dart' show volumeIcon;
import '../../../../l10n/app_localizations.dart';

/// Una acción del menú del título, debajo del árbol.
class FolderMenuAction {
  const FolderMenuAction(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;

  /// null la muestra desactivada.
  final VoidCallback? onTap;
}

/// Título de Explorar y de Espacio: la carpeta actual (o la memoria en su
/// raíz). Tocarlo abre un menú con la ruta como árbol (de la memoria a la
/// carpeta actual, cada nivel con sangría) y debajo [actions]. Reemplaza la
/// fila del breadcrumb (pedido el 2026-10-23; en Espacio el 2026-10-24).
class FolderTitle extends StatelessWidget {
  const FolderTitle({
    super.key,
    required this.trail,
    required this.volume,
    required this.onOpen,
    required this.actions,
  });

  /// Carpetas desde la raíz de la memoria hasta la actual.
  final List<String> trail;
  final StorageVolume volume;
  final ValueChanged<String> onOpen;
  final List<FolderMenuAction> actions;

  static const _indent = 14.0;
  static const _maxIndent = 6;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    String label(String path) => p.equals(path, volume.path)
        ? volumeLabel(l10n, volume)
        : p.basename(path);

    PopupMenuItem<VoidCallback> item({
      required IconData icon,
      required String text,
      required VoidCallback? onTap,
      bool current = false,
      int depth = 0,
    }) => PopupMenuItem(
      value: onTap,
      enabled: !current && onTap != null,
      child: Row(
        children: [
          // Árbol: cada nivel se mete un poco más y lleva la flecha que baja
          // desde su carpeta de arriba. La sangría se topa para nombres
          // largos en rutas muy hondas.
          if (depth > 0) ...[
            SizedBox(width: (depth - 1).clamp(0, _maxIndent) * _indent),
            Icon(
              Icons.subdirectory_arrow_right_rounded,
              size: 16,
              color: colors.textDisabled,
            ),
            const SizedBox(width: 4),
          ],
          Icon(
            icon,
            size: 20,
            color: current
                ? colors.primary
                : onTap == null
                ? colors.textDisabled
                : colors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.body.copyWith(
                color: current
                    ? colors.primary
                    : onTap == null
                    ? colors.textDisabled
                    : colors.textPrimary,
                fontWeight: current ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );

    return PopupMenuButton<VoidCallback>(
      tooltip: l10n.browserLocationTitle,
      position: PopupMenuPosition.under,
      color: colors.bgElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      onSelected: (action) => action(),
      // El menú se cierra antes de la acción: las acciones usan el contexto
      // de la pantalla, no el del menú.
      itemBuilder: (_) => [
        // De la memoria hacia abajo hasta la carpeta actual, como árbol.
        for (final (i, path) in trail.indexed)
          item(
            icon: i == 0
                ? volumeIcon(volume.kind)
                : i == trail.length - 1
                ? Icons.folder_open_rounded
                : Icons.folder_rounded,
            text: label(path),
            current: i == trail.length - 1,
            depth: i,
            onTap: () => onOpen(path),
          ),
        const PopupMenuDivider(),
        for (final action in actions)
          item(icon: action.icon, text: action.label, onTap: action.onTap),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label(trail.last),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.pageTitle.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.expand_more_rounded, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
