import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/patient_repository.dart';
import '../models/onboarding_data.dart';
import '../models/patient_profile.dart';

/// Stato del questionario onboarding
class OnboardingState {
  final int currentStep;
  final OnboardingData data;
  final bool isLoading;
  final String? errorMessage;

  const OnboardingState({
    this.currentStep = 0,
    this.data = const OnboardingData(),
    this.isLoading = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    int? currentStep,
    OnboardingData? data,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Verifica se può avanzare allo step successivo
  bool get canProceedToNext {
    switch (currentStep) {
      case 0: // Goal
        return data.goal != null;
      case 1: // Lifestyle
        return data.lifestyle != null;
      case 2: // Time Availability
        return data.timeAvailability != null;
      case 3: // Pain Conditions (opzionale, sempre valido)
        return true;
      default:
        return false;
    }
  }

  /// Numero totale di step
  static const int totalSteps = 4;

  /// Progress percentuale (0.0 - 1.0)
  double get progress => (currentStep + 1) / totalSteps;
}

/// Provider del controller onboarding
final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
        OnboardingController.new);

/// Controller per gestire il flusso del questionario onboarding
class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  /// Avanza allo step successivo
  void nextStep() {
    if (state.currentStep < OnboardingState.totalSteps - 1 &&
        state.canProceedToNext) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  /// Torna allo step precedente
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Salta al passo specifico (per navigation diretta)
  void goToStep(int step) {
    if (step >= 0 && step < OnboardingState.totalSteps) {
      state = state.copyWith(currentStep: step);
    }
  }

  /// Seleziona obiettivo
  void setGoal(OnboardingGoal goal) {
    state = state.copyWith(
      data: state.data.copyWith(goal: goal),
    );
  }

  /// Seleziona lifestyle
  void setLifestyle(LifestyleType lifestyle) {
    state = state.copyWith(
      data: state.data.copyWith(lifestyle: lifestyle),
    );
  }

  /// Seleziona tempo disponibile
  void setTimeAvailability(TimeAvailability time) {
    state = state.copyWith(
      data: state.data.copyWith(timeAvailability: time),
    );
  }

  /// Toggle condizione di dolore (multi-select)
  void togglePainCondition(PainCondition condition) {
    final currentConditions = Set<PainCondition>.from(state.data.painConditions);

    // Se selezioniamo "Nessuno", rimuoviamo tutte le altre
    if (condition == PainCondition.none) {
      currentConditions.clear();
      currentConditions.add(PainCondition.none);
    } else {
      // Rimuovi "Nessuno" se presente
      currentConditions.remove(PainCondition.none);

      // Toggle la condizione selezionata
      if (currentConditions.contains(condition)) {
        currentConditions.remove(condition);
      } else {
        currentConditions.add(condition);
      }

      // Se rimane vuoto, aggiungi automaticamente "Nessuno"
      if (currentConditions.isEmpty) {
        currentConditions.add(PainCondition.none);
      }
    }

    state = state.copyWith(
      data: state.data.copyWith(painConditions: currentConditions),
    );
  }

  /// Imposta note aggiuntive
  void setAdditionalNotes(String notes) {
    state = state.copyWith(
      data: state.data.copyWith(additionalNotes: notes),
    );
  }

  /// Completa l'onboarding e salva su Firestore
  Future<bool> completeOnboarding() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = state.copyWith(
        errorMessage: 'Utente non autenticato. Effettua di nuovo l\'accesso.',
      );
      return false;
    }

    if (!state.data.isComplete) {
      state = state.copyWith(
        errorMessage: 'Completa tutte le domande obbligatorie prima di continuare.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Determina il percorso da assegnare
      final pathId = state.data.determinePathId();

      // Crea il profilo completo
      final profile = PatientProfile(
        uid: user.uid,
        email: user.email,
        onboardingCompleted: true,
        onboardingData: state.data,
        assignedPathId: pathId,
        updatedAt: DateTime.now(),
      );

      // Salva su Firestore
      final repository = PatientRepository();
      await repository.saveOnboardingData(user.uid, profile);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Errore durante il salvataggio: ${e.toString()}',
      );
      return false;
    }
  }

  /// Reset dello stato (per testing o retry)
  void reset() {
    state = const OnboardingState();
  }
}
