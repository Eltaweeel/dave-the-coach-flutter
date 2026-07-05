import 'package:dave_the_coach_flutter/core/app_bootstrap.dart';
import 'package:dave_the_coach_flutter/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the Dave the COACH landing view', (tester) async {
    await tester.pumpWidget(DaveCoachApp(bootstrap: AppBootstrap.preview()));
    await tester.pumpAndSettle();

    expect(find.text('DAVE THE COACH'), findsOneWidget);
    expect(find.textContaining('athlete operating system'), findsOneWidget);
    expect(find.text('Abdo training update'), findsOneWidget);
    expect(find.text('Leg day skipped'), findsOneWidget);
    expect(find.text('Pull day planned'), findsOneWidget);
  });
}
