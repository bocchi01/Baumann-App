import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../auth/firebase_auth_repository.dart' as firebase_auth;
import '../models/user_model.dart';
import '../navigation/app_router.dart';
import '../screens/main_screen.dart';
import '../screens/onboarding_screen.dart';

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  final bool isLoading;
  final UserModel? user;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final Provider<IAuthRepository> authRepositoryProvider =
    Provider<IAuthRepository>((Ref ref) => firebase_auth.FirebaseAuthRepository());

final NotifierProvider<AuthController, AuthState> authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final UserModel user = await ref
          .read(authRepositoryProvider)
          .signInWithEmail(email, password);
      state = state.copyWith(isLoading: false, user: user, clearError: true);
      _navigateToHome(user);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapError(error),
      );
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final UserModel user = await ref
          .read(authRepositoryProvider)
          .registerWithEmail(email, password);
      state = state.copyWith(isLoading: false, user: user, clearError: true);
      _navigateToOnboarding();
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapError(error),
      );
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  void _navigateToHome(UserModel user) {
    final NavigatorState? navigator = appNavigatorKey.currentState;
    navigator?.pushAndRemoveUntil(
      MaterialPageRoute<MainScreen>(
        builder: (BuildContext context) => const MainScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void _navigateToOnboarding() {
    final NavigatorState? navigator = appNavigatorKey.currentState;
    navigator?.pushAndRemoveUntil(
      MaterialPageRoute<OnboardingScreen>(
        builder: (BuildContext context) => const OnboardingScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<bool> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AuthState();
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapError(error),
      );
      return false;
    }
  }

  String _mapError(Object error) {
    final String description = error.toString();
    if (description.startsWith('Exception: ')) {
      return description.substring('Exception: '.length);
    }
    return description;
  }
}
