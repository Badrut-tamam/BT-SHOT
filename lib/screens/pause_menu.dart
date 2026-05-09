import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/custom_button.dart';
import '../theme/app_colors.dart';

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
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: AppColors.background.withOpacity(0.8),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PAUSED',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 60),
                CustomButton(
                  text: 'RESUME',
                  onPressed: onResume,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'RESTART',
                  isSecondary: true,
                  onPressed: onRestart,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'QUIT GAME',
                  isSecondary: true,
                  onPressed: onExit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
