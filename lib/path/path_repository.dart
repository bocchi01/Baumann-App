import 'dart:async';

import '../models/daily_session.dart';
import '../models/path_module.dart';
import '../models/posture_path.dart';
import '../models/session_exercise.dart';

abstract class IPathRepository {
  Future<PosturePath> fetchCurrentUserPath();

  Future<void> markSessionAsComplete(String sessionId);

  Future<Set<String>> getCompletedSessionIds();
}

class MockPathRepository implements IPathRepository {
  MockPathRepository();

  final Set<String> _completedSessionIds = <String>{};

  @override
  Future<PosturePath> fetchCurrentUserPath() async {
    await Future.delayed(const Duration(milliseconds: 800));

    const List<SessionExercise> mobilityFlowExercises = <SessionExercise>[
      SessionExercise(
        exerciseId: 'stretch_cat_camel',
        durationInSeconds: 60,
        order: 1,
      ),
      SessionExercise(
        exerciseId: 'thoracic_rotation',
        reps: 12,
        order: 2,
      ),
      SessionExercise(
        exerciseId: 'hip_circles',
        durationInSeconds: 45,
        order: 3,
      ),
      SessionExercise(
        exerciseId: 'breathing_reset',
        durationInSeconds: 120,
        order: 4,
      ),
    ];

    const List<SessionExercise> strengthFoundationExercises = <SessionExercise>[
      SessionExercise(exerciseId: 'wall_slides', reps: 15, order: 1),
      SessionExercise(exerciseId: 'glute_bridge', reps: 12, order: 2),
      SessionExercise(
          exerciseId: 'plank_hold', durationInSeconds: 45, order: 3),
      SessionExercise(
          exerciseId: 'child_pose', durationInSeconds: 90, order: 4),
    ];

    const List<SessionExercise> releaseGuidedExercises = <SessionExercise>[
      SessionExercise(
        exerciseId: 'foam_roll_thoracic',
        durationInSeconds: 120,
        order: 1,
      ),
      SessionExercise(
        exerciseId: 'neck_mobility',
        reps: 10,
        order: 2,
      ),
      SessionExercise(
        exerciseId: 'box_breathing',
        durationInSeconds: 180,
        order: 3,
      ),
    ];

    const List<SessionExercise> alignmentExercises = <SessionExercise>[
      SessionExercise(exerciseId: 'band_pull_apart', reps: 15, order: 1),
      SessionExercise(
        exerciseId: 'split_squat_hold',
        durationInSeconds: 40,
        order: 2,
      ),
      SessionExercise(
        exerciseId: 'thoracic_extension_wall',
        reps: 12,
        order: 3,
      ),
      SessionExercise(
        exerciseId: 'breathing_reset',
        durationInSeconds: 120,
        order: 4,
      ),
    ];

    const List<SessionExercise> thoracicDynamicExercises = <SessionExercise>[
      SessionExercise(
        exerciseId: 'thoracic_opener',
        durationInSeconds: 60,
        order: 1,
      ),
      SessionExercise(
        exerciseId: 'spinal_wave',
        durationInSeconds: 45,
        order: 2,
      ),
      SessionExercise(
        exerciseId: 'wall_angel_hold',
        durationInSeconds: 40,
        order: 3,
      ),
      SessionExercise(exerciseId: 'cat_camel', reps: 16, order: 4),
    ];

    const List<SessionExercise> weekendResetExercises = <SessionExercise>[
      SessionExercise(
        exerciseId: 'mobility_flow',
        durationInSeconds: 120,
        order: 1,
      ),
      SessionExercise(exerciseId: 'glute_bridge', reps: 15, order: 2),
      SessionExercise(
        exerciseId: 'box_breathing',
        durationInSeconds: 180,
        order: 3,
      ),
    ];

    const List<DailySession> weekOneSessions = <DailySession>[
      DailySession(
        id: 'sess_w1d1',
        dayNumber: 1,
        title: 'Mobilità Mattutina',
        estimatedDurationInMinutes: 12,
        exercises: mobilityFlowExercises,
      ),
      DailySession(
        id: 'sess_w1d3',
        dayNumber: 3,
        title: 'Stabilità del Core',
        estimatedDurationInMinutes: 15,
        exercises: strengthFoundationExercises,
      ),
      DailySession(
        id: 'sess_w1d5',
        dayNumber: 5,
        title: 'Rilascio Guidato',
        estimatedDurationInMinutes: 10,
        exercises: releaseGuidedExercises,
      ),
    ];

    const List<DailySession> weekTwoSessions = <DailySession>[
      DailySession(
        id: 'sess_w2d1',
        dayNumber: 1,
        title: 'Allineamento posturale',
        estimatedDurationInMinutes: 16,
        exercises: alignmentExercises,
      ),
      DailySession(
        id: 'sess_w2d3',
        dayNumber: 3,
        title: 'Mobilità Toracica Dinamica',
        estimatedDurationInMinutes: 14,
        exercises: thoracicDynamicExercises,
      ),
      DailySession(
        id: 'sess_w2d6',
        dayNumber: 6,
        title: 'Reset Completo Weekend',
        estimatedDurationInMinutes: 18,
        exercises: weekendResetExercises,
      ),
    ];

    return const PosturePath(
      id: 'path_office_back_wellness',
      title: 'Percorso Schiena Protetta in Ufficio',
      description:
          'Un viaggio di 6 settimane per costruire abitudini posturali solide, migliorare la mobilità e ridurre le tensioni accumulate in ufficio.',
      durationInWeeks: 6,
      modules: <PathModule>[
        PathModule(
          id: 'module_week_1',
          title: 'Settimana 1 · Fondamenta e Mobilità',
          weekNumber: 1,
          sessions: weekOneSessions,
        ),
        PathModule(
          id: 'module_week_2',
          title: 'Settimana 2 · Stabilità e Resistenza',
          weekNumber: 2,
          sessions: weekTwoSessions,
        ),
      ],
    );
  }

  @override
  Future<void> markSessionAsComplete(String sessionId) async {
    _completedSessionIds.add(sessionId);
  }

  @override
  Future<Set<String>> getCompletedSessionIds() async {
    return _completedSessionIds;
  }
}
