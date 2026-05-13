import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'save_service.dart';

class AudioService {
  // ── SATU player khusus per suara — BGM TIDAK PERNAH diganggu SFX ──
  static final AudioPlayer _bgmPlayer       = AudioPlayer();
  static final AudioPlayer _shootPlayer     = AudioPlayer();
  static final AudioPlayer _popPlayer       = AudioPlayer();
  static final AudioPlayer _explosionPlayer = AudioPlayer();
  static final AudioPlayer _laserPlayer     = AudioPlayer();
  static final AudioPlayer _winPlayer       = AudioPlayer();
  static final AudioPlayer _losePlayer      = AudioPlayer();
  static final AudioPlayer _warningPlayer   = AudioPlayer();
  static final AudioPlayer _dropPlayer      = AudioPlayer();

  static bool   _bgmStarted = false;
  static String _currentBgm = '';

  // Jalur aset
  static const String _pathShoot     = 'sounds/shoot.wav';
  static const String _pathPop       = 'sounds/pop.wav';
  static const String _pathWin       = 'sounds/win.mp3';
  static const String _pathLose      = 'sounds/lose.mp3';
  static const String _pathExplosion = 'sounds/explosion.wav';
  static const String _pathWarning   = 'sounds/warning.mp3';
  static const String _pathLaser     = 'sounds/laser.mp3';
  static const String _pathDrop      = 'sounds/drop.mp3';
  static const String _pathBgmMenu   = 'sounds/DJ KICAU KICAU KICAU MANIA SLOW VIRAL TIKTOK FULL SONG MAMAN FVNDY 2026 - (320 Kbps).mp3';
  static const String _pathBgmGame   = 'sounds/bgm_game.mp3';

  /// Panggil SEKALI saat app pertama kali dijalankan
  static Future<void> init() async {
    try {
      // BGM dengan mode mediaPlayer untuk menghindari audio focus issues
      _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      _bgmPlayer.setPlayerMode(PlayerMode.mediaPlayer);

      final sfxPlayers = [
        _shootPlayer, _popPlayer, _explosionPlayer,
        _laserPlayer, _winPlayer, _losePlayer,
        _warningPlayer, _dropPlayer,
      ];
      
      // SFX menggunakan lowLatency agar tidak mengganggu BGM
      for (final p in sfxPlayers) {
        p.setReleaseMode(ReleaseMode.stop);
        p.setPlayerMode(PlayerMode.lowLatency);
      }
    } catch (e) {
      debugPrint("Audio init error: $e");
    }
  }

  // ─── Musik Latar ───────────────────────────────────────────────
  static Future<void> startMenuBGM() async => _startBGM(_pathBgmMenu);
  static Future<void> startGameBGM() async {
    // Musik dihentikan saat masuk game sesuai permintaan user (hanya ingin SFX)
    await stopBGM();
  }

  static Future<void> _startBGM(String path) async {
    if (!SaveService.isMusicOn()) {
      await _bgmPlayer.stop();
      _bgmStarted = false;
      return;
    }

    // Jika sudah memutar lagu yang sama dan sedang playing, jangan restart
    if (_bgmStarted && _currentBgm == path) {
      if (_bgmPlayer.state == PlayerState.playing) return;
      
      // Jika paused atau stopped/completed, coba resume/restart
      try {
        if (_bgmPlayer.state == PlayerState.paused) {
          await _bgmPlayer.resume();
        } else {
          await _bgmPlayer.play(AssetSource(path));
        }
        return;
      } catch (e) {
        debugPrint('[BGM] Resume/Restart error: $e');
        // Fallthrough to full restart logic below
      }
    }

    try {
      await _bgmPlayer.stop();
      _bgmStarted = true;
      _currentBgm = path;
      await _bgmPlayer.setVolume(SaveService.getMusicVolume());
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource(path));
      debugPrint('[BGM] Memutar track baru: $path');
    } catch (e) {
      _bgmStarted = false;
      _currentBgm = '';
      debugPrint('[BGM] Play error: $e');
    }
  }

  static Future<void> pauseBGM() async => _bgmPlayer.pause();

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
      if (_bgmPlayer.state != PlayerState.playing && _currentBgm.isNotEmpty) {
        await _startBGM(_currentBgm);
      } else {
        await resumeBGM();
      }
    } else {
      await pauseBGM();
    }
  }

  /// Memastikan BGM terus playing tanpa berhenti saat bermain
  static Future<void> ensureGameBGMPlaying() async {
    // Dimatikan karena user tidak ingin ada musik di dalam game
    return;
  }

  /// Maintain audio focus - dipanggil saat ada event (seperti menembak)
  /// untuk memastikan BGM tidak kehilangan audio focus
  static Future<void> maintainBGMFocus() async {
    try {
      if (SaveService.isMusicOn() && _currentBgm.isNotEmpty) {
        // Hanya restore jika lagu yang sedang di-set adalah musik menu
        if (_currentBgm == _pathBgmMenu) {
          if (_bgmPlayer.state != PlayerState.playing) {
            await _bgmPlayer.resume();
            debugPrint('[BGM] Menu music focus restored');
          }
        }
      }
    } catch (e) {
      debugPrint('[BGM] Focus maintain error: $e');
    }
  }

  // ─── Efek Suara ────────────────────────────────────────────────
  // Setiap SFX punya player SENDIRI → tidak bisa mengganggu BGM

  static void playShoot() {
    if (!SaveService.isSoundOn()) return;
    try { 
      _shootPlayer.stop().then((_) {
        _shootPlayer.play(AssetSource(_pathShoot), volume: SaveService.getSfxVolume() * 0.4);
      }).catchError((e) => debugPrint("Shoot sound error: $e"));
    } catch (_) {}
  }

  static void playPop() {
    if (!SaveService.isSoundOn()) return;
    try { 
      _popPlayer.stop().then((_) {
        _popPlayer.play(AssetSource(_pathPop), volume: SaveService.getSfxVolume() * 0.5);
      }).catchError((e) => debugPrint("Pop sound error: $e"));
    } catch (_) {}
  }

  static void playMelodicPop(int comboCount) {
    if (!SaveService.isSoundOn()) return;
    try {
      double pitch = 1.0 + (comboCount * 0.1).clamp(0.0, 1.0);
      _popPlayer.setPlaybackRate(pitch);
      _popPlayer.play(AssetSource(_pathPop), volume: SaveService.getSfxVolume() * 0.6);
    } catch (_) {}
  }

  static void playLaser() {
    if (!SaveService.isSoundOn()) return;
    try { 
      _laserPlayer.stop().then((_) {
        // Fallback ke explosion jika laser.mp3 tidak ada
        _laserPlayer.play(AssetSource(_pathExplosion), volume: SaveService.getSfxVolume() * 1.5);
        // Restore BGM focus after playing SFX
        Future.delayed(const Duration(milliseconds: 10), () {
          maintainBGMFocus();
        });
      }).catchError((e) => debugPrint("Laser sound error: $e"));
    } catch (_) {}
  }

  static void playWin() {
    if (!SaveService.isSoundOn()) return;
    try { _winPlayer.play(AssetSource(_pathExplosion), volume: SaveService.getSfxVolume()); } catch (_) {}
  }

  static void playLose() {
    if (!SaveService.isSoundOn()) return;
    try { _losePlayer.play(AssetSource(_pathExplosion), volume: SaveService.getSfxVolume()); } catch (_) {}
  }

  static void playExplosion() {
    if (!SaveService.isSoundOn()) return;
    try { 
      _explosionPlayer.play(AssetSource(_pathExplosion), volume: SaveService.getSfxVolume() * 0.8);
      // Restore BGM focus after playing SFX
      Future.delayed(const Duration(milliseconds: 10), () {
        maintainBGMFocus();
      });
    } catch (_) {}
  }

  static void playWarning() {
    if (!SaveService.isSoundOn()) return;
    // Skip if missing
  }

  static void playDrop() {
    if (!SaveService.isSoundOn()) return;
    // Skip if missing
  }

  // ─── Getaran ───────────────────────────────────────────────────
  static Future<void> vibrate(int duration) async {
    if (!SaveService.isVibrationOn()) return;
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: duration);
    }
  }
}
