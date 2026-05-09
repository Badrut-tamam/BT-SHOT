import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../services/level_service.dart';
import '../theme/app_colors.dart';
import '../components/space_background.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  final int totalLevels = 100;
  final int levelsPerPage = 20;
  int currentCategoryIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {'name': 'EASY', 'range': '1 - 20', 'color': Colors.greenAccent},
    {'name': 'NORMAL', 'range': '21 - 40', 'color': Colors.blueAccent},
    {'name': 'HARD', 'range': '41 - 60', 'color': Colors.orangeAccent},
    {'name': 'EXPERT', 'range': '61 - 80', 'color': Colors.redAccent},
    {'name': 'NIGHTMARE', 'range': '81 - 100', 'color': Colors.purpleAccent},
  ];

  @override
  Widget build(BuildContext context) {
    int unlockedLevel = LevelService.getUnlockedLevel();
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 6 : 4;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'GALAXY MAP',
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
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Category Selector
                _buildCategorySelector(),
                
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GridView.builder(
                      padding: const EdgeInsets.only(top: 20, bottom: 40),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: levelsPerPage,
                      itemBuilder: (context, index) {
                        int levelNumber = (currentCategoryIndex * levelsPerPage) + index + 1;
                        bool isUnlocked = levelNumber <= unlockedLevel;
                        
                        return _buildLevelCard(levelNumber, isUnlocked);
                      },
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

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = currentCategoryIndex == index;
          var cat = categories[index];
          
          return GestureDetector(
            onTap: () => setState(() => currentCategoryIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? cat['color'].withOpacity(0.2) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected ? cat['color'] : Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  cat['name'],
                  style: GoogleFonts.outfit(
                    color: isSelected ? cat['color'] : Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelCard(int level, bool isUnlocked) {
    int stars = LevelService.getLevelStars(level);
    return FadeInScale(
      child: GestureDetector(
        onTap: isUnlocked 
          ? () => Navigator.pushNamed(context, '/game', arguments: level)
          : null,
        child: Container(
          decoration: BoxDecoration(
            color: isUnlocked 
                ? Colors.white.withOpacity(0.05) 
                : Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isUnlocked 
                  ? Colors.cyanAccent.withOpacity(0.3) 
                  : Colors.white.withOpacity(0.05),
              width: 1.5,
            ),
            boxShadow: isUnlocked 
              ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 10)]
              : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isUnlocked) ...[
                Text(
                  '$level',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                _buildStars(stars),
              ] else ...[
                Icon(Icons.lock_rounded, color: Colors.white.withOpacity(0.1), size: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStars(int stars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Icon(
          Icons.star_rounded,
          size: 12,
          color: index < stars ? Colors.amberAccent : Colors.white.withOpacity(0.1),
        );
      }),
    );
  }
}

class FadeInScale extends StatelessWidget {
  final Widget child;
  const FadeInScale({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      duration: const Duration(milliseconds: 400),
      child: child,
    );
  }
}
