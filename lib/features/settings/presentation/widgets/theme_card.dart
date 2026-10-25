import 'package:flutter/material.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/gakoken_card_tile.dart';
import '../../../../l10n/app_localizations.dart';

class ThemeCard extends StatelessWidget {
  final String name;
  final String description;
  final bool isActive;
  final Color primary;
  final Color background;
  final Color surface;
  final VoidCallback onTap;
  final VoidCallback? onMore; // Replaces trailing widget, now triggers options

  const ThemeCard({
    super.key,
    required this.name,
    required this.description,
    this.isActive = false,
    required this.primary,
    required this.background,
    required this.surface,
    required this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return GakokenCardTile(
      onTap: onTap,
      leading: _buildPreviewCircle(context),
      title: name,
      subtitleWidgets: [
        if (description.isNotEmpty)
          Text(
            description,
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (isActive) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.colors.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 12,
                  color: context.colors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)!.statusActive,
                  style: context.typography.small.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewCircle(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          // Background base
          Container(
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.borderSubtle),
            ),
          ),
          // Half circle for surface? Or just a dot?
          // Let's do the "Primary Dot" design from before
          Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
