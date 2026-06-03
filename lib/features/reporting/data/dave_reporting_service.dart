import 'dart:convert';

import 'package:dave_the_coach_flutter/features/auth/domain/app_session.dart';
import 'package:dave_the_coach_flutter/features/checkins/domain/weekly_checkin.dart';
import 'package:http/http.dart' as http;

class DaveReportingService {
  DaveReportingService({required this.webhookUrl, required this.webhookSecret});

  final String webhookUrl;
  final String webhookSecret;

  bool get isConfigured =>
      webhookUrl.trim().isNotEmpty && webhookSecret.trim().isNotEmpty;

  Future<void> reportWeeklyCheckin({
    required AppSession actor,
    required WeeklyCheckin checkin,
  }) async {
    if (!isConfigured) {
      return;
    }

    final response = await http.post(
      Uri.parse(webhookUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $webhookSecret',
      },
      body: jsonEncode({
        'event': 'weekly_checkin_saved',
        'actor': {
          'user_id': actor.userId,
          'email': actor.email,
          'display_name': actor.displayName,
          'role': actor.role.name,
        },
        'checkin': {
          'id': checkin.id,
          'athlete_id': checkin.athleteId,
          'week_start': checkin.weekStart.toIso8601String(),
          'bodyweight_kg': checkin.bodyweightKg,
          'sleep_hours': checkin.sleepHours,
          'recovery_score': checkin.recoveryScore,
          'notes': checkin.notes,
        },
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception(
        'Dave reporting failed with status ${response.statusCode}.',
      );
    }
  }
}
