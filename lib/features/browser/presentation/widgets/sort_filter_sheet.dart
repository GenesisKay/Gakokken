import 'package:flutter/material.dart';

import '../../../../core/services/explorer_settings_service.dart';
import '../../../../core/services/view_prefs.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/gakoken_bottom_sheet.dart';
import '../../../../core/widgets/kind_filter_chips.dart';
import '../../../../core/widgets/modal_drag_handle.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/browser_controller.dart';
import 'view_mode_sheet.dart';

/// Vista, orden y filtro por tipo de esta pestaña (cada pestaña los suyos
/// desde el 2026-11-13), en una sola hoja desde el ícono de ajustes de
/// Explorar (juntos el 2026-10-23). Los cambios se aplican al momento.
void showSortFilterSheet(BuildContext context, BrowserController tab) =>
    showListOptionsSheet(context, sort: tab, view: tab, filter: tab);

/// Solo ordenar, con un orden propio (como el de los archivos de un tipo).
void showSortSheet(BuildContext context, SortChoice sort) =>
    showListOptionsSheet(context, sort: sort);

/// La hoja de Explorar para cualquier lista: vista si hay [view], orden con
/// agrupar por fecha y filtro por tipo si hay [filter] (Favoritos y la
/// Papelera la usan con los suyos, pedido el 2026-10-29). [dateLabel]
/// nombra el orden por fecha (Agregado, Borrado); sin [sizes] no se ordena
/// por tamaño.
void showListOptionsSheet(
  BuildContext context, {
  required SortChoice sort,
  ViewChoice? view,
  KindFilterChoice? filter,
  String? dateLabel,
  bool sizes = true,
}) {
  showGakokenBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    showDragHandle: false,
    builder: (_) => _SortFilterSheet(
      sort: sort,
      view: view,
      filter: filter,
      dateLabel: dateLabel,
      sizes: sizes,
    ),
  );
}

class _SortFilterSheet extends StatelessWidget {
  const _SortFilterSheet({
    required this.sort,
    this.view,
    this.filter,
    this.dateLabel,
    this.sizes = true,
  });

  final SortChoice sort;
  final ViewChoice? view;

  /// Sin filtro tampoco se ordena por tipo (los archivos de un solo tipo).
  final KindFilterChoice? filter;
  final String? dateLabel;
  final bool sizes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final settings = sort;
    final view = this.view;
    final filter = this.filter;
    final fields = {
      SortField.name: l10n.columnName,
      SortField.modified: dateLabel ?? l10n.sortModified,
      if (sizes) SortField.size: l10n.columnSize,
      if (filter != null) SortField.kind: l10n.sortKind,
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
          listenable: Listenable.merge([?filter, settings, ?view]),
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ModalDragHandle(),
              Text(
                view == null ? l10n.sortBy : l10n.browserDisplayTitle,
                style: context.typography.modalTitle,
              ),
              if (view != null) ...[
                title(l10n.browserViewTitle),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final mode in BrowserViewMode.values)
                      _ViewChip(
                        mode: mode,
                        selected: view.viewMode == mode,
                        onTap: () => view.setViewMode(mode),
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
              // Encenderlo ordena por fecha; otro orden lo apaga.
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ChoiceChip(
                  avatar: Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                    color: settings.groupByDate
                        ? colors.primary
                        : colors.textSecondary,
                  ),
                  label: Text(l10n.groupByDate),
                  labelStyle: context.typography.small.copyWith(
                    color: colors.textPrimary,
                  ),
                  selected: settings.groupByDate,
                  showCheckmark: false,
                  selectedColor: colors.primary.withValues(alpha: 0.16),
                  side: BorderSide(
                    color: settings.groupByDate
                        ? colors.primary
                        : colors.borderSubtle,
                  ),
                  onSelected: settings.setGroupByDate,
                ),
              ),
              if (filter != null) ...[
                Row(
                  children: [
                    Expanded(child: title(l10n.filterKinds)),
                    if (filter.kindFilter.isNotEmpty)
                      TextButton(
                        onPressed: filter.clearKinds,
                        child: Text(l10n.filterClear),
                      ),
                  ],
                ),
                KindFilterChips(
                  selected: filter.kindFilter,
                  onToggle: filter.toggleKind,
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
