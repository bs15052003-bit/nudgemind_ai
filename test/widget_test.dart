import 'package:flutter_test/flutter_test.dart';
import 'package:nudgemind_ai/main.dart';

void main() {
  testWidgets('NudgeMind App smoke test', (WidgetTester tester) async {
    // Builds our actual fresh NudgeMindApp framework stack
    await tester.pumpWidget(const NudgeMindApp());
    expect(find.byType(NudgeMindApp), findsOneWidget);
  });
}
