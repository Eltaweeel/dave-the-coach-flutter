import 'package:dave_the_coach_flutter/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the Dave the COACH hero copy', (tester) async {
    await tester.pumpWidget(const DaveCoachApp());

    expect(find.text('DAVE THE COACH'), findsOneWidget);
    expect(
      find.textContaining('A futuristic calisthenics coaching app'),
      findsOneWidget,
    );
  });
}
