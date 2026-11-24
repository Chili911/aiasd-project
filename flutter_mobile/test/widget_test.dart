import 'package:flutter_test/flutter_test.dart';
import 'package:weatherly/main.dart';

void main() {
  testWidgets('Weatherly displays the login screen', (tester) async {
    await tester.pumpWidget(const WeatherlyApp());
    await tester.pumpAndSettle();

    expect(find.byType(WeatherlyApp), findsOneWidget);
    expect(find.text('Weatherly'), findsWidgets);
  });
}