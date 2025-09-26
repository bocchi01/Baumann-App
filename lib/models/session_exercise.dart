import 'package:meta/meta.dart';

@immutable
class SessionExercise {
  const SessionExercise({
    required this.exerciseId,
    this.reps,
    this.durationInSeconds,
    required this.order,
  });

  final String exerciseId;
  final int? reps;
  final int? durationInSeconds;
  final int order;

  factory SessionExercise.fromJson(Map<String, dynamic> json) {
    return SessionExercise(
      exerciseId: json['exerciseId'] as String,
      reps: json['reps'] as int?,
      durationInSeconds: json['durationInSeconds'] as int?,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'exerciseId': exerciseId,
      'reps': reps,
      'durationInSeconds': durationInSeconds,
      'order': order,
    };
  }
}
