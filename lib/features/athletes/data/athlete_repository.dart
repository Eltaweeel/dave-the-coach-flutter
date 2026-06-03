import 'package:dave_the_coach_flutter/features/athletes/domain/athlete_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AthleteRepository {
  AthleteRepository({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  Future<AthleteProfile?> loadAthleteProfile(String userId) async {
    final client = _requireClient();

    final profileRaw = await client
        .from('profiles')
        .select('id,email,display_name,role')
        .eq('id', userId)
        .maybeSingle();

    if (profileRaw is! Map<String, dynamic>) {
      return null;
    }

    final athleteRaw = await client
        .from('athlete_profiles')
        .select('id,coach_id,goal,training_level,age,height_cm,notes')
        .eq('id', userId)
        .maybeSingle();

    return AthleteProfile.fromSupabase(
      profile: profileRaw,
      athlete: athleteRaw is Map<String, dynamic> ? athleteRaw : null,
    );
  }

  Future<List<AthleteProfile>> loadCoachRoster(String coachId) async {
    final client = _requireClient();

    final athleteRows = await client
        .from('athlete_profiles')
        .select('id,coach_id,goal,training_level,age,height_cm,notes')
        .eq('coach_id', coachId);

    final athleteMaps = (athleteRows as List)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);

    if (athleteMaps.isEmpty) {
      return const [];
    }

    final ids = athleteMaps
        .map((row) => row['id'] as String)
        .toList(growable: false);

    final profileRows = await client
        .from('profiles')
        .select('id,email,display_name,role')
        .inFilter('id', ids);

    final profileMaps = (profileRows as List)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);

    final profileById = {
      for (final profile in profileMaps) profile['id'] as String: profile,
    };

    return athleteMaps
        .map(
          (athlete) => AthleteProfile.fromSupabase(
            profile:
                profileById[athlete['id'] as String] ??
                {
                  'id': athlete['id'],
                  'email': '',
                  'display_name': 'Athlete',
                  'role': 'athlete',
                },
            athlete: athlete,
          ),
        )
        .toList(growable: false);
  }

  SupabaseClient _requireClient() {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase is not configured.');
    }
    return client;
  }
}
