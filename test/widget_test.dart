import 'package:flutter_test/flutter_test.dart';
import 'package:ai_persian_secretary/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AiPersianSecretaryApp());
    expect(find.text('منشی هوشمند فارسی'), findsNothing);
  });
}
