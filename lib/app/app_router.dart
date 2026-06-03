import 'package:dave_the_coach_flutter/core/app_bootstrap.dart';
import 'package:dave_the_coach_flutter/features/athletes/presentation/athlete_dashboard_screen.dart';
import 'package:dave_the_coach_flutter/features/auth/presentation/auth_gate.dart';
import 'package:dave_the_coach_flutter/features/auth/presentation/login_screen.dart';
import 'package:dave_the_coach_flutter/features/auth/presentation/signup_screen.dart';
import 'package:dave_the_coach_flutter/features/coach/presentation/coach_dashboard_screen.dart';
import 'package:dave_the_coach_flutter/features/public/presentation/public_landing_screen.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter(AppBootstrap bootstrap) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => PublicLandingScreen(bootstrap: bootstrap),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(bootstrap: bootstrap),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignupScreen(bootstrap: bootstrap),
      ),
      GoRoute(
        path: '/app',
        builder: (context, state) => AuthGate(bootstrap: bootstrap),
      ),
      GoRoute(
        path: '/athlete',
        builder: (context, state) =>
            AthleteDashboardScreen(bootstrap: bootstrap),
      ),
      GoRoute(
        path: '/coach',
        builder: (context, state) => CoachDashboardScreen(bootstrap: bootstrap),
      ),
    ],
  );
}
