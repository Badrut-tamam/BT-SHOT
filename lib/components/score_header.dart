import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class ScoreHeader extends StatelessWidget {
  final int score;
  final int level;
  final int bubbles;
  final double laserProgress;
  final VoidCallback onBack;

  const ScoreHeader({
    super.key,
    required this.score,
    required this.level,
    required this.bubbles,
    required this.laserProgress,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(bottom: BorderSide(color: Colors.cyanAccent.withOpacity(0.2))),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: const Icon(Icons.menu_rounded, color: Colors.cyanAccent),
                ),
                Text(
                  'GALAXY COMMAND',
                  style: GoogleFonts.outfit(
                    color: Colors.cyanAccent.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const Icon(Icons.settings_input_antenna_rounded, color: Colors.cyanAccent, size: 16),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('LVL', '$level'),
                _buildStat('SCORE', '$score', isHighlight: true),
                _buildStat('SHOTS', '$bubbles'),
                _buildStat('LASER', '${(laserProgress * 100).toInt()}%', color: Colors.blueAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, {bool isHighlight = false, Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.grey[500],
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: color ?? (isHighlight ? Colors.white : Colors.cyanAccent),
            fontWeight: FontWeight.w900,
            fontSize: isHighlight ? 20 : 16,
            shadows: isHighlight ? [
              Shadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 10)
            ] : [],
          ),
        ),
      ],
    );
  }
}
