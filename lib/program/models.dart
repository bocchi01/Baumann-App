// models.dart
// Modelli di dati per la sezione Programma
// Immutabili e fortemente tipizzati per affidabilità

/// Dati del programma personalizzato completo
class ProgramData {
  final String title;
  final String subtitle;
  final int totalWeeks;
  final int totalSessions;
  final int completedWeeks;
  final int completedSessions;
  final int avgSessionMinutes;

  const ProgramData({
    required this.title,
    required this.subtitle,
    required this.totalWeeks,
    required this.totalSessions,
    required this.completedWeeks,
    required this.completedSessions,
    required this.avgSessionMinutes,
  });

  /// Percentuale di completamento del programma (0.0 - 1.0)
  double get completionRatio =>
      totalWeeks > 0 ? completedWeeks / totalWeeks : 0.0;

  /// Percentuale di aderenza alle sessioni (0.0 - 1.0)
  double get adherenceRatio =>
      totalSessions > 0 ? completedSessions / totalSessions : 0.0;
}

/// Dati di una singola settimana del programma
class WeekData {
  final int weekNumber;
  final String phaseTitle;
  final String objective;
  final int sessionsTotal;
  final int sessionsCompleted;
  final int sessionDuration;

  const WeekData({
    required this.weekNumber,
    required this.phaseTitle,
    required this.objective,
    required this.sessionsTotal,
    required this.sessionsCompleted,
    required this.sessionDuration,
  });

  /// Rapporto di completamento della settimana (0.0 - 1.0)
  double get completionRatio =>
      sessionsTotal > 0 ? sessionsCompleted / sessionsTotal : 0.0;

  /// Indica se la settimana è completata al 100%
  bool get isCompleted => sessionsCompleted >= sessionsTotal;

  /// Indica se la settimana è in corso (almeno 1 sessione completata)
  bool get isInProgress => sessionsCompleted > 0 && !isCompleted;

  /// Indica se la settimana non è ancora iniziata
  bool get isNotStarted => sessionsCompleted == 0;
}
