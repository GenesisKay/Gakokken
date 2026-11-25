import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../storage/hive_bootstrap.dart';
import 'origami_tour.dart';

/// Guarda en la caja de ajustes de Hive qué recorridos ya se hicieron.
class HiveTourStore implements TourStore {
  // v2 (2026-11-13): la v1 podía quedar marcada sin haberse mostrado.
  static String _key(String id) => 'tour_v2_done_$id';

  Box? get _box => Hive.isBoxOpen(HiveBootstrap.settingsBox)
      ? Hive.box(HiveBootstrap.settingsBox)
      : null;

  @override
  Future<bool> isDone(String id) async => _box?.get(_key(id)) as bool? ?? false;

  @override
  Future<void> setDone(String id, bool done) async => _box?.put(_key(id), done);
}

/// Elementos que resalta el tutorial. Cada uno envuelve su widget con
/// `KeyedSubtree(key: GakokenTourKeys.x, child: ...)`. Si se borra o se mueve
/// un elemento, se ajusta su paso aquí en el mismo cambio (OR-14).
class GakokenTourKeys {
  GakokenTourKeys._();

  static final nav = GlobalKey(debugLabel: 'tour.nav');
  static final folderTitle = GlobalKey(debugLabel: 'tour.folderTitle');
  static final search = GlobalKey(debugLabel: 'tour.search');
  static final display = GlobalKey(debugLabel: 'tour.display');
  static final usageBar = GlobalKey(debugLabel: 'tour.usageBar');
}

class GakokenTours {
  GakokenTours._();

  static const explore = 'gakoken.explore';
  static const favorites = 'gakoken.favorites';
  static const usage = 'gakoken.usage';

  /// Pestaña de cada recorrido (Ajustes no tiene).
  static const tabs = [explore, favorites, usage];

  static TourLabels labels(AppLocalizations l10n) => TourLabels(
    skip: l10n.tourSkip,
    next: l10n.tourNext,
    done: l10n.tourDone,
    stepCount: l10n.tourStepCount,
  );

  static TourDef byId(String id, AppLocalizations l10n) =>
      all(l10n).firstWhere((t) => t.id == id);

  static List<TourDef> all(AppLocalizations l10n) => [
    TourDef(
      id: explore,
      title: l10n.navExplore,
      steps: [
        TourStep(
          target: GakokenTourKeys.nav,
          title: l10n.tourExpNavTitle,
          body: l10n.tourExpNavBody,
        ),
        TourStep(
          target: GakokenTourKeys.folderTitle,
          title: l10n.tourExpTitleTitle,
          body: l10n.tourExpTitleBody,
        ),
        TourStep(
          target: GakokenTourKeys.search,
          title: l10n.tourExpSearchTitle,
          body: l10n.tourExpSearchBody,
        ),
        TourStep(
          target: GakokenTourKeys.display,
          title: l10n.tourExpDisplayTitle,
          body: l10n.tourExpDisplayBody,
        ),
        TourStep(title: l10n.tourExpSelectTitle, body: l10n.tourExpSelectBody),
      ],
    ),
    TourDef(
      id: favorites,
      title: l10n.navFavorites,
      steps: [TourStep(title: l10n.tourFavTitle, body: l10n.tourFavBody)],
    ),
    TourDef(
      id: usage,
      title: l10n.navUsage,
      steps: [
        TourStep(
          target: GakokenTourKeys.usageBar,
          title: l10n.tourUseBarTitle,
          body: l10n.tourUseBarBody,
        ),
        TourStep(title: l10n.tourUseKindTitle, body: l10n.tourUseKindBody),
      ],
    ),
  ];

  static List<TourEntry> entries(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      TourEntry(
        id: explore,
        title: l10n.navExplore,
        icon: Icons.folder_outlined,
      ),
      TourEntry(
        id: favorites,
        title: l10n.navFavorites,
        icon: Icons.star_outline_rounded,
      ),
      TourEntry(
        id: usage,
        title: l10n.navUsage,
        icon: Icons.pie_chart_outline_rounded,
      ),
    ];
  }
}
