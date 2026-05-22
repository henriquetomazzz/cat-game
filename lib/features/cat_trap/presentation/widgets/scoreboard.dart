import 'package:flutter/material.dart';

class Scoreboard extends StatelessWidget {
  final int scoreCat;
  final int scoreFence;

  const Scoreboard({
    super.key,
    required this.scoreCat,
    required this.scoreFence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ScoreSide(
            icon: Icons.pets,
            label: 'GATO',
            score: scoreCat,
            color: Colors.white,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A6A),
              ),
            ),
          ),
          _ScoreSide(
            icon: Icons.grid_on,
            label: 'CERCA',
            score: scoreFence,
            color: Color(0xFFE94560),
          ),
        ],
      ),
    );
  }
}

class _ScoreSide extends StatelessWidget {
  final IconData icon;
  final String label;
  final int score;
  final Color color;

  const _ScoreSide({
    required this.icon,
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6A6A8A),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}