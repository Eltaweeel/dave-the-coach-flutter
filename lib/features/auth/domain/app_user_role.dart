enum AppUserRole { athlete, coach }

extension AppUserRoleX on AppUserRole {
  String get value => name;

  static AppUserRole fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'coach':
        return AppUserRole.coach;
      case 'athlete':
      default:
        return AppUserRole.athlete;
    }
  }

  String get label => this == AppUserRole.coach ? 'Coach' : 'Athlete';
}
