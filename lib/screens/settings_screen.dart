import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/save_service.dart';
import '../theme/app_colors.dart';
import '../components/space_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkMode = true;
  bool _batterySaver = false;
  double _musicVolume = 0.8;
  double _sfxVolume = 0.8;
  int _fpsMode = 60;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _soundEnabled = SaveService.isSoundOn();
      _musicEnabled = SaveService.isMusicOn();
      _vibrationEnabled = SaveService.isVibrationOn();
      _darkMode = SaveService.isDarkMode();
      _batterySaver = SaveService.isBatterySaver();
      _musicVolume = SaveService.getMusicVolume();
      _sfxVolume = SaveService.getSfxVolume();
      _fpsMode = SaveService.getFpsMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'CONFIGURATION',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('AUDIO'),
                  _buildToggleItem(
                    title: 'MUSIC',
                    icon: Icons.music_note_rounded,
                    value: _musicEnabled,
                    onChanged: (val) {
                      setState(() => _musicEnabled = val);
                      SaveService.setMusicOn(val);
                    },
                  ),
                  _buildSliderItem(
                    title: 'MUSIC VOLUME',
                    value: _musicVolume,
                    onChanged: (val) {
                      setState(() => _musicVolume = val);
                      SaveService.setMusicVolume(val);
                    },
                  ),
                  _buildToggleItem(
                    title: 'SOUND FX',
                    icon: Icons.volume_up_rounded,
                    value: _soundEnabled,
                    onChanged: (val) {
                      setState(() => _soundEnabled = val);
                      SaveService.setSoundOn(val);
                    },
                  ),
                  _buildSliderItem(
                    title: 'SFX VOLUME',
                    value: _sfxVolume,
                    onChanged: (val) {
                      setState(() => _sfxVolume = val);
                      SaveService.setSfxVolume(val);
                    },
                  ),
                  
                  const SizedBox(height: 30),
                  _buildSectionTitle('SYSTEM'),
                  _buildToggleItem(
                    title: 'VIBRATION',
                    icon: Icons.vibration_rounded,
                    value: _vibrationEnabled,
                    onChanged: (val) {
                      setState(() => _vibrationEnabled = val);
                      SaveService.setVibrationOn(val);
                    },
                  ),
                  _buildToggleItem(
                    title: 'DARK MODE',
                    icon: Icons.dark_mode_rounded,
                    value: _darkMode,
                    onChanged: (val) {
                      setState(() => _darkMode = val);
                      SaveService.setDarkMode(val);
                    },
                  ),
                  _buildToggleItem(
                    title: 'BATTERY SAVER',
                    icon: Icons.battery_saver_rounded,
                    value: _batterySaver,
                    onChanged: (val) {
                      setState(() => _batterySaver = val);
                      SaveService.setBatterySaver(val);
                    },
                  ),
                  _buildFpsSelector(),
                  
                  const SizedBox(height: 30),
                  _buildSectionTitle('GAME'),
                  _buildActionButton('RESET PROGRESS', Icons.refresh_rounded, Colors.redAccent, () {
                    _showResetDialog();
                  }),
                  _buildActionButton('PRIVACY POLICY', Icons.privacy_tip_rounded, Colors.white, () {
                    _showPrivacyDialog();
                  }),
                  _buildActionButton('ABOUT GAME', Icons.info_rounded, Colors.white, () {
                    _showAboutDialog();
                  }),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 15),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.cyanAccent.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.cyanAccent,
            activeTrackColor: Colors.cyanAccent.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItem({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w700),
          ),
          Slider(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.cyanAccent,
            inactiveColor: Colors.white.withOpacity(0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildFpsSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const Icon(Icons.speed_rounded, color: Colors.cyanAccent, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'FPS LIMIT',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Row(
            children: [60, 120].map((fps) {
              bool isSelected = _fpsMode == fps;
              return GestureDetector(
                onTap: () {
                  setState(() => _fpsMode = fps);
                  SaveService.setFpsMode(fps);
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.cyanAccent : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? Colors.cyanAccent : Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    '$fps',
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 15),
            Text(
              title,
              style: GoogleFonts.outfit(color: color, fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF000428),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.redAccent.withOpacity(0.2))),
        title: Text('RESET PROGRESS?', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
        content: Text('All your high scores and unlocked levels will be permanently deleted from the galaxy database.', 
          style: GoogleFonts.outfit(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL', style: GoogleFonts.outfit(color: Colors.cyanAccent))),
          TextButton(
            onPressed: () async {
              await SaveService.resetProgress();
              Navigator.pop(context);
              _loadSettings();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data wiped successfully')),
                );
              }
            },
            child: Text('RESET', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF000428),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.cyanAccent.withOpacity(0.2))),
        title: Text('ABOUT GAME', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.rocket_launch_rounded, color: Colors.cyanAccent, size: 50),
            const SizedBox(height: 20),
            Text('SPACE SHOOTER PREMIUM', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Text('Version 1.0.0\nDeveloped for a premium mobile experience with smooth performance and neon aesthetics.', 
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            Text('© 2026 GALAXY STUDIOS', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('CLOSE', style: GoogleFonts.outfit(color: Colors.cyanAccent))),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF000428),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.cyanAccent.withOpacity(0.2))),
        title: Text('PRIVACY POLICY', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
        content: SingleChildScrollView(
          child: Text(
            'Your privacy is important to us. Space Shooter Premium does not collect any personal data or transmit information outside of your device.\n\n'
            '1. Data Storage: All game progress is stored locally on your device.\n'
            '2. Analytics: We do not use third-party analytics.\n'
            '3. Permissions: The game only requires standard Flutter permissions for rendering and vibration.\n\n'
            'Safe travels, Commander.',
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('I UNDERSTAND', style: GoogleFonts.outfit(color: Colors.cyanAccent))),
        ],
      ),
    );
  }
}
