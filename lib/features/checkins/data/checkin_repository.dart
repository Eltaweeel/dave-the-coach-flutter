import 'package:dave_the_coach_flutter/features/checkins/domain/weekly_checkin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class CheckinRepository {
  CheckinRepository({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  final _uuid = const Uuid();

  Future<List<WeeklyCheckin>> listForAthlete(String athleteId) async {
    final client = _requireClient();

    final rows = await client
        .from('weekly_checkins')
        .select(
          'id,athlete_id,week_start,bodyweight_kg,sleep_hours,recovery_score,notes,created_at',
        )
        .eq('athlete_id', athleteId)
        .order('week_start', ascending: false);

    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(WeeklyCheckin.fromMap)
        .toList(growable: false);
  }

  Future<WeeklyCheckin> saveWeeklyCheckin({
    required String athleteId,
    required DateTime weekStart,
    required double bodyweightKg,
    required double sleepHours,
    required int recoveryScore,
    required String notes,
  }) async {
    final client = _requireClient();

    final payload = WeeklyCheckin(
      id: _uuid.v4(),
      athleteId: athleteId,
      weekStart: DateTime.utc(weekStart.year, weekStart.month, weekStart.day),
      bodyweightKg: bodyweightKg,
      sleepHours: sleepHours,
      recoveryScore: recoveryScore,
      notes: notes,
      createdAt: DateTime.now().toUtc(),
    ).toUpsertMap();

    final row = await client
        .from('weekly_checkins')
        .upsert(payload, onConflict: 'athlete_id,week_start')
        .select(
          'id,athlete_id,week_start,bodyweight_kg,sleep_hours,recovery_score,notes,created_at',
        )
        .single();

    return WeeklyCheckin.fromMap(row);
  }

  SupabaseClient _requireClient() {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase is not configured.');
    }
    return client;
  }
}
