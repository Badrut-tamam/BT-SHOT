import 'package:flutter/material.dart';
import '../components/custom_button.dart';
import '../services/save_service.dart';

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
    int highScore = SaveService.getHighScore();
    bool isNewHighScore = score >= highScore && score > 0;

    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isNewHighScore ? 'NEW HIGH SCORE!' : 'GAME OVER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isNewHighScore ? Colors.amber : Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Score Display
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      const Text('TOTAL SCORE', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        '$score',
                        style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      const Divider(color: Colors.white24),
                      const Text('BEST SCORE', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        '$highScore',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),
                CustomButton(
                  text: 'PLAY AGAIN',
                  onPressed: onRetry,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'EXIT TO MENU',
                  onPressed: onExit,
                  color: Colors.transparent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
