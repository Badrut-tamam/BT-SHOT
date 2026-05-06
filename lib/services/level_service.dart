import 'save_service.dart';

class LevelService {
  static int getUnlockedLevel() {
    return SaveService.getUnlockedLevel();
  }

  static void unlockNextLevel(int completedLevel) {
    if (completedLevel < 10) {
      SaveService.setUnlockedLevel(completedLevel + 1);
    }
  }

  static bool isLevelUnlocked(int level) {
    return level <= getUnlockedLevel();
  }
}
