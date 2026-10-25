import 'package:flutter/material.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/gakoken_bottom_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/modal_drag_handle.dart';

class ThemeOptionsBottomModal extends StatelessWidget {
  final String themeId;
  final String themeName;
  final String themeDescription;
  final bool isActive;
  final bool isSystem; // To disable delete
  final VoidCallback onApply;
  final VoidCallback? onEdit;
  final VoidCallback onExportJson;
  final VoidCallback onExportFile;
  final VoidCallback? onDelete;

  const ThemeOptionsBottomModal({
    super.key,
    required this.themeId,
    required this.themeName,
    required this.themeDescription,
    required this.isActive,
    this.isSystem = false,
    required this.onApply,
    this.onEdit,
    required this.onExportJson,
    required this.onExportFile,
    this.onDelete,
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
          // Header
          Row(
            children: [
              Icon(Icons.palette, color: context.colors.primary, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      themeName,
                      style: context.typography.cardTitle.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (themeDescription.isNotEmpty)
                      Text(
                        themeDescription,
                        style: context.typography.body.copyWith(
                          color: context.colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.stateSuccess.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.colors.stateSuccess.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.themeStatusActive,
                    style: context.typography.small.copyWith(
                      color: context.colors.stateSuccess,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Primary Action: Apply (if not active)
          if (!isActive) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onApply();
                },
                icon: const Icon(Icons.check_circle_outline),
                label: Text(AppLocalizations.of(context)!.themeActionApply),
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.textInverse,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: context.colors.borderSubtle),
            const SizedBox(height: 16),
          ],

          // Actions
          _buildActionItem(
            context,
            icon: Icons.code,
            label: AppLocalizations.of(context)!.themeActionCopyJson,
            onTap: () {
              Navigator.pop(context);
              onExportJson();
            },
          ),

          _buildActionItem(
            context,
            icon: context.icons.download,
            label: AppLocalizations.of(context)!.themeActionSaveFile,
            onTap: () {
              Navigator.pop(context);
              onExportFile();
            },
          ),

          if (onEdit != null || (onDelete != null && !isSystem)) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                if (onEdit != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onEdit!();
                      },
                      icon: Icon(context.icons.edit),
                      label: Text(AppLocalizations.of(context)!.btnEdit),
                    ),
                  ),
                if (onEdit != null && onDelete != null && !isSystem)
                  const SizedBox(width: 16),
                if (onDelete != null && !isSystem)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete!();
                      },
                      icon: Icon(context.icons.delete),
                      label: Text(AppLocalizations.of(context)!.btnDelete),
                      style: FilledButton.styleFrom(
                        backgroundColor: context.colors.stateError,
                        foregroundColor: context.colors.textInverse,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: context.colors.textPrimary),
      title: Text(label, style: context.typography.body),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
