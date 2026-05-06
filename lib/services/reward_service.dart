class RewardService {
  int comboCount = 0;

  void resetCombo() {
    comboCount = 0;
  }

  void incrementCombo() {
    comboCount++;
  }

  int getScoreMultiplier() {
    if (comboCount >= 5) return 5;
    if (comboCount >= 3) return 3;
    if (comboCount >= 2) return 2;
    return 1;
  }

  String getComboText() {
    if (comboCount >= 5) return 'AMAZING!';
    if (comboCount >= 3) return 'GREAT!';
    if (comboCount >= 2) return 'NICE!';
    return '';
  }

  int calculateCoins(int levelScore) {
    // Reward 1 coin for every 100 points
    return (levelScore / 100).floor();
  }
}
