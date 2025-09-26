import 'package:meta/meta.dart';

import 'path_module.dart';

@immutable
class PosturePath {
  const PosturePath({
    required this.id,
    required this.title,
    required this.description,
    required this.durationInWeeks,
    required this.modules,
  });

  final String id;
  final String title;
  final String description;
  final int durationInWeeks;
  final List<PathModule> modules;

  factory PosturePath.fromJson(Map<String, dynamic> json) {
    return PosturePath(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      durationInWeeks: json['durationInWeeks'] as int,
      modules: (json['modules'] as List<dynamic>)
          .map((dynamic item) =>
              PathModule.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'durationInWeeks': durationInWeeks,
      'modules': modules.map((PathModule module) => module.toJson()).toList(),
    };
  }
}
