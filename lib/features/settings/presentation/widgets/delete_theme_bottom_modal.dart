import 'package:flutter/material.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/gakoken_bottom_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/modal_drag_handle.dart';

class DeleteThemeBottomModal extends StatelessWidget {
  final String themeName;
  final VoidCallback onConfirmDelete;

  const DeleteThemeBottomModal({
    super.key,
    required this.themeName,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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
          Row(
            children: [
              Icon(
                context.icons.delete,
                color: context.colors.stateError,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.titleDeleteTheme,
                  style: context.typography.modalTitle.copyWith(
                    color: context.colors.stateError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                AppLocalizations.of(context)!.themeConfirmDelete(themeName),
                style: context.typography.body,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.btnCancel),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    onConfirmDelete();
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.stateError,
                    foregroundColor: context.colors.textInverse,
                  ),
                  icon: Icon(context.icons.delete),
                  label: Text(AppLocalizations.of(context)!.btnDelete),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
