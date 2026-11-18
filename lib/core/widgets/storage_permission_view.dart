import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/theme_extensions.dart';

/// Día 0 (OR-12): aviso de para qué se necesita el acceso a los archivos y
/// botón Dar permiso. Lo usan Explorar y Espacio mientras no hay permiso.
class StoragePermissionView extends StatelessWidget {
  const StoragePermissionView({super.key, required this.onGrant});

  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_rounded, size: 64, color: colors.primary),
            const SizedBox(height: 16),
            Text(
              l10n.browserPermissionText,
              textAlign: TextAlign.center,
              style: context.typography.body.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onGrant,
              child: Text(l10n.btnGrantPermission),
            ),
          ],
        ),
      ),
    );
  }
}
