import 'package:dave_the_coach_flutter/core/app_bootstrap.dart';
import 'package:dave_the_coach_flutter/features/auth/domain/app_session.dart';
import 'package:dave_the_coach_flutter/features/auth/domain/app_user_role.dart';
import 'package:dave_the_coach_flutter/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.bootstrap});

  final AppBootstrap bootstrap;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  AppUserRole _role = AppUserRole.athlete;
  bool _loading = false;
  String? _error;
  String? _message;

  @override
  void dispose() {
    _nameController.dispose();
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
      _message = null;
    });

    try {
      final session = await widget.bootstrap.authRepository.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
        role: _role,
      );

      if (session == null) {
        setState(() {
          _message =
              'Account created. If your Supabase project requires email confirmation, confirm the email first, then sign in.';
        });
        return;
      }

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
    context.go(session.role == AppUserRole.coach ? '/coach' : '/athlete');
  }

  @override
  Widget build(BuildContext context) {
    return AuthFrame(
      title: 'Create your private coaching account',
      subtitle:
          'Athletes and coaches can use the same public app URL. Supabase decides who sees what once they authenticate.',
      footerPrompt: 'Already have an account?',
      footerActionLabel: 'Sign in',
      onFooterAction: () => context.go('/login'),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.bootstrap.config.isSupabaseConfigured)
              const BannerMessage(
                message:
                    'This build still needs SUPABASE_URL and SUPABASE_ANON_KEY to activate real sign-up and private data.',
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Display name'),
              validator: (value) => (value == null || value.trim().length < 2)
                  ? 'Enter your name'
                  : null,
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
            const SizedBox(height: 14),
            const Text('Role', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SegmentedButton<AppUserRole>(
              segments: const [
                ButtonSegment(
                  value: AppUserRole.athlete,
                  label: Text('Athlete'),
                ),
                ButtonSegment(value: AppUserRole.coach, label: Text('Coach')),
              ],
              selected: {_role},
              onSelectionChanged: (selection) {
                setState(() => _role = selection.first);
              },
            ),
            const SizedBox(height: 16),
            if (_error != null) BannerMessage(message: _error!),
            if (_message != null) BannerMessage(message: _message!),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.rocket_launch_rounded),
              label: Text(_loading ? 'Creating account...' : 'Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
