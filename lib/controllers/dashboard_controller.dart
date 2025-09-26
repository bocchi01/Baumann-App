import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import 'auth_controller.dart' show authRepositoryProvider;
import '../models/daily_session.dart';
import '../models/path_module.dart';
import '../models/posture_path.dart';
import '../models/user_model.dart';
import '../path/firestore_path_repository.dart';

class DashboardState {
  const DashboardState({
    this.isLoading = false,
    this.user,
    this.path,
    this.todaySession,
    this.currentWeek = 1,
    this.completedDays = const <int>{},
    this.errorMessage,
  });

  final bool isLoading;
  final UserModel? user;
  final PosturePath? path;
  final DailySession? todaySession;
  final int currentWeek;
  final Set<int> completedDays;
  final String? errorMessage;

  DashboardState copyWith({
    bool? isLoading,
    UserModel? user,
    bool clearUser = false,
    PosturePath? path,
    bool clearPath = false,
    DailySession? todaySession,
    bool clearSession = false,
    int? currentWeek,
    Set<int>? completedDays,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : user ?? this.user,
      path: clearPath ? null : path ?? this.path,
      todaySession: clearSession ? null : todaySession ?? this.todaySession,
      currentWeek: currentWeek ?? this.currentWeek,
      completedDays: Set<int>.unmodifiable(completedDays ?? this.completedDays),
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final NotifierProvider<DashboardController, DashboardState>
    dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(
  DashboardController.new,
);

class DashboardController extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return const DashboardState();
  }

  Future<void> fetchData() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final IAuthRepository authRepository = ref.read(authRepositoryProvider);
    final IPathRepository pathRepository =
      ref.read(pathRepositoryProvider);

      final UserModel? user = await authRepository.getCurrentUser();
      if (user == null) {
        throw Exception('Utente non autenticato.');
      }

      final PosturePath path = await pathRepository.fetchCurrentUserPath();
      final DailySession? todaySession = _selectTodaySession(path);
      final int currentWeek = _determineWeek(path, todaySession);
      final Set<int> completedDays = _resolveCompletedDays(todaySession);

      state = state.copyWith(
        isLoading: false,
        user: user,
        path: path,
        todaySession: todaySession,
        currentWeek: currentWeek,
        completedDays: completedDays,
        clearError: true,
      );
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

  DailySession? _selectTodaySession(PosturePath path) {
    final List<DailySession> sessions = path.modules
        .expand((PathModule module) => module.sessions)
        .toList()
      ..sort((DailySession a, DailySession b) =>
          a.dayNumber.compareTo(b.dayNumber));

    if (sessions.isEmpty) {
      return null;
    }

    final int today = DateTime.now().weekday; // 1 = lunedì, 7 = domenica
    for (final DailySession session in sessions) {
      if (session.dayNumber >= today) {
        return session;
      }
    }
    return sessions.last;
  }

  int _determineWeek(PosturePath path, DailySession? session) {
    if (session == null) {
      return path.modules.isNotEmpty ? path.modules.first.weekNumber : 1;
    }

    for (final PathModule module in path.modules) {
      final bool containsSession =
          module.sessions.any((DailySession s) => s.id == session.id);
      if (containsSession) {
        return module.weekNumber;
      }
    }
    return path.modules.isNotEmpty ? path.modules.first.weekNumber : 1;
  }

  Set<int> _resolveCompletedDays(DailySession? session) {
    final int today = DateTime.now().weekday;
    final int currentDay = session?.dayNumber ?? today;
    final int effectiveDay = currentDay.clamp(1, 7);

    return Set<int>.unmodifiable(<int>{
      for (int day = 1; day < effectiveDay; day++) day,
    });
  }

  String _mapError(Object error) {
    final String message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }
}
