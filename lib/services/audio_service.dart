import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'save_service.dart';

class AudioService {
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static bool _bgmStarted = false;
  
  static const String _pathShoot = 'sounds/shoot.mp3';
  static const String _pathPop = 'sounds/pop.mp3';
  static const String _pathWin = 'sounds/win.mp3';
  static const String _pathLose = 'sounds/lose.mp3';
  static const String _pathExplosion = 'sounds/explosion.mp3';
  static const String _pathBgm = 'sounds/bgm.mp3';

  // ─── Background Music ─────────────────────────────────────────
  static Future<void> startBGM() async {
    if (!SaveService.isMusicOn()) return;
    if (_bgmStarted) return;
    _bgmStarted = true;
    await _bgmPlayer.setVolume(SaveService.getMusicVolume());
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    try {
      await _bgmPlayer.play(AssetSource(_pathBgm));
    } catch (_) {
      // No BGM file present – silently ignore so app doesn't crash
      _bgmStarted = false;
    }
  }

  static Future<void> pauseBGM() async {
    await _bgmPlayer.pause();
  }

  static Future<void> resumeBGM() async {
    if (!SaveService.isMusicOn()) return;
    await _bgmPlayer.resume();
  }

  static Future<void> stopBGM() async {
    _bgmStarted = false;
    await _bgmPlayer.stop();
  }

  static Future<void> updateBGMVolume() async {
    await _bgmPlayer.setVolume(SaveService.getMusicVolume());
    if (SaveService.isMusicOn()) {
      await resumeBGM();
    } else {
      await pauseBGM();
    }
  }

  // ─── Sound Effects ────────────────────────────────────────────
  static Future<void> playShoot() async {
    if (!SaveService.isSoundOn()) return;
    try {
      await _sfxPlayer.play(AssetSource(_pathShoot), volume: SaveService.getSfxVolume());
    } catch (_) {}
  }

  static Future<void> playPop() async {
    if (!SaveService.isSoundOn()) return;
    try {
      await _sfxPlayer.play(AssetSource(_pathPop), volume: SaveService.getSfxVolume() * 0.5);
    } catch (_) {}
  }

  static Future<void> playWin() async {
    if (!SaveService.isSoundOn()) return;
    try {
      await _sfxPlayer.play(AssetSource(_pathWin), volume: SaveService.getSfxVolume());
    } catch (_) {}
  }

  static Future<void> playLose() async {
    if (!SaveService.isSoundOn()) return;
    try {
      await _sfxPlayer.play(AssetSource(_pathLose), volume: SaveService.getSfxVolume());
    } catch (_) {}
  }

  static Future<void> playExplosion() async {
    if (!SaveService.isSoundOn()) return;
    try {
      await _sfxPlayer.play(AssetSource(_pathExplosion), volume: SaveService.getSfxVolume() * 0.8);
    } catch (_) {}
  }

  // ─── Vibration ───────────────────────────────────────────────
  static Future<void> vibrate(int duration) async {
    if (!SaveService.isVibrationOn()) return;
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: duration);
    }
  }

  // ─── Drop ────────────────────────────────────────────────────
  static Future<void> playDrop() async {
    // No sound file for drop yet — placeholder
  }
}
