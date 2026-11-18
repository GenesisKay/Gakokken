import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// Grupo de una fecha en las listas agrupadas por fecha (pedido el
/// 2026-10-29): Hoy, Ayer, Últimos 7 días y luego un grupo por mes, como en
/// las galerías. [rank] es mayor mientras más reciente.
class DateGroup {
  const DateGroup._(this.rank, this.month);

  static const _today = 1 << 30;
  static const _yesterday = _today - 1;
  static const _week = _today - 2;

  /// Para comparar y ordenar grupos: mayor es más reciente.
  final int rank;

  /// Primer día del mes, en los grupos por mes.
  final DateTime? month;

  /// El grupo de [date] visto desde [now]. Lo que tiene fecha futura cuenta
  /// como hoy.
  factory DateGroup.of(DateTime date, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final days = today.difference(day).inDays;
    if (days <= 0) return const DateGroup._(_today, null);
    if (days == 1) return const DateGroup._(_yesterday, null);
    if (days < 7) return const DateGroup._(_week, null);
    return DateGroup._(
      date.year * 12 + date.month,
      DateTime(date.year, date.month),
    );
  }

  String label(AppLocalizations l10n, String locale) {
    final month = this.month;
    if (month == null) {
      return switch (rank) {
        _today => l10n.dateGroupToday,
        _yesterday => l10n.dateGroupYesterday,
        _ => l10n.dateGroupWeek,
      };
    }
    final text = DateFormat.yMMMM(locale).format(month);
    return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
  }

  @override
  bool operator ==(Object other) => other is DateGroup && other.rank == rank;

  @override
  int get hashCode => rank.hashCode;
}

/// Tramo [start, end) de una lista que cae en un mismo [group].
class DateRun {
  const DateRun(this.group, this.start, this.end);

  final DateGroup group;
  final int start;
  final int end;
}

/// Tramos seguidos con el mismo grupo. La lista ya viene ordenada por grupo
/// (ver `sortEntries`), así que cada grupo sale una sola vez.
List<DateRun> dateRuns(List<DateTime> dates, DateTime now) {
  final runs = <DateRun>[];
  var start = 0;
  DateGroup? current;
  for (var i = 0; i < dates.length; i++) {
    final group = DateGroup.of(dates[i], now);
    if (group != current) {
      if (current != null) runs.add(DateRun(current, start, i));
      current = group;
      start = i;
    }
  }
  if (current != null) runs.add(DateRun(current, start, dates.length));
  return runs;
}
