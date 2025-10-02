import 'dart:async';

import 'package:flutter_haptic_feedback/flutter_haptic_feedback.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/daily_session.dart';
import '../models/exercise.dart';
import '../models/session_exercise.dart';
import '../path/exercise_catalog.dart';
import '../path/firestore_path_repository.dart';

enum ExercisePlayerPhase {
  idle,
  loadingVideo,
  playing,
  paused,
  resting,
  finished,
}

class ExercisePlayerState {
  const ExercisePlayerState({
    required this.session,
    required this.currentExerciseIndex,
    required this.isPlaying,
    required this.countdownValue,
    required this.phase,
    this.currentExercise,
    this.videoController,
    this.isVideoReady = false,
  });

  final DailySession session;
  final int currentExerciseIndex;
  final bool isPlaying;
  final int countdownValue;
  final ExercisePlayerPhase phase;
  final Exercise? currentExercise;
  final VideoPlayerController? videoController;
  final bool isVideoReady;

  bool get hasExercises => session.exercises.isNotEmpty;

  bool get hasNextExercise =>
      currentExerciseIndex < session.exercises.length - 1;

  bool get hasPreviousExercise => currentExerciseIndex > 0;

  SessionExercise? get currentSessionExercise {
    if (!hasExercises || currentExerciseIndex >= session.exercises.length) {
      return null;
    }
    return session.exercises[currentExerciseIndex];
  }

  SessionExercise? get nextSessionExercise {
    if (!hasNextExercise) {
      return null;
    }
    return session.exercises[currentExerciseIndex + 1];
  }

  int get currentTargetCount {
    final SessionExercise? exercise = currentSessionExercise;
    if (exercise == null) {
      return 0;
    }
    return ExercisePlayerState._resolveCountdown(exercise);
  }

  ExercisePlayerState copyWith({
    DailySession? session,
    int? currentExerciseIndex,
    bool? isPlaying,
    int? countdownValue,
    ExercisePlayerPhase? phase,
    Exercise? currentExercise,
    bool clearCurrentExercise = false,
    VideoPlayerController? videoController,
    bool clearVideoController = false,
    bool? isVideoReady,
  }) {
    return ExercisePlayerState(
      session: session ?? this.session,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      countdownValue: countdownValue ?? this.countdownValue,
      phase: phase ?? this.phase,
      currentExercise:
          clearCurrentExercise ? null : currentExercise ?? this.currentExercise,
      videoController:
          clearVideoController ? null : videoController ?? this.videoController,
      isVideoReady: isVideoReady ?? this.isVideoReady,
    );
  }

  factory ExercisePlayerState.initial(DailySession session) {
    if (session.exercises.isEmpty) {
      return ExercisePlayerState(
        session: session,
        currentExerciseIndex: 0,
        isPlaying: false,
        countdownValue: 0,
        phase: ExercisePlayerPhase.finished,
      );
    }

    return ExercisePlayerState(
      session: session,
      currentExerciseIndex: 0,
      isPlaying: false,
      countdownValue: _resolveCountdown(session.exercises.first),
      phase: ExercisePlayerPhase.idle,
    );
  }

  static int _resolveCountdown(SessionExercise exercise) {
    return exercise.durationInSeconds ?? exercise.reps ?? 30;
  }
}

final Provider<MockExerciseCatalog> exerciseCatalogProvider =
    Provider<MockExerciseCatalog>((Ref ref) => const MockExerciseCatalog());

final AutoDisposeNotifierProviderFamily<ExercisePlayerController,
        ExercisePlayerState, DailySession> exercisePlayerControllerProvider =
    AutoDisposeNotifierProviderFamily<ExercisePlayerController,
        ExercisePlayerState, DailySession>(ExercisePlayerController.new);

class ExercisePlayerController
    extends AutoDisposeFamilyNotifier<ExercisePlayerState, DailySession> {
  static const int _restDurationInSeconds = 10;

  Timer? _ticker;
  bool _initialized = false;

  MockExerciseCatalog get _catalog => ref.read(exerciseCatalogProvider);

  @override
  ExercisePlayerState build(DailySession session) {
    ref.onDispose(_disposeResources);
    return ExercisePlayerState.initial(session);
  }

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    if (!state.hasExercises || state.phase == ExercisePlayerPhase.finished) {
      return;
    }

    await _loadExercise(state.currentExerciseIndex, autoPlay: true);
  }

  Future<void> play() async {
    if (state.phase == ExercisePlayerPhase.finished) {
      return;
    }

    if (state.phase == ExercisePlayerPhase.resting) {
      if (!state.isPlaying) {
        state = state.copyWith(isPlaying: true);
        _startTicker();
      }
      return;
    }

    if (!state.isVideoReady) {
      return;
    }

    await state.videoController?.play();
    state = state.copyWith(
      isPlaying: true,
      phase: ExercisePlayerPhase.playing,
    );
    _startTicker();
  }

  Future<void> pause() async {
    if (state.phase == ExercisePlayerPhase.finished) {
      return;
    }

    _ticker?.cancel();

    if (state.phase == ExercisePlayerPhase.resting) {
      state = state.copyWith(isPlaying: false);
      return;
    }

    await _pauseVideo();

    state = state.copyWith(
      isPlaying: false,
      phase: ExercisePlayerPhase.paused,
    );
  }

  Future<void> goToNextExercise({bool fromRest = false}) async {
    if (!state.hasNextExercise) {
      await _finishSession();
      return;
    }

    final int nextIndex = state.currentExerciseIndex + 1;
    await _loadExercise(nextIndex, autoPlay: true);

    if (fromRest) {
      state = state.copyWith(phase: ExercisePlayerPhase.playing);
    }
  }

  Future<void> goToPreviousExercise() async {
    if (!state.hasPreviousExercise) {
      return;
    }

    final int previousIndex = state.currentExerciseIndex - 1;
    await _loadExercise(previousIndex, autoPlay: false);
    await pause();
  }

  Future<void> _loadExercise(int index, {required bool autoPlay}) async {
    _ticker?.cancel();

    final SessionExercise exerciseConfig = state.session.exercises[index];
    final Exercise exercise = _catalog.getById(exerciseConfig.exerciseId);
    final int countdown = ExercisePlayerState._resolveCountdown(exerciseConfig);

    await _pauseVideo();
    await _disposeCurrentVideo();

    final VideoPlayerController controller = VideoPlayerController.networkUrl(
      Uri.parse(exercise.videoUrl),
    );

    state = state.copyWith(
      currentExerciseIndex: index,
      countdownValue: countdown,
      phase: ExercisePlayerPhase.loadingVideo,
      isPlaying: false,
      currentExercise: exercise,
      videoController: controller,
      isVideoReady: false,
    );

    await controller.initialize();
    await controller.setLooping(false);

    state = state.copyWith(
      isVideoReady: true,
      phase:
          autoPlay ? ExercisePlayerPhase.playing : ExercisePlayerPhase.paused,
      isPlaying: autoPlay,
      countdownValue: countdown,
    );

    if (autoPlay) {
      await controller.play();
      _startTicker();
    }
  }

  void _startTicker() {
    _ticker?.cancel();

    if (!state.isPlaying) {
      return;
    }

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isPlaying) {
        return;
      }

      final int nextValue = (state.countdownValue - 1).clamp(0, 9999);
      state = state.copyWith(countdownValue: nextValue);

      if (state.phase == ExercisePlayerPhase.resting &&
          nextValue > 0 &&
          nextValue <= 3) {
        _emitHaptic(
            () => FlutterHapticFeedback.impact(ImpactFeedbackStyle.light, 0.6));
      }

      if (nextValue <= 0) {
        _ticker?.cancel();
        if (state.phase == ExercisePlayerPhase.resting) {
          unawaited(goToNextExercise(fromRest: true));
        } else {
          unawaited(_handleExerciseCompleted());
        }
      }
    });
  }

  Future<void> _handleExerciseCompleted() async {
    if (!state.hasNextExercise) {
      await _finishSession();
      return;
    }

    await _pauseVideo();

    _emitHaptic(
      () => FlutterHapticFeedback.impact(ImpactFeedbackStyle.medium, 1),
    );

    state = state.copyWith(
      phase: ExercisePlayerPhase.resting,
      isPlaying: true,
      countdownValue: _restDurationInSeconds,
    );

    _startTicker();
  }

  Future<void> skipRest() async {
    if (state.phase != ExercisePlayerPhase.resting) {
      return;
    }

    _ticker?.cancel();
    state = state.copyWith(isPlaying: false, countdownValue: 0);
    await goToNextExercise(fromRest: true);
  }

  Future<void> _finishSession() async {
    _ticker?.cancel();
    await _pauseVideo();

    await _markSessionCompletion(state.session.id);
    state = state.copyWith(
      isPlaying: false,
      countdownValue: 0,
      phase: ExercisePlayerPhase.finished,
    );
  }

  Future<void> _markSessionCompletion(String sessionId) async {
    final IPathRepository repository = ref.read(pathRepositoryProvider);
    try {
      await repository.markSessionAsComplete(sessionId);
    } catch (_) {
      // Swallow errors so a failed write doesn't interrupt the session flow.
    }
  }

  void _disposeResources() {
    _ticker?.cancel();
    _ticker = null;
    final VideoPlayerController? controller = state.videoController;
    if (controller != null) {
      unawaited(controller.dispose());
    }
  }

  void _emitHaptic(Future<void> Function() feedback) {
    try {
      unawaited(feedback());
    } catch (_) {
      // Haptic feedback is best-effort; ignore platform errors.
    }
  }

  Future<void> _pauseVideo() async {
    final VideoPlayerController? controller = state.videoController;
    if (controller != null) {
      await controller.pause();
    }
  }

  Future<void> _disposeCurrentVideo() async {
    final VideoPlayerController? controller = state.videoController;
    if (controller != null) {
      await controller.dispose();
      state = state.copyWith(clearVideoController: true, isVideoReady: false);
    }
  }
}
