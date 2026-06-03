import 'package:dave_the_coach_flutter/core/app_bootstrap.dart';
import 'package:dave_the_coach_flutter/features/auth/domain/app_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.bootstrap});

  final AppBootstrap bootstrap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<AppSession?>(
          future: bootstrap.authRepository.currentSession(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }

            final session = snapshot.data;
            if (session == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.go('/login');
                }
              });
              return const Text('Redirecting to login...');
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) {
                return;
              }
              context.go(session.role.name == 'coach' ? '/coach' : '/athlete');
            });
            return const Text('Opening workspace...');
          },
        ),
      ),
    );
  }
}
