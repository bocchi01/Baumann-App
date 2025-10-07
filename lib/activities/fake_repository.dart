// fake_repository.dart
// Repository con dati fittizi per sezione Attività
// Fornisce dati coerenti per testing e sviluppo

import 'models.dart';

/// Repository fake per dati attività e diario
class FakeActivityRepository {
  /// Restituisce il piano di oggi (prossima sessione)
  TodayPlan getTodayPlan() {
    return const TodayPlan(
      nextSessionTitle: 'Settimana 2 - Sessione 2',
      durationMin: 12,
      hasMissedSession: false,
    );
  }

  /// Restituisce dati aderenza settimanale
  AdherenceData getAdherence() {
    return const AdherenceData(3, 4); // 3 su 4 completate questa settimana
  }

  /// Restituisce preferenze promemoria
  ReminderPref getReminder() {
    return const ReminderPref('Promemoria giornaliero alle 18:00', true);
  }

  /// Restituisce storico attività (ultime 10 voci)
  List<ActivityEntry> getActivities() {
    final now = DateTime.now();

    return <ActivityEntry>[
      // Oggi
      ActivityEntry(
        id: '1',
        title: 'Settimana 2 - Sessione 1',
        dateTime: DateTime(now.year, now.month, now.day, 18, 15),
        durationMin: 12,
        status: ActivityStatus.done,
        comfort: ComfortLevel.better,
        notes: 'Ottima sessione, movimenti più fluidi',
      ),

      // Ieri
      ActivityEntry(
        id: '2',
        title: 'Settimana 1 - Sessione 2',
        dateTime: DateTime(now.year, now.month, now.day - 1, 19, 30),
        durationMin: 10,
        status: ActivityStatus.done,
        comfort: ComfortLevel.better,
      ),

      // 2 giorni fa
      ActivityEntry(
        id: '3',
        title: 'Settimana 1 - Sessione 1',
        dateTime: DateTime(now.year, now.month, now.day - 2, 18, 0),
        durationMin: 10,
        status: ActivityStatus.done,
        comfort: ComfortLevel.same,
        notes: 'Prima sessione del programma',
      ),

      // 3 giorni fa - saltata
      ActivityEntry(
        id: '4',
        title: 'Ripasso Mobilità',
        dateTime: DateTime(now.year, now.month, now.day - 3, 18, 0),
        durationMin: 10,
        status: ActivityStatus.skipped,
      ),

      // 5 giorni fa
      ActivityEntry(
        id: '5',
        title: 'Valutazione Iniziale',
        dateTime: DateTime(now.year, now.month, now.day - 5, 17, 45),
        durationMin: 15,
        status: ActivityStatus.done,
        comfort: ComfortLevel.same,
        notes: 'Prima valutazione della mobilità',
      ),

      // 7 giorni fa
      ActivityEntry(
        id: '6',
        title: 'Sessione Introduttiva',
        dateTime: DateTime(now.year, now.month, now.day - 7, 19, 0),
        durationMin: 8,
        status: ActivityStatus.done,
        comfort: ComfortLevel.better,
      ),

      // 9 giorni fa - interrotta
      ActivityEntry(
        id: '7',
        title: 'Test Movimenti Base',
        dateTime: DateTime(now.year, now.month, now.day - 9, 18, 30),
        durationMin: 5,
        status: ActivityStatus.stopped,
        notes: 'Interrotta per impegno improvviso',
      ),

      // 10 giorni fa
      ActivityEntry(
        id: '8',
        title: 'Onboarding',
        dateTime: DateTime(now.year, now.month, now.day - 10, 20, 15),
        durationMin: 10,
        status: ActivityStatus.done,
        comfort: ComfortLevel.same,
      ),
    ];
  }

  /// Filtra attività per status
  List<ActivityEntry> filterByStatus(
    List<ActivityEntry> activities,
    ActivityStatus? status,
  ) {
    if (status == null) return activities;
    return activities.where((a) => a.status == status).toList();
  }
}
