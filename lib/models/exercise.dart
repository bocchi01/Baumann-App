import 'package:meta/meta.dart';

@immutable
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.videoUrl,
    required this.targetArea,
  });

  final String id;
  final String name;
  final String description;
  final String videoUrl;
  final String targetArea;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      videoUrl: json['videoUrl'] as String,
      targetArea: json['targetArea'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'videoUrl': videoUrl,
      'targetArea': targetArea,
    };
  }
}
