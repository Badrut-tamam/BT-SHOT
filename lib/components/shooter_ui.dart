import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_colors.dart';
import 'spaceship_widget.dart';
import 'alien_bubble.dart';
import '../models/bubble_model.dart';

class ShooterUI extends StatelessWidget {
  final Color shooterColor;
  final Color nextColor;
  final FaceType shooterFaceType;
  final FaceType nextFaceType;
  final double angle;
  final bool laserReady;
  final double laserProgress;
  final VoidCallback? onLaserTap;
  final VoidCallback? onSwapTap;
  final bool canSwap;
  final double recoilOffset;
  final bool isMuzzleFlashing;

  const ShooterUI({
    super.key,
    required this.shooterColor,
    required this.nextColor,
    required this.shooterFaceType,
    required this.nextFaceType,
    required this.angle,
    this.laserReady = false,
    this.laserProgress = 0.0,
    this.onLaserTap,
    this.onSwapTap,
    this.canSwap = true,
    this.recoilOffset = 0,
    this.isMuzzleFlashing = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final cardOffset = (screenWidth * 0.22).clamp(80.0, 140.0);
        
        return Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Reserve Card
              Positioned(
                bottom: 40,
                left: screenWidth / 2 - cardOffset - 40,
                child: GestureDetector(
                  onTap: canSwap ? onSwapTap : null,
                  child: _buildGlassCard(
                    label: 'SWAP',
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AlienBubble(color: nextColor, size: 28, faceType: nextFaceType),
                        if (!canSwap)
                          Icon(Icons.block, color: Colors.red.withOpacity(0.8), size: 30),
                      ]
                    ),
                    color: canSwap ? Colors.white : Colors.grey,
                  ),
                ),
              ),

              // Laser Cannon Card (PETIR)
              Positioned(
                bottom: 40,
                right: screenWidth / 2 - cardOffset - 40,
                child: laserReady 
                  ? Pulse(
                      infinite: true,
                      duration: const Duration(milliseconds: 1500),
                      child: _buildLaserBtn(),
                    )
                  : _buildLaserBtn(),
              ),
              
              // Main Spaceship Shooter
              Positioned(
                bottom: 10,
                child: SpaceshipWidget(
                  angle: angle,
                  engineColor: shooterColor,
                  recoilOffset: recoilOffset,
                  isMuzzleFlashing: isMuzzleFlashing,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLaserBtn() {
    return GestureDetector(
      onTap: onLaserTap,
      child: _buildGlassCard(
        label: laserReady ? 'READY!' : 'PETIR',
        color: laserReady ? Colors.cyanAccent : Colors.white,
        isReady: laserReady,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                value: laserProgress,
                strokeWidth: 3,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(
                  laserReady ? Colors.white : Colors.cyanAccent.withOpacity(0.5)
                ),
              ),
            ),
            if (!laserReady)
              Text(
                '${(laserProgress * 100).toInt()}%',
                style: GoogleFonts.outfit(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            if (laserReady)
              const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required String label, required Widget child, required Color color, bool isReady = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isReady ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isReady ? color : color.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: isReady ? [
              BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, spreadRadius: 1)
            ] : [],
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: isReady ? Colors.white : color.withOpacity(0.5), 
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                )
              ),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
