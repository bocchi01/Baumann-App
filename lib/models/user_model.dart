import 'package:meta/meta.dart';

@immutable
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    this.name,
    required this.subscriptionStatus,
    this.trialStartDate,
  });

  final String id;
  final String email;
  final String? name;
  final String subscriptionStatus;
  final DateTime? trialStartDate;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      subscriptionStatus: json['subscriptionStatus'] as String,
      trialStartDate: json['trialStartDate'] == null
          ? null
          : DateTime.parse(json['trialStartDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'name': name,
      'subscriptionStatus': subscriptionStatus,
      'trialStartDate': trialStartDate?.toIso8601String(),
    };
  }
}
