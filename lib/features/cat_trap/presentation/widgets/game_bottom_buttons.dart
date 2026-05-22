import 'package:flutter/material.dart';

import '../../domain/enums/game_state.dart';

class GameBottomButtons extends StatelessWidget {
  final GameState state;
  final VoidCallback onResetGame;
  final VoidCallback onResetScores;

  const GameBottomButtons({
    super.key,
    required this.state,
    required this.onResetGame,
    required this.onResetScores,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: onResetGame,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(
              state == GameState.playing ? 'REINICIAR' : 'JOGAR NOVAMENTE',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6A6A8A),
              side: const BorderSide(color: Color(0xFF2A2A4A)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
          if (state != GameState.playing) ...[
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onResetScores,
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('ZERAR PLACAR'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6A6A8A),
                side: const BorderSide(color: Color(0xFF2A2A4A)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }
}