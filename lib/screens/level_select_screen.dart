import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../services/level_service.dart';
import '../theme/app_colors.dart';
import '../components/background_particles.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int unlockedLevel = LevelService.getUnlockedLevel();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'LEVEL SELECT',
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
          const BackgroundParticles(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  int levelNumber = index + 1;
                  bool isUnlocked = levelNumber <= unlockedLevel;
                  
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 50),
                    child: GestureDetector(
                      onTap: isUnlocked 
                        ? () {
                            Navigator.pushNamed(context, '/game', arguments: levelNumber);
                          }
                        : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isUnlocked 
                              ? Colors.white.withOpacity(0.1) 
                              : Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isUnlocked 
                                ? AppColors.neonBlue.withOpacity(0.5) 
                                : Colors.white.withOpacity(0.05),
                            width: 2,
                          ),
                          boxShadow: isUnlocked 
                            ? [
                                BoxShadow(
                                  color: AppColors.neonBlue.withOpacity(0.2), 
                                  blurRadius: 15,
                                  spreadRadius: 1,
                                )
                              ]
                            : [],
                        ),
                        child: Center(
                          child: isUnlocked 
                            ? Text(
                                '$levelNumber',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              )
                            : Icon(Icons.lock_rounded, color: Colors.white.withOpacity(0.1), size: 30),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
