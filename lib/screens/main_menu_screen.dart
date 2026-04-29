import 'package:flutter/material.dart';
import '../components/custom_button.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              // Game Title
              const Text(
                'BUBBLE\nSHOOTER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              // Buttons
              CustomButton(
                text: 'PLAY',
                onPressed: () {
                  Navigator.pushNamed(context, '/game');
                },
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'SETTINGS',
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'LEADERBOARD',
                onPressed: () {
                  // Dummy action
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Leaderboard not implemented yet')),
                  );
                },
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'EXIT',
                onPressed: () {
                  // Dummy exit
                },
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
