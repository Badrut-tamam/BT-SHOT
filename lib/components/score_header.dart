import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class ScoreHeader extends StatelessWidget {
  final int score;
  final int level;
  final int bubbles;
  final double laserProgress;
  final bool laserReady;
  final VoidCallback onBack;

  const ScoreHeader({
    super.key,
    required this.score,
    required this.level,
    required this.bubbles,
    required this.laserProgress,
    required this.onBack,
    this.laserReady = false,
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
              // ☰ Hamburger menu — ganti ikon gir
              GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
                ),
              ),
              _buildTopTitle(),
              // Laser charge mini-indicator
              _buildLaserMiniIndicator(),
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
          // Laser bar di bawah data cards
          const SizedBox(height: 10),
          _buildLaserBar(),
        ],
      ),
    );
  }

  Widget _buildLaserMiniIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: laserReady
            ? Colors.cyanAccent.withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: laserReady ? Colors.cyanAccent : Colors.white.withOpacity(0.2),
          width: laserReady ? 1.5 : 1,
        ),
        boxShadow: laserReady
            ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 12, spreadRadius: 1)]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bolt_rounded,
            color: laserReady ? Colors.cyanAccent : Colors.white38,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            laserReady ? 'READY!' : '${(laserProgress * 100).toInt()}%',
            style: GoogleFonts.outfit(
              color: laserReady ? Colors.cyanAccent : Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaserBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.electric_bolt_rounded, color: Colors.cyanAccent, size: 10),
            const SizedBox(width: 4),
            Text(
              laserReady ? '⚡ LASER READY — TEKAN PETIR!' : 'PETIR  ${(laserProgress * 100).toInt()}%',
              style: GoogleFonts.outfit(
                color: laserReady ? Colors.cyanAccent : Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(
                height: 4,
                color: Colors.white.withOpacity(0.05),
              ),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 300),
                widthFactor: laserProgress.clamp(0.0, 1.0),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.blueAccent,
                      Colors.cyanAccent,
                      if (laserReady) Colors.white,
                    ]),
                    boxShadow: laserReady
                        ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.8), blurRadius: 6)]
                        : [],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
