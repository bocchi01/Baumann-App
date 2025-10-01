import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation/app_router.dart';
import '../screens/main_screen.dart';

class OnboardingState {
  const OnboardingState({
    this.goal,
    this.lifestyle,
    this.time,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String? goal;
  final String? lifestyle;
  final String? time;
  final bool isSubmitting;
  final String? errorMessage;

  bool get isComplete => goal != null && lifestyle != null && time != null;

  OnboardingState copyWith({
    String? goal,
    String? lifestyle,
    String? time,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      goal: goal ?? this.goal,
      lifestyle: lifestyle ?? this.lifestyle,
      time: time ?? this.time,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final NotifierProvider<OnboardingController, OnboardingState>
    onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setGoal(String value) {
    state = state.copyWith(goal: value, clearError: true);
  }

  void setLifestyle(String value) {
    state = state.copyWith(lifestyle: value, clearError: true);
  }

  void setTime(String value) {
    state = state.copyWith(time: value, clearError: true);
  }

  Future<void> submitOnboarding() async {
    if (!state.isComplete) {
      state = state.copyWith(
        errorMessage: 'Completa tutte le domande per continuare.',
      );
      return;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception(
            'Utente non autenticato. Effettua di nuovo l\'accesso.');
      }

      final String? goal = state.goal;
      final String? lifestyle = state.lifestyle;
      final String? time = state.time;

      String assignedPathId;
      if (goal == 'prevenzione' && lifestyle == 'moderato') {
        assignedPathId = 'percorso_prevenzione_01';
      } else {
        assignedPathId = 'percorso_ufficio_01';
      }

      debugPrint('Decisione finale: Assegnato il percorso ID: $assignedPathId');
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(userId).set(
        <String, dynamic>{
          'onboardingAnswers': <String, dynamic>{
            'goal': goal,
            'lifestyle': lifestyle,
            'time': time,
          },
          'assignedPathId': assignedPathId,
          'onboardingCompletedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.code == 'permission-denied'
            ? 'Non riusciamo a salvare i tuoi dati. Attendi qualche minuto e riprova. Se il problema persiste contatta il supporto.'
            : (error.message ??
                'Si è verificato un errore imprevisto. Riprova più tardi.'),
      );
      return;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
      return;
    }

    state = state.copyWith(isSubmitting: false);

    final NavigatorState? navigator = appNavigatorKey.currentState;
    navigator?.pushAndRemoveUntil(
      MaterialPageRoute<MainScreen>(
        builder: (_) => const MainScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
