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

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

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

  static Future<void> resetProgress() async {
    await _prefs.setInt(keyHighScore, 0);
    await _prefs.setInt(keyCoins, 0);
    await _prefs.setInt(keyLastLevel, 1);
    await _prefs.setInt(keyUnlockedLevel, 1);
  }
}
