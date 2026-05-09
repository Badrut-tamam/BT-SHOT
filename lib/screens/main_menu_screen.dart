import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../components/custom_button.dart';
import '../components/space_background.dart';
import '../components/spaceship_widget.dart';
import '../theme/app_colors.dart';
import 'dart:math' as math;

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Space Background with Stars and Parallax
          const SpaceBackground(isMenu: true),
          
          // Passing Spaceship
          Positioned(
            bottom: 200,
            left: -100,
            child: SlideInRight(
              duration: const Duration(seconds: 15),
              infinite: true,
              from: 600,
              child: const SpaceshipWidget(angle: -math.pi / 2),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  // Game Title with Animation
                  FadeInDown(
                    duration: const Duration(seconds: 1),
                    child: Hero(
                      tag: 'title',
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            Text(
                              'SPACE',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 20,
                                height: 0.8,
                              ),
                            ),
                            Text(
                              'SHOOTER',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 8,
                                height: 0.9,
                                shadows: [
                                  Shadow(color: AppColors.neonBlue.withOpacity(0.8), blurRadius: 20),
                                  Shadow(color: AppColors.neonPurple.withOpacity(0.5), blurRadius: 40),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeIn(
                    delay: const Duration(milliseconds: 800),
                    child: Text(
                      'PREMIUM EDITION',
                      style: GoogleFonts.outfit(
                        color: Colors.cyanAccent.withOpacity(0.6),
                        letterSpacing: 6,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Spacer(),
                  
                  // Buttons with Animation
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Column(
                        children: [
                          CustomButton(
                            text: 'START MISSION',
                            onPressed: () {
                              Navigator.pushNamed(context, '/game');
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'GALAXY MAP',
                            isSecondary: true,
                            onPressed: () {
                              Navigator.pushNamed(context, '/levels');
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: 'CONFIG',
                                  isSecondary: true,
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/settings');
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomButton(
                                  text: 'EXIT',
                                  isSecondary: true,
                                  onPressed: () {
                                    // Exit logic
                                  },
                                ),
                              ),
                            ],
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
        ],
      ),
    );
  }
}
