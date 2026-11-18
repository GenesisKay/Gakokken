import 'package:flutter_test/flutter_test.dart';
import 'package:gakoken/core/files/date_groups.dart';
import 'package:gakoken/core/files/file_entry.dart';
import 'package:gakoken/core/services/explorer_settings_service.dart';
import 'package:gakoken/core/services/view_prefs.dart';
import 'package:gakoken/features/browser/presentation/controllers/selection.dart';

FileEntry _entry(String name, DateTime modified, {bool isDir = false}) =>
    FileEntry(
      path: '/x/$name',
      name: name,
      isDir: isDir,
      size: 0,
      modified: modified,
    );

void main() {
  final now = DateTime(2026, 10, 29, 15);

  group('Date groups', () {
    test('Today, yesterday, last 7 days, then one per month', () {
      int rank(DateTime d) => DateGroup.of(d, now).rank;
      expect(rank(DateTime(2026, 10, 29, 1)), rank(now));
      expect(rank(DateTime(2026, 11, 2)), rank(now)); // futuro: hoy
      final yesterday = rank(DateTime(2026, 10, 28, 23));
      final week = rank(DateTime(2026, 10, 23));
      final october = rank(DateTime(2026, 10, 22));
      final september = rank(DateTime(2026, 9, 30));
      expect(rank(now) > yesterday, isTrue);
      expect(yesterday > week, isTrue);
      expect(week > october, isTrue);
      expect(october > september, isTrue);
      expect(rank(DateTime(2026, 10, 1)), october);
      expect(DateGroup.of(DateTime(2026, 9, 3), now).month, DateTime(2026, 9));
    });

    test('Runs split a sorted list once per group', () {
      final runs = dateRuns([
        DateTime(2026, 10, 29),
        DateTime(2026, 10, 29),
        DateTime(2026, 10, 28),
        DateTime(2026, 9, 1),
      ], now);
      expect(
        [for (final r in runs) (r.start, r.end)],
        [(0, 2), (2, 3), (3, 4)],
      );
      expect(dateRuns(const [], now), isEmpty);
    });
  });

  group('Group by date', () {
    test('Turning it on sorts by date, newest first', () {
      final prefs = ViewPrefs();
      prefs.setGroupByDate(true);
      expect(prefs.sortField, SortField.modified);
      expect(prefs.ascending, isFalse);
      // Otro toque a fecha invierte y sigue agrupado.
      prefs.tapSort(SortField.modified);
      expect(prefs.ascending, isTrue);
      expect(prefs.groupByDate, isTrue);
      // Otro orden lo apaga.
      prefs.tapSort(SortField.name);
      expect(prefs.groupByDate, isFalse);
      expect(prefs.sortField, SortField.name);
    });

    test('Folders go first inside each group, not before every group', () {
      final today = DateTime.now();
      final old = today.subtract(const Duration(days: 60));
      final prefs = ViewPrefs()..setGroupByDate(true);
      final sorted = sortEntries([
        _entry('old.txt', old),
        _entry('OldDir', old, isDir: true),
        _entry('new.txt', today),
        _entry('NewDir', today, isDir: true),
      ], prefs);
      expect(
        [for (final e in sorted) e.name],
        ['NewDir', 'new.txt', 'OldDir', 'old.txt'],
      );
      // Sin agrupar, las carpetas van primero en toda la lista.
      prefs.tapSort(SortField.name);
      prefs.tapSort(SortField.modified);
      expect(prefs.groupByDate, isFalse);
      expect(
        [for (final e in sortEntries(sorted, prefs)) e.name],
        ['OldDir', 'NewDir', 'old.txt', 'new.txt'],
      );
    });
  });

  group('Selection', () {
    test('Tapping a group header selects it, tapping again clears it', () {
      final selection = SelectionController()..keys = ['a', 'b', 'c', 'd'];
      selection.toggleRange(1, 3);
      expect(selection.selected, {'b', 'c'});
      selection.toggleSelection('c');
      selection.toggleRange(1, 3);
      expect(selection.selected, {'b', 'c'});
      selection.toggleRange(1, 3);
      expect(selection.selecting, isFalse);
    });

    test('Dragging marks a range and what disappears is dropped', () {
      final selection = SelectionController()..keys = ['a', 'b', 'c', 'd'];
      selection
        ..startDragSelection(0)
        ..updateDragSelection(2)
        ..endDragSelection();
      expect(selection.selected, {'a', 'b', 'c'});
      selection
        ..keys = ['a', 'd']
        ..retainVisible();
      expect(selection.selected, {'a'});
    });
  });

  test('Kind filter keeps folders', () {
    final filter = KindFilterState();
    final folder = _entry('Fotos', now, isDir: true);
    final pdf = _entry('a.pdf', now);
    final jpg = _entry('b.jpg', now);
    filter.toggleKind(pdf.kind);
    expect([folder, pdf, jpg].where(filter.matches), [folder, pdf]);
    filter.clearKinds();
    expect([folder, pdf, jpg].where(filter.matches).length, 3);
  });
}
