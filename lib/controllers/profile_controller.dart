import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../models/user_model.dart';
import 'auth_controller.dart';

class ProfileState {
  const ProfileState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
}

final NotifierProvider<ProfileController, ProfileState>
    profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);

class ProfileController extends Notifier<ProfileState> {
  bool _initialized = false;

  IAuthRepository get _authRepository => ref.read(authRepositoryProvider);

  @override
  ProfileState build() {
    ref.listen<AuthState>(authControllerProvider, (AuthState? prev, AuthState next) {
      if (next.user != prev?.user) {
        state = ProfileState(user: next.user, isLoading: false);
      }
    });

    if (!_initialized) {
      _initialized = true;
      _loadCurrentUser();
      return const ProfileState(isLoading: true);
    }

    return state;
  }

  Future<void> refresh() async {
    state = ProfileState(user: state.user, isLoading: true);
    await _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final UserModel? user = await _authRepository.getCurrentUser();
      state = ProfileState(user: user, isLoading: false);
    } catch (error) {
      state = ProfileState(
        user: state.user,
        isLoading: false,
        errorMessage: _mapError(error),
      );
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
