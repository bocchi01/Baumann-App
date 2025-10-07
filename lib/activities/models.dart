// models.dart
// Modelli di dati per la sezione Attività (diario operativo)
// Immutabili e fortemente tipizzati

/// Stato di un'attività/sessione
enum ActivityStatus {
  done('Completata'),
  skipped('Saltata'),
  stopped('Interrotta'),
  planned('Pianificata');

  const ActivityStatus(this.label);
  final String label;
}

/// Livello di comfort percepito post-sessione
enum ComfortLevel {
  worse('Peggio'),
  same('Invariato'),
  better('Meglio');

  const ComfortLevel(this.label);
  final String label;
}

/// Voce del registro attività
class ActivityEntry {
  final String id;
  final String title;
  final DateTime dateTime;
  final int durationMin;
  final ActivityStatus status;
  final ComfortLevel? comfort;
  final String? notes;

  const ActivityEntry({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.durationMin,
    required this.status,
    this.comfort,
    this.notes,
  });

  /// Formatta data in formato leggibile
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (entryDate == today) {
      return 'Oggi';
    } else if (entryDate == today.subtract(const Duration(days: 1))) {
      return 'Ieri';
    } else {
      final weekdays = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
      return '${weekdays[dateTime.weekday - 1]} ${dateTime.day}/${dateTime.month}';
    }
  }

  /// Formatta orario
  String get formattedTime {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Piano della giornata (cosa fare oggi)
class TodayPlan {
  final String nextSessionTitle;
  final int durationMin;
  final bool hasMissedSession;

  const TodayPlan({
    required this.nextSessionTitle,
    required this.durationMin,
    required this.hasMissedSession,
  });
}

/// Dati aderenza settimanale
class AdherenceData {
  final int completedThisWeek;
  final int plannedThisWeek;

  const AdherenceData(this.completedThisWeek, this.plannedThisWeek);

  /// Percentuale di aderenza (0.0 - 1.0)
  double get percent =>
      plannedThisWeek > 0 ? completedThisWeek / plannedThisWeek : 0.0;

  /// Percentuale formattata per UI
  String get percentFormatted => '${(percent * 100).round()}%';
}

/// Preferenze promemoria
class ReminderPref {
  final String label;
  final bool enabled;

  const ReminderPref(this.label, this.enabled);
}
