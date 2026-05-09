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
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildControlBtn(Icons.pause_rounded, onBack),
              _buildTopTitle(),
              _buildControlBtn(Icons.settings_rounded, () {}),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildDataCard('SECTOR', '$level', AppColors.neonBlue)),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _buildDataCard('POINTS', '$score', AppColors.neonPurple, isMain: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildDataCard('AMMO', '$bubbles', Colors.orangeAccent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildTopTitle() {
    return Column(
      children: [
        Text(
          'GALAXY COMMAND',
          style: GoogleFonts.outfit(
            color: Colors.cyanAccent,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.transparent, AppColors.neonBlue, Colors.transparent]),
          ),
        ),
      ],
    );
  }

  Widget _buildDataCard(String label, String value, Color color, {bool isMain = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, spreadRadius: -2),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color.withOpacity(0.7),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: isMain ? 24 : 18,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(color: color.withOpacity(0.8), blurRadius: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
