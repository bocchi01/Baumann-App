/// Modello del profilo paziente
/// Rappresenta i dati essenziali salvati in Firestore patients/{uid}
class PatientProfile {
  final String uid;
  final bool onboardingCompleted;
  final String? email;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  const PatientProfile({
    required this.uid,
    required this.onboardingCompleted,
    this.email,
    this.updatedAt,
    this.createdAt,
  });

  /// Crea un'istanza da documento Firestore
  factory PatientProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return PatientProfile(
      uid: uid,
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
      email: data['email'] as String?,
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['updatedAt'] as int))
          : null,
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['createdAt'] as int))
          : null,
    );
  }

  /// Converte in Map per Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'onboardingCompleted': onboardingCompleted,
      if (email != null) 'email': email,
      if (updatedAt != null)
        'updatedAt': updatedAt!.millisecondsSinceEpoch,
      if (createdAt != null)
        'createdAt': createdAt!.millisecondsSinceEpoch,
    };
  }

  PatientProfile copyWith({
    String? uid,
    bool? onboardingCompleted,
    String? email,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return PatientProfile(
      uid: uid ?? this.uid,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      email: email ?? this.email,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
