import 'package:dave_the_coach_flutter/core/app_bootstrap.dart';
import 'package:dave_the_coach_flutter/features/athletes/domain/athlete_profile.dart';
import 'package:dave_the_coach_flutter/features/auth/domain/app_session.dart';
import 'package:dave_the_coach_flutter/features/checkins/domain/weekly_checkin.dart';
import 'package:dave_the_coach_flutter/features/checkins/presentation/checkin_form_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AthleteDashboardScreen extends StatefulWidget {
  const AthleteDashboardScreen({super.key, required this.bootstrap});

  final AppBootstrap bootstrap;

  @override
  State<AthleteDashboardScreen> createState() => _AthleteDashboardScreenState();
}

class _AthleteDashboardScreenState extends State<AthleteDashboardScreen> {
  late Future<_AthleteDashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_AthleteDashboardData> _load() async {
    final session = await widget.bootstrap.authRepository.currentSession();
    if (session == null) {
      throw Exception('You need to sign in as an athlete first.');
    }
    if (session.role.name == 'coach') {
      throw Exception('This route is for athlete accounts.');
    }

    final profile = await widget.bootstrap.athleteRepository.loadAthleteProfile(
      session.userId,
    );
    final checkins = await widget.bootstrap.checkinRepository.listForAthlete(
      session.userId,
    );

    return _AthleteDashboardData(
      session: session,
      profile: profile,
      checkins: checkins,
    );
  }

  Future<void> _saveCheckin(
    AppSession session, {
    required double bodyweightKg,
    required double sleepHours,
    required int recoveryScore,
    required String notes,
  }) async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    final checkin = await widget.bootstrap.checkinRepository.saveWeeklyCheckin(
      athleteId: session.userId,
      weekStart: DateTime(monday.year, monday.month, monday.day),
      bodyweightKg: bodyweightKg,
      sleepHours: sleepHours,
      recoveryScore: recoveryScore,
      notes: notes,
    );

    await widget.bootstrap.daveReportingService.reportWeeklyCheckin(
      actor: session,
      checkin: checkin,
    );

    setState(() {
      _future = _load();
    });
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
          child: FutureBuilder<_AthleteDashboardData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ErrorState(
                  message: '${snapshot.error}',
                  onBack: () => context.go('/login'),
                );
              }

              final data = snapshot.data!;
              final profile = data.profile;

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
                                '${data.session.displayName}’s private athlete dashboard',
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
                          'This area is intended for real private athlete data: profile, weekly check-ins, and coach-visible progress updates.',
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
                            _MetricCard(
                              label: 'Goal',
                              value: profile?.goal ?? 'Not set yet',
                            ),
                            _MetricCard(
                              label: 'Training level',
                              value: profile?.trainingLevel ?? 'Pending',
                            ),
                            _MetricCard(
                              label: 'Check-ins logged',
                              value: '${data.checkins.length}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stacked = constraints.maxWidth < 940;
                            final left = Column(
                              children: [
                                _ProfileCard(
                                  profile: profile,
                                  session: data.session,
                                ),
                                const SizedBox(height: 14),
                                CheckinFormCard(
                                  onSubmit:
                                      ({
                                        required bodyweightKg,
                                        required sleepHours,
                                        required recoveryScore,
                                        required notes,
                                      }) => _saveCheckin(
                                        data.session,
                                        bodyweightKg: bodyweightKg,
                                        sleepHours: sleepHours,
                                        recoveryScore: recoveryScore,
                                        notes: notes,
                                      ),
                                ),
                              ],
                            );
                            final right = CheckinHistoryCard(
                              checkins: data.checkins,
                            );

                            if (stacked) {
                              return Column(
                                children: [
                                  left,
                                  const SizedBox(height: 14),
                                  right,
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: left),
                                const SizedBox(width: 14),
                                Expanded(flex: 2, child: right),
                              ],
                            );
                          },
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

class _AthleteDashboardData {
  const _AthleteDashboardData({
    required this.session,
    required this.profile,
    required this.checkins,
  });

  final AppSession session;
  final AthleteProfile? profile;
  final List<WeeklyCheckin> checkins;
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.session});

  final AthleteProfile? profile;
  final AppSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Athlete profile',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Text('Name: ${profile?.displayName ?? session.displayName}'),
          const SizedBox(height: 6),
          Text('Email: ${profile?.email ?? session.email}'),
          const SizedBox(height: 6),
          Text('Goal: ${profile?.goal ?? 'Pending setup'}'),
          const SizedBox(height: 6),
          Text('Training level: ${profile?.trainingLevel ?? 'Pending setup'}'),
          const SizedBox(height: 6),
          Text(
            'Notes: ${profile?.notes.isNotEmpty == true ? profile!.notes : 'No private coach notes yet.'}',
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x3328E0FF)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton(onPressed: onBack, child: const Text('Go to login')),
          ],
        ),
      ),
    );
  }
}
