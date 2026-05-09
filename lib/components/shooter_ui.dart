import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'spaceship_widget.dart';
import 'alien_bubble.dart';

class ShooterUI extends StatelessWidget {
  final Color shooterColor;
  final Color nextColor;
  final double angle;
  final bool laserReady;
  final double laserProgress;
  final VoidCallback? onLaserTap;

  const ShooterUI({
    super.key,
    required this.shooterColor,
    required this.nextColor,
    required this.angle,
    this.laserReady = false,
    this.laserProgress = 0.0,
    this.onLaserTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Next Ball Preview
          Positioned(
            bottom: 40,
            left: MediaQuery.of(context).size.width / 2 - 120,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Text(
                    'RESERVE', 
                    style: GoogleFonts.outfit(
                      color: Colors.cyanAccent.withOpacity(0.5), 
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    )
                  ),
                  const SizedBox(height: 6),
                  AlienBubble(color: nextColor, size: 24),
                ],
              ),
            ),
          ),

          // Laser Cannon Button
          Positioned(
            bottom: 40,
            right: MediaQuery.of(context).size.width / 2 - 120,
            child: GestureDetector(
              onTap: laserReady ? onLaserTap : null,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: laserReady 
                    ? Colors.blue.withOpacity(0.3) 
                    : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: laserReady ? Colors.blueAccent : Colors.white.withOpacity(0.1),
                    width: 2,
                  ),
                  boxShadow: laserReady ? [
                    BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 15)
                  ] : [],
                ),
                child: Column(
                  children: [
                    Text(
                      'LASER', 
                      style: GoogleFonts.outfit(
                        color: laserReady ? Colors.white : Colors.grey[600], 
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      )
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: laserProgress,
                          strokeWidth: 3,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            laserReady ? Colors.cyanAccent : Colors.blueGrey
                          ),
                        ),
                        Icon(
                          Icons.bolt_rounded,
                          color: laserReady ? Colors.white : Colors.grey[600],
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Main Spaceship Shooter
          Positioned(
            bottom: 10,
            child: SpaceshipWidget(
              angle: angle,
              engineColor: shooterColor,
            ),
          ),
        ],
      ),
    );
  }
}
