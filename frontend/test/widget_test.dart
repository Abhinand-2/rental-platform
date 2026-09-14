import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('Rental Platform app loads', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const RentalPlatformApp(),
    );

    await tester.pump();

    expect(find.text('Rental Platform'), findsNothing);
  });
}