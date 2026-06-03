import 'package:dave_the_coach_flutter/features/auth/domain/app_user_role.dart';

class AppSession {
  const AppSession({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
  });

  final String userId;
  final String email;
  final String displayName;
  final AppUserRole role;
}
