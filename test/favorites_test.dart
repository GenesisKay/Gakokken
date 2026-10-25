import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gakoken/core/services/favorites_service.dart';
import 'package:gakoken/core/storage/hive_bootstrap.dart';
import 'package:hive_ce/hive.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('gakoken_hive');
    Hive.init(dir.path);
    await Hive.openBox(HiveBootstrap.favoritesBox);
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('Add, list newest first, no duplicates, remove', () async {
    final favorites = FavoritesService();
    await favorites.add('/s/Download', isDir: true);
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await favorites.add('/s/Download/factura.pdf', isDir: false);
    await favorites.add('/s/Download', isDir: true);

    expect(favorites.all.map((f) => f.path), [
      '/s/Download/factura.pdf',
      '/s/Download',
    ]);
    expect(favorites.all.last.isDir, isTrue);
    expect(favorites.all.first.name, 'factura.pdf');
    expect(favorites.contains('/s/Download'), isTrue);

    await favorites.remove('/s/Download');
    expect(favorites.contains('/s/Download'), isFalse);
    expect(favorites.all, hasLength(1));
  });

  test('Paths longer than 255 characters are fine', () async {
    final longPath = '/s/${'a' * 300}.txt';
    await FavoritesService().add(longPath, isDir: false);
    expect(FavoritesService().contains(longPath), isTrue);
  });

  test(
    'Moving or renaming keeps favorites pointing to the new place',
    () async {
      final favorites = FavoritesService();
      final docs = p.join('s', 'Docs');
      await favorites.add(docs, isDir: true);
      await favorites.add(p.join(docs, 'factura.pdf'), isDir: false);
      await favorites.add(p.join('s', 'Docs2'), isDir: true);
      final archive = p.join('s', 'Archivo');
      await favorites.relocate(docs, archive);
      expect(favorites.contains(archive), isTrue);
      expect(favorites.contains(p.join(archive, 'factura.pdf')), isTrue);
      expect(
        favorites.contains(p.join('s', 'Docs2')),
        isTrue,
        reason: 'Solo el prefijo exacto',
      );
      expect(favorites.contains(docs), isFalse);
    },
  );

  test('Favorites survive closing the box', () async {
    await FavoritesService().add('/s/Music', isDir: true);
    await Hive.close();
    Hive.init(dir.path);
    await Hive.openBox(HiveBootstrap.favoritesBox);
    expect(FavoritesService().contains('/s/Music'), isTrue);
  });
}
