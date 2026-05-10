import 'package:flutter/material.dart';
import 'game_screen.dart';

void main() {
  runApp(const PegueOGatoApp());
}

class PegueOGatoApp extends StatelessWidget {
  const PegueOGatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pegue o Gato',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4A90D9),
          secondary: Color(0xFFE94560),
          surface: Color(0xFF1A1A2E),
        ),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
