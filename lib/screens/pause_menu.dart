import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/custom_button.dart';
import '../theme/app_colors.dart';
import '../services/save_service.dart';
import '../services/audio_service.dart';

class PauseMenu extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const PauseMenu({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: AppColors.background.withOpacity(0.8),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PAUSED',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 60),
                CustomButton(
                  text: 'RESUME',
                  onPressed: onResume,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'RESTART',
                  isSecondary: true,
                  onPressed: onRestart,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'SETTINGS',
                  isSecondary: true,
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'MAIN MENU',
                  isSecondary: true,
                  onPressed: onExit,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _AudioToggle(
                      icon: Icons.music_note_rounded,
                      isActive: SaveService.isMusicOn(),
                      onTap: () {
                        SaveService.setMusicOn(!SaveService.isMusicOn());
                        AudioService.updateBGMVolume();
                      },
                    ),
                    const SizedBox(width: 20),
                    _AudioToggle(
                      icon: Icons.volume_up_rounded,
                      isActive: SaveService.isSoundOn(),
                      onTap: () {
                        SaveService.setSoundOn(!SaveService.isSoundOn());
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioToggle extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _AudioToggle({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_AudioToggle> createState() => _AudioToggleState();
}

class _AudioToggleState extends State<_AudioToggle> {
  late bool active;

  @override
  void initState() {
    super.initState();
    active = widget.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => active = !active);
        widget.onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? Colors.cyanAccent.withOpacity(0.2) : Colors.white10,
          shape: BoxShape.circle,
          border: Border.all(color: active ? Colors.cyanAccent : Colors.white24),
        ),
        child: Icon(widget.icon, color: active ? Colors.cyanAccent : Colors.white24, size: 24),
      ),
    );
  }
}
