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
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Column(
                      children: [
                        Icon(
                          isNewHighScore ? Icons.emoji_events_rounded : Icons.gpp_maybe_rounded,
                          color: isNewHighScore ? Colors.amberAccent : Colors.redAccent.withOpacity(0.5),
                          size: 80,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isNewHighScore ? 'GALAXY LEGEND!' : 'MISSION FAILED',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Score Card
                  FadeInScale(
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: (isNewHighScore ? Colors.amber : Colors.blue).withOpacity(0.05),
                            blurRadius: 40,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'FINAL SCORE', 
                            style: GoogleFonts.outfit(
                              color: Colors.cyanAccent.withOpacity(0.5), 
                              fontSize: 12, 
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3
                            )
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            child: Text(
                              '$score',
                              style: GoogleFonts.outfit(
                                color: Colors.white, 
                                fontSize: 64, 
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.military_tech_rounded, color: Colors.amberAccent.withOpacity(0.6), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'BEST: $highScore',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withOpacity(0.4), 
                                  fontSize: 16, 
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Buttons
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: Column(
                      children: [
                        _buildActionBtn('TRY AGAIN', Icons.refresh_rounded, true, onRetry),
                        const SizedBox(height: 16),
                        _buildActionBtn('MAIN MENU', Icons.home_rounded, false, onExit),
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

  Widget _buildActionBtn(String text, IconData icon, bool isPrimary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPrimary ? Colors.white : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: isPrimary ? [
            BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 15)
          ] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.black : Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.outfit(
                color: isPrimary ? Colors.black : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FadeInScale extends StatelessWidget {
  final Widget child;
  final Duration delay;
  const FadeInScale({super.key, required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      delay: delay,
      duration: const Duration(milliseconds: 600),
      child: child,
    );
  }
}
