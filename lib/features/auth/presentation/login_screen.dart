import 'package:dave_the_coach_flutter/core/app_bootstrap.dart';
import 'package:dave_the_coach_flutter/features/auth/domain/app_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.bootstrap});

  final AppBootstrap bootstrap;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = await widget.bootstrap.authRepository.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      _routeForSession(session);
    } catch (error) {
      setState(() => _error = '$error');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _routeForSession(AppSession session) {
    if (!mounted) {
      return;
    }
    context.go(session.role.name == 'coach' ? '/coach' : '/athlete');
  }

  @override
  Widget build(BuildContext context) {
    return AuthFrame(
      title: 'Sign in to the athlete workspace',
      subtitle:
          'Use this public app URL as your launch point. Real privacy is enforced by Supabase auth and row-level security.',
      footerPrompt: 'No account yet?',
      footerActionLabel: 'Create one',
      onFooterAction: () => context.go('/signup'),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.bootstrap.config.isSupabaseConfigured)
              const BannerMessage(
                message:
                    'Supabase keys are not configured in this build yet. Add SUPABASE_URL and SUPABASE_ANON_KEY in GitHub Actions to enable live login.',
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => (value == null || !value.contains('@'))
                  ? 'Enter a valid email'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) => (value == null || value.length < 6)
                  ? 'Password must be at least 6 characters'
                  : null,
            ),
            const SizedBox(height: 16),
            if (_error != null) BannerMessage(message: _error!),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_rounded),
              label: Text(_loading ? 'Signing in...' : 'Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthFrame extends StatelessWidget {
  const AuthFrame({
    required this.title,
    required this.subtitle,
    required this.footerPrompt,
    required this.footerActionLabel,
    required this.onFooterAction,
    required this.child,
  });

  final String title;
  final String subtitle;
  final String footerPrompt;
  final String footerActionLabel;
  final VoidCallback onFooterAction;
  final Widget child;

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 520,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0x3328E0FF)),
                  color: Colors.white.withValues(alpha: 0.04),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Back to launch page'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9BA6C7),
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 20),
                    child,
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          footerPrompt,
                          style: const TextStyle(color: Color(0xFF9BA6C7)),
                        ),
                        TextButton(
                          onPressed: onFooterAction,
                          child: Text(footerActionLabel),
                        ),
                      ],
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
}

class BannerMessage extends StatelessWidget {
  const BannerMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x3328E0FF)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF9BA6C7), height: 1.45),
      ),
    );
  }
}
