import 'dart:io';

import '../../src/rust/api/engine.dart' as rust;
import '../files/file_entry.dart';
import 'file_engine.dart';

/// Motor en Rust (`rust/src/api/engine.rs`), elegido en la Fase 1.
class RustFileEngine implements FileEngine {
  @override
  Stream<List<FileEntry>> list(String path, {bool showHidden = false}) => rust
      .listDir(path: path, showHidden: showHidden)
      .map((batch) => batch.map(fileEntryOf).toList());

  @override
  Future<bool> exists(String path) async =>
      await FileSystemEntity.type(path) != FileSystemEntityType.notFound;
}

FileEntry fileEntryOf(rust.FileItem item) => FileEntry(
  path: item.path,
  name: item.name,
  isDir: item.isDir,
  size: item.size,
  modified: DateTime.fromMillisecondsSinceEpoch(item.modifiedSecs * 1000),
  childCount: item.childCount,
);
