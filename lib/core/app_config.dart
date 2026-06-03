class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.daveWebhookUrl,
    required this.daveWebhookSecret,
  });

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
      supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
      daveWebhookUrl: String.fromEnvironment('DAVE_WEBHOOK_URL'),
      daveWebhookSecret: String.fromEnvironment('DAVE_WEBHOOK_SECRET'),
    );
  }

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String daveWebhookUrl;
  final String daveWebhookSecret;

  bool get isSupabaseConfigured =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  bool get isDaveReportingConfigured =>
      daveWebhookUrl.trim().isNotEmpty && daveWebhookSecret.trim().isNotEmpty;
}
