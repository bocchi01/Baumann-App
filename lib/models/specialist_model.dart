import 'package:meta/meta.dart';

@immutable
class Specialist {
  const Specialist({
    required this.id,
    required this.name,
    required this.title,
    required this.profileImageUrl,
    required this.bio,
    required this.specializations,
  });

  final String id;
  final String name;
  final String title;
  final String profileImageUrl;
  final String bio;
  final List<String> specializations;
}
