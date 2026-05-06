import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../components/custom_button.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Colors.blueGrey[900]!,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // Game Title with Animation
                FadeInDown(
                  duration: const Duration(seconds: 1),
                  child: Text(
                    'BUBBLE\nSHOOTER',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      height: 0.9,
                      shadows: [
                        Shadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 20),
                        Shadow(color: Colors.purpleAccent.withOpacity(0.3), blurRadius: 40),
                      ],
                    ),
                  ),
                ),
                const Text(
                  'PREMIUM EDITION',
                  style: TextStyle(
                    color: Colors.grey,
                    letterSpacing: 5,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                
                // Buttons with Animation
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        CustomButton(
                          text: 'PLAY',
                          onPressed: () {
                            Navigator.pushNamed(context, '/game');
                          },
                          color: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'LEVELS',
                          onPressed: () {
                            Navigator.pushNamed(context, '/levels');
                          },
                          color: Colors.transparent,
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'SETTINGS',
                          onPressed: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                          color: Colors.transparent,
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'EXIT',
                          onPressed: () {
                            // Exit app logic
                          },
                          color: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
