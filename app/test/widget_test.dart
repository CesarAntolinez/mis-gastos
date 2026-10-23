import 'package:flutter_test/flutter_test.dart';

import 'package:mis_gastos/main.dart';

void main() {
  testWidgets('App renders welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(const MisGastosApp());

    expect(find.text('Bienvenido a Mis Gastos'), findsOneWidget);
  });
}
