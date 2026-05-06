import 'package:flutter/material.dart';

class ScoreHeader extends StatelessWidget {
  final int score;
  final int level;
  final int bubbles;
  final VoidCallback onBack;

  const ScoreHeader({
    super.key,
    required this.score,
    required this.level,
    required this.bubbles,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      color: Colors.black,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBack,
            ),
            // Level Info
            Column(
              children: [
                const Text('LEVEL', style: TextStyle(color: Colors.grey, fontSize: 10)),
                Text('$level', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            // Score Info
            Column(
              children: [
                const Text('SCORE', style: TextStyle(color: Colors.grey, fontSize: 10)),
                Text('$score', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              ],
            ),
            // Bubbles Info
            Column(
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
