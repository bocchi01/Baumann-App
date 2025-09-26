import 'package:meta/meta.dart';

import 'daily_session.dart';

@immutable
class PathModule {
  const PathModule({
    required this.id,
    required this.title,
    required this.weekNumber,
    required this.sessions,
  });

  final String id;
  final String title;
  final int weekNumber;
  final List<DailySession> sessions;

  factory PathModule.fromJson(Map<String, dynamic> json) {
    return PathModule(
      id: json['id'] as String,
      title: json['title'] as String,
      weekNumber: json['weekNumber'] as int,
      sessions: (json['sessions'] as List<dynamic>)
          .map((dynamic item) =>
              DailySession.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'weekNumber': weekNumber,
      'sessions':
          sessions.map((DailySession session) => session.toJson()).toList(),
    };
  }
}
