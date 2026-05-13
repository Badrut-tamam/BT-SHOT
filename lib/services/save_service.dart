import 'package:shared_preferences/shared_preferences.dart';

class SaveService {
  static const String keyHighScore = 'high_score';
  static const String keyCoins = 'coins';
  static const String keyLastLevel = 'last_level';
  static const String keyUnlockedLevel = 'unlocked_level';
  static const String keySoundOn = 'sound_on';
  static const String keyVibrationOn = 'vibration_on';
  static const String keyMusicOn = 'music_on';
  static const String keyMusicVolume = 'music_volume';
  static const String keySfxVolume = 'sfx_volume';
  static const String keyDarkMode = 'dark_mode';
  static const String keyBatterySaver = 'battery_saver';
  static const String keyFpsMode = 'fps_mode';
  static const String keyAimAssist = 'aim_assist';
  static const String keyDifficulty = 'difficulty'; // 0=Easy, 1=Medium, 2=Hard
  static const String keyParticleEffect = 'particle_effect';
  static const String keyScreenShake = 'screen_shake';
  static const String keyGlowEffect = 'glow_effect';
  static const String keyLevelStars = 'level_stars_';

  static const String keyTotalWins = 'total_wins';
  static const String keyTotalLosses = 'total_losses';
  static const String keyTotalShots = 'total_shots';
  static const String keyTotalHits = 'total_hits';
  static const String keyTotalPlayTime = 'total_play_time';
  static const String keyHighestLevel = 'highest_level';
  
  static const String keySelectedShip = 'selected_ship';
  static const String keyUnlockedShipPrefix = 'unlocked_ship_';
  static const String keyShipUpgradePrefix = 'ship_upgrade_';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Default unlock ship 0
    if (!isShipUnlocked(0)) {
      await unlockShip(0);
    }
  }

  // --- RECORD STATS ---
  static int getTotalWins() => _prefs.getInt(keyTotalWins) ?? 0;
  static Future<void> addWin() async => await _prefs.setInt(keyTotalWins, getTotalWins() + 1);

  static int getTotalLosses() => _prefs.getInt(keyTotalLosses) ?? 0;
  static Future<void> addLoss() async => await _prefs.setInt(keyTotalLosses, getTotalLosses() + 1);

  static int getTotalShots() => _prefs.getInt(keyTotalShots) ?? 0;
  static Future<void> addShots(int count) async => await _prefs.setInt(keyTotalShots, getTotalShots() + count);

  static int getTotalHits() => _prefs.getInt(keyTotalHits) ?? 0;
  static Future<void> addHits(int count) async => await _prefs.setInt(keyTotalHits, getTotalHits() + count);

  static int getTotalPlayTime() => _prefs.getInt(keyTotalPlayTime) ?? 0; // In seconds
  static Future<void> addPlayTime(int seconds) async => await _prefs.setInt(keyTotalPlayTime, getTotalPlayTime() + seconds);

  static int getHighestLevel() => _prefs.getInt(keyHighestLevel) ?? 1;
  static Future<void> setHighestLevel(int level) async {
    if (level > getHighestLevel()) await _prefs.setInt(keyHighestLevel, level);
  }

  // --- HANGAR DATA ---
  static int getSelectedShip() => _prefs.getInt(keySelectedShip) ?? 0;
  static Future<void> setSelectedShip(int shipId) async => await _prefs.setInt(keySelectedShip, shipId);

  static bool isShipUnlocked(int shipId) => _prefs.getBool('$keyUnlockedShipPrefix$shipId') ?? false;
  static Future<void> unlockShip(int shipId) async => await _prefs.setBool('$keyUnlockedShipPrefix$shipId', true);

  // Upgrade types: 0=Speed, 1=Aim, 2=Laser
  static int getShipUpgradeLevel(int shipId, int upgradeType) => _prefs.getInt('${keyShipUpgradePrefix}${shipId}_$upgradeType') ?? 1;
  static Future<void> setShipUpgradeLevel(int shipId, int upgradeType, int level) async => 
      await _prefs.setInt('${keyShipUpgradePrefix}${shipId}_$upgradeType', level);

  // High Score
  static int getHighScore() => _prefs.getInt(keyHighScore) ?? 0;
  static Future<void> setHighScore(int score) async {
    if (score > getHighScore()) {
      await _prefs.setInt(keyHighScore, score);
    }
  }

  // Coins
  static int getCoins() => _prefs.getInt(keyCoins) ?? 0;
  static Future<void> addCoins(int amount) async {
    int current = getCoins();
    await _prefs.setInt(keyCoins, current + amount);
  }
  static Future<void> spendCoins(int amount) async {
    int current = getCoins();
    if (current >= amount) await _prefs.setInt(keyCoins, current - amount);
  }

  // Level
  static int getLastLevel() => _prefs.getInt(keyLastLevel) ?? 1;
  static Future<void> setLastLevel(int level) async {
    await _prefs.setInt(keyLastLevel, level);
  }

  static int getUnlockedLevel() => _prefs.getInt(keyUnlockedLevel) ?? 1;
  static Future<void> setUnlockedLevel(int level) async {
    if (level > getUnlockedLevel()) {
      await _prefs.setInt(keyUnlockedLevel, level);
    }
  }

  // Stars
  static int getLevelStars(int level) => _prefs.getInt('$keyLevelStars$level') ?? 0;
  static Future<void> setLevelStars(int level, int stars) async {
    int current = getLevelStars(level);
    if (stars > current) {
      await _prefs.setInt('$keyLevelStars$level', stars);
    }
  }

  // Settings
  static bool isSoundOn() => _prefs.getBool(keySoundOn) ?? true;
  static Future<void> setSoundOn(bool on) async {
    await _prefs.setBool(keySoundOn, on);
  }

  static bool isMusicOn() => _prefs.getBool(keyMusicOn) ?? true;
  static Future<void> setMusicOn(bool on) async {
    await _prefs.setBool(keyMusicOn, on);
  }

  static double getMusicVolume() => _prefs.getDouble(keyMusicVolume) ?? 0.8;
  static Future<void> setMusicVolume(double vol) async {
    await _prefs.setDouble(keyMusicVolume, vol);
  }

  static double getSfxVolume() => _prefs.getDouble(keySfxVolume) ?? 0.8;
  static Future<void> setSfxVolume(double vol) async {
    await _prefs.setDouble(keySfxVolume, vol);
  }

  static bool isVibrationOn() => _prefs.getBool(keyVibrationOn) ?? true;
  static Future<void> setVibrationOn(bool on) async {
    await _prefs.setBool(keyVibrationOn, on);
  }

  static bool isDarkMode() => _prefs.getBool(keyDarkMode) ?? true;
  static Future<void> setDarkMode(bool on) async {
    await _prefs.setBool(keyDarkMode, on);
  }

  static bool isBatterySaver() => _prefs.getBool(keyBatterySaver) ?? false;
  static Future<void> setBatterySaver(bool on) async {
    await _prefs.setBool(keyBatterySaver, on);
  }

  static int getFpsMode() => _prefs.getInt(keyFpsMode) ?? 60;
  static Future<void> setFpsMode(int fps) async {
    await _prefs.setInt(keyFpsMode, fps);
  }
  
  static bool isAimAssist() => _prefs.getBool(keyAimAssist) ?? true;
  static Future<void> setAimAssist(bool on) async => await _prefs.setBool(keyAimAssist, on);

  static int getDifficulty() => _prefs.getInt(keyDifficulty) ?? 1; // 1 = Medium
  static Future<void> setDifficulty(int diff) async => await _prefs.setInt(keyDifficulty, diff);

  static bool isParticleEffect() => _prefs.getBool(keyParticleEffect) ?? true;
  static Future<void> setParticleEffect(bool on) async => await _prefs.setBool(keyParticleEffect, on);

  static bool isScreenShake() => _prefs.getBool(keyScreenShake) ?? true;
  static Future<void> setScreenShake(bool on) async => await _prefs.setBool(keyScreenShake, on);

  static bool isGlowEffect() => _prefs.getBool(keyGlowEffect) ?? true;
  static Future<void> setGlowEffect(bool on) async => await _prefs.setBool(keyGlowEffect, on);

  static Future<void> resetProgress() async {
    await _prefs.setInt(keyHighScore, 0);
    await _prefs.setInt(keyCoins, 0);
    await _prefs.setInt(keyLastLevel, 1);
    await _prefs.setInt(keyUnlockedLevel, 1);
    await _prefs.setInt(keyTotalWins, 0);
    await _prefs.setInt(keyTotalLosses, 0);
    await _prefs.setInt(keyTotalShots, 0);
    await _prefs.setInt(keyTotalHits, 0);
    await _prefs.setInt(keyTotalPlayTime, 0);
    await _prefs.setInt(keyHighestLevel, 1);

    // Clear stars for all 100 levels
    for (int i = 1; i <= 100; i++) {
      await _prefs.remove('$keyLevelStars$i');
    }
  }
}
