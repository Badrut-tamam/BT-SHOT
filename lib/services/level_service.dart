import 'save_service.dart';

class LevelService {
  static int getUnlockedLevel() {
    return SaveService.getUnlockedLevel();
  }

  static Future<void> unlockNextLevel(int completedLevel) async {
    if (completedLevel < 100) {
      await SaveService.setUnlockedLevel(completedLevel + 1);
    }
  }

  static bool isLevelUnlocked(int level) {
    return level <= getUnlockedLevel();
  }

  static int getLevelStars(int level) {
    return SaveService.getLevelStars(level);
  }

  static Future<void> setLevelStars(int level, int stars) async {
    await SaveService.setLevelStars(level, stars);
  }

  static int calculateStars(int shotsLeft, int totalShots) {
    double ratio = shotsLeft / totalShots;
    if (ratio >= 0.4) return 3;
    if (ratio >= 0.15) return 2;
    return 1;
  }
}
