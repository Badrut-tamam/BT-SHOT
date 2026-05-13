import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_colors.dart';
import '../components/custom_button.dart';
import '../components/space_background.dart';
import '../components/spaceship_widget.dart';
import '../services/audio_service.dart';
import '../services/save_service.dart';
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
    
    // Start background music when menu appears
    AudioService.startMenuBGM();
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
                              subtitle: 'SECTOR ${SaveService.getLastLevel()}',
                              icon: Icons.rocket_launch_rounded,
                              onPressed: () async {
                                await Navigator.pushNamed(context, '/game');
                                if (mounted) {
                                  AudioService.startMenuBGM();
                                  setState(() {});
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: 'LEVELS',
                                    icon: Icons.grid_view_rounded,
                                    isSecondary: true,
                                    onPressed: () async {
                                      await Navigator.pushNamed(context, '/levels');
                                      if (mounted) {
                                        AudioService.startMenuBGM();
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: CustomButton(
                                    text: 'HANGAR',
                                    icon: Icons.shopping_bag_rounded,
                                    isSecondary: true,
                                    onPressed: () async {
                                      await Navigator.pushNamed(context, '/shop');
                                      if (mounted) {
                                        AudioService.startMenuBGM();
                                        setState(() {});
                                      }
                                    },
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
                                    onPressed: () async {
                                      await Navigator.pushNamed(context, '/settings');
                                      if (mounted) {
                                        AudioService.startMenuBGM();
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: CustomButton(
                                    text: 'RECORDS',
                                    icon: Icons.emoji_events_rounded,
                                    isSecondary: true,
                                    onPressed: () async {
                                      await Navigator.pushNamed(context, '/achievements');
                                      if (mounted) {
                                        AudioService.startMenuBGM();
                                        setState(() {});
                                      }
                                    },
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
        double glowOpacity = 0.3 + (_logoPulseController.value * 0.5);
        return Column(
          children: [
            // Premium icon glow stack
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer ambient glow rings
                Container(
                  width: isSmallScreen ? 160 : 200,
                  height: isSmallScreen ? 160 : 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonBlue.withOpacity(glowOpacity * 0.4),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                      BoxShadow(
                        color: AppColors.neonPurple.withOpacity(glowOpacity * 0.3),
                        blurRadius: 80,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Spinning ring
                Transform.rotate(
                  angle: _logoPulseController.value * 2 * 3.14159,
                  child: Container(
                    width: isSmallScreen ? 120 : 155,
                    height: isSmallScreen ? 120 : 155,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.neonBlue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                // Inner glow circle
                Container(
                  width: isSmallScreen ? 90 : 120,
                  height: isSmallScreen ? 90 : 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.neonBlue.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Rocket icon
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                  child: Icon(
                    Icons.rocket_rounded,
                    color: Colors.white,
                    size: isSmallScreen ? 55 : 75,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // "GALAXY" subtitle
            Text(
              'GALAXY',
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.7),
                fontSize: isSmallScreen ? 16 : 22,
                fontWeight: FontWeight.w300,
                letterSpacing: 14,
              ),
            ),
            // "SHOOTER X" main title
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppColors.neonBlue, Colors.white, AppColors.neonPurple],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'SHOOTER X',
                  maxLines: 1,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 38 : 52,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    height: 0.95,
                    shadows: [
                      Shadow(color: AppColors.neonBlue, blurRadius: 30),
                      Shadow(color: AppColors.neonPurple, blurRadius: 50),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '— PREMIUM ARCADE —',
              style: GoogleFonts.outfit(
                color: Colors.white24,
                fontSize: 10,
                letterSpacing: 5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );
      },
    );
  }
}
