// fake_repository.dart
// Repository con dati fittizi per prototipazione
// Da sostituire con chiamate backend reali

import 'models.dart';

/// Repository fake per dati del programma
/// Fornisce dati coerenti per UI testing e sviluppo
class FakeProgramRepository {
  /// Restituisce i dati del programma personalizzato
  ProgramData getProgram() {
    return const ProgramData(
      title: 'Schiena Protetta — Ufficio',
      subtitle: '8 settimane per chi lavora seduto: comfort e mobilità',
      totalWeeks: 8,
      completedWeeks: 1,
      totalSessions: 20,
      completedSessions: 3,
      avgSessionMinutes: 11,
    );
  }

  /// Restituisce la lista delle settimane del programma
  List<WeekData> getWeeks() {
    return const <WeekData>[
      WeekData(
        weekNumber: 1,
        phaseTitle: 'MOBILITÀ E FONDAMENTA',
        objective: 'Alleggerire la zona lombare e migliorare l\'appoggio seduto',
        sessionsTotal: 2,
        sessionsCompleted: 2,
        sessionDuration: 10,
      ),
      WeekData(
        weekNumber: 2,
        phaseTitle: 'STABILITÀ E CORE',
        objective: 'Attivare i muscoli profondi per un supporto migliore',
        sessionsTotal: 3,
        sessionsCompleted: 1,
        sessionDuration: 12,
      ),
      WeekData(
        weekNumber: 3,
        phaseTitle: 'CONTROLLO MOTORIO',
        objective: 'Migliorare la coordinazione nei movimenti quotidiani',
        sessionsTotal: 3,
        sessionsCompleted: 0,
        sessionDuration: 15,
      ),
      WeekData(
        weekNumber: 4,
        phaseTitle: 'FORZA FUNZIONALE',
        objective: 'Costruire resistenza per attività prolungate',
        sessionsTotal: 3,
        sessionsCompleted: 0,
        sessionDuration: 18,
      ),
      WeekData(
        weekNumber: 5,
        phaseTitle: 'INTEGRAZIONE DINAMICA',
        objective: 'Applicare le competenze a movimenti complessi',
        sessionsTotal: 3,
        sessionsCompleted: 0,
        sessionDuration: 20,
      ),
      WeekData(
        weekNumber: 6,
        phaseTitle: 'RESILIENZA E ADATTAMENTO',
        objective: 'Preparare il corpo a gestire variazioni e stress',
        sessionsTotal: 2,
        sessionsCompleted: 0,
        sessionDuration: 15,
      ),
      WeekData(
        weekNumber: 7,
        phaseTitle: 'CONSOLIDAMENTO',
        objective: 'Rinforzare le abitudini acquisite',
        sessionsTotal: 2,
        sessionsCompleted: 0,
        sessionDuration: 12,
      ),
      WeekData(
        weekNumber: 8,
        phaseTitle: 'AUTONOMIA E MANTENIMENTO',
        objective: 'Prepararti a continuare in autonomia',
        sessionsTotal: 2,
        sessionsCompleted: 0,
        sessionDuration: 10,
      ),
    ];
  }

  /// Restituisce i dati della prossima sessione da completare
  /// Ritorna null se tutte le sessioni sono completate
  WeekData? getNextSession() {
    final weeks = getWeeks();
    for (final week in weeks) {
      if (!week.isCompleted) {
        return week;
      }
    }
    return null;
  }
}
