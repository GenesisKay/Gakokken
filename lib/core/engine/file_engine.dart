import '../files/file_entry.dart';

/// Interfaz del motor para listar carpetas: lo único que las pantallas usan
/// para leer archivos (ver Gakoken-Arquitectura en el vault). La implementa
/// `RustFileEngine`; las pruebas usan una falsa.
abstract interface class FileEngine {
  /// Se fija en `main` después de cargar el motor Rust.
  static late FileEngine instance;

  /// Contenido de una carpeta, por partes: las primeras entradas llegan en
  /// cuanto se leen. Una entrada puede volver a llegar con más datos (por
  /// ejemplo el [FileEntry.childCount] de una carpeta); la clave es la ruta.
  /// Si la carpeta no se puede leer, el stream termina con un error.
  /// Sin [showHidden], se omiten los nombres que empiezan con punto.
  Stream<List<FileEntry>> list(String path, {bool showHidden = false});

  Future<bool> exists(String path);
}
