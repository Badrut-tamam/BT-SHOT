import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_colors.dart';
import '../components/custom_button.dart';
import '../components/space_background.dart';
import '../components/spaceship_widget.dart';
import 'dart:math' as math;

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with TickerProviderStateMixin {
  late AnimationController _shipController;
  late AnimationController _logoPulseController;

  @override
  void initState() {
    super.initState();
    _shipController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _logoPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shipController.dispose();
    _logoPulseController.dispose();
    super.dispose();
  }

  Future<bool> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF000428),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.cyanAccent.withOpacity(0.2))),
        title: Text('ABANDON MISSION?', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
        content: Text('Are you sure you want to exit the galaxy?', style: GoogleFonts.outfit(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('STAY', style: GoogleFonts.outfit(color: Colors.cyanAccent))),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text('EXIT', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.w900))
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog();
        if (shouldPop && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Premium Space Background (includes meteors)
            const RepaintBoundary(child: SpaceBackground(isMenu: true)),
            
            // Passing Spaceship (Slow cinematic move)
            AnimatedBuilder(
              animation: _shipController,
              builder: (context, child) {
                return Positioned(
                  bottom: isSmallScreen ? 100 : 200,
                  left: -300 + (_shipController.value * (size.width + 600)),
                  child: RepaintBoundary(
                    child: Transform(
                      transform: Matrix4.rotationZ(math.pi / 2),
                      alignment: Alignment.center,
                      child: const SpaceshipWidget(angle: 0),
                    ),
                  ),
                );
              },
            ),
            
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: isSmallScreen ? 20 : 40),
                  child: Column(
                    children: [
                      // Animated Futuristic Logo
                      FadeInDown(
                        duration: const Duration(milliseconds: 1500),
                        child: _buildAnimatedLogo(isSmallScreen),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 40 : 80),
                      
                      // Menu Buttons with Icons
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: Column(
                          children: [
                            CustomButton(
                              text: 'LAUNCH MISSION',
                              icon: Icons.rocket_launch_rounded,
                              onPressed: () => Navigator.pushNamed(context, '/game'),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: 'LEVELS',
                                    icon: Icons.grid_view_rounded,
                                    isSecondary: true,
                                    onPressed: () => Navigator.pushNamed(context, '/levels'),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: CustomButton(
                                    text: 'HANGAR',
                                    icon: Icons.shopping_bag_rounded,
                                    isSecondary: true,
                                    onPressed: () => Navigator.pushNamed(context, '/shop'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: 'CONFIG',
                                    icon: Icons.settings_rounded,
                                    isSecondary: true,
                                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: CustomButton(
                                    text: 'RECORDS',
                                    icon: Icons.emoji_events_rounded,
                                    isSecondary: true,
                                    onPressed: () => Navigator.pushNamed(context, '/achievements'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            CustomButton(
                              text: 'EXIT GALAXY',
                              icon: Icons.power_settings_new_rounded,
                              isSecondary: true,
                              onPressed: _showExitDialog,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 20 : 60),
                      
                      // Premium Footer
                      FadeIn(
                        delay: const Duration(seconds: 2),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 1,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'VER 1.0.0 - PREMIUM ARCADE',
                              style: GoogleFonts.outfit(
                                color: Colors.white24,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: _logoPulseController,
      builder: (context, child) {
        double scale = 1.0 + (_logoPulseController.value * 0.05);
        return Transform.scale(
          scale: scale,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: isSmallScreen ? 100 : 140,
                    height: isSmallScreen ? 100 : 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonBlue.withOpacity(0.4 * _logoPulseController.value),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: AppColors.neonPurple.withOpacity(0.3 * (1 - _logoPulseController.value)),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                    child: Icon(
                      Icons.rocket_rounded,
                      color: Colors.white,
                      size: isSmallScreen ? 60 : 90,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'SPACE',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 20 : 28,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 20,
                  height: 0.8,
                ),
              ),
              Text(
                'SHOOTER',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 42 : 56,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  height: 0.9,
                  shadows: [
                    Shadow(color: AppColors.neonBlue, blurRadius: 20),
                    Shadow(color: AppColors.neonPurple, blurRadius: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
