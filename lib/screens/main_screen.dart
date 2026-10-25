import 'package:flutter/material.dart';

import '../core/services/index_service.dart';
import '../core/services/trash_service.dart';
import '../core/theme/theme_extensions.dart';
import '../features/browser/presentation/controllers/explorer_controller.dart';
import '../features/browser/presentation/pages/browser_screen.dart';
import '../features/favorites/presentation/pages/favorites_screen.dart';
import '../features/settings/presentation/pages/settings_screen.dart';
import '../features/storage_usage/presentation/controllers/usage_tab_controller.dart';
import '../features/storage_usage/presentation/pages/storage_usage_tab.dart';
import '../l10n/app_localizations.dart';

/// App shell with bottom tabs: Explore | Favorites | Storage | Settings.
/// Storage lives in the bar for now (asked on 2026-10-20; it may move).
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const _exploreTab = 0;
  static const _favoritesTab = 1;
  static const _usageTab = 2;

  int _index = _exploreTab;
  final _explorer = ExplorerController(
    onPermissionGranted: () {
      IndexService().start();
      TrashService().purgeExpired();
    },
  );
  final _usage = UsageTabController();

  @override
  void initState() {
    super.initState();
    _explorer.init();
  }

  @override
  void dispose() {
    _explorer.dispose();
    _usage.dispose();
    super.dispose();
  }

  void _openInExplore(String path) {
    setState(() => _index = _exploreTab);
    _explorer.active.open(path);
  }

  void _showUsage(String path) {
    setState(() => _index = _usageTab);
    _usage.show(path);
  }

  /// El botón atrás del sistema navega dentro de Explorar (historial, luego
  /// subir) y de Espacio antes de salir de la app.
  bool get _canLeave => switch (_index) {
    _exploreTab => !_explorer.active.canHandleBack,
    _usageTab => !_usage.canGoBack,
    _ => true,
  };

  void _handleBack() {
    switch (_index) {
      case _exploreTab:
        _explorer.active.handleSystemBack();
      case _usageTab:
        _usage.goBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return ListenableBuilder(
      listenable: Listenable.merge([_explorer, _usage]),
      builder: (context, child) => PopScope(
        canPop: _canLeave,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _handleBack();
        },
        child: child!,
      ),
      child: Scaffold(
        backgroundColor: colors.bgPrimary,
        body: IndexedStack(
          index: _index,
          children: [
            BrowserScreen(explorer: _explorer, onShowUsage: _showUsage),
            FavoritesScreen(
              visible: _index == _favoritesTab,
              onOpenFolder: _openInExplore,
            ),
            StorageUsageTab(
              controller: _usage,
              onOpenInExplore: _openInExplore,
            ),
            const SettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: colors.bgElevated,
          indicatorColor: colors.primary.withValues(alpha: 0.16),
          surfaceTintColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.folder_outlined, color: colors.textSecondary),
              selectedIcon: Icon(Icons.folder, color: colors.primary),
              label: l10n.navExplore,
            ),
            NavigationDestination(
              icon: Icon(
                Icons.star_outline_rounded,
                color: colors.textSecondary,
              ),
              selectedIcon: Icon(Icons.star_rounded, color: colors.primary),
              label: l10n.navFavorites,
            ),
            NavigationDestination(
              icon: Icon(
                Icons.pie_chart_outline_rounded,
                color: colors.textSecondary,
              ),
              selectedIcon: Icon(
                Icons.pie_chart_rounded,
                color: colors.primary,
              ),
              label: l10n.navUsage,
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: colors.textSecondary),
              selectedIcon: Icon(Icons.settings, color: colors.primary),
              label: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
