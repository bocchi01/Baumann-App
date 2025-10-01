import 'dart:async';

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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: isResting
                    ? _RestView(
                        key: const ValueKey<String>('rest-view'),
                        controller: controller,
                        state: state,
                        nextExercise: nextExercise,
                      )
                    : _ExerciseView(
                        key: const ValueKey<String>('exercise-view'),
                        controller: controller,
                        state: state,
                        session: session,
                        currentExercise: currentExercise,
                        countdownLabel: countdownLabel,
                        countdownValue: countdownValue,
                        isLoadingVideo: isLoadingVideo,
                        exerciseProgress: exerciseProgress,
                        isControlsDisabled: isControlsDisabled,
                        canSkip: state.hasNextExercise,
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

class _ExerciseView extends StatelessWidget {
  const _ExerciseView({
    super.key,
    required this.controller,
    required this.state,
    required this.session,
    required this.currentExercise,
    required this.countdownLabel,
    required this.countdownValue,
    required this.isLoadingVideo,
    required this.exerciseProgress,
    required this.isControlsDisabled,
    required this.canSkip,
  });

  final ExercisePlayerController controller;
  final ExercisePlayerState state;
  final DailySession session;
  final Exercise? currentExercise;
  final String countdownLabel;
  final String countdownValue;
  final bool isLoadingVideo;
  final double exerciseProgress;
  final bool isControlsDisabled;
  final bool canSkip;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _VideoPane(
            state: state,
            isLoadingVideo: isLoadingVideo,
            exerciseProgress: exerciseProgress,
            onTogglePlay: () {
              if (state.isPlaying) {
                unawaited(controller.pause());
              } else {
                unawaited(controller.play());
              }
            },
            onSkip:
                canSkip ? () => unawaited(controller.goToNextExercise()) : null,
            canSkip: canSkip,
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
    );
  }
}

class _RestView extends StatelessWidget {
  const _RestView({
    super.key,
    required this.controller,
    required this.state,
    this.nextExercise,
  });

  final ExercisePlayerController controller;
  final ExercisePlayerState state;
  final Exercise? nextExercise;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String formattedTime = _formatTime(state.countdownValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: <Color>[
              AppTheme.baumannPrimaryBlue.withValues(alpha: 0.9),
              AppTheme.baumannSecondaryBlue.withValues(alpha: 0.85),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Recupera',
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'PROSSIMO ESERCIZIO',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 8),
                if (nextExercise != null) ...<Widget>[
                  Text(
                    nextExercise!.name,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (nextExercise!.description.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      nextExercise!.description,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ] else
                  Text(
                    'Tieni il ritmo!',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(height: 32),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    final Animation<Offset> offsetAnimation = Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      ),
                    );
                    return ClipRect(
                      child: SlideTransition(
                        position: offsetAnimation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    formattedTime,
                    key: ValueKey<int>(state.countdownValue),
                    style: textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.baumannPrimaryBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: state.hasNextExercise
                      ? () => unawaited(controller.skipRest())
                      : null,
                  icon: const Icon(Icons.fast_forward_rounded),
                  label: const Text('Salta il riposo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString()}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _VideoPane extends StatelessWidget {
  const _VideoPane({
    required this.state,
    required this.isLoadingVideo,
    required this.exerciseProgress,
    required this.onTogglePlay,
    required this.onSkip,
    required this.canSkip,
  });

  final ExercisePlayerState state;
  final bool isLoadingVideo;
  final double exerciseProgress;
  final VoidCallback onTogglePlay;
  final VoidCallback? onSkip;
  final bool canSkip;

  bool get _isPlaying =>
      state.isPlaying && state.phase == ExercisePlayerPhase.playing;

  @override
  Widget build(BuildContext context) {
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
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.black.withValues(alpha: 0.25),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.35),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: isLoadingVideo,
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 24,
                    children: <Widget>[
                      _CircleControlButton(
                        icon: _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        onPressed: onTogglePlay,
                        size: 68,
                      ),
                      _CircleControlButton(
                        icon: Icons.skip_next_rounded,
                        onPressed: canSkip ? onSkip : null,
                        size: 60,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _VideoProgressBar(progress: exerciseProgress),
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

class _CircleControlButton extends StatelessWidget {
  const _CircleControlButton({
    required this.icon,
    required this.size,
    this.onPressed,
  });

  final IconData icon;
  final double size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    return Material(
      color: Colors.black.withValues(alpha: enabled ? 0.45 : 0.2),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: size,
        padding: const EdgeInsets.all(12),
        onPressed: onPressed,
      ),
    );
  }
}

class _VideoProgressBar extends StatelessWidget {
  const _VideoProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: progress.clamp(0.0, 1.0),
      minHeight: 8,
      backgroundColor: Colors.black.withValues(alpha: 0.2),
      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
