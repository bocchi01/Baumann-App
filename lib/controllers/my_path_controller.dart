import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_session.dart';
import '../models/path_module.dart';
import '../models/posture_path.dart';
import '../path/firestore_path_repository.dart';

class MyPathState {
  const MyPathState({
    this.isLoading = false,
    this.path,
    this.completedSessionIds = const <String>{},
    this.errorMessage,
  });

  final bool isLoading;
  final PosturePath? path;
  final Set<String> completedSessionIds;
  final String? errorMessage;

  bool get hasData => path != null;

  MyPathState copyWith({
    bool? isLoading,
    PosturePath? path,
    bool clearPath = false,
    Set<String>? completedSessionIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MyPathState(
      isLoading: isLoading ?? this.isLoading,
      path: clearPath ? null : path ?? this.path,
      completedSessionIds: completedSessionIds ?? this.completedSessionIds,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final NotifierProvider<MyPathController, MyPathState> myPathControllerProvider =
    NotifierProvider<MyPathController, MyPathState>(MyPathController.new);

class MyPathController extends Notifier<MyPathState> {
  @override
  MyPathState build() {
    return const MyPathState();
  }

  Future<void> fetchPath() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final IPathRepository repository = ref.read(pathRepositoryProvider);
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('Utente non autenticato.');
      }

      final PosturePath path = await repository.fetchUserPath(userId);
      final Set<String> completedSessionIds =
          await repository.getCompletedSessionIds();

      state = state.copyWith(
        isLoading: false,
        path: path,
        completedSessionIds: completedSessionIds,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapError(error),
      );
    }
  }

  bool isSessionCompleted(String sessionId) {
    return state.completedSessionIds.contains(sessionId);
  }

  String? resolveNextSessionId() {
    final PosturePath? path = state.path;
    if (path == null) {
      return null;
    }

    for (final PathModule module in path.modules) {
      for (final DailySession session in module.sessions) {
        if (!state.completedSessionIds.contains(session.id)) {
          return session.id;
        }
      }
    }
    return null;
  }

  String _mapError(Object error) {
    final String message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }
}
