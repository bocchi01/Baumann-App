// models.dart
// Modelli di dati per la Home (cruscotto motivazionale)
// Immutabili e fortemente tipizzati

/// Stato di un giorno nella week strip
enum WeekDayStatusValue {
  done('Completata'),
  skipped('Saltata'),
  planned('Pianificata'),
  recover('Recupero');

  const WeekDayStatusValue(this.label);
  final String label;
}

/// Trend del comfort percepito
enum ComfortTrendValue {
  better('Migliore'),
  same('Invariato'),
  worse('Peggiore');

  const ComfortTrendValue(this.label);
  final String label;
}

/// Come ti senti oggi? (per check-in quotidiano)
enum DailyFeelingValue {
  good('Bene'),
  stiff('Un po\' rigido/a'),
  sore('Dolorante');

  const DailyFeelingValue(this.label);
  final String label;
}

/// Sessione di oggi (azione principale)
class TodaySession {
  final String title;
  final int durationMin;
  final bool isCompleted;
  final bool hasMissedSession;

  const TodaySession({
    required this.title,
    required this.durationMin,
    required this.isCompleted,
    required this.hasMissedSession,
  });
}

/// Stato di un giorno nella settimana
class WeekDayStatus {
  final DateTime date;
  final WeekDayStatusValue status;

  const WeekDayStatus({
    required this.date,
    required this.status,
  });

  /// Nome giorno abbreviato (Lun, Mar, ecc.)
  String get dayName {
    const days = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    return days[date.weekday - 1];
  }

  /// Numero giorno del mese
  int get dayNumber => date.day;

  /// È oggi?
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// Statistiche progresso settimanale
class ProgressStats {
  final int completed;
  final int planned;
  final ComfortTrendValue comfortTrend;

  const ProgressStats({
    required this.completed,
    required this.planned,
    required this.comfortTrend,
  });

  /// Percentuale completamento (0.0 - 1.0)
  double get completionRatio =>
      planned > 0 ? completed / planned : 0.0;

  /// Percentuale formattata
  String get percentFormatted => '${(completionRatio * 100).round()}%';
}

/// Preferenze promemoria
class ReminderPref {
  final String label;
  final bool enabled;

  const ReminderPref(this.label, this.enabled);
}

/// Stato check-in quotidiano
class DailyCheckin {
  final bool hasCheckedInToday;
  final DailyFeelingValue? todayFeeling;

  const DailyCheckin({
    required this.hasCheckedInToday,
    this.todayFeeling,
  });
}
