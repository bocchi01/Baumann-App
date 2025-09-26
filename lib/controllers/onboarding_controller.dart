import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation/app_router.dart';
import '../screens/main_screen.dart';

class OnboardingState {
  const OnboardingState({
    this.goal,
    this.lifestyle,
    this.timeAvailability,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String? goal;
  final String? lifestyle;
  final String? timeAvailability;
  final bool isSubmitting;
  final String? errorMessage;

  bool get isComplete =>
      goal != null && lifestyle != null && timeAvailability != null;

  OnboardingState copyWith({
    String? goal,
    String? lifestyle,
    String? timeAvailability,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      goal: goal ?? this.goal,
      lifestyle: lifestyle ?? this.lifestyle,
      timeAvailability: timeAvailability ?? this.timeAvailability,
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

  void selectGoal(String goal) {
    state = state.copyWith(goal: goal, clearError: true);
  }

  void selectLifestyle(String lifestyle) {
    state = state.copyWith(lifestyle: lifestyle, clearError: true);
  }

  void selectTimeAvailability(String availability) {
    state = state.copyWith(timeAvailability: availability, clearError: true);
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
      await Future<void>.delayed(const Duration(seconds: 1));
    } finally {
      state = state.copyWith(isSubmitting: false);
    }

    final NavigatorState? navigator = appNavigatorKey.currentState;
    navigator?.pushAndRemoveUntil(
      MaterialPageRoute<MainScreen>(
        builder: (_) => const MainScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
