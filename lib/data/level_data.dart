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
  static final List<LevelConfig> levels = [
    LevelConfig(levelNumber: 1, rowsToFill: 3, colorCount: 3, shotLimit: 25),
    LevelConfig(levelNumber: 2, rowsToFill: 4, colorCount: 3, shotLimit: 30),
    LevelConfig(levelNumber: 3, rowsToFill: 4, colorCount: 4, shotLimit: 35),
    LevelConfig(levelNumber: 4, rowsToFill: 5, colorCount: 4, shotLimit: 35),
    LevelConfig(levelNumber: 5, rowsToFill: 5, colorCount: 5, shotLimit: 40),
    LevelConfig(levelNumber: 6, rowsToFill: 6, colorCount: 5, shotLimit: 45),
    LevelConfig(levelNumber: 7, rowsToFill: 6, colorCount: 6, shotLimit: 50),
    LevelConfig(levelNumber: 8, rowsToFill: 7, colorCount: 6, shotLimit: 55),
    LevelConfig(levelNumber: 9, rowsToFill: 8, colorCount: 6, shotLimit: 60),
    LevelConfig(levelNumber: 10, rowsToFill: 9, colorCount: 6, shotLimit: 65),
  ];

  static LevelConfig getLevel(int level) {
    if (level < 1) return levels[0];
    if (level > levels.length) return levels.last;
    return levels[level - 1];
  }
}
