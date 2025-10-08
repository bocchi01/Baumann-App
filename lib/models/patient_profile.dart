import 'onboarding_data.dart';

/// Modello del profilo paziente
/// Rappresenta i dati essenziali salvati in Firestore patients/{uid}
class PatientProfile {
  final String uid;
  final bool onboardingCompleted;
  final String? email;
  final OnboardingData? onboardingData;
  final String? assignedPathId;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  const PatientProfile({
    required this.uid,
    required this.onboardingCompleted,
    this.email,
    this.onboardingData,
    this.assignedPathId,
    this.updatedAt,
    this.createdAt,
  });

  /// Crea un'istanza da documento Firestore
  factory PatientProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return PatientProfile(
      uid: uid,
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
      email: data['email'] as String?,
      onboardingData: data['onboardingData'] != null
          ? OnboardingData.fromFirestore(
              data['onboardingData'] as Map<String, dynamic>)
          : null,
      assignedPathId: data['assignedPathId'] as String?,
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((data['updatedAt'] as int))
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((data['createdAt'] as int))
          : null,
    );
  }

  /// Converte in Map per Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'onboardingCompleted': onboardingCompleted,
      if (email != null) 'email': email,
      if (onboardingData != null) 'onboardingData': onboardingData!.toFirestore(),
      if (assignedPathId != null) 'assignedPathId': assignedPathId,
      if (updatedAt != null) 'updatedAt': updatedAt!.millisecondsSinceEpoch,
      if (createdAt != null) 'createdAt': createdAt!.millisecondsSinceEpoch,
    };
  }

  PatientProfile copyWith({
    String? uid,
    bool? onboardingCompleted,
    String? email,
    OnboardingData? onboardingData,
    String? assignedPathId,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return PatientProfile(
      uid: uid ?? this.uid,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      email: email ?? this.email,
      onboardingData: onboardingData ?? this.onboardingData,
      assignedPathId: assignedPathId ?? this.assignedPathId,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
