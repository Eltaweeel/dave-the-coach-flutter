import 'package:dave_the_coach_flutter/features/auth/domain/app_user_role.dart';

class AthleteProfile {
  const AthleteProfile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    required this.goal,
    required this.trainingLevel,
    required this.notes,
    this.coachId,
    this.age,
    this.heightCm,
  });

  final String id;
  final String displayName;
  final String email;
  final AppUserRole role;
  final String goal;
  final String trainingLevel;
  final String notes;
  final String? coachId;
  final int? age;
  final double? heightCm;

  factory AthleteProfile.fromSupabase({
    required Map<String, dynamic> profile,
    Map<String, dynamic>? athlete,
  }) {
    return AthleteProfile(
      id: profile['id'] as String,
      displayName:
          (profile['display_name'] as String?)?.trim().isNotEmpty == true
          ? profile['display_name'] as String
          : ((profile['email'] as String?) ?? 'Athlete'),
      email: (profile['email'] as String?) ?? '',
      role: AppUserRoleX.fromValue(profile['role'] as String?),
      goal:
          (athlete?['goal'] as String?) ??
          'Build elite calisthenics strength and consistency',
      trainingLevel: (athlete?['training_level'] as String?) ?? 'Intermediate',
      notes: (athlete?['notes'] as String?) ?? '',
      coachId: athlete?['coach_id'] as String?,
      age: athlete?['age'] as int?,
      heightCm: (athlete?['height_cm'] as num?)?.toDouble(),
    );
  }
}
