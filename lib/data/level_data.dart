class LevelConfig {
  final int levelNumber;
  final int rowsToFill;
  final int colorCount;
  final int shotLimit;
  final int targetScore;
  final double dropSpeed;
  final double powerUpChance;
  final bool isBoss;

  LevelConfig({
    required this.levelNumber,
    required this.rowsToFill,
    required this.colorCount,
    required this.shotLimit,
    required this.targetScore,
    this.dropSpeed = 1.0,
    this.powerUpChance = 0.1,
    this.isBoss = false,
  });
}

class LevelData {
  static final List<LevelConfig> levels = _generateLevels();

  static List<LevelConfig> _generateLevels() {
    List<LevelConfig> list = [];
    for (int i = 1; i <= 100; i++) {
      int rows = 3;
      int colors = 3;
      int shots = 25;
      int target = 1000;
      double speed = 1.0;
      double powerUp = 0.1;
      bool isBoss = i % 10 == 0;

      if (i <= 20) {
        // Easy (1 - 20)
        rows = 3 + (i > 10 ? 1 : 0);
        colors = i <= 5 ? 3 : 4;
        shots = 30 - (i / 2).floor();
        target = 500 + (i * 100);
        speed = 0.8 + (i * 0.01);
      } else if (i <= 40) {
        // Normal (21 - 40)
        rows = 4 + ((i - 20) / 10).floor();
        colors = 4;
        shots = 25 - ((i - 20) / 3).floor();
        target = 3000 + ((i - 20) * 200);
        speed = 1.0 + ((i - 20) * 0.02);
        powerUp = 0.15;
      } else if (i <= 60) {
        // Hard (41 - 60)
        rows = 6 + ((i - 40) / 10).floor();
        colors = 5;
        shots = 22 - ((i - 40) / 4).floor();
        target = 8000 + ((i - 40) * 300);
        speed = 1.5 + ((i - 40) * 0.03);
        powerUp = 0.2;
      } else if (i <= 80) {
        // Expert (61 - 80)
        rows = 7 + ((i - 60) / 10).floor();
        colors = 5;
        shots = 20 - ((i - 60) / 5).floor();
        target = 15000 + ((i - 60) * 500);
        speed = 2.0 + ((i - 60) * 0.04);
        powerUp = 0.25;
      } else {
        // Nightmare (81 - 100)
        rows = 8 + ((i - 80) / 10).floor();
        colors = 6;
        shots = 18 - ((i - 80) / 10).floor();
        target = 30000 + ((i - 80) * 1000);
        speed = 3.0 + ((i - 80) * 0.05);
        powerUp = 0.3;
      }

      // Boss Adjustment
      if (isBoss) {
        rows += 2;
        shots += 5;
        target = (target * 1.5).toInt();
        speed *= 1.2;
      }

      list.add(LevelConfig(
        levelNumber: i,
        rowsToFill: rows.clamp(3, 11),
        colorCount: colors.clamp(3, 6),
        shotLimit: shots.clamp(10, 40),
        targetScore: target,
        dropSpeed: speed,
        powerUpChance: powerUp,
        isBoss: isBoss,
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
