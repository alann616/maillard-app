import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart'; // Asegúrate de que importe main
import 'package:app/core/database/app_database.dart'; // Importa la BD

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Inicializamos una BD real (o mockeada idealmente) para que el test no falle
    final db = AppDatabase(); 

    // Build our app and trigger a frame.
    // AQUÍ ESTABA EL ERROR: Usamos MainApp y le pasamos la db
    await tester.pumpWidget(MainApp(db: db));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}