import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'save_service.dart';

class AudioService {
  // Multiple SFX players to prevent cut-off on rapid sounds
  static final AudioPlayer _sfxPlayer  = AudioPlayer();
  static final AudioPlayer _sfx2Player = AudioPlayer();
  static final AudioPlayer _bgmPlayer  = AudioPlayer();
  static bool _bgmStarted = false;

  // Asset paths
  static const String _pathShoot     = 'sounds/shoot.wav';
  static const String _pathPop       = 'sounds/pop.wav';
  static const String _pathWin       = 'sounds/win.mp3';
  static const String _pathLose      = 'sounds/lose.mp3';
  static const String _pathExplosion = 'sounds/explosion.wav';
  static const String _pathWarning   = 'sounds/warning.mp3';
  static const String _pathLaser     = 'sounds/laser.mp3';
  static const String _pathDrop      = 'sounds/drop.mp3';
  static const String _pathBgmMenu   = 'sounds/DJ KICAU KICAU KICAU MANIA SLOW VIRAL TIKTOK FULL SONG MAMAN FVNDY 2026 - (320 Kbps).mp3';
  static const String _pathBgmGame   = 'audio/SERULING INDIAN MERDU.mp3';

  static String _currentBgm = '';

  // ─── Background Music ──────────────────────────────────────────
  static Future<void> startMenuBGM() async {
    await _startBGM(_pathBgmMenu);
  }

  static Future<void> startGameBGM() async {
    await _startBGM(_pathBgmGame);
  }

  static Future<void> _startBGM(String path) async {
    if (!SaveService.isMusicOn()) return;
    
    // If already playing this exact track, don't restart it
    if (_bgmStarted && _currentBgm == path) {
      if (_bgmPlayer.state == PlayerState.playing) return;
      if (_bgmPlayer.state == PlayerState.paused) {
        await _bgmPlayer.resume();
        return;
      }
    }

    try {
      // IMPORTANT: Stop any previous music before starting a new one to prevent overlapping
      await _bgmPlayer.stop();
      
      _bgmStarted = true;
      _currentBgm = path;

      // Set volume and ensure it loops
      await _bgmPlayer.setVolume(SaveService.getMusicVolume());
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      
      try {
        // Try playing the requested track
        await _bgmPlayer.play(AssetSource(path));
        debugPrint('Playing BGM: $path');
      } catch (e) {
        _bgmStarted = false;
        _currentBgm = '';
        debugPrint('BGM play failed: $e');
      }
    } catch (e) {
      _bgmStarted = false;
      debugPrint('General BGM error: $e');
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
    _currentBgm = '';
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

  // ─── Sound Effects ─────────────────────────────────────────────
  static Future<void> playShoot() async {
    if (!SaveService.isSoundOn()) return;
    try {
      await _sfxPlayer.play(AssetSource(_pathShoot), volume: SaveService.getSfxVolume());
    } catch (_) {}
  }

  static Future<void> playPop() async {
    if (!SaveService.isSoundOn()) return;
    try {
      await _sfx2Player.setPlaybackRate(1.0);
      await _sfx2Player.play(AssetSource(_pathPop), volume: SaveService.getSfxVolume() * 0.5);
    } catch (_) {}
  }

  static Future<void> playMelodicPop(int comboCount) async {
    if (!SaveService.isSoundOn()) return;
    try {
      // Scale pitch from 1.0 to 2.0 based on combo
      // 1.0 (base), 1.059 (semitone), etc. Or just linear for simplicity.
      double pitch = 1.0 + (comboCount * 0.1).clamp(0.0, 1.0);
      await _sfx2Player.setPlaybackRate(pitch);
      await _sfx2Player.play(AssetSource(_pathPop), volume: SaveService.getSfxVolume() * 0.6);
    } catch (_) {}
  }

  static Future<void> playLaser() async {
    if (!SaveService.isSoundOn()) return;
    try {
      await _sfxPlayer.play(AssetSource(_pathLaser), volume: SaveService.getSfxVolume() * 1.2);
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

  static Future<void> playWarning() async {
    if (!SaveService.isSoundOn()) return;
    try {
      await _sfx2Player.play(AssetSource(_pathWarning), volume: SaveService.getSfxVolume());
    } catch (_) {}
  }

  static Future<void> playDrop() async {
    if (!SaveService.isSoundOn()) return;
    try {
      await _sfx2Player.play(AssetSource(_pathDrop), volume: SaveService.getSfxVolume() * 0.4);
    } catch (_) {}
  }

  // ─── Vibration ─────────────────────────────────────────────────
  static Future<void> vibrate(int duration) async {
    if (!SaveService.isVibrationOn()) return;
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: duration);
    }
  }
}
