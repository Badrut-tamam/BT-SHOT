import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../components/custom_button.dart';
import '../services/save_service.dart';
import '../theme/app_colors.dart';

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

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: AppColors.background.withOpacity(0.85),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    child: Text(
                      isNewHighScore ? 'NEW BEST!' : 'GAME OVER',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: isNewHighScore ? AppColors.neonBlue : Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        shadows: isNewHighScore ? [
                          Shadow(color: AppColors.neonBlue.withOpacity(0.5), blurRadius: 20)
                        ] : [],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Score Display
                  FadeIn(
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'SCORE', 
                            style: GoogleFonts.outfit(
                              color: Colors.grey[400], 
                              fontSize: 12, 
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2
                            )
                          ),
                          Text(
                            '$score',
                            style: GoogleFonts.outfit(
                              color: Colors.white, 
                              fontSize: 54, 
                              fontWeight: FontWeight.w900
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 1,
                            width: 60,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'BEST SCORE', 
                            style: GoogleFonts.outfit(
                              color: Colors.grey[500], 
                              fontSize: 10, 
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1
                            )
                          ),
                          Text(
                            '$highScore',
                            style: GoogleFonts.outfit(
                              color: Colors.white.withOpacity(0.8), 
                              fontSize: 20, 
                              fontWeight: FontWeight.w800
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: Column(
                      children: [
                        CustomButton(
                          text: 'TRY AGAIN',
                          onPressed: onRetry,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'MAIN MENU',
                          isSecondary: true,
                          onPressed: onExit,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
