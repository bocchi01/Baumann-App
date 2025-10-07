// fake_repository.dart
// Repository con dati fittizi per la Home
// Fornisce dati coerenti per testing e sviluppo

import 'models.dart';

/// Repository fake per dati della Home
class FakeHomeRepository {
  /// Restituisce la sessione di oggi
  TodaySession getTodaySession() {
    return const TodaySession(
      title: 'Settimana 2 - Sessione 2',
      durationMin: 12,
      isCompleted: false,
      hasMissedSession: true, // Ha saltato una sessione
    );
  }

  /// Restituisce lo stato dei 7 giorni della settimana
  List<WeekDayStatus> getWeekStatus() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return <WeekDayStatus>[
      // Lunedì - completata
      WeekDayStatus(
        date: startOfWeek,
        status: WeekDayStatusValue.done,
      ),
      // Martedì - completata
      WeekDayStatus(
        date: startOfWeek.add(const Duration(days: 1)),
        status: WeekDayStatusValue.done,
      ),
      // Mercoledì - saltata
      WeekDayStatus(
        date: startOfWeek.add(const Duration(days: 2)),
        status: WeekDayStatusValue.skipped,
      ),
      // Giovedì - completata
      WeekDayStatus(
        date: startOfWeek.add(const Duration(days: 3)),
        status: WeekDayStatusValue.done,
      ),
      // Venerdì - oggi (pianificata)
      WeekDayStatus(
        date: startOfWeek.add(const Duration(days: 4)),
        status: WeekDayStatusValue.planned,
      ),
      // Sabato - pianificata
      WeekDayStatus(
        date: startOfWeek.add(const Duration(days: 5)),
        status: WeekDayStatusValue.planned,
      ),
      // Domenica - recupero
      WeekDayStatus(
        date: startOfWeek.add(const Duration(days: 6)),
        status: WeekDayStatusValue.recover,
      ),
    ];
  }

  /// Restituisce statistiche progresso
  ProgressStats getProgressStats() {
    return const ProgressStats(
      completed: 3,
      planned: 5,
      comfortTrend: ComfortTrendValue.better,
    );
  }

  /// Restituisce preferenze promemoria
  ReminderPref getReminder() {
    return const ReminderPref('Promemoria giornaliero alle 18:00', true);
  }

  /// Restituisce stato check-in quotidiano
  DailyCheckin getDailyCheckin() {
    return const DailyCheckin(
      hasCheckedInToday: false, // Non ha ancora fatto il check-in oggi
    );
  }
}
