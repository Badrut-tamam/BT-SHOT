import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_colors.dart';
import '../components/space_background.dart';
import '../services/save_service.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  int _highScore = 0;
  int _highestLevel = 0;
  int _totalWins = 0;
  int _totalLosses = 0;
  int _totalShots = 0;
  int _totalHits = 0;
  int _totalPlayTime = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _highScore = SaveService.getHighScore();
      _highestLevel = SaveService.getHighestLevel();
      _totalWins = SaveService.getTotalWins();
      _totalLosses = SaveService.getTotalLosses();
      _totalShots = SaveService.getTotalShots();
      _totalHits = SaveService.getTotalHits();
      _totalPlayTime = SaveService.getTotalPlayTime();
    });
  }

  String _formatPlayTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  String _calculateAccuracy() {
    if (_totalShots == 0) return '0%';
    double acc = (_totalHits / _totalShots) * 100;
    return '${acc.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const RepaintBoundary(child: SpaceBackground()),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        FadeInDown(
                          child: _buildMainStatCard(
                            'HIGH SCORE', 
                            '$_highScore', 
                            Icons.emoji_events,
                            AppColors.neonPurple
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: Row(
                            children: [
                              Expanded(child: _buildStatCard('HIGHEST SECTOR', '$_highestLevel', AppColors.neonBlue)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatCard('ACCURACY', _calculateAccuracy(), Colors.greenAccent)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: Row(
                            children: [
                              Expanded(child: _buildStatCard('TOTAL WINS', '$_totalWins', Colors.amber)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatCard('TOTAL LOSSES', '$_totalLosses', Colors.redAccent)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: Row(
                            children: [
                              Expanded(child: _buildStatCard('SHOTS FIRED', '$_totalShots', Colors.orangeAccent)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatCard('PLAY TIME', _formatPlayTime(_totalPlayTime), Colors.cyanAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Text(
            'SERVICE RECORDS',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(color: color, fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
