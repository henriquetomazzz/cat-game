import 'package:flutter/material.dart';

import 'features/cat_trap/presentation/screens/game_screen.dart';

void main() {
  runApp(const CatTrapApp());
}

class CatTrapApp extends StatelessWidget {
  const CatTrapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat Trap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}