import 'package:flutter/foundation.dart';

import 'index_service.dart';

/// Si la app está cargando algo en segundo plano (miniaturas, poner al día
/// el índice): la barra de arriba muestra una ruedita chica mientras tanto,
/// sin tapar nada (pedido el 2026-10-29). El primer indexado no cuenta:
/// ese tiene su propio aviso con el número de archivos.
class ActivityService extends ChangeNotifier {
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal() {
    _index.addListener(_onIndex);
    _indexBusy = _indexUpdating;
  }

  final _index = IndexService();
  int _tasks = 0;
  bool _indexBusy = false;

  bool get _indexUpdating => _index.indexing && _index.ready;

  bool get busy => _tasks > 0 || _indexBusy;

  /// Cuenta [work] mientras corre.
  Future<T> track<T>(Future<T> work) async {
    final was = busy;
    _tasks++;
    if (!was) notifyListeners();
    try {
      return await work;
    } finally {
      _tasks--;
      if (!busy) notifyListeners();
    }
  }

  void _onIndex() {
    final updating = _indexUpdating;
    if (updating == _indexBusy) return;
    final was = busy;
    _indexBusy = updating;
    if (busy != was) notifyListeners();
  }
}
