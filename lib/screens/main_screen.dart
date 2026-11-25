import 'package:gakoken/core/tutorial/gakoken_tours.dart';
import 'package:gakoken/core/tutorial/origami_tour.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../core/services/android_widget_sync.dart' show WidgetLink;
import '../core/services/index_service.dart';
import '../core/services/trash_service.dart';
import '../core/theme/theme_extensions.dart';
import '../core/widgets/gakoken_app_bar.dart';
import '../core/widgets/storage_permission_view.dart';
import '../features/browser/presentation/controllers/explorer_controller.dart';
import '../features/browser/presentation/pages/browser_screen.dart';
import '../features/favorites/presentation/pages/favorites_screen.dart';
import '../features/search/presentation/pages/search_screen.dart';
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
      _permissionJustGranted?.call();
    },
  );

  /// El controlador se crea antes que el estado: este enlace deja que el
  /// recorrido de la pestaña actual salga en cuanto hay permiso.
  static VoidCallback? _permissionJustGranted;
  final _usage = UsageTabController();

  @override
  void initState() {
    super.initState();
    _permissionJustGranted = () => _maybeTour(_index);
    _explorer.init();
    OrigamiTour.requested.addListener(_onTourRequested);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeTour(_index);
      _onTourRequested();
    });
    if (Platform.isAndroid) {
      HomeWidget.initiallyLaunchedFromHomeWidget().then(_openWidgetLink);
      _widgetClicks = HomeWidget.widgetClicked.listen(_openWidgetLink);
    }
  }

  StreamSubscription<Uri?>? _widgetClicks;

  /// Android home screen widgets open the exact screen (OR-17).
  void _openWidgetLink(Uri? uri) {
    final link = WidgetLink.parse(uri);
    if (link == null || !mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    switch (link.host) {
      case 'search':
        setState(() => _index = _exploreTab);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SearchScreen(
              currentPath: null,
              onOpenFolder: _openInExplore,
              onReveal: (target) {
                setState(() => _index = _exploreTab);
                _explorer.active.reveal(target.path, isDir: target.isDir);
              },
            ),
          ),
        );
      case 'usage':
        setState(() => _index = _usageTab);
      case 'favorites':
        setState(() => _index = _favoritesTab);
      case 'open':
        final path = link.path;
        if (path == null) return;
        setState(() => _index = _exploreTab);
        _explorer.active.reveal(path, isDir: link.isDir);
    }
  }

  /// Tutorial guiado (OR-14): cada pestaña ofrece su recorrido la primera
  /// vez que se abre. Explorar y Espacio esperan a que haya permiso.
  Future<void> _maybeTour(int index) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted || _index != index || index >= GakokenTours.tabs.length) {
      return;
    }
    if (index != _favoritesTab && _explorer.permissionGranted != true) return;
    final l10n = AppLocalizations.of(context)!;
    await OrigamiTour.maybeShow(
      context,
      GakokenTours.byId(GakokenTours.tabs[index], l10n),
      GakokenTours.labels(l10n),
    );
  }

  /// Recorrido pedido desde Ajustes > Tutorial: va a su pestaña y lo muestra.
  Future<void> _onTourRequested() async {
    final id = OrigamiTour.requested.value;
    if (id == null || !mounted) return;
    OrigamiTour.requested.value = null;
    final index = GakokenTours.tabs.indexOf(id);
    if (index < 0) return;
    setState(() => _index = index);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await OrigamiTour.show(
      context,
      GakokenTours.byId(id, l10n),
      GakokenTours.labels(l10n),
    );
  }

  @override
  void dispose() {
    _permissionJustGranted = null;
    _widgetClicks?.cancel();
    OrigamiTour.requested.removeListener(_onTourRequested);
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
            // Día 0: sin permiso, Espacio pide el mismo acceso que Explorar
            // en lugar de mostrar todo en cero.
            if (_explorer.permissionGranted == true)
              StorageUsageTab(
                controller: _usage,
                onOpenInExplore: _openInExplore,
              )
            else
              Scaffold(
                backgroundColor: colors.bgPrimary,
                appBar: GakokenAppBar(title: l10n.navUsage),
                body: _explorer.permissionGranted == null
                    ? const SizedBox.shrink()
                    : StoragePermissionView(
                        onGrant: _explorer.requestPermission,
                      ),
              ),
            const SettingsScreen(),
          ],
        ),
        bottomNavigationBar: KeyedSubtree(key: GakokenTourKeys.nav, child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) {
            setState(() => _index = i);
            _maybeTour(i);
          },
          backgroundColor: colors.bgElevated,
          // Sin pastilla detrás del ícono activo: pintaba un segundo fondo
          // que no llegaba al texto. La activa se marca con el ícono relleno
          // en primary (pedido el 2026-11-10).
          indicatorColor: Colors.transparent,
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
        )),
      ),
    );
  }
}
