import 'dart:io';

import 'package:path/path.dart' as p;

import '../services/storage_volumes_service.dart';

/// Una ruta que existe: carpeta o archivo.
typedef PathTarget = ({String path, bool isDir});

/// Lee una ruta pegada o escrita (en el buscador o en "Ir a una ruta"):
/// quita espacios y comillas de los lados, acepta `file://` y la barra del
/// final. null si no parece una ruta completa.
String? parsePathInput(String text) {
  var s = text.trim();
  if (s.length >= 2 &&
      ((s.startsWith('"') && s.endsWith('"')) ||
          (s.startsWith("'") && s.endsWith("'")))) {
    s = s.substring(1, s.length - 1).trim();
  }
  if (s.startsWith('file://')) {
    try {
      s = Uri.parse(s).toFilePath();
    } on Object {
      return null;
    }
  }
  if (s.isEmpty || s.contains('\n') || !p.isAbsolute(s)) return null;
  return p.normalize(s);
}

/// Por qué no se puede ir a una ruta.
enum PathProblem { notFound, unavailable }

/// Busca la ruta de [text]. Devuelve la carpeta o el archivo, o el problema
/// si no existe o queda fuera de lo que Explorar puede abrir.
Future<(PathTarget?, PathProblem?)> lookUpPath(String text) async {
  final path = parsePathInput(text);
  if (path == null) return (null, PathProblem.notFound);
  final type = await FileSystemEntity.type(path);
  final PathTarget target;
  switch (type) {
    case FileSystemEntityType.directory:
      target = (path: path, isDir: true);
    case FileSystemEntityType.file:
      target = (path: path, isDir: false);
    default:
      return (null, PathProblem.notFound);
  }
  final folder = target.isDir ? path : p.dirname(path);
  if (!StorageVolumesService().isAvailable(folder)) {
    return (null, PathProblem.unavailable);
  }
  return (target, null);
}
