class WeeklyCheckin {
  const WeeklyCheckin({
    required this.id,
    required this.athleteId,
    required this.weekStart,
    required this.bodyweightKg,
    required this.sleepHours,
    required this.recoveryScore,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String athleteId;
  final DateTime weekStart;
  final double bodyweightKg;
  final double sleepHours;
  final int recoveryScore;
  final String notes;
  final DateTime createdAt;

  factory WeeklyCheckin.fromMap(Map<String, dynamic> map) {
    return WeeklyCheckin(
      id: map['id'] as String,
      athleteId: map['athlete_id'] as String,
      weekStart: DateTime.parse(map['week_start'] as String),
      bodyweightKg: (map['bodyweight_kg'] as num?)?.toDouble() ?? 0,
      sleepHours: (map['sleep_hours'] as num?)?.toDouble() ?? 0,
      recoveryScore: (map['recovery_score'] as num?)?.toInt() ?? 0,
      notes: (map['notes'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toUpsertMap() {
    return {
      'id': id,
      'athlete_id': athleteId,
      'week_start': weekStart.toIso8601String(),
      'bodyweight_kg': bodyweightKg,
      'sleep_hours': sleepHours,
      'recovery_score': recoveryScore,
      'notes': notes,
    };
  }
}
