import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../components/custom_button.dart';
import '../components/space_background.dart';
import '../components/spaceship_widget.dart';
import '../theme/app_colors.dart';
import 'dart:math' as math;

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _shipController;

  @override
  void initState() {
    super.initState();
    _shipController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _shipController.dispose();
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
            // Space Background
            const RepaintBoundary(child: SpaceBackground(isMenu: true)),
            
            // Passing Spaceship
            AnimatedBuilder(
              animation: _shipController,
              builder: (context, child) {
                return Positioned(
                  bottom: isSmallScreen ? 100 : 150,
                  left: -200 + (_shipController.value * (size.width + 400)),
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
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 20 : 40),
                  child: Column(
                    children: [
                      // Animated Glowing Logo
                      FadeInDown(
                        duration: const Duration(milliseconds: 1500),
                        child: _buildAnimatedLogo(isSmallScreen),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 30 : 60),
                      
                      // Main Buttons
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                          child: Column(
                            children: [
                              _buildMenuButton(
                                text: 'LAUNCH MISSION',
                                icon: Icons.rocket_launch_rounded,
                                onPressed: () => Navigator.pushNamed(context, '/game'),
                                isPrimary: true,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMenuButton(
                                      text: 'LEVELS',
                                      icon: Icons.grid_view_rounded,
                                      onPressed: () => Navigator.pushNamed(context, '/levels'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildMenuButton(
                                      text: 'SHOP',
                                      icon: Icons.shopping_bag_rounded,
                                      onPressed: () => Navigator.pushNamed(context, '/shop'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMenuButton(
                                      text: 'SETTINGS',
                                      icon: Icons.settings_rounded,
                                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildMenuButton(
                                      text: 'RECORDS',
                                      icon: Icons.emoji_events_rounded,
                                      onPressed: () => Navigator.pushNamed(context, '/achievements'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildMenuButton(
                                text: 'EXIT GALAXY',
                                icon: Icons.power_settings_new_rounded,
                                onPressed: _showExitDialog,
                                isDanger: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Footer
                      const Text(
                        'VERSION 1.0.0 - PREMIUM',
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
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
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect
            Pulse(
              infinite: true,
              child: Container(
                width: isSmallScreen ? 80 : 120,
                height: isSmallScreen ? 80 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.neonBlue.withOpacity(0.3), blurRadius: isSmallScreen ? 25 : 40, spreadRadius: isSmallScreen ? 5 : 10)
                  ],
                ),
              ),
            ),
            Icon(Icons.rocket_rounded, color: Colors.white, size: isSmallScreen ? 50 : 80),
          ],
        ),
        SizedBox(height: isSmallScreen ? 10 : 20),
        Text(
          'SPACE',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: isSmallScreen ? 18 : 24,
            fontWeight: FontWeight.w300,
            letterSpacing: 15,
            height: 0.8,
          ),
        ),
        Text(
          'SHOOTER',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: isSmallScreen ? 36 : 48,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            height: 0.9,
            shadows: [
              Shadow(color: AppColors.neonBlue.withOpacity(0.8), blurRadius: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
    bool isDanger = false,
  }) {
    return ZoomIn(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: isPrimary 
              ? AppColors.primaryGradient 
              : LinearGradient(
                  colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.1)],
                ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPrimary 
                ? Colors.cyanAccent.withOpacity(0.5) 
                : (isDanger ? Colors.redAccent.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
              width: 1.5,
            ),
            boxShadow: isPrimary ? [
              BoxShadow(color: AppColors.neonBlue.withOpacity(0.3), blurRadius: 15, spreadRadius: 1)
            ] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isPrimary ? Colors.white : (isDanger ? Colors.redAccent : Colors.cyanAccent), size: 20),
              const SizedBox(width: 12),
              Text(
                text,
                style: GoogleFonts.outfit(
                  color: isPrimary ? Colors.white : (isDanger ? Colors.redAccent : Colors.white),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
