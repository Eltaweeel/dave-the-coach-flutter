import 'package:dave_the_coach_flutter/core/app_bootstrap.dart';
import 'package:dave_the_coach_flutter/features/athletes/domain/athlete_profile.dart';
import 'package:dave_the_coach_flutter/features/auth/domain/app_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key, required this.bootstrap});

  final AppBootstrap bootstrap;

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  late Future<_CoachDashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_CoachDashboardData> _load() async {
    final session = await widget.bootstrap.authRepository.currentSession();
    if (session == null) {
      throw Exception('You need to sign in as a coach first.');
    }
    if (session.role.name != 'coach') {
      throw Exception('This route is for coach accounts only.');
    }

    final roster = await widget.bootstrap.athleteRepository.loadCoachRoster(
      session.userId,
    );
    return _CoachDashboardData(session: session, roster: roster);
  }

  Future<void> _signOut() async {
    await widget.bootstrap.authRepository.signOut();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF04060E), Color(0xFF081120), Color(0xFF091429)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<_CoachDashboardData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${snapshot.error}'),
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Go to login'),
                      ),
                    ],
                  ),
                );
              }

              final data = snapshot.data!;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${data.session.displayName}’s coach command center',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: _signOut,
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text('Sign out'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Coach access is intended to stay private while using the same public app URL. Supabase RLS determines which athlete records a coach can see.',
                          style: TextStyle(
                            color: Color(0xFF9BA6C7),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: [
                            _CoachMetricCard(
                              label: 'Assigned athletes',
                              value: '${data.roster.length}',
                            ),
                            _CoachMetricCard(
                              label: 'Reporting flow',
                              value:
                                  widget
                                      .bootstrap
                                      .config
                                      .isDaveReportingConfigured
                                  ? 'Ready'
                                  : 'Pending config',
                            ),
                            const _CoachMetricCard(
                              label: 'Data privacy',
                              value: 'RLS enforced',
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0x3328E0FF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Athlete roster',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 14),
                              if (data.roster.isEmpty)
                                const Text(
                                  'No athletes are assigned yet. Once athlete profiles are linked to this coach in Supabase, they will appear here.',
                                  style: TextStyle(
                                    color: Color(0xFF9BA6C7),
                                    height: 1.5,
                                  ),
                                )
                              else
                                ...data.roster.map(
                                  (athlete) =>
                                      _AthleteRosterTile(profile: athlete),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CoachDashboardData {
  const _CoachDashboardData({required this.session, required this.roster});

  final AppSession session;
  final List<AthleteProfile> roster;
}

class _CoachMetricCard extends StatelessWidget {
  const _CoachMetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x3328E0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF9BA6C7))),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _AthleteRosterTile extends StatelessWidget {
  const _AthleteRosterTile({required this.profile});

  final AthleteProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF101A31).withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x3328E0FF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.displayName,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 6),
            Text(
              profile.email,
              style: const TextStyle(color: Color(0xFF9BA6C7)),
            ),
            const SizedBox(height: 6),
            Text('Goal: ${profile.goal}'),
            const SizedBox(height: 4),
            Text('Training level: ${profile.trainingLevel}'),
            if (profile.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Notes: ${profile.notes}'),
            ],
          ],
        ),
      ),
    );
  }
}
