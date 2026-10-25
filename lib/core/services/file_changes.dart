import 'dart:async';

/// Aviso de que el contenido de unas carpetas cambió (copiar, mover,
/// renombrar, papelera), para que las pantallas que las muestran se recarguen.
class FileChanges {
  FileChanges._();

  static final _controller = StreamController<Set<String>>.broadcast();

  /// Carpetas cuyo contenido cambió.
  static Stream<Set<String>> get stream => _controller.stream;

  static void notify(Iterable<String> dirs) => _controller.add(dirs.toSet());
}
