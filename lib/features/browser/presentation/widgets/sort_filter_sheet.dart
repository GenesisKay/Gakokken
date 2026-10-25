import 'package:flutter/material.dart';

import '../../../../core/services/explorer_settings_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/gakoken_bottom_sheet.dart';
import '../../../../core/widgets/kind_filter_chips.dart';
import '../../../../core/widgets/modal_drag_handle.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/browser_controller.dart';
import 'view_mode_sheet.dart';

/// Vista y orden (para todas las pestañas) y filtro por tipo (solo esta
/// pestaña), en una sola hoja desde el ícono de ajustes de Explorar (juntos
/// el 2026-10-23). Los cambios se aplican al momento.
void showSortFilterSheet(BuildContext context, BrowserController tab) {
  showGakokenBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    builder: (_) => _SortFilterSheet(tab: tab, sort: ExplorerSettingsService()),
  );
}

/// Solo ordenar, con un orden propio (como el de los archivos de un tipo).
void showSortSheet(BuildContext context, SortChoice sort) {
  showGakokenBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    builder: (_) => _SortFilterSheet(sort: sort),
  );
}

class _SortFilterSheet extends StatelessWidget {
  const _SortFilterSheet({this.tab, required this.sort});

  /// Sin pestaña no hay filtro por tipo.
  final BrowserController? tab;
  final SortChoice sort;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final settings = sort;
    final tab = this.tab;
    // La vista de Explorar es una para todas las pestañas.
    final explorer = ExplorerSettingsService();
    final fields = {
      SortField.name: l10n.columnName,
      SortField.modified: l10n.sortModified,
      SortField.size: l10n.columnSize,
      // Sin pestaña (archivos de un solo tipo) ordenar por tipo no sirve.
      if (tab != null) SortField.kind: l10n.sortKind,
    };
    Widget title(String text) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: context.typography.body.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24 + gakokenSheetBottomInset(context),
        ),
        child: ListenableBuilder(
          listenable: Listenable.merge([
            if (tab != null) tab,
            settings,
            explorer,
          ]),
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ModalDragHandle(),
              Text(
                tab == null ? l10n.sortBy : l10n.browserDisplayTitle,
                style: context.typography.modalTitle,
              ),
              if (tab != null) ...[
                title(l10n.browserViewTitle),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final mode in BrowserViewMode.values)
                      _ViewChip(
                        mode: mode,
                        selected: explorer.viewMode == mode,
                        onTap: () => explorer.setViewMode(mode),
                      ),
                  ],
                ),
                title(l10n.sortBy),
              ] else
                const SizedBox(height: 16),
              // Un toque: de menor a mayor; otro toque: de mayor a menor.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in fields.entries)
                    _SortChip(
                      label: entry.value,
                      selected: settings.sortField == entry.key,
                      ascending: settings.ascending,
                      tooltip: settings.sortField == entry.key
                          ? (settings.ascending
                                ? l10n.sortAscending
                                : l10n.sortDescending)
                          : null,
                      onTap: () => settings.tapSort(entry.key),
                    ),
                ],
              ),
              if (tab != null) ...[
                Row(
                  children: [
                    Expanded(child: title(l10n.filterKinds)),
                    if (tab.kindFilter.isNotEmpty)
                      TextButton(
                        onPressed: tab.clearKinds,
                        child: Text(l10n.filterClear),
                      ),
                  ],
                ),
                KindFilterChips(
                  selected: tab.kindFilter,
                  onToggle: tab.toggleKind,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewChip extends StatelessWidget {
  const _ViewChip({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final BrowserViewMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final label = switch (mode) {
      BrowserViewMode.list => l10n.viewList,
      BrowserViewMode.details => l10n.viewDetails,
      BrowserViewMode.grid => l10n.viewGrid,
      BrowserViewMode.gallery => l10n.viewGallery,
    };
    return ChoiceChip(
      avatar: Icon(
        viewModeIcon(mode),
        size: 18,
        color: selected ? colors.primary : colors.textSecondary,
      ),
      label: Text(label),
      labelStyle: context.typography.small.copyWith(color: colors.textPrimary),
      selected: selected,
      showCheckmark: false,
      selectedColor: colors.primary.withValues(alpha: 0.16),
      side: BorderSide(color: selected ? colors.primary : colors.borderSubtle),
      onSelected: (_) => onTap(),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.ascending,
    required this.tooltip,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool ascending;
  final String? tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final chip = ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (selected) ...[
            const SizedBox(width: 4),
            Icon(
              ascending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 16,
              color: colors.textPrimary,
            ),
          ],
        ],
      ),
      labelStyle: context.typography.small.copyWith(color: colors.textPrimary),
      selected: selected,
      showCheckmark: false,
      selectedColor: colors.primary.withValues(alpha: 0.16),
      side: BorderSide(color: selected ? colors.primary : colors.borderSubtle),
      onSelected: (_) => onTap(),
    );
    return tooltip == null ? chip : Tooltip(message: tooltip!, child: chip);
  }
}
