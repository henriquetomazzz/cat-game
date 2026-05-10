import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pegue_o_gato/game_screen.dart';

void main() {
  testWidgets('Game screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: GameScreen()));
    await tester.pump();
    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('GATO'), findsOneWidget);
    expect(find.text('CERCA'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
  });
}
