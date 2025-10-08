/// Modelli per i dati dell'onboarding multi-step

/// Obiettivo principale dell'utente
enum OnboardingGoal {
  prevention('Prevenzione', 'Mantenere una postura corretta e prevenire problemi futuri', '🛡️'),
  correction('Correzione', 'Correggere problemi posturali esistenti e ridurre il dolore', '🔧'),
  performance('Performance', 'Migliorare prestazioni atletiche e flessibilità', '🏃');

  const OnboardingGoal(this.label, this.description, this.emoji);

  final String label;
  final String description;
  final String emoji;
}

/// Stile di vita / livello di attività
enum LifestyleType {
  sedentary('Sedentario', 'Lavoro da scrivania, poca attività fisica', '💻'),
  moderate('Moderato', 'Alcune ore in piedi, attività fisica occasionale', '🚶'),
  active('Attivo', 'Lavoro fisico o allenamento regolare', '🏋️');

  const LifestyleType(this.label, this.description, this.emoji);

  final String label;
  final String description;
  final String emoji;
}

/// Tempo disponibile per gli esercizi quotidiani
enum TimeAvailability {
  five('5 minuti', 'Esercizi rapidi ed essenziali', 5),
  ten('10 minuti', 'Routine bilanciata', 10),
  fifteen('15 minuti', 'Sessione completa', 15),
  thirty('30+ minuti', 'Allenamento approfondito', 30);

  const TimeAvailability(this.label, this.description, this.minutes);

  final String label;
  final String description;
  final int minutes;
}

/// Condizioni di dolore preesistenti
enum PainCondition {
  none('Nessuno', 'Non ho dolori particolari'),
  neckShoulder('Collo e Spalle', 'Dolore o tensione nella zona cervicale'),
  lowerBack('Zona Lombare', 'Dolore alla parte bassa della schiena'),
  upperBack('Zona Dorsale', 'Dolore tra le scapole'),
  chronic('Dolore Cronico', 'Dolore persistente da più di 3 mesi');

  const PainCondition(this.label, this.description);

  final String label;
  final String description;
}

/// Dati completi dell'onboarding
class OnboardingData {
  final OnboardingGoal? goal;
  final LifestyleType? lifestyle;
  final TimeAvailability? timeAvailability;
  final Set<PainCondition> painConditions;
  final String? additionalNotes;

  const OnboardingData({
    this.goal,
    this.lifestyle,
    this.timeAvailability,
    this.painConditions = const {},
    this.additionalNotes,
  });

  /// Verifica se tutti i dati obbligatori sono completi
  bool get isComplete =>
      goal != null && lifestyle != null && timeAvailability != null;

  /// Converte in Map per Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (goal != null) 'goal': goal!.name,
      if (lifestyle != null) 'lifestyle': lifestyle!.name,
      if (timeAvailability != null)
        'timeAvailability': timeAvailability!.name,
      'painConditions': painConditions.map((e) => e.name).toList(),
      if (additionalNotes != null && additionalNotes!.isNotEmpty)
        'additionalNotes': additionalNotes,
    };
  }

  /// Crea un'istanza da documento Firestore
  factory OnboardingData.fromFirestore(Map<String, dynamic> data) {
    return OnboardingData(
      goal: data['goal'] != null
          ? OnboardingGoal.values.firstWhere(
              (e) => e.name == data['goal'],
              orElse: () => OnboardingGoal.prevention,
            )
          : null,
      lifestyle: data['lifestyle'] != null
          ? LifestyleType.values.firstWhere(
              (e) => e.name == data['lifestyle'],
              orElse: () => LifestyleType.moderate,
            )
          : null,
      timeAvailability: data['timeAvailability'] != null
          ? TimeAvailability.values.firstWhere(
              (e) => e.name == data['timeAvailability'],
              orElse: () => TimeAvailability.ten,
            )
          : null,
      painConditions: data['painConditions'] != null
          ? (data['painConditions'] as List)
              .map((e) => PainCondition.values.firstWhere(
                    (p) => p.name == e,
                    orElse: () => PainCondition.none,
                  ))
              .toSet()
          : {},
      additionalNotes: data['additionalNotes'] as String?,
    );
  }

  OnboardingData copyWith({
    OnboardingGoal? goal,
    LifestyleType? lifestyle,
    TimeAvailability? timeAvailability,
    Set<PainCondition>? painConditions,
    String? additionalNotes,
  }) {
    return OnboardingData(
      goal: goal ?? this.goal,
      lifestyle: lifestyle ?? this.lifestyle,
      timeAvailability: timeAvailability ?? this.timeAvailability,
      painConditions: painConditions ?? this.painConditions,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    );
  }

  /// Determina quale percorso assegnare in base alle risposte
  String determinePathId() {
    // Logica di assegnazione percorso basata su risposte
    
    // Se ha dolore cronico → percorso terapeutico
    if (painConditions.contains(PainCondition.chronic)) {
      return 'path_chronic_pain';
    }

    // Se è sedentario + prevenzione → percorso ufficio
    if (lifestyle == LifestyleType.sedentary &&
        goal == OnboardingGoal.prevention) {
      return 'path_office_worker';
    }

    // Se è attivo + performance → percorso athlete
    if (lifestyle == LifestyleType.active &&
        goal == OnboardingGoal.performance) {
      return 'path_athlete_performance';
    }

    // Se ha dolore specifico → percorso mirato
    if (painConditions.contains(PainCondition.lowerBack)) {
      return 'path_lower_back_focus';
    }

    if (painConditions.contains(PainCondition.neckShoulder)) {
      return 'path_neck_shoulder_focus';
    }

    // Default: percorso bilanciato generale
    return 'path_balanced_general';
  }
}
