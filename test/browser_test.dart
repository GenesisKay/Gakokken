import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gakoken/core/engine/file_engine.dart';
import 'package:gakoken/core/files/file_entry.dart';
import 'package:gakoken/core/files/file_format.dart';
import 'package:gakoken/core/files/file_kind.dart';
import 'package:gakoken/core/services/explorer_settings_service.dart';
import 'package:gakoken/core/services/folder_watch_service.dart';
import 'package:gakoken/core/services/storage_volumes_service.dart';
import 'package:gakoken/features/browser/presentation/controllers/browser_controller.dart';
import 'package:gakoken/features/browser/presentation/controllers/explorer_controller.dart';
import 'package:gakoken/features/storage_usage/presentation/controllers/usage_tab_controller.dart';
import 'package:path/path.dart' as p;

/// Motor de prueba: entrega lo que se le pida por ruta y recuerda si se
/// pidieron los ocultos.
class _FakeEngine implements FileEngine {
  final listings = <String, StreamController<List<FileEntry>>>{};
  bool? lastShowHidden;

  @override
  Stream<List<FileEntry>> list(String path, {bool showHidden = false}) {
    lastShowHidden = showHidden;
    return (listings[path] = StreamController<List<FileEntry>>()).stream;
  }

  @override
  Future<bool> exists(String path) async => true;
}

FileEntry _entry(
  String path, {
  bool isDir = false,
  int? childCount,
  int size = 10,
  int day = 1,
}) => FileEntry(
  path: path,
  name: p.basename(path),
  isDir: isDir,
  size: size,
  modified: DateTime(2026, 1, day),
  childCount: childCount,
);

void main() {
  const root = '/storage/emulated/0';
  const sd = '/storage/AB12-34CD';
  const usb = '/storage/USB1';
  final settings = ExplorerSettingsService();
  final volumes = StorageVolumesService();
  late _FakeEngine engine;
  late BrowserController tab;

  setUp(() {
    settings.reset();
    volumes.volumes = const [
      StorageVolume(path: root, label: '', kind: VolumeKind.internal),
      StorageVolume(path: sd, label: 'Tarjeta SD', kind: VolumeKind.sd),
      StorageVolume(path: usb, label: 'USB', kind: VolumeKind.usb),
    ];
    engine = _FakeEngine();
    tab = BrowserController(path: root, engine: engine);
  });

  tearDown(() => tab.dispose());

  group('BrowserController', () {
    test('Sorts folders first, then by name ignoring case', () async {
      tab.reload();
      engine.listings[root]!.add([
        _entry('$root/zeta.txt'),
        _entry('$root/Alfa.pdf'),
        _entry('$root/Musica', isDir: true),
      ]);
      await pumpEventQueue();
      expect(tab.entries.map((e) => e.name), [
        'Musica',
        'Alfa.pdf',
        'zeta.txt',
      ]);
      expect(tab.loading, isTrue);
    });

    test(
      'A repeated path updates the entry (item count arrives later)',
      () async {
        tab.reload();
        engine.listings[root]!
          ..add([_entry('$root/DCIM', isDir: true)])
          ..add([_entry('$root/DCIM', isDir: true, childCount: 3)]);
        await engine.listings[root]!.close();
        await pumpEventQueue();
        expect(tab.entries.single.childCount, 3);
        expect(tab.loading, isFalse);
      },
    );

    test('One tap sorts ascending, another descending', () async {
      tab.reload();
      engine.listings[root]!.add([
        _entry('$root/grande.mp4', size: 900, day: 1),
        _entry('$root/chico.pdf', size: 5, day: 3),
        _entry('$root/medio.jpg', size: 50, day: 2),
        _entry('$root/Zeta', isDir: true, size: 10),
        _entry('$root/Alfa', isDir: true, size: 999),
      ]);
      await pumpEventQueue();
      List<String> names() => tab.entries.map((e) => e.name).toList();

      tab.tapSort(SortField.size);
      expect(tab.ascending, isTrue);
      expect(names(), ['Zeta', 'Alfa', 'chico.pdf', 'medio.jpg', 'grande.mp4']);

      tab.tapSort(SortField.size);
      expect(tab.ascending, isFalse);
      expect(names(), ['Alfa', 'Zeta', 'grande.mp4', 'medio.jpg', 'chico.pdf']);

      // Otro criterio vuelve a empezar de menor a mayor.
      tab.tapSort(SortField.modified);
      expect(tab.ascending, isTrue);
      expect(names().sublist(2), ['grande.mp4', 'medio.jpg', 'chico.pdf']);

      tab.tapSort(SortField.kind);
      expect(names().sublist(2), ['chico.pdf', 'medio.jpg', 'grande.mp4']);
    });

    test('Type filter keeps folders and can be cleared', () async {
      tab.reload();
      engine.listings[root]!.add([
        _entry('$root/a.pdf'),
        _entry('$root/b.jpg'),
        _entry('$root/Docs', isDir: true),
      ]);
      await pumpEventQueue();
      tab.toggleKind(FileKind.pdf);
      expect(tab.entries.map((e) => e.name), ['Docs', 'a.pdf']);
      expect(tab.totalCount, 3);
      tab.clearKinds();
      expect(tab.entries, hasLength(3));
    });

    test('History back and forward, like Windows Explorer', () {
      final a = p.join(root, 'A');
      final b = p.join(a, 'B');
      final c = p.join(root, 'C');
      tab.open(a);
      tab.open(b);
      expect(tab.canGoForward, isFalse);
      expect(tab.goBack(), isTrue);
      expect(tab.path, a);
      expect(tab.goForward(), isTrue);
      expect(tab.path, b);
      tab.goBack();
      tab.open(c);
      expect(
        tab.canGoForward,
        isFalse,
        reason: 'Abrir otra carpeta borra adelante',
      );
      expect(tab.goBack(), isTrue);
      expect(tab.path, a);
    });

    test('System back uses history, then goes up, then leaves', () {
      final deep = BrowserController(
        path: p.join(root, 'Download', 'Facturas'),
        engine: engine,
      );
      expect(deep.canGoBack, isFalse);
      expect(deep.handleSystemBack(), isTrue);
      expect(deep.path, p.join(root, 'Download'));
      expect(deep.handleSystemBack(), isTrue, reason: 'Ahora hay historial');
      expect(deep.path, p.join(root, 'Download', 'Facturas'));
      deep.dispose();
      expect(tab.handleSystemBack(), isFalse);
    });

    test('Each storage device is its own root', () {
      final music = p.join(sd, 'Music');
      tab.open(music);
      expect(tab.volume.kind, VolumeKind.sd);
      expect(tab.trail, [sd, music]);
      expect(tab.goUp(), isTrue);
      expect(tab.path, sd);
      expect(tab.goUp(), isFalse);

      tab.open('/data/data');
      expect(tab.path, root, reason: 'Fuera de las memorias va a Interno');
      expect(volumes.indexedRoots, [root, sd]);
    });

    test('The system root holds every storage device but they win', () {
      const system = StorageVolume(
        path: '/',
        label: '',
        kind: VolumeKind.system,
      );
      volumes.volumes = [...volumes.volumes, system];
      expect(volumes.volumeOf('$root/Download').kind, VolumeKind.internal);
      expect(volumes.volumeOf('$sd/Music').kind, VolumeKind.sd);
      expect(volumes.volumeOf('/system/bin').kind, VolumeKind.system);
      expect(volumes.indexedRoots, [root, sd]);
      expect(volumes.home, root, reason: 'Recién instalada abre en Interno');

      // Interno es una carpeta de la ruta desde la raíz, no un lugar aparte.
      final dcim = p.join(root, 'DCIM');
      final deep = BrowserController(path: dcim, engine: engine);
      final storage = p.join('/', 'storage');
      final emulated = p.join(storage, 'emulated');
      expect(
        deep.trail.map(p.normalize),
        ['/', storage, emulated, root, dcim].map(p.normalize),
      );
      expect(deep.atVolumeRoot, isFalse);
      expect(deep.goUp(), isTrue);
      expect(deep.atVolumeRoot, isTrue);
      expect(deep.canGoUp, isTrue, reason: 'Desde Interno se sube a la raíz');
      deep.dispose();
      expect(
        volumes.isAvailable('/storage/GONE-1234/Music'),
        isFalse,
        reason: 'Una memoria quitada ya no existe',
      );
    });

    test('Showing hidden files reloads the folder', () async {
      tab.reload();
      expect(engine.lastShowHidden, isFalse);
      settings.setShowHidden(true);
      expect(engine.lastShowHidden, isTrue);
    });

    test(
      'Selection: toggle, select all, back clears, navigating clears',
      () async {
        tab.reload();
        engine.listings[root]!.add([
          _entry('$root/a.pdf'),
          _entry('$root/b.jpg'),
          _entry('$root/Docs', isDir: true),
        ]);
        await pumpEventQueue();
        tab.toggleSelection('$root/a.pdf');
        expect(tab.selecting, isTrue);
        expect(tab.canHandleBack, isTrue);
        tab.selectAll();
        expect(tab.selectedEntries, hasLength(3));
        tab.toggleSelection('$root/a.pdf');
        expect(tab.selected, hasLength(2));
        expect(tab.handleSystemBack(), isTrue);
        expect(tab.selecting, isFalse);
        expect(tab.path, root, reason: 'Atrás solo soltó la selección');

        tab.toggleSelection('$root/b.jpg');
        tab.open(p.join(root, 'Docs'));
        expect(tab.selecting, isFalse);
      },
    );

    test(
      'Dragging selects a span that shrinks when the finger goes back',
      () async {
        tab.reload();
        engine.listings[root]!.add([
          for (final name in ['a', 'b', 'c', 'd', 'e'])
            _entry('$root/$name.txt'),
        ]);
        await pumpEventQueue();
        String name(String path) => p.basenameWithoutExtension(path);

        tab.toggleSelection('$root/e.txt');
        tab.startDragSelection(1);
        tab.updateDragSelection(3);
        expect(tab.selected.map(name), unorderedEquals(['b', 'c', 'd', 'e']));
        tab.updateDragSelection(2);
        expect(
          tab.selected.map(name),
          unorderedEquals(['b', 'c', 'e']),
          reason: 'Al regresar, d vuelve a como estaba',
        );
        tab.updateDragSelection(0);
        expect(tab.selected.map(name), unorderedEquals(['a', 'b', 'e']));
        tab.endDragSelection();

        // Empezar sobre algo seleccionado desmarca el tramo.
        tab.startDragSelection(0);
        tab.updateDragSelection(1);
        expect(tab.selected.map(name), ['e']);
        tab.endDragSelection();
      },
    );

    test('A quiet refresh keeps the list until the new one is ready', () async {
      tab.reload();
      engine.listings[root]!.add([
        _entry('$root/a.txt'),
        _entry('$root/b.txt'),
      ]);
      await engine.listings[root]!.close();
      await pumpEventQueue();
      tab
        ..toggleSelection('$root/a.txt')
        ..toggleSelection('$root/b.txt');

      tab.refreshQuietly();
      engine.listings[root]!.add([
        _entry('$root/a.txt'),
        _entry('$root/c.txt'),
      ]);
      await pumpEventQueue();
      expect(tab.entries.map((e) => e.name), [
        'a.txt',
        'b.txt',
      ], reason: 'No se vacía mientras lee');
      await engine.listings[root]!.close();
      await pumpEventQueue();
      expect(tab.entries.map((e) => e.name), ['a.txt', 'c.txt']);
      expect(tab.selected, {'$root/a.txt'}, reason: 'b.txt ya no existe');
    });

    test('An unreadable folder is marked as failed', () async {
      final data = p.join(root, 'Android', 'data');
      tab.open(data);
      engine.listings[data]!.addError(Exception('Permission denied'));
      await engine.listings[data]!.close();
      await pumpEventQueue();
      expect(tab.failed, isTrue);
      expect(tab.entries, isEmpty);
    });
  });

  test('ExplorerController opens, selects and closes tabs', () {
    final explorer = ExplorerController(
      engine: engine,
      permissionGranted: true,
    );
    expect(explorer.tabs, hasLength(1));
    explorer.close(0);
    expect(explorer.tabs, hasLength(1), reason: 'Siempre queda una');

    explorer.newTab(p.join(root, 'DCIM'));
    expect(explorer.tabs, hasLength(2));
    expect(explorer.activeIndex, 1);
    expect(explorer.active.path, p.join(root, 'DCIM'));

    explorer.select(0);
    expect(explorer.active.path, root);
    explorer.close(0);
    expect(explorer.active.path, p.join(root, 'DCIM'));
    explorer.dispose();
  });

  test('Each tab keeps its own view, sort and filter', () {
    final explorer = ExplorerController(
      engine: engine,
      permissionGranted: true,
    );
    final first = explorer.active
      ..setViewMode(BrowserViewMode.grid)
      ..tapSort(SortField.modified)
      ..tapSort(SortField.modified)
      ..toggleKind(FileKind.pdf);

    explorer.newTab(p.join(root, 'DCIM'));
    final second = explorer.active;
    expect(second.viewMode, BrowserViewMode.grid, reason: 'Copia la vista');
    expect(second.sortField, SortField.modified);
    expect(second.ascending, isFalse);
    expect(second.kindFilter, isEmpty, reason: 'El filtro no se copia');

    second
      ..setViewMode(BrowserViewMode.details)
      ..tapSort(SortField.name);
    expect(first.viewMode, BrowserViewMode.grid);
    expect(first.sortField, SortField.modified);
    expect(first.kindFilter, {FileKind.pdf});
    explorer.dispose();
  });

  test('Tab options survive being saved and read back', () {
    const saved = TabListOptions(
      viewMode: BrowserViewMode.gallery,
      sortField: SortField.size,
      ascending: false,
      kinds: {FileKind.image},
    );
    final back = TabListOptions.fromMap(saved.toMap(), const TabListOptions());
    expect(back.viewMode, BrowserViewMode.gallery);
    expect(back.sortField, SortField.size);
    expect(back.ascending, isFalse);
    expect(back.kinds, {FileKind.image});

    final odd = TabListOptions.fromMap({
      'view': 'old',
      'kinds': ['image', 'gone'],
    }, const TabListOptions(sortField: SortField.kind));
    expect(odd.viewMode, BrowserViewMode.list);
    expect(odd.sortField, SortField.kind);
    expect(odd.kinds, {FileKind.image});
  });

  test('Changes from another app refresh only the open folder', () async {
    final explorer = ExplorerController(
      engine: engine,
      permissionGranted: true,
    );
    explorer.active.reload();
    await engine.listings[root]!.close();
    await pumpEventQueue();

    var listing = engine.listings[root];
    FolderWatchService().emit({p.join(sd, 'foto.jpg')});
    await pumpEventQueue();
    expect(engine.listings[root], same(listing), reason: 'Otra carpeta');

    FolderWatchService().emit({p.join(root, 'foto.jpg')});
    await pumpEventQueue();
    expect(engine.listings[root], isNot(same(listing)));
    explorer.dispose();
  });

  test('UsageTabController keeps a way back up to the root', () {
    final usage = UsageTabController();
    final dcim = p.join(root, 'DCIM');
    final camera = p.join(dcim, 'Camera');
    usage.show(camera);
    expect(usage.trail, [root, dcim, camera]);
    expect(usage.goBack(), isTrue);
    expect(usage.path, dcim);
    usage.open(camera);
    expect(usage.path, camera);
    usage.show(sd);
    expect(usage.canGoBack, isFalse);
    usage.dispose();
  });

  test('formatBytes', () {
    expect(formatBytes(512, 'en'), '512 B');
    expect(formatBytes(1536, 'en'), '1.5 KB');
    expect(formatBytes(1536, 'es'), '1,5 KB');
    expect(formatBytes(150 * 1024 * 1024, 'en'), '150 MB');
    expect(formatBytes(3 * 1024 * 1024 * 1024, 'en'), '3 GB');
  });
}
