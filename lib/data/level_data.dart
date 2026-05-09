class LevelConfig {
  final int levelNumber;
  final int rowsToFill;
  final int colorCount;
  final int shotLimit;

  LevelConfig({
    required this.levelNumber,
    required this.rowsToFill,
    required this.colorCount,
    required this.shotLimit,
  });
}

class LevelData {
  static final List<LevelConfig> levels = _generateLevels();

  static List<LevelConfig> _generateLevels() {
    List<LevelConfig> list = [];
    for (int i = 1; i <= 100; i++) {
      int rows = 3;
      int colors = 3;
      int shots = 30;

      if (i <= 10) {
        // Easy
        rows = 3 + (i > 5 ? 1 : 0);
        colors = 3;
        shots = 30 + (10 - i);
      } else if (i <= 30) {
        // Normal
        rows = 4 + ((i - 10) / 10).floor();
        colors = 4;
        shots = 30 - ((i - 10) / 2).floor();
      } else if (i <= 60) {
        // Challenging
        rows = 6 + ((i - 30) / 10).floor();
        colors = 5;
        shots = 28 - ((i - 30) / 3).floor();
      } else {
        // Hard
        rows = 8 + ((i - 60) / 15).floor();
        colors = 6;
        shots = 25 - ((i - 60) / 5).floor();
      }

      list.add(LevelConfig(
        levelNumber: i,
        rowsToFill: rows.clamp(3, 10),
        colorCount: colors.clamp(3, 6),
        shotLimit: shots.clamp(15, 50),
      ));
    }
    return list;
  }

  static LevelConfig getLevel(int level) {
    if (level < 1) return levels[0];
    if (level > levels.length) return levels.last;
    return levels[level - 1];
  }
}
