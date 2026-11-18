import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../files/file_kind.dart';
import '../files/file_labels.dart';
import '../services/view_prefs.dart';
import '../theme/theme_extensions.dart';
import 'file_kind_icon.dart';

/// Chips para filtrar por tipo de archivo (sin carpetas). Ninguno marcado
/// es mostrar todos.
class KindFilterChips extends StatelessWidget {
  const KindFilterChips({
    super.key,
    required this.selected,
    required this.onToggle,
    this.scrollable = false,
  });

  final Set<FileKind> selected;
  final ValueChanged<FileKind> onToggle;

  /// Una sola fila que se desplaza, en lugar de varias filas.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final chips = [
      for (final kind in FileKind.values)
        if (kind != FileKind.folder)
          FilterChip(
            avatar: FileKindIcon(kind: kind, size: 18),
            label: Text(kindLabel(l10n, kind)),
            labelStyle: context.typography.small.copyWith(
              color: colors.textPrimary,
            ),
            selected: selected.contains(kind),
            showCheckmark: false,
            selectedColor: colors.primary.withValues(alpha: 0.16),
            side: BorderSide(
              color: selected.contains(kind)
                  ? colors.primary
                  : colors.borderSubtle,
            ),
            onSelected: (_) => onToggle(kind),
          ),
    ];

    if (!scrollable) {
      return Wrap(spacing: 8, runSpacing: 8, children: chips);
    }
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Center(child: chips[i]),
      ),
    );
  }
}

/// Tipos filtrados, siempre a la vista arriba de la lista para que no
/// parezca que faltan archivos. La X de cada uno lo quita. En Explorar,
/// Favoritos y la Papelera.
class ActiveKindFilters extends StatelessWidget {
  const ActiveKindFilters({super.key, required this.filter});

  final KindFilterChoice filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          for (final kind in filter.kindFilter)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InputChip(
                label: Text(kindLabel(l10n, kind)),
                labelStyle: context.typography.small.copyWith(
                  color: colors.textPrimary,
                ),
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                side: BorderSide(color: colors.primary),
                deleteIcon: const Icon(Icons.close_rounded, size: 16),
                deleteButtonTooltipMessage: l10n.filterClear,
                onDeleted: () => filter.toggleKind(kind),
              ),
            ),
        ],
      ),
    );
  }
}
