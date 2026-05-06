import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'save_service.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  
  // Note: These should be paths to actual assets. 
  // I will assume assets/sounds/ exist. The user might need to add them.
  static const String _pathShoot = 'sounds/shoot.mp3';
  static const String _pathPop = 'sounds/pop.mp3';
  static const String _pathWin = 'sounds/win.mp3';
  static const String _pathLose = 'sounds/lose.mp3';

  static Future<void> playShoot() async {
    if (SaveService.isSoundOn()) {
      await _player.play(AssetSource(_pathShoot));
    }
  }

  static Future<void> playPop() async {
    if (SaveService.isSoundOn()) {
      await _player.play(AssetSource(_pathPop), volume: 0.5);
    }
  }

  static Future<void> playWin() async {
    if (SaveService.isSoundOn()) {
      await _player.play(AssetSource(_pathWin));
    }
  }

  static Future<void> playLose() async {
    if (SaveService.isSoundOn()) {
      await _player.play(AssetSource(_pathLose));
    }
  }

  static Future<void> vibrate(int duration) async {
    if (SaveService.isVibrationOn()) {
      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate(duration: duration);
      }
    }
  }
}
