import 'package:flutter/material.dart';

class ScoreHeader extends StatelessWidget {
  final int score;
  final int level;
  final int bubbles;
  final int coins;
  final VoidCallback onBack;

  const ScoreHeader({
    super.key,
    required this.score,
    required this.level,
    required this.bubbles,
    required this.coins,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBack,
            ),
            // Level & Coins
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LEVEL $level', style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text('$coins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
            // Score (Center)
            Column(
              children: [
                const Text('SCORE', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                Text('$score', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              ],
            ),
            // Bubbles Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('BUBBLES', style: TextStyle(color: Colors.grey, fontSize: 10)),
                Row(
                  children: [
                    const Icon(Icons.blur_on, color: Colors.blueAccent, size: 16),
                    const SizedBox(width: 4),
                    Text('$bubbles', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
