import 'file_kind.dart';

/// Un archivo o carpeta tal como lo entrega el motor.
class FileEntry {
  const FileEntry({
    required this.path,
    required this.name,
    required this.isDir,
    required this.size,
    required this.modified,
    this.childCount,
  });

  final String path;
  final String name;
  final bool isDir;

  /// Bytes del archivo. En carpetas, lo que ocupan con sus subcarpetas según
  /// el índice (0 si todavía no hay índice).
  final int size;
  final DateTime modified;

  /// Elementos visibles dentro de una carpeta. Llega después del resto del
  /// listado (es más lento de contar); null mientras tanto o si no se pudo leer.
  final int? childCount;

  FileKind get kind => FileKind.fromName(name, isDir: isDir);
}
