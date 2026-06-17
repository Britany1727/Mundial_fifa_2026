import 'package:flutter_test/flutter_test.dart';
import 'package:mundial_fifa_2026/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const Mundial2026App());
    expect(find.text('Mundial 2026'), findsOneWidget);
  });
}
