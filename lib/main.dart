import 'package:dave_the_coach_flutter/app/app_router.dart';
import 'package:dave_the_coach_flutter/core/app_bootstrap.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  final bootstrap = await AppBootstrap.initialize();
  runApp(DaveCoachApp(bootstrap: bootstrap));
}

class DaveCoachApp extends StatelessWidget {
  const DaveCoachApp({super.key, required this.bootstrap});

  final AppBootstrap bootstrap;

  @override
  Widget build(BuildContext context) {
    final router = createAppRouter(bootstrap);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF63F3FF),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF63F3FF),
          secondary: const Color(0xFF8DFF8A),
          tertiary: const Color(0xFFC77DFF),
          surface: const Color(0xFF0B1224),
        );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Dave the COACH | Mobile Athlete OS',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFF050816),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0x3328E0FF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0x3328E0FF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF63F3FF)),
          ),
          labelStyle: const TextStyle(color: Color(0xFF9BA6C7)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF63F3FF),
            foregroundColor: const Color(0xFF050816),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0x3328E0FF)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF63F3FF)),
        ),
      ),
      routerConfig: router,
    );
  }
}
