import 'package:flutter/material.dart';
import '../components/custom_button.dart';

class GameOverScreen extends StatelessWidget {
  final int score;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const GameOverScreen({
    super.key,
    required this.score,
    required this.onRetry,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'SCORE: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 50),
            CustomButton(
              text: 'RETRY',
              onPressed: onRetry,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'BACK TO MENU',
              onPressed: onExit,
            ),
          ],
        ),
      ),
    );
  }
}
