import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../../l10n/app_localizations.dart';
import '../files/file_format.dart';
import '../files/file_kind.dart';
import '../files/file_labels.dart';
import '../theme/color_extensions.dart';
import 'favorites_service.dart';
import 'index_service.dart';
import 'locale_service.dart';
import 'storage_permission_service.dart';
import 'storage_volumes_service.dart';
import 'theme_service.dart';

/// Android home screen widgets (OR-17): Search, Storage, Favorites and Recent.
///
/// Builds one JSON snapshot (storage of the internal memory with the same
/// colored bar as the Storage tab, favorites, theme colors and translated
/// texts) and hands it to `home_widget`; the native widgets only draw it.
/// Recent files are read by the widget itself from Android's media index
/// (newest first), so the Rust index is not touched.
class AndroidWidgetSync with WidgetsBindingObserver {
  AndroidWidgetSync._();
  static final AndroidWidgetSync instance = AndroidWidgetSync._();

  static const snapshotKey = 'origami_widget_snapshot';
  static const _pkg = 'com.morobu.gakoken.widget';
  static const providers = [
    '$_pkg.SearchWidgetProvider',
    '$_pkg.StorageWidgetProvider',
    '$_pkg.FavoritesWidgetProvider',
    '$_pkg.RecentWidgetProvider',
  ];

  /// Less than this of the bar joins Others, like the Storage tab.
  static const _minShare = 0.015;

  bool _started = false;
  Timer? _debounce;
  int _seenRevision = -1;

  void start() {
    if (_started || !Platform.isAndroid) return;
    _started = true;
    for (final l in <Listenable>[
      FavoritesService(),
      StorageVolumesService(),
      ThemeService(),
      LocaleService(),
    ]) {
      l.addListener(schedule);
    }
    IndexService().addListener(_onIndex);
    WidgetsBinding.instance.addObserver(this);
    schedule(const Duration(milliseconds: 1500));
  }

  void _onIndex() {
    final index = IndexService();
    if (index.indexing || index.revision == _seenRevision) return;
    _seenRevision = index.revision;
    schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) schedule();
  }

  void schedule([Duration delay = const Duration(milliseconds: 800)]) {
    if (!_started) return;
    _debounce?.cancel();
    _debounce = Timer(delay, push);
  }

  Future<void> push() async {
    try {
      await HomeWidget.saveWidgetData<String>(
          snapshotKey, jsonEncode(await buildSnapshot()));
    } catch (e) {
      debugPrint('AndroidWidgetSync: $e');
    }
    // Each widget on its own: one that fails does not stop the rest
    // (skill origami-widgets, W-03).
    for (final p in providers) {
      try {
        await HomeWidget.updateWidget(qualifiedAndroidName: p);
      } catch (e) {
        debugPrint('AndroidWidgetSync $p: $e');
      }
    }
  }

  Future<Map<String, Object?>> buildSnapshot() async {
    final locale = LocaleService().currentLocale;
    final l10n = lookupAppLocalizations(switch (locale.languageCode) {
      'es' || 'en' || 'fr' || 'ja' => Locale(locale.languageCode),
      _ => const Locale('en'),
    });
    final tag = locale.toString();
    final colors = ThemeService().currentColors;
    final granted = await StoragePermissionService.isGranted();

    return {
      'v': 1,
      'theme': {'mode': 'fixed', 'light': _palette(colors)},
      'perm': granted,
      't': {
        'search': l10n.searchHint,
        'usage': l10n.navUsage,
        'favorites': l10n.navFavorites,
        'recent': l10n.widgetRecentFiles,
        'emptyFavorites': l10n.widgetEmptyFavorites,
        'grant': l10n.btnGrantPermission,
      },
      'space': granted ? await _space(l10n, tag, colors) : null,
      'favorites': [
        for (final f in FavoritesService().all.take(12))
          {'path': f.path, 'name': f.name, 'dir': f.isDir},
      ],
    };
  }

  /// Internal memory: used of total, and the colored bar of the Storage tab
  /// (one slice per file kind, Apps, System and Free).
  Future<Map<String, Object?>?> _space(
    AppLocalizations l10n,
    String tag,
    AppColorExtension colors,
  ) async {
    final volumes = StorageVolumesService().volumes;
    if (volumes.isEmpty) return null;
    final volume = volumes.first;
    if (volume.totalBytes <= 0) return null;
    final used = volume.totalBytes - volume.freeBytes;

    final slices = <Map<String, Object?>>[];
    var kindsBytes = 0;
    final usage = IndexService().ready ? await IndexService().usage(volume.path) : null;
    if (usage != null) {
      final byKind = <FileKind, int>{};
      for (final ext in usage.byExtension) {
        final kind = FileKind.fromName(
          ext.extension_.isEmpty ? 'x' : 'x.${ext.extension_}',
        );
        byKind[kind] = (byKind[kind] ?? 0) + ext.bytes.toInt();
      }
      final kinds = byKind.entries.where((e) => e.value > 0).toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      var other = 0;
      for (final e in kinds) {
        kindsBytes += e.value;
        if (e.key == FileKind.other || e.value / volume.totalBytes < _minShare) {
          other += e.value;
        } else {
          slices.add({
            'l': kindLabel(l10n, e.key),
            'c': _c(e.key.color ?? colors.primary),
            'f': e.value / volume.totalBytes,
          });
        }
      }
      if (other > 0) {
        slices.add({
          'l': l10n.kindOther,
          'c': _c(FileKind.other.color!),
          'f': other / volume.totalBytes,
        });
      }
    }
    final apps = volume.appsBytes ?? 0;
    if (apps > 0) {
      slices.add({
        'l': l10n.usageApps,
        'c': _c(colors.primary),
        'f': apps / volume.totalBytes,
      });
    }
    final system = used - kindsBytes - apps;
    if (system > 0) {
      slices.add({
        'l': volume.appsBytes == null ? l10n.usageSystemOther : l10n.usageSystem,
        'c': _c(colors.textSecondary),
        'f': system / volume.totalBytes,
      });
    }
    return {
      'used': formatBytes(used, tag),
      'total': formatBytes(volume.totalBytes, tag),
      'free': l10n.usageFreeOnly(formatBytes(volume.freeBytes, tag)),
      'usedF': used / volume.totalBytes,
      'freeColor': _c(colors.surfaceHover),
      'slices': slices,
    };
  }

  static int _c(Color c) => c.toARGB32();

  Map<String, int> _palette(AppColorExtension c) => {
        'bg': _c(c.bgSecondary),
        'text': _c(c.textPrimary),
        'text2': _c(c.textSecondary),
        'primary': _c(c.primary),
        'onPrimary': _c(c.textInverse),
        'border': _c(c.borderSubtle),
        'success': _c(c.stateSuccess),
        'error': _c(c.stateError),
        'warning': _c(c.stateWarning),
        'disabled': _c(c.textDisabled),
      };
}

/// Deep links the widgets open: `gakoken://search`, `gakoken://usage`,
/// `gakoken://favorites` and `gakoken://open?path=...&dir=1`.
class WidgetLink {
  final String host;
  final String? path;
  final bool isDir;

  const WidgetLink(this.host, this.path, this.isDir);

  static WidgetLink? parse(Uri? uri) {
    if (uri == null || uri.scheme != 'gakoken') return null;
    return WidgetLink(
      uri.host,
      uri.queryParameters['path'],
      uri.queryParameters['dir'] == '1',
    );
  }
}
