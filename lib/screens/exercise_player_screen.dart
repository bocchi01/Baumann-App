import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../controllers/exercise_player_controller.dart';
import '../models/daily_session.dart';
import '../models/exercise.dart';
import '../models/session_exercise.dart';
import '../path/exercise_catalog.dart';
import '../theme/theme.dart';
import 'session_complete_screen.dart';

class ExercisePlayerScreen extends ConsumerWidget {
  const ExercisePlayerScreen({required this.session, super.key});

  final DailySession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AutoDisposeNotifierProviderFamily<
        ExercisePlayerController,
        ExercisePlayerState,
        DailySession> provider = exercisePlayerControllerProvider;
    final ExercisePlayerState state = ref.watch(provider(session));
    final ExercisePlayerController controller =
        ref.read(provider(session).notifier);

    ref.listen<ExercisePlayerState>(provider(session), (previous, next) {
      if (previous == null) {
        controller.init();
      }
      if (previous?.phase != ExercisePlayerPhase.finished &&
          next.phase == ExercisePlayerPhase.finished) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => SessionCompleteScreen(session: session),
          ),
        );
      }
    });

    final MockExerciseCatalog catalog = ref.watch(exerciseCatalogProvider);
    final Exercise? currentExercise = state.currentExercise ??
        (state.currentSessionExercise != null
            ? catalog.getById(state.currentSessionExercise!.exerciseId)
            : null);
    final SessionExercise? currentConfig = state.currentSessionExercise;
    final int totalExercises = session.exercises.length;
    final int targetValue = state.currentTargetCount;

    final double exerciseProgress = switch (state.phase) {
      ExercisePlayerPhase.resting => 1.0,
      ExercisePlayerPhase.finished => 1.0,
      _ when targetValue <= 0 => 0,
      _ => ((targetValue - state.countdownValue) / targetValue).clamp(0.0, 1.0),
    };

    final double overallProgress = totalExercises == 0
        ? 1.0
        : ((state.currentExerciseIndex + exerciseProgress)
                    .clamp(0.0, totalExercises.toDouble()) /
                totalExercises)
            .clamp(0.0, 1.0);

    final ExercisePlayerPhase phase = state.phase;
    final bool isLoadingVideo =
        phase == ExercisePlayerPhase.loadingVideo && !state.isVideoReady;
    final bool isResting = phase == ExercisePlayerPhase.resting;
    final bool isFinished = phase == ExercisePlayerPhase.finished;
    final bool isControlsDisabled =
        isLoadingVideo || isFinished || !state.hasExercises;

    final SessionExercise? nextConfig = state.nextSessionExercise;
    final Exercise? nextExercise =
        nextConfig != null ? catalog.getById(nextConfig.exerciseId) : null;
    final String countdownLabel;
    final String countdownValue;

    if (isResting) {
      countdownLabel = 'Riposo';
      countdownValue = '${state.countdownValue}s';
    } else if (currentConfig != null &&
        currentConfig.durationInSeconds == null &&
        currentConfig.reps != null) {
      countdownLabel = 'Ripetizioni';
      countdownValue = '${state.countdownValue}';
    } else {
      countdownLabel = 'Secondi';
      countdownValue = '${state.countdownValue}s';
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(session.title),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _confirmExit(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: overallProgress,
                  minHeight: 10,
                  backgroundColor: Colors.black.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.baumannPrimaryBlue,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _VideoPane(
                      state: state,
                      isLoadingVideo: isLoadingVideo,
                      isResting: isResting,
                      nextExercise: nextExercise,
                      onResume: () {
                        controller.play();
                      },
                    ),
                    const SizedBox(height: 24),
                    _ExerciseInfoSection(
                      state: state,
                      session: session,
                      countdownLabel: countdownLabel,
                      countdownValue: countdownValue,
                      exercise: currentExercise,
                    ),
                    const SizedBox(height: 24),
                    _ControlBar(
                      controller: controller,
                      state: state,
                      isDisabled: isControlsDisabled,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Interrompere la sessione?'),
          content: const Text(
            'Se esci ora, i progressi di questa sessione non verranno salvati.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Continua'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Esci'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _VideoPane extends StatelessWidget {
  const _VideoPane({
    required this.state,
    required this.isLoadingVideo,
    required this.isResting,
    required this.nextExercise,
    required this.onResume,
  });

  final ExercisePlayerState state;
  final bool isLoadingVideo;
  final bool isResting;
  final Exercise? nextExercise;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final ExercisePlayerPhase phase = state.phase;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (state.isVideoReady && state.videoController != null)
              _VideoPlayerWidget(controller: state.videoController!)
            else
              _VideoPlaceholder(isLoading: isLoadingVideo),
            if (phase == ExercisePlayerPhase.paused && !isResting)
              _PausedOverlay(onPlay: onResume),
            if (isResting)
              _RestOverlay(
                secondsRemaining: state.countdownValue,
                nextExercise: nextExercise,
              ),
            if (isLoadingVideo) const _LoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  const _VideoPlayerWidget({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: widget.controller.value.size.width,
        height: widget.controller.value.size.height,
        child: VideoPlayer(widget.controller),
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: isLoading
          ? const CircularProgressIndicator()
      : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
                Icon(Icons.play_circle_outline,
                    size: 64, color: Colors.white70),
                SizedBox(height: 12),
                Text(
                  'Video pronto a partire',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
    );
  }
}

class _PausedOverlay extends StatelessWidget {
  const _PausedOverlay({required this.onPlay});

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      alignment: Alignment.center,
      child: IconButton(
        iconSize: 72,
        color: Colors.white,
        onPressed: onPlay,
        icon: const Icon(Icons.play_arrow_rounded),
      ),
    );
  }
}

class _RestOverlay extends StatelessWidget {
  const _RestOverlay({
    required this.secondsRemaining,
    required this.nextExercise,
  });

  final int secondsRemaining;
  final Exercise? nextExercise;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Recupera',
            style: textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Prossimo esercizio tra',
            style: textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '${secondsRemaining}s',
            style: textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          if (nextExercise != null) ...<Widget>[
            Text(
              nextExercise!.name,
              style: textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              nextExercise!.description,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.35),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

class _ExerciseInfoSection extends StatelessWidget {
  const _ExerciseInfoSection({
    required this.state,
    required this.session,
    required this.countdownLabel,
    required this.countdownValue,
    required this.exercise,
  });

  final ExercisePlayerState state;
  final DailySession session;
  final String countdownLabel;
  final String countdownValue;
  final Exercise? exercise;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int totalExercises = session.exercises.length;
    final int currentPosition =
        (state.currentExerciseIndex + 1).clamp(0, totalExercises);
    final Exercise? exerciseData = exercise;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              exerciseData?.name ?? 'Esercizio in preparazione',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esercizio $currentPosition di $totalExercises',
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      countdownLabel,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppTheme.baumannSecondaryBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      countdownValue,
                      style: textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.baumannPrimaryBlue,
                      ),
                    ),
                  ],
                ),
                if (exerciseData != null && exerciseData.targetArea.isNotEmpty)
                  _InfoChip(label: exerciseData.targetArea),
              ],
            ),
            if (exerciseData != null &&
                exerciseData.description.isNotEmpty) ...<Widget>[
              const SizedBox(height: 20),
              Text(
                exerciseData.description,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.baumannAccentOrange.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.baumannAccentOrange,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.controller,
    required this.state,
    required this.isDisabled,
  });

  final ExercisePlayerController controller;
  final ExercisePlayerState state;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
  const Color buttonColor = AppTheme.baumannPrimaryBlue;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              iconSize: 36,
              color: buttonColor,
              onPressed: isDisabled || !state.hasPreviousExercise
                  ? null
                  : () async => controller.goToPreviousExercise(),
              icon: const Icon(Icons.skip_previous_rounded),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(18),
              ),
              onPressed: isDisabled
                  ? null
                  : () async {
                      if (state.isPlaying) {
                        await controller.pause();
                      } else {
                        await controller.play();
                      }
                    },
              child: Icon(
                state.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 38,
              ),
            ),
            IconButton(
              iconSize: 36,
              color: buttonColor,
              onPressed: isDisabled || !state.hasNextExercise
                  ? null
                  : () async => controller.goToNextExercise(),
              icon: const Icon(Icons.skip_next_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
