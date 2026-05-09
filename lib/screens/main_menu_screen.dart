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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Space Background
          const SpaceBackground(isMenu: true),
          
          // Passing Spaceship
          AnimatedBuilder(
            animation: _shipController,
            builder: (context, child) {
              return Positioned(
                bottom: 150,
                left: -200 + (_shipController.value * (MediaQuery.of(context).size.width + 400)),
                child: Transform.rotate(
                  angle: math.pi / 2,
                  child: const SpaceshipWidget(angle: 0),
                ),
              );
            },
          ),
          
          SafeArea(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Animated Glowing Logo
                  FadeInDown(
                    duration: const Duration(milliseconds: 1500),
                    child: _buildAnimatedLogo(),
                  ),
                  
                  const Spacer(),
                  
                  // Main Buttons
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
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
                                  text: 'ACHIEVEMENTS',
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
                            onPressed: () {},
                            isDanger: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Footer
                  Text(
                    'VERSION 1.0.0',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withOpacity(0.2),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect
            Pulse(
              infinite: true,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.neonBlue.withOpacity(0.3), blurRadius: 40, spreadRadius: 10)
                  ],
                ),
              ),
            ),
            const Icon(Icons.rocket_rounded, color: Colors.white, size: 80),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'SPACE',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w300,
            letterSpacing: 15,
            height: 0.8,
          ),
        ),
        Text(
          'SHOOTER',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 48,
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
