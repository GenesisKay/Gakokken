import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../../../core/files/file_labels.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/explorer_controller.dart';

/// Pestañas de Explorar, como el Explorador de Windows: cada una con su
/// carpeta; la X la cierra y el + del final abre otra. Solo se muestra con
/// dos o más pestañas: con una sola, su nombre repetiría el título. Con una,
/// Pestaña nueva está en el menú del título.
class ExplorerTabStrip extends StatelessWidget {
  const ExplorerTabStrip({super.key, required this.controller});

  final ExplorerController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final tabs = controller.tabs;

    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final tab = tabs[i];
                final selected = i == controller.activeIndex;
                final label = tab.canGoUp
                    ? p.basename(tab.path)
                    : volumeLabel(l10n, tab.volume);
                return Center(
                  child: Material(
                    color: selected
                        ? colors.primary.withValues(alpha: 0.16)
                        : colors.bgElevated,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: selected ? colors.primary : colors.borderSubtle,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => controller.select(i),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 12,
                          right: tabs.length > 1 ? 2 : 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.typography.small.copyWith(
                                  color: selected
                                      ? colors.textPrimary
                                      : colors.textSecondary,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (tabs.length > 1)
                              SizedBox.square(
                                dimension: 30,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  tooltip: l10n.tabClose,
                                  iconSize: 16,
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: colors.textSecondary,
                                  ),
                                  onPressed: () => controller.close(i),
                                ),
                              )
                            else
                              const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            tooltip: l10n.tabNew,
            icon: Icon(Icons.add_rounded, color: colors.textPrimary),
            onPressed: () => controller.newTab(),
          ),
        ],
      ),
    );
  }
}
