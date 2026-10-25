import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';
import 'gakoken_bottom_sheet.dart';
import 'modal_drag_handle.dart';

class GakokenSheetOption {
  const GakokenSheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
}

/// Hoja inferior con un encabezado y una lista de opciones. Tocar una opción
/// cierra la hoja y luego corre su acción.
Future<void> showGakokenOptionsSheet({
  required BuildContext context,
  required Widget header,
  required List<GakokenSheetOption> options,
}) {
  return showGakokenBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    builder: (sheetContext) {
      final colors = sheetContext.colors;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ModalDragHandle(),
            header,
            const SizedBox(height: 8),
            for (final option in options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  option.icon,
                  color: option.selected
                      ? colors.primary
                      : colors.textSecondary,
                ),
                title: Text(
                  option.label,
                  style: sheetContext.typography.body.copyWith(
                    color: option.selected
                        ? colors.primary
                        : colors.textPrimary,
                    fontWeight: option.selected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: option.selected
                    ? Icon(Icons.check, color: colors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(sheetContext);
                  option.onTap();
                },
              ),
          ],
        ),
      );
    },
  );
}
