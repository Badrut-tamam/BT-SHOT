import 'package:flutter/material.dart';

class PowerUpService extends ChangeNotifier {
  double _laserProgress = 0.0;
  bool _isLaserReady = false;
  bool _isLaserActive = false;

  double get laserProgress => _laserProgress;
  bool get isLaserReady => _isLaserReady;
  bool get isLaserActive => _isLaserActive;

  void updateProgress(int currentBubbles, int initialBubbles, [double multiplier = 1.0]) {
    if (initialBubbles == 0) return;
    
    // Progress is based on % of bubbles destroyed
    double destroyedPercent = (initialBubbles - currentBubbles) / initialBubbles;
    
    // We want it to be ready at 50% usually
    _laserProgress = ((destroyedPercent / 0.5) * multiplier).clamp(0.0, 1.0);
    
    if (_laserProgress >= 1.0 && !_isLaserReady) {
      _isLaserReady = true;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  void activateLaser() {
    if (!_isLaserReady) return;
    
    _isLaserActive = true;
    _isLaserReady = false;
    _laserProgress = 0.0;
    notifyListeners();
    
    // Auto-deactivate after animation duration
    Future.delayed(const Duration(milliseconds: 1000), () {
      _isLaserActive = false;
      notifyListeners();
    });
  }

  void reset() {
    _laserProgress = 0.0;
    _isLaserReady = false;
    _isLaserActive = false;
    notifyListeners();
  }
}
