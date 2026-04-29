import 'package:flutter/material.dart';

class ScoreHeader extends StatelessWidget {
  final int score;
  final VoidCallback onBack;

  const ScoreHeader({
    super.key,
    required this.score,
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
            Row(
              children: [
                const Icon(Icons.star, color: Colors.yellow, size: 24),
                const SizedBox(width: 8),
                Text(
                  '$score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Icon(Icons.favorite, color: Colors.red, size: 24),
                SizedBox(width: 4),
                Icon(Icons.favorite, color: Colors.red, size: 24),
                SizedBox(width: 4),
                Icon(Icons.favorite_border, color: Colors.red, size: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
