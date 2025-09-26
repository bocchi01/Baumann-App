import 'package:meta/meta.dart';

import 'session_exercise.dart';

@immutable
class DailySession {
  const DailySession({
    required this.id,
    required this.dayNumber,
    required this.title,
    required this.estimatedDurationInMinutes,
    required this.exercises,
  });

  final String id;
  final int dayNumber;
  final String title;
  final int estimatedDurationInMinutes;
  final List<SessionExercise> exercises;

  factory DailySession.fromJson(Map<String, dynamic> json) {
    return DailySession(
      id: json['id'] as String,
      dayNumber: json['dayNumber'] as int,
      title: json['title'] as String,
      estimatedDurationInMinutes: json['estimatedDurationInMinutes'] as int,
      exercises: (json['exercises'] as List<dynamic>)
          .map((dynamic item) =>
              SessionExercise.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'dayNumber': dayNumber,
      'title': title,
      'estimatedDurationInMinutes': estimatedDurationInMinutes,
      'exercises': exercises
          .map((SessionExercise exercise) => exercise.toJson())
          .toList(),
    };
  }
}
