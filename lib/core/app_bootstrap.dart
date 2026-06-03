import 'package:dave_the_coach_flutter/core/app_config.dart';
import 'package:dave_the_coach_flutter/features/athletes/data/athlete_repository.dart';
import 'package:dave_the_coach_flutter/features/auth/data/auth_repository.dart';
import 'package:dave_the_coach_flutter/features/checkins/data/checkin_repository.dart';
import 'package:dave_the_coach_flutter/features/reporting/data/dave_reporting_service.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppBootstrap {
  AppBootstrap._({required this.config, required this.supabaseClient})
    : authRepository = AuthRepository(client: supabaseClient),
      athleteRepository = AthleteRepository(client: supabaseClient),
      checkinRepository = CheckinRepository(client: supabaseClient),
      daveReportingService = DaveReportingService(
        webhookUrl: config.daveWebhookUrl,
        webhookSecret: config.daveWebhookSecret,
      );

  factory AppBootstrap.preview() {
    const config = AppConfig(
      supabaseUrl: '',
      supabaseAnonKey: '',
      daveWebhookUrl: '',
      daveWebhookSecret: '',
    );
    return AppBootstrap._(config: config, supabaseClient: null);
  }

  final AppConfig config;
  final SupabaseClient? supabaseClient;
  final AuthRepository authRepository;
  final AthleteRepository athleteRepository;
  final CheckinRepository checkinRepository;
  final DaveReportingService daveReportingService;

  static Future<AppBootstrap> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    final config = AppConfig.fromEnvironment();
    SupabaseClient? client;

    if (config.isSupabaseConfigured) {
      await Supabase.initialize(
        url: config.supabaseUrl,
        anonKey: config.supabaseAnonKey,
      );
      client = Supabase.instance.client;
    }

    return AppBootstrap._(config: config, supabaseClient: client);
  }
}
