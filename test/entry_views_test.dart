import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gakoken/core/files/file_entry.dart';
import 'package:gakoken/core/services/explorer_settings_service.dart';
import 'package:gakoken/core/theme/app_theme.dart';
import 'package:gakoken/core/theme/color_extensions.dart';
import 'package:gakoken/features/browser/presentation/widgets/entry_views.dart';
import 'package:gakoken/l10n/app_localizations.dart';

void main() {
  final now = DateTime.now();
  final entries = [
    for (var i = 0; i < 30; i++)
      FileEntry(
        path: '/x/f$i.txt',
        name: 'f$i.txt',
        isDir: false,
        size: 0,
        modified: now.subtract(Duration(days: i * 5)),
      ),
  ];

  for (final mode in BrowserViewMode.values) {
    testWidgets('Grouped by date in ${mode.name}: headers and group tap', (
      tester,
    ) async {
      (int, int)? tapped;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.createTheme(AppColorExtension.defaultTheme),
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: EntryViews(
              entries: entries,
              mode: mode,
              onTap: (_) {},
              sortField: SortField.modified,
              ascending: false,
              onSortColumn: (_) {},
              groupByDate: true,
              showSize: false,
              selected: {entries.first.path},
              onSelectGroup: (start, end) => tapped = (start, end),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Hoy'), findsOneWidget);
      await tester.tap(find.text('Hoy'));
      expect(tapped, (0, 1));
      // Con selección, cada encabezado lleva su círculo.
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  Widget app(Widget body) => MaterialApp(
    theme: AppTheme.createTheme(AppColorExtension.defaultTheme),
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: body),
  );

  test('Zoom order goes from denser to more visual views', () {
    expect(zoomStep(BrowserViewMode.list, zoomIn: true), BrowserViewMode.grid);
    expect(
      zoomStep(BrowserViewMode.grid, zoomIn: true),
      BrowserViewMode.gallery,
    );
    expect(zoomStep(BrowserViewMode.gallery, zoomIn: true), isNull);
    expect(
      zoomStep(BrowserViewMode.list, zoomIn: false),
      BrowserViewMode.details,
    );
    expect(zoomStep(BrowserViewMode.details, zoomIn: false), isNull);
  });

  testWidgets('Pinching changes the view one step per gesture', (tester) async {
    final changes = <BrowserViewMode>[];
    await tester.pumpWidget(
      app(
        EntryViews(
          entries: entries,
          mode: BrowserViewMode.list,
          onTap: (_) {},
          sortField: SortField.name,
          ascending: true,
          onSortColumn: (_) {},
          onViewMode: changes.add,
        ),
      ),
    );
    final center = tester.getCenter(find.byType(CustomScrollView));
    final a = await tester.startGesture(center - const Offset(40, 0));
    final b = await tester.startGesture(
      center + const Offset(40, 0),
      pointer: 7,
    );
    // Abrir mucho los dedos sigue siendo un solo paso.
    for (var i = 1; i <= 6; i++) {
      await a.moveTo(center - Offset(40.0 + i * 20, 0));
      await b.moveTo(center + Offset(40.0 + i * 20, 0));
    }
    await a.up();
    await b.up();
    expect(changes, [BrowserViewMode.grid]);

    final c = await tester.startGesture(center - const Offset(100, 0));
    final d = await tester.startGesture(
      center + const Offset(100, 0),
      pointer: 9,
    );
    await c.moveTo(center - const Offset(40, 0));
    await d.moveTo(center + const Offset(40, 0));
    await c.up();
    await d.up();
    expect(
      changes.last,
      BrowserViewMode.details,
      reason: 'Cerrar los dedos aleja',
    );
  });

  // Con selección, deslizar de lado selecciona sin mantener presionado; recto
  // hacia abajo hace scroll.
  for (final mode in [BrowserViewMode.list, BrowserViewMode.gallery]) {
    testWidgets('Swipe selects while selecting in ${mode.name}', (
      tester,
    ) async {
      final calls = <String>[];
      Widget build(Set<String> selected) => app(
        EntryViews(
          entries: entries,
          mode: mode,
          onTap: (_) {},
          sortField: SortField.modified,
          ascending: false,
          onSortColumn: (_) {},
          selected: selected,
          dragSelect: DragSelectCallbacks(
            onStart: (i) => calls.add('start $i'),
            onUpdate: (i) => calls.add('update $i'),
            onEnd: () => calls.add('end'),
          ),
        ),
      );

      // Sin selección deslizar de lado no hace nada.
      await tester.pumpWidget(build({}));
      await tester.dragFrom(const Offset(30, 30), const Offset(80, 0));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);

      await tester.pumpWidget(build({entries.first.path}));
      await tester.dragFrom(const Offset(30, 30), const Offset(80, 0));
      await tester.pumpAndSettle();
      expect(calls.first, 'start 0');
      expect(calls.last, 'end');

      calls.clear();
      await tester.dragFrom(const Offset(30, 300), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
    });
  }

  for (final mode in [BrowserViewMode.grid, BrowserViewMode.gallery]) {
    testWidgets('Selected cell has a circle in ${mode.name}', (tester) async {
      await tester.pumpWidget(
        app(
          EntryViews(
            entries: entries,
            mode: mode,
            onTap: (_) {},
            sortField: SortField.modified,
            ascending: false,
            onSortColumn: (_) {},
            selected: {entries.first.path},
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  }
}
