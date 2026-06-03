import 'package:flutter/material.dart';

void main() {
  runApp(const DaveCoachApp());
}

const _canvas = Color(0xFF050816);
const _panel = Color(0xFF0B1224);
const _panelSoft = Color(0xFF101A31);
const _line = Color(0x3328E0FF);
const _textSoft = Color(0xFF98A8C7);
const _electricBlue = Color(0xFF57A8FF);
const _electricCyan = Color(0xFF63F3FF);
const _electricGreen = Color(0xFF8DFF8A);
const _electricPink = Color(0xFFC77DFF);

enum DemoSurface { athlete, coach }

class DaveCoachApp extends StatelessWidget {
  const DaveCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _electricCyan,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _electricCyan,
      secondary: _electricGreen,
      tertiary: _electricPink,
      surface: _panel,
      onSurface: Colors.white,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dave the COACH | Mobile Athlete OS',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: _canvas,
        textTheme: Typography.whiteMountainView.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: _panel,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: _line),
          ),
        ),
      ),
      home: const ShowcaseScreen(),
    );
  }
}

class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  DemoSurface _surface = DemoSurface.athlete;

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
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              left: -80,
              child: _GlowOrb(color: _electricCyan, size: 340),
            ),
            const Positioned(
              top: 140,
              right: -100,
              child: _GlowOrb(color: _electricGreen, size: 360),
            ),
            const Positioned(
              bottom: -120,
              right: 80,
              child: _GlowOrb(color: _electricPink, size: 300),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _TopBar(),
                          const SizedBox(height: 18),
                          _HeroSection(
                            selectedSurface: _surface,
                            onSelectSurface: (value) {
                              setState(() => _surface = value);
                            },
                          ),
                          const SizedBox(height: 18),
                          const _MetricsSection(),
                          const SizedBox(height: 18),
                          const _InstallSection(),
                          const SizedBox(height: 18),
                          _DemoSection(surface: _surface),
                          const SizedBox(height: 18),
                          const _RoadmapSection(),
                          const SizedBox(height: 18),
                          const _FooterSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _line),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 12,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_electricGreen, _electricCyan],
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'D',
                  style: TextStyle(
                    color: _canvas,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'DAVE THE COACH',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Installable athlete OS · coach business cockpit',
                    style: TextStyle(color: _textSoft, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _PillLabel(label: 'Flutter web'),
              _PillLabel(label: 'PWA install ready'),
              _PillLabel(label: 'Coach + athlete modes'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.selectedSurface,
    required this.onSelectSurface,
  });

  final DemoSurface selectedSurface;
  final ValueChanged<DemoSurface> onSelectSurface;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 980;
        final children = [
          Expanded(
            flex: stacked ? 0 : 3,
            child: _GlassPanel(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionEyebrow(label: 'FUTURE-READY FITNESS PRODUCT'),
                  const SizedBox(height: 18),
                  Text(
                    'A futuristic calisthenics coaching app that feels premium on web, iPhone, and Android.',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 0.95,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This separate SaaS surface gives Dave the COACH a business-grade operating layer for athlete onboarding, weekly check-ins, plan control, and future Hermes reporting — while your Hunter Agent site remains the public showcase.',
                    style: TextStyle(
                      color: _textSoft,
                      fontSize: 16,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => onSelectSurface(DemoSurface.athlete),
                        icon: const Icon(Icons.sports_gymnastics_rounded),
                        label: const Text('Preview athlete experience'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => onSelectSurface(DemoSurface.coach),
                        icon: const Icon(Icons.admin_panel_settings_rounded),
                        label: const Text('Preview coach command center'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: const [
                      _StatBadge(value: 'PWA', label: 'Install from browser'),
                      _StatBadge(value: '2 modes', label: 'Athlete + coach'),
                      _StatBadge(value: 'Supabase next', label: 'Ready for auth/data'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: stacked ? 0 : 18, height: stacked ? 18 : 0),
          Expanded(
            flex: stacked ? 0 : 2,
            child: _GlassPanel(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRODUCT POSITIONING',
                    style: TextStyle(
                      color: _electricCyan,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _FeatureRow(
                    icon: Icons.phone_iphone_rounded,
                    title: 'Mobile-first install flow',
                    body: 'Works as a web app today and can be added to the home screen on supported mobile browsers.',
                  ),
                  const SizedBox(height: 14),
                  const _FeatureRow(
                    icon: Icons.flash_on_rounded,
                    title: 'Energetic athlete feel',
                    body: 'Dark neon surfaces, high-contrast stats, and calisthenics-focused dashboard language.',
                  ),
                  const SizedBox(height: 14),
                  const _FeatureRow(
                    icon: Icons.hub_rounded,
                    title: 'Built for future automation',
                    body: 'Prepared for live auth, coach-managed plans, and Hermes update routing to Dave.',
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SegmentedButton<DemoSurface>(
                      segments: const [
                        ButtonSegment(
                          value: DemoSurface.athlete,
                          label: Text('Athlete UI'),
                          icon: Icon(Icons.monitor_heart_outlined),
                        ),
                        ButtonSegment(
                          value: DemoSurface.coach,
                          label: Text('Coach UI'),
                          icon: Icon(Icons.query_stats_rounded),
                        ),
                      ],
                      selected: {selectedSurface},
                      onSelectionChanged: (value) {
                        onSelectSurface(value.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];

        return stacked
            ? Column(children: children)
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: children);
      },
    );
  }
}

class _MetricsSection extends StatelessWidget {
  const _MetricsSection();

  @override
  Widget build(BuildContext context) {
    const metrics = [
      ('12 min', 'Fast athlete check-in flow'),
      ('4 layers', 'Plan, recovery, progress, messaging'),
      ('1 coach HQ', 'Dave owns all athlete operations'),
      ('∞ upgrades', 'Ready for Supabase and native wrappers'),
    ];

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: metrics
          .map(
            (metric) => SizedBox(
              width: 285,
              child: _GlassPanel(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.$1,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      metric.$2,
                      style: const TextStyle(color: _textSoft, height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _InstallSection extends StatelessWidget {
  const _InstallSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 920;
        return stacked
            ? Column(
                children: const [
                  _InstallCard(),
                  SizedBox(height: 16),
                  _DeviceCard(),
                ],
              )
            : const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _InstallCard()),
                  SizedBox(width: 16),
                  Expanded(child: _DeviceCard()),
                ],
              );
      },
    );
  }
}

class _InstallCard extends StatelessWidget {
  const _InstallCard();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionEyebrow(label: 'INSTALL EXPERIENCE'),
          SizedBox(height: 16),
          Text(
            'Users can open the app from a link, then install it to the home screen on supported mobile devices.',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 12),
          Text(
            'That gives you a download-like experience today with a single Flutter codebase. Full App Store / Play Store packaging can be added later with native signing and store pipelines.',
            style: TextStyle(color: _textSoft, height: 1.55),
          ),
          SizedBox(height: 18),
          _InstallStep(
            step: '01',
            title: 'Open the private app URL',
            body: 'Athletes receive a branded link from Dave.',
          ),
          _InstallStep(
            step: '02',
            title: 'Add to home screen',
            body: 'Supported browsers present install / add-to-home-screen options.',
          ),
          _InstallStep(
            step: '03',
            title: 'Use it like an app',
            body: 'Fast dashboard loading, check-ins, and coach updates from one interface.',
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionEyebrow(label: 'DEVICE STRATEGY'),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _DevicePill(icon: Icons.android_rounded, label: 'Android browser install'),
              _DevicePill(icon: Icons.phone_iphone_rounded, label: 'iPhone home-screen app'),
              _DevicePill(icon: Icons.desktop_windows_rounded, label: 'Desktop dashboard'),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _line),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended rollout',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                SizedBox(height: 12),
                Text('• Phase 1: installable web app for athletes + Dave'),
                SizedBox(height: 6),
                Text('• Phase 2: Supabase auth, plans, check-ins, reporting'),
                SizedBox(height: 6),
                Text('• Phase 3: native store packaging if you want App Store / Play Store delivery'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({required this.surface});

  final DemoSurface surface;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionEyebrow(
            label: surface == DemoSurface.athlete ? 'ATHLETE SURFACE' : 'COACH SURFACE',
          ),
          const SizedBox(height: 16),
          Text(
            surface == DemoSurface.athlete
                ? 'Athlete dashboard demo'
                : 'Coach command-center demo',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            surface == DemoSurface.athlete
                ? 'Focused on momentum, check-ins, weekly structure, and visible progression.'
                : 'Focused on roster management, athlete attention, delivery flow, and business control.',
            style: const TextStyle(color: _textSoft, height: 1.5),
          ),
          const SizedBox(height: 22),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: surface == DemoSurface.athlete
                ? const _AthletePreview(key: ValueKey('athlete-preview'))
                : const _CoachPreview(key: ValueKey('coach-preview')),
          ),
        ],
      ),
    );
  }
}

class _AthletePreview extends StatelessWidget {
  const _AthletePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 940;
        final statusCards = Wrap(
          spacing: 14,
          runSpacing: 14,
          children: const [
            _InfoCard(title: 'Recovery score', value: '89%', note: 'Sleep + soreness + readiness'),
            _InfoCard(title: 'Check-in streak', value: '11', note: 'Weekly compliance streak'),
            _InfoCard(title: 'Skill focus', value: 'MU + WPU', note: 'Muscle-up timing + weighted pull-ups'),
          ],
        );

        final planCard = _SubPanel(
          title: 'This week\'s plan stack',
          child: Column(
            children: const [
              _PlanTile(day: 'MON', title: 'Pull / muscle-up timing', completion: 0.72),
              SizedBox(height: 12),
              _PlanTile(day: 'WED', title: 'Push / weighted dip quality', completion: 0.48),
              SizedBox(height: 12),
              _PlanTile(day: 'SAT', title: 'Legs / trunk / reload power', completion: 0.25),
            ],
          ),
        );

        final journeyCard = _SubPanel(
          title: 'Journey timeline',
          child: Column(
            children: const [
              _TimelineTile(label: 'Today', body: 'Logged energy 8/10 and elbow pain 1/10.'),
              _TimelineTile(label: '2 days ago', body: 'Pulled 24 kg weighted pull-up triple with clean tempo.'),
              _TimelineTile(label: 'Last week', body: 'Dave updated pulling volume after recovery trend improved.'),
            ],
          ),
        );

        if (stacked) {
          return Column(
            children: [
              statusCards,
              const SizedBox(height: 14),
              planCard,
              const SizedBox(height: 14),
              journeyCard,
            ],
          );
        }

        return Column(
          children: [
            statusCards,
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: planCard),
                const SizedBox(width: 14),
                Expanded(flex: 2, child: journeyCard),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CoachPreview extends StatelessWidget {
  const _CoachPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 940;
        final roster = _SubPanel(
          title: 'Coach roster focus',
          child: Column(
            children: const [
              _RosterTile(name: 'Abdo', status: 'Needs weekly review', accent: _electricGreen),
              SizedBox(height: 12),
              _RosterTile(name: 'Sara M.', status: 'Recovery trending down', accent: _electricPink),
              SizedBox(height: 12),
              _RosterTile(name: 'Youssef A.', status: 'Ready for plan progression', accent: _electricCyan),
            ],
          ),
        );

        final pipeline = _SubPanel(
          title: 'Automation pipeline',
          child: Column(
            children: const [
              _TimelineTile(label: 'Input', body: 'Athlete logs training, recovery, and milestone notes.'),
              _TimelineTile(label: 'Coach layer', body: 'Dave reviews highlights and adjusts the weekly block.'),
              _TimelineTile(label: 'Hermes bridge', body: 'Important changes can be routed into reporting or reminders.'),
            ],
          ),
        );

        final stats = Wrap(
          spacing: 14,
          runSpacing: 14,
          children: const [
            _InfoCard(title: 'Active athletes', value: '18', note: 'Across calisthenics + body recomposition'),
            _InfoCard(title: 'Plans updated', value: '7', note: 'This week across the roster'),
            _InfoCard(title: 'Urgent flags', value: '2', note: 'Mobility and recovery intervention'),
          ],
        );

        if (stacked) {
          return Column(
            children: [
              stats,
              const SizedBox(height: 14),
              roster,
              const SizedBox(height: 14),
              pipeline,
            ],
          );
        }

        return Column(
          children: [
            stats,
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: roster),
                const SizedBox(width: 14),
                Expanded(flex: 2, child: pipeline),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _RoadmapSection extends StatelessWidget {
  const _RoadmapSection();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionEyebrow(label: 'BUILD ROADMAP'),
          SizedBox(height: 16),
          Text(
            'What comes next after this Flutter foundation',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 16),
          _InstallStep(
            step: '01',
            title: 'Connect Supabase',
            body: 'Real sign-in, athlete profiles, plans, weekly check-ins, and role-aware data access.',
          ),
          _InstallStep(
            step: '02',
            title: 'Add real editing flows',
            body: 'Coach updates, athlete progress forms, exercise completion, and timeline journaling.',
          ),
          _InstallStep(
            step: '03',
            title: 'Ship automation',
            body: 'Hermes reporting, reminders, update summaries, and coach-side notifications.',
          ),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: const [
          Text(
            'Dave the COACH • Flutter athlete operating system',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'Built as a separate app surface so Hunter Agent can remain your public showcase.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textSoft),
          ),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: _line),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.025),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 40,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SubPanel extends StatelessWidget {
  const _SubPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panelSoft.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}

class _PillLabel extends StatelessWidget {
  const _PillLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: _line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _textSoft,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _electricCyan.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _electricCyan,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: _textSoft)),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: _line),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: _electricGreen),
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
              const SizedBox(height: 4),
              Text(body, style: const TextStyle(color: _textSoft, height: 1.45)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InstallStep extends StatelessWidget {
  const _InstallStep({
    required this.step,
    required this.title,
    required this.body,
  });

  final String step;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [_electricGreen, _electricCyan],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              step,
              style: const TextStyle(
                color: _canvas,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: _textSoft, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DevicePill extends StatelessWidget {
  const _DevicePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _electricCyan, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.note,
  });

  final String title;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panelSoft.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: _textSoft)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(note, style: const TextStyle(color: _textSoft, height: 1.4)),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.day,
    required this.title,
    required this.completion,
  });

  final String day;
  final String title;
  final double completion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                day,
                style: const TextStyle(
                  color: _electricGreen,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text('${(completion * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: completion,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(_electricCyan),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: _electricGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: _textSoft, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RosterTile extends StatelessWidget {
  const _RosterTile({
    required this.name,
    required this.status,
    required this.accent,
  });

  final String name;
  final String status;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              name.characters.first,
              style: TextStyle(color: accent, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(status, style: const TextStyle(color: _textSoft)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: _textSoft),
        ],
      ),
    );
  }
}
