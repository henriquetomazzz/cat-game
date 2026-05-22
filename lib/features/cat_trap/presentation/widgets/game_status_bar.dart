import 'package:flutter/material.dart';

import '../../domain/enums/game_state.dart';

class GameStatusBar extends StatelessWidget {
  final GameState state;
  final bool isPlayerTurn;

  const GameStatusBar({
    super.key,
    required this.state,
    required this.isPlayerTurn,
  });

  @override
  Widget build(BuildContext context) {
    final String text;
    final Color color;

    switch (state) {
      case GameState.playing:
        if (isPlayerTurn) {
          text = 'SUA VEZ — toque em um hexágono adjacente';
          color = const Color(0xFF4A90D9);
        } else {
          text = 'VEZ DA CERCA...';
          color = const Color(0xFFE94560);
        }

      case GameState.catWins:
        text = 'VOCÊ VENCEU! O GATO FUGIU!';
        color = const Color(0xFF4ADE80);

      case GameState.fenceWins:
        text = 'A CERCA VENCEU! O GATO FOI PRESO!';
        color = const Color(0xFFE94560);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      alignment: Alignment.center,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 1,
        ),
        child: Text(text),
      ),
    );
  }
}