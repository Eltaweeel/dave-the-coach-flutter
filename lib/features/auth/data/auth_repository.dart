import 'package:dave_the_coach_flutter/features/auth/domain/app_session.dart';
import 'package:dave_the_coach_flutter/features/auth/domain/app_user_role.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository({required SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  bool get isConfigured => _client != null;

  Stream<AppSession?> authStateChanges() async* {
    yield await currentSession();

    if (_client == null) {
      return;
    }

    yield* _client.auth.onAuthStateChange.asyncMap((_) => currentSession());
  }

  Future<AppSession?> currentSession() async {
    if (_client == null) {
      return null;
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final rawProfile = await _client
        .from('profiles')
        .select('id,email,display_name,role')
        .eq('id', user.id)
        .maybeSingle();

    final profile = rawProfile is Map<String, dynamic>
        ? rawProfile
        : <String, dynamic>{};

    return AppSession(
      userId: user.id,
      email: (profile['email'] as String?) ?? user.email ?? '',
      displayName:
          (profile['display_name'] as String?)?.trim().isNotEmpty == true
          ? profile['display_name'] as String
          : (user.userMetadata?['display_name'] as String?) ??
                user.email ??
                'Athlete',
      role: AppUserRoleX.fromValue(
        profile['role'] as String? ?? user.userMetadata?['role'] as String?,
      ),
    );
  }

  Future<AppSession> signIn({
    required String email,
    required String password,
  }) async {
    final client = _requireClient();

    await client.auth.signInWithPassword(email: email, password: password);

    final session = await currentSession();
    if (session == null) {
      throw Exception('Sign-in succeeded, but no active session was found.');
    }

    return session;
  }

  Future<AppSession?> signUp({
    required String email,
    required String password,
    required String displayName,
    required AppUserRole role,
  }) async {
    final client = _requireClient();

    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName, 'role': role.value},
    );

    final user = response.user ?? client.auth.currentUser;
    if (user == null) {
      return null;
    }

    await client.from('profiles').upsert({
      'id': user.id,
      'email': email,
      'display_name': displayName,
      'role': role.value,
    });

    if (role == AppUserRole.athlete) {
      await client.from('athlete_profiles').upsert({
        'id': user.id,
        'goal': 'Build elite calisthenics strength and consistency',
        'training_level': 'Intermediate',
      });
    }

    return currentSession();
  }

  Future<void> signOut() async {
    final client = _requireClient();
    await client.auth.signOut();
  }

  SupabaseClient _requireClient() {
    final client = _client;
    if (client == null) {
      throw Exception(
        'Supabase is not configured yet. Add SUPABASE_URL and SUPABASE_ANON_KEY to enable real login.',
      );
    }
    return client;
  }
}
