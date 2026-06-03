import 'package:dave_the_coach_flutter/core/app_bootstrap.dart';
import 'package:dave_the_coach_flutter/features/auth/domain/app_user_role.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublicLandingScreen extends StatelessWidget {
  const PublicLandingScreen({super.key, required this.bootstrap});

  final AppBootstrap bootstrap;

  @override
  Widget build(BuildContext context) {
    final configured = bootstrap.config.isSupabaseConfigured;

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _chip('DAVE THE COACH'),
                        _chip('Flutter web / PWA'),
                        _chip(
                          configured
                              ? 'Supabase configured'
                              : 'Supabase setup required',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: _panelDecoration(),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final stacked = constraints.maxWidth < 900;
                          final left = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dave the COACH athlete operating system',
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      height: 0.95,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'This public app URL is how you launch it for real users. Athletes and coaches open the link, sign in, then access their private data through Supabase auth and row-level security.',
                                style: TextStyle(
                                  color: Color(0xFF9BA6C7),
                                  height: 1.6,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  FilledButton.icon(
                                    onPressed: () => context.go('/login'),
                                    icon: const Icon(Icons.login_rounded),
                                    label: const Text('Login'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => context.go('/signup'),
                                    icon: const Icon(
                                      Icons.person_add_alt_1_rounded,
                                    ),
                                    label: const Text('Create account'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => context.go('/app'),
                                    icon: const Icon(
                                      Icons.arrow_forward_rounded,
                                    ),
                                    label: const Text('Open app gate'),
                                  ),
                                ],
                              ),
                            ],
                          );

                          final right = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _statusCard(
                                title: 'Public launch path',
                                body:
                                    'Keep this GitHub Pages URL public. The app shell is public, but athlete data stays private behind Supabase auth + RLS.',
                                accent: const Color(0xFF63F3FF),
                              ),
                              const SizedBox(height: 12),
                              _statusCard(
                                title: 'Athlete flow',
                                body:
                                    'Athlete signs up, profile is created, weekly check-ins are saved privately, and updates can be reported to Dave.',
                                accent: const Color(0xFF8DFF8A),
                              ),
                              const SizedBox(height: 12),
                              _statusCard(
                                title: 'Coach flow',
                                body:
                                    'Coach logs in to monitor assigned athletes, progress, and check-in snapshots.',
                                accent: const Color(0xFFC77DFF),
                              ),
                            ],
                          );

                          if (stacked) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                left,
                                const SizedBox(height: 18),
                                right,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: left),
                              const SizedBox(width: 18),
                              Expanded(flex: 2, child: right),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        _metricCard(
                          'Login modes',
                          'Athlete + Coach',
                          Icons.verified_user_rounded,
                        ),
                        _metricCard(
                          'Privacy model',
                          'Supabase RLS',
                          Icons.lock_rounded,
                        ),
                        _metricCard(
                          'Reporting',
                          bootstrap.config.isDaveReportingConfigured
                              ? 'Webhook ready'
                              : 'Webhook pending',
                          Icons.hub_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: _panelDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Test roles',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: AppUserRole.values
                                .map(
                                  (role) => Chip(
                                    label: Text(role.label),
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.05,
                                    ),
                                    side: const BorderSide(
                                      color: Color(0x3328E0FF),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            configured
                                ? 'Supabase keys are configured at build time. You can now sign up real users and move into private athlete data.'
                                : 'To make login fully real for public users, set SUPABASE_URL and SUPABASE_ANON_KEY in the GitHub Pages build workflow and apply the Supabase SQL setup in docs/setup/supabase.md.',
                            style: const TextStyle(
                              color: Color(0xFF9BA6C7),
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _metricCard(String title, String value, IconData icon) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF63F3FF)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Color(0xFF9BA6C7))),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ],
      ),
    );
  }

  static Widget _statusCard({
    required String title,
    required String body,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(color: Color(0xFF9BA6C7), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x3328E0FF)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF63F3FF),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  static BoxDecoration _panelDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: const Color(0x3328E0FF)),
      gradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.025),
        ],
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x55000000),
          blurRadius: 40,
          offset: Offset(0, 16),
        ),
      ],
    );
  }
}
