import 'package:intl/intl.dart';

const _units = ['B', 'KB', 'MB', 'GB', 'TB'];

/// Tamaño legible con base 1024: `512 B`, `1.5 KB`, `2.3 GB`. Los decimales
/// siguen el idioma (`1,5 KB` en español).
String formatBytes(int bytes, String locale) {
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < _units.length - 1) {
    value /= 1024;
    unit++;
  }
  final pattern = unit == 0 || value >= 100 ? '0' : '0.#';
  return '${NumberFormat(pattern, locale).format(value)} ${_units[unit]}';
}

/// Fecha corta para listas: `12 oct 2026`.
String formatDate(DateTime date, String locale) =>
    DateFormat.yMMMd(locale).format(date);
