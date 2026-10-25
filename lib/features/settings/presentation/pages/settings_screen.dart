import 'package:flutter/material.dart';

import '../../../../core/services/explorer_settings_service.dart';
import '../../../../core/services/index_service.dart';
import '../../../../core/services/locale_service.dart';
import '../../../../core/services/preview_settings_service.dart';
import '../../../../core/services/trash_service.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/widgets/gakoken_app_bar.dart';
import '../../../../core/widgets/gakoken_bottom_sheet.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/hidden_files_sheet.dart';
import '../widgets/index_sheet.dart';
import '../widgets/language_selection_bottom_modal.dart';
import '../widgets/preview_settings_sheet.dart';
import '../../../trash/presentation/pages/trash_screen.dart';
import '../widgets/trash_days_dialog.dart';
import 'themes_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.initialize();
    _themeService.addListener(_onChanged);
    PreviewSettingsService().addListener(_onChanged);
    IndexService().addListener(_onChanged);
    ExplorerSettingsService().addListener(_onChanged);
    TrashService().addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _themeService.removeListener(_onChanged);
    PreviewSettingsService().removeListener(_onChanged);
    IndexService().removeListener(_onChanged);
    ExplorerSettingsService().removeListener(_onChanged);
    TrashService().removeListener(_onChanged);
    super.dispose();
  }

  String _languageLabel() {
    switch (LocaleService().currentLocale.languageCode) {
      case 'es':
        return 'Español';
      case 'ja':
        return '日本語';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }

  String _themeLabel(AppLocalizations l10n) {
    final id = _themeService.activeThemeId;
    switch (id) {
      case 'default':
        return l10n.themeDefaultName;
      case 'nekokag':
        return l10n.themeNameNekokag;
      case 'eloisa':
        return l10n.themeNameEloisa;
      case 'asiole':
        return l10n.themeDefaultName8;
      case 'ajoruto':
        return l10n.themeDefaultName7;
      case 'oturoja':
        return l10n.themeDefaultName2;
      case 'manubu':
        return l10n.themeDefaultName3;
      case 'ubunam':
        return l10n.themeDefaultName4;
      case 'zontle':
        return l10n.themeDefaultName5;
      case 'eltnoz':
        return l10n.themeDefaultName6;
      case 'bioka':
        return l10n.themeNameBioka;
      case 'akoib':
        return l10n.themeNameAkoib;
    }
    for (final theme in _themeService.getAvailableThemes()) {
      if (theme.id == id) return theme.name;
    }
    return l10n.themesTitle;
  }

  void _openLanguage() {
    showGakokenBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      builder: (_) => LanguageSelectionBottomModal(
        onLanguageChanged: () {
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _openThemes() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ThemesScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: GakokenAppBar(title: l10n.navSettings, isRootScreen: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _SettingsMenu(
            children: [
              _SettingsMenuRow(
                icon: context.icons.language,
                title: l10n.labelLanguage,
                value: _languageLabel(),
                onTap: _openLanguage,
              ),
              _SettingsMenuRow(
                icon: context.icons.palette,
                title: l10n.themesTitle,
                value: _themeLabel(l10n),
                onTap: _openThemes,
              ),
              _SettingsMenuRow(
                icon: Icons.image_outlined,
                title: l10n.previewTitle,
                value: previewSettingsLabel(l10n),
                onTap: () => showPreviewSettingsSheet(context),
              ),
              _SettingsMenuRow(
                icon: Icons.visibility_off_outlined,
                title: l10n.hiddenTitle,
                value: hiddenFilesLabel(l10n),
                onTap: () => showHiddenFilesSheet(context),
              ),
              _SettingsMenuRow(
                icon: Icons.delete_outline_rounded,
                title: l10n.trashTitle,
                value: l10n.trashCount(TrashService().items.length),
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const TrashScreen())),
              ),
              _SettingsMenuRow(
                icon: Icons.timer_outlined,
                title: l10n.trashDaysTitle,
                value: l10n.trashDaysValue(TrashService().retentionDays),
                onTap: () => showTrashDaysDialog(context),
              ),
              _SettingsMenuRow(
                icon: Icons.manage_search_rounded,
                title: l10n.indexTitle,
                value: indexLabel(context, l10n),
                onTap: () => showIndexSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Gakoken',
              style: context.typography.small.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsMenu extends StatelessWidget {
  const _SettingsMenu({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: 68,
            color: colors.borderSubtle,
          ),
        );
      }
      rows.add(children[i]);
    }

    return Material(
      color: colors.bgElevated,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: rows),
      ),
    );
  }
}

class _SettingsMenuRow extends StatelessWidget {
  const _SettingsMenuRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: typography.small.copyWith(color: colors.textSecondary),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
