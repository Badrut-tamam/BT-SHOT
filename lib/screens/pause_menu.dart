import 'package:flutter/material.dart';
import '../components/custom_button.dart';

class PauseMenu extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const PauseMenu({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 50),
            CustomButton(
              text: 'RESUME',
              onPressed: onResume,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'RESTART',
              onPressed: onRestart,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'EXIT TO MENU',
              onPressed: onExit,
            ),
          ],
        ),
      ),
    );
  }
}
