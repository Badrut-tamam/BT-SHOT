import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../components/background_particles.dart';
import '../components/space_background.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/menu');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Space Background
          RepaintBoundary(child: SpaceBackground(isMenu: true)),
          
          // Background Glow
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonBlue.withOpacity(0.2),
                    blurRadius: 150,
                    spreadRadius: 70,
                  ),
                ],
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ZoomIn(
                  duration: const Duration(milliseconds: 1200),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.1),
                          blurRadius: 20,
                        )
                      ],
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                FadeInDown(
                  delay: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      Text(
                        'SPACE',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 20,
                          height: 0.8,
                        ),
                      ),
                      Text(
                        'SHOOTER',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(color: AppColors.neonBlue.withOpacity(0.8), blurRadius: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FadeIn(
                  delay: const Duration(seconds: 2),
                  child: Text(
                    'PREMIUM EDITION',
                    style: GoogleFonts.outfit(
                      color: Colors.cyanAccent.withOpacity(0.5),
                      letterSpacing: 6,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                FadeIn(
                  delay: const Duration(milliseconds: 800),
                  child: SizedBox(
                    width: 100,
                    height: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Indicator
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeIn(
              delay: const Duration(seconds: 3),
              child: Text(
                'LOADING GALAXY...',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white24,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
