import 'package:flutter_test/flutter_test.dart';
import 'package:shopease_flutter/main.dart';

void main() {
  testWidgets('ShopEase app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ShopEaseApp());

    expect(find.text('ShopEase'), findsOneWidget);
  });
}
