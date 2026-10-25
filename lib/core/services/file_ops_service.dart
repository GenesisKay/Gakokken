import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../src/rust/api/ops.dart' as ops;
import 'favorites_service.dart';
import 'file_changes.dart';
import 'index_service.dart';

export '../../src/rust/api/ops.dart' show ConflictPolicy, NewFolderStatus;

enum ClipboardMode { copy, cut }

/// Una tarea de copiar o mover, con su progreso.
class FileJob {
  FileJob(this.id, this.isMove, this.destDir, this.total);

  final int id;
  final bool isMove;
  final String destDir;
  final int total;
  ops.JobProgress? progress;

  double get fraction {
    final p = progress;
    if (p == null || p.totalBytes == 0) return 0;
    return (p.doneBytes / p.totalBytes).clamp(0, 1);
  }
}

class JobResult {
  const JobResult({
    required this.done,
    required this.failed,
    required this.cancelled,
  });

  final int done;
  final List<String> failed;
  final bool cancelled;
}

/// Pregunta qué hacer con los nombres que ya existen en el destino. null es
/// cancelar todo.
typedef ConflictResolver =
    Future<ops.ConflictPolicy?> Function(List<String> names);

/// Portapapeles de Gakoken (copiar o cortar, sirve entre pestañas) y tareas
/// de copiar y mover. Las tareas van una tras otra; el motor Rust las corre
/// con progreso y se pueden cancelar.
class FileOpsService extends ChangeNotifier {
  static final FileOpsService _instance = FileOpsService._internal();
  factory FileOpsService() => _instance;
  FileOpsService._internal();

  List<String> _clipboard = const [];
  ClipboardMode? _mode;
  FileJob? _job;
  int _nextId = 1;
  Future<void> _queue = Future.value();

  List<String> get clipboard => _clipboard;
  ClipboardMode? get clipboardMode => _mode;

  /// Tarea en curso, o null.
  FileJob? get job => _job;

  void setClipboard(List<String> paths, ClipboardMode mode) {
    _clipboard = List.unmodifiable(paths);
    _mode = mode;
    notifyListeners();
  }

  void clearClipboard() {
    _clipboard = const [];
    _mode = null;
    notifyListeners();
  }

  /// Pega el portapapeles en [destDir]. Al terminar de mover, se vacía.
  Future<JobResult?> paste(String destDir, ConflictResolver resolve) async {
    final sources = _clipboard;
    final mode = _mode;
    if (sources.isEmpty || mode == null) return null;
    final isMove = mode == ClipboardMode.cut;
    return transfer(
      sources,
      destDir,
      isMove: isMove,
      resolve: resolve,
      // Lo cortado se pega una sola vez; si se cancela la pregunta, sigue ahí.
      onAccepted: isMove ? clearClipboard : null,
    );
  }

  /// Copia o mueve [sources] dentro de [destDir]. Si ya hay nombres iguales,
  /// pregunta con [resolve] antes de empezar.
  Future<JobResult?> transfer(
    List<String> sources,
    String destDir, {
    required bool isMove,
    required ConflictResolver resolve,
    VoidCallback? onAccepted,
  }) async {
    final conflicts = await ops.findConflicts(
      sources: sources,
      destDir: destDir,
    );
    // Pegar en la misma carpeta al copiar siempre crea una copia nueva.
    final sameFolder = sources.every((s) => p.equals(p.dirname(s), destDir));
    var policy = ops.ConflictPolicy.keepBoth;
    if (conflicts.isNotEmpty && !sameFolder) {
      final chosen = await resolve(conflicts);
      if (chosen == null) return null;
      policy = chosen;
    }
    onAccepted?.call();
    // Una tarea a la vez: la nueva espera a que termine la anterior.
    final result = _queue.then(
      (_) => _run(sources, destDir, isMove: isMove, policy: policy),
    );
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<JobResult> _run(
    List<String> sources,
    String destDir, {
    required bool isMove,
    required ops.ConflictPolicy policy,
  }) async {
    final job = FileJob(_nextId++, isMove, destDir, sources.length);
    _job = job;
    notifyListeners();
    var result = const JobResult(done: 0, failed: [], cancelled: false);
    try {
      await for (final progress in ops.transfer(
        jobId: job.id,
        sources: sources,
        destDir: destDir,
        isMove: isMove,
        conflict: policy,
      )) {
        job.progress = progress;
        notifyListeners();
        if (progress.finished) {
          result = JobResult(
            done: progress.created.length,
            failed: progress.failed,
            cancelled: progress.cancelled,
          );
          await _afterTransfer(sources, destDir, isMove, progress.created);
        }
      }
    } catch (e) {
      result = JobResult(
        done: 0,
        failed: [for (final s in sources) p.basename(s)],
        cancelled: false,
      );
    } finally {
      _job = null;
      notifyListeners();
    }
    return result;
  }

  Future<void> _afterTransfer(
    List<String> sources,
    String destDir,
    bool isMove,
    List<String> created,
  ) async {
    final dirs = {destDir};
    if (isMove) {
      final byName = {for (final c in created) p.basename(c): c};
      for (final source in sources) {
        dirs.add(p.dirname(source));
        final moved = byName[p.basename(source)];
        if (moved != null) await FavoritesService().relocate(source, moved);
      }
    }
    FileChanges.notify(dirs);
    await IndexService().refreshPaths([...created, if (isMove) ...sources]);
  }

  void cancel() {
    final job = _job;
    if (job != null) ops.cancelJob(jobId: job.id);
  }

  /// Crea la carpeta [name] dentro de [parentDir]. No toca el portapapeles.
  Future<ops.NewFolderStatus> createFolder(String parentDir, String name) async {
    final status = await ops.createFolder(parentDir: parentDir, name: name);
    if (status == ops.NewFolderStatus.created) {
      FileChanges.notify({parentDir});
      await IndexService().refreshPaths([p.join(parentDir, name.trim())]);
    }
    return status;
  }

  /// Cambia el nombre de [path]. Lanza error si no es válido o ya existe.
  Future<String> rename(String path, String newName) async {
    final renamed = await ops.renamePath(path: path, newName: newName);
    await FavoritesService().relocate(path, renamed);
    FileChanges.notify({p.dirname(path)});
    await IndexService().refreshPaths([path, renamed]);
    return renamed;
  }
}
