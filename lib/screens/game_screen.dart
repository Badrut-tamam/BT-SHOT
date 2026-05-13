import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../components/score_header.dart';
import '../components/bubble_grid.dart';
import '../components/shooter_ui.dart';
import '../services/game_engine.dart';
import '../services/save_service.dart';
import '../services/audio_service.dart';
import '../components/custom_button.dart';
import '../services/level_service.dart';
import '../components/space_background.dart';
import '../services/powerup_service.dart';
import '../theme/app_colors.dart';
import 'pause_menu.dart';
import 'game_over_screen.dart';
import '../data/level_data.dart';

enum GameState { playing, paused, gameOver, victory }

class GameScreen extends StatefulWidget {
  final int? initialLevel;
  const GameScreen({super.key, this.initialLevel});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameEngine _engine;
  GameState _gameState = GameState.playing;
  late AnimationController _controller;
  late AnimationController _warningFlashController;
  double _aimAngle = -pi / 2;
  late PowerUpService _powerUpService;
  int _initialBubbleCount = 0;
  bool _showLaserEffect = false;

  // Effects
  final List<ComboTextEffect> _comboEffects = [];
  final List<ParticleEffect> _particles = [];
  double _shakeIntensity = 0.0;
  final Random _random = Random();
  final Stopwatch _playTimer = Stopwatch();
  bool _batterySaver = false;
  int _musicCheckFrameCounter = 0;

  // Warning state
  bool _wasInCritical = false;

  @override
  void initState() {
    super.initState();
    _batterySaver = SaveService.isBatterySaver();
    _engine = GameEngine(targetLevel: widget.initialLevel);
    _engine.startLevel(widget.initialLevel ?? 1, SaveService.getDifficulty()); // Explicitly set difficulty
    _powerUpService = PowerUpService();
    
    _engine.onBubblesPopped = (count, combo) {
      double charge = (count * 0.01) + (combo * 0.02);
      _powerUpService.addCharge(charge);
      
      if (_powerUpService.isLaserReady && !_wasInCritical) {
        // Just reached full charge
        _addComboEffect("LASER READY!");
        AudioService.playWin(); // Use win sound for ready feedback
      }
    };
    
    _initialBubbleCount = _engine.getFilledBubbleCount();

    int fpsDuration = SaveService.getFpsMode() >= 120 ? 8 : 16;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: fpsDuration),
    )..addListener(_gameLoop);
    _controller.repeat();

    // Warning flash (red blink)
    _warningFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _playTimer.start();
    AudioService.startGameBGM();
  }

  @override
  void dispose() {
    _controller.dispose();
    _warningFlashController.dispose();
    _playTimer.stop();
    if (_engine.shotsFired > 0) {
      SaveService.addShots(_engine.shotsFired);
      SaveService.addHits(_engine.bubblesPoppedThisMatch);
      SaveService.addPlayTime(_playTimer.elapsed.inSeconds);
    }
    super.dispose();
  }

  void _gameLoop() {
    if (_gameState == GameState.playing) {
      // Periodically check if music is still playing (every ~1 second)
      _musicCheckFrameCounter++;
      if (_musicCheckFrameCounter >= 60) {
        _musicCheckFrameCounter = 0;
        AudioService.ensureGameBGMPlaying();
      }
      
      setState(() {
        int oldScore = _engine.score;
        int oldCombo = _engine.rewardService.comboCount;
        
        _engine.update(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
          0.016,
          _triggerGameOver,
        );

        // Update Laser Progress - No longer automatic percentage based
        // Handled via onBubblesPopped callback above
        
        // Check for Win
        if (_engine.checkWin()) {
          _triggerVictory();
        }

        // Check for Lose
        if (_engine.checkLose()) {
          _triggerGameOver();
        }

        // Vibrate when entering critical zone for first time
        if (_engine.isInCritical && !_wasInCritical) {
          AudioService.vibrate(300);
        }
        _wasInCritical = _engine.isInCritical;

        // Shake when critical
        if (_engine.isInCritical && _engine.countdownTimer < 5) {
          _shakeIntensity = 3.0;
        }

        // Show combo effect if combo increased
        if (_engine.rewardService.comboCount > oldCombo && _engine.rewardService.comboCount >= 2) {
          _addComboEffect(_engine.rewardService.getComboText());
          _shakeIntensity = 4.0;
        }

        // Add particles if score increased
        if (_engine.score > oldScore) {
          Offset popPos = _engine.lastPopPosition ?? Offset(MediaQuery.of(context).size.width / 2, 200);
          bool isBigMatch = (_engine.score - oldScore) > 100;
          
          _addParticles(
            popPos.dx, 
            popPos.dy, 
            color: _engine.shooterColor, 
            count: isBigMatch ? 20 : 10,
            isExplosion: isBigMatch
          );
          _shakeIntensity = isBigMatch ? 5.0 : 2.0;
          _engine.lastPopPosition = null; 
        }

        // Dampen shake
        if (_shakeIntensity > 0) {
          _shakeIntensity *= 0.9;
          if (_shakeIntensity < 0.1) _shakeIntensity = 0.0;
        }

        _comboEffects.removeWhere((e) => e.isFinished);
        _particles.removeWhere((p) => p.isFinished);
        for (var e in _comboEffects) { e.update(); }
        for (var p in _particles) { p.update(); }
      });
    }
  }

  void _activateLaser() {
    if (!_powerUpService.isLaserReady) {
      // Feedback if not ready
      _addComboEffect("LASER NOT READY");
      setState(() {
        _shakeIntensity = 3.0; // Small shake
      });
      AudioService.playPop(); // Small error-like sound
      return;
    }
    
    AudioService.playLaser();
    AudioService.vibrate(150); // Increased vibration for mega shot
    setState(() {
      _showLaserEffect = true;
      _shakeIntensity = 30.0; // Mega shake for laser
      _engine.recoilOffset = 30.0;
    });
    
    final size = MediaQuery.of(context).size;
    _powerUpService.activateLaser();
    _engine.fireLaser(_aimAngle, size.width, size.height);
    _addComboEffect("MEGA SHOT!");
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _showLaserEffect = false;
        });
      }
    });
  }

  void _addComboEffect(String text) {
    _comboEffects.add(ComboTextEffect(text: text));
  }

  void _addParticles(double x, double y, {Color? color, int count = 12, bool isExplosion = false}) {
    int finalCount = _batterySaver ? (count ~/ 2) : count;
    for (int i = 0; i < finalCount; i++) {
      _particles.add(ParticleEffect(
        x: x, 
        y: y, 
        color: color, 
        isExplosion: isExplosion
      ));
    }
  }

  void _togglePause() {
    setState(() {
      if (_gameState == GameState.playing) {
        _gameState = GameState.paused;
        AudioService.pauseBGM();
      } else {
        _gameState = GameState.playing;
        AudioService.resumeBGM();
      }
    });
  }

  Future<void> _triggerGameOver() async {
    if (_gameState == GameState.gameOver || _gameState == GameState.victory) return;
    
    int earnedCoins = _engine.rewardService.calculateCoins(_engine.score);
    await SaveService.addCoins(earnedCoins);
    
    _playTimer.stop();
    await SaveService.addLoss();
    await SaveService.addShots(_engine.shotsFired);
    await SaveService.addHits(_engine.bubblesPoppedThisMatch);
    await SaveService.addPlayTime(_playTimer.elapsed.inSeconds);
    _engine.shotsFired = 0;
    _engine.bubblesPoppedThisMatch = 0;
    _playTimer.reset();
    
    setState(() {
      _gameState = GameState.gameOver;
      _shakeIntensity = 15.0;
    });
    AudioService.playLose();
  }

  Future<void> _triggerVictory() async {
    if (_gameState == GameState.victory) return;
    
    // Calculate stars
    int stars = LevelService.calculateStars(_engine.remainingBubbles, _engine.maxBubbles);
    
    // Save progress - Critical: await these!
    await LevelService.unlockNextLevel(_engine.level);
    await LevelService.setLevelStars(_engine.level, stars);
    
    int earnedCoins = _engine.rewardService.calculateCoins(_engine.score) + (stars * 50);
    await SaveService.addCoins(earnedCoins);
    
    await SaveService.setHighestLevel(_engine.level);
    _playTimer.stop();
    await SaveService.addWin();
    await SaveService.addShots(_engine.shotsFired);
    await SaveService.addHits(_engine.bubblesPoppedThisMatch);
    await SaveService.addPlayTime(_playTimer.elapsed.inSeconds);
    _engine.shotsFired = 0;
    _engine.bubblesPoppedThisMatch = 0;
    _playTimer.reset();
    
    setState(() {
      _gameState = GameState.victory;
      _shakeIntensity = 10.0;
    });
    AudioService.playWin();
  }

  Future<void> _nextLevel() async {
    await _engine.startLevel(_engine.level + 1, SaveService.getDifficulty());
    setState(() {
      _gameState = GameState.playing;
      _comboEffects.clear();
      _particles.clear();
      _initialBubbleCount = _engine.getFilledBubbleCount();
      _powerUpService.reset();
    });
    // Ensure game BGM continues playing
    await AudioService.startGameBGM();
  }

  Future<void> _restartGame() async {
    await _engine.startLevel(_engine.level, SaveService.getDifficulty());
    setState(() {
      _gameState = GameState.playing;
      _comboEffects.clear();
      _particles.clear();
      _initialBubbleCount = _engine.getFilledBubbleCount();
      _powerUpService.reset();
      _playTimer.reset();
      _playTimer.start();
    });
    // Ensure game BGM is playing when restarting
    await AudioService.startGameBGM();
  }

  void _exitToMenu() {
    // Stop game BGM before going back to menu
    AudioService.stopBGM();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _handlePointerUpdate(dynamic event) {
    if (_gameState != GameState.playing) return;
    
    // Position can come from PointerEvent or DragUpdateDetails or DragDownDetails
    Offset pos;
    if (event is PointerEvent) {
      pos = event.position;
    } else if (event is DragUpdateDetails) {
      pos = event.globalPosition;
    } else if (event is DragDownDetails) {
      pos = event.globalPosition;
    } else {
      return;
    }

    double dx = pos.dx - MediaQuery.of(context).size.width / 2;
    // The spaceship center is exactly 55 pixels from the bottom of the screen
    double dy = pos.dy - (MediaQuery.of(context).size.height - 55);
    setState(() {
      _aimAngle = atan2(dy, dx);
      // Ensure the angle is pointing upwards
      if (_aimAngle > 0) _aimAngle = dx > 0 ? 0 : pi;
    });
  }

  void _handlePointerUp(dynamic event) {
    if (_gameState != GameState.playing) return;
    
    // Check if we can shoot
    if (_engine.activeBubble == null && _engine.remainingBubbles > 0) {
       _engine.shoot(_aimAngle, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
       
       // Bonus: recoil / shoot effects
       setState(() {
         _shakeIntensity = 3.0; // Recoil shake
         _addParticles(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height - 55, count: 5);
       });
       
       // Maintain BGM audio focus after shooting (fire and forget)
       unawaited(AudioService.maintainBGMFocus());
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Offset shakeOffset = Offset(
      (_random.nextDouble() - 0.5) * _shakeIntensity,
      (_random.nextDouble() - 0.5) * _shakeIntensity,
    );

    bool isBoss = LevelData.getLevel(_engine.level).isBoss;
    double progressPct = 1.0 - (_engine.getFilledBubbleCount() / max(1, _initialBubbleCount));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_gameState == GameState.playing) _togglePause();
        else _exitToMenu();
      },
      child: Scaffold(
        backgroundColor: isBoss ? const Color(0xFF1A0000) : Colors.black,
        body: Transform.translate(
          offset: shakeOffset,
          child: Stack(
            children: [
              const RepaintBoundary(child: SpaceBackground()),

              if (_gameState == GameState.playing && _engine.activeBubble == null)
                IgnorePointer(child: _buildAimPrediction(size)),

              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: _handlePointerUpdate,
                onPanDown: _handlePointerUpdate,
                onPanEnd: _handlePointerUp,
                child: Container(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      RepaintBoundary(
                        child: BubbleGrid(engine: _engine, screenWidth: size.width),
                      ),

                      // ── Danger Line ──
                      if (_engine.isInDanger)
                        _buildDangerLine(size),

                      // ── Particles ──
                      ..._particles.map((p) => Positioned(
                        left: p.x, top: p.y,
                        child: p.build(),
                      )),

                      // ── Score Header ──
                      Positioned(
                        top: 0, left: 0, right: 0,
                        child: ScoreHeader(
                          score: _engine.score,
                          level: _engine.level,
                          bubbles: _engine.remainingBubbles,
                          laserProgress: _powerUpService.laserProgress,
                          laserReady: _powerUpService.isLaserReady,
                          onBack: _togglePause,
                        ),
                      ),

                      // ── Progress Bar ──
                      Positioned(
                        top: 140, left: 16, right: 16,
                        child: _buildProgressBar(progressPct),
                      ),

                      // ── Shooter UI ──
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: ShooterUI(
                          shooterColor: _engine.shooterColor,
                          nextColor: _engine.nextColor,
                          shooterFaceType: _engine.shooterFaceType,
                          nextFaceType: _engine.nextFaceType,
                          angle: _aimAngle,
                          laserReady: _powerUpService.isLaserReady,
                          laserProgress: _powerUpService.laserProgress,
                          onLaserTap: _activateLaser,
                          onSwapTap: () => setState(() => _engine.swapBubble()),
                          canSwap: !_engine.hasSwapped,
                          recoilOffset: _engine.recoilOffset,
                          isMuzzleFlashing: _engine.isMuzzleFlashing,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Warning Flash Overlay ──
              if (_engine.isInDanger && _gameState == GameState.playing)
                IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _warningFlashController,
                    builder: (_, __) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red.withOpacity(
                            _engine.isInCritical
                              ? 0.5 * _warningFlashController.value
                              : 0.2 * _warningFlashController.value,
                          ),
                          width: _engine.isInCritical ? 6 : 3,
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Warning Text Banner ──
              if (_engine.isInDanger && _gameState == GameState.playing)
                _buildWarningBanner(size),

              // ── Countdown ──
              if (_engine.countdownActive && _gameState == GameState.playing)
                _buildCountdown(),

              // ── Laser Effect (PETIR) ──
              if (_showLaserEffect)
                Positioned(
                  bottom: 60, // Start from ship height
                  left: size.width / 2 - 40, // Center horizontally
                  child: IgnorePointer(
                    child: FadeIn(
                      duration: const Duration(milliseconds: 100),
                      child: Transform.rotate(
                        angle: _aimAngle + pi / 2,
                        alignment: Alignment.bottomCenter, // Rotate from the bottom (ship)
                        child: Container(
                          width: 80,
                          height: size.height * 1.5, // Extra long to cover screen
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.cyanAccent.withOpacity(0.5),
                                Colors.white,
                                Colors.cyanAccent,
                                Colors.white,
                                Colors.cyanAccent.withOpacity(0.5),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.1, 0.4, 0.5, 0.6, 0.9, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.9), 
                                blurRadius: 120, 
                                spreadRadius: 40
                              ),
                              BoxShadow(
                                color: Colors.white, 
                                blurRadius: 30, 
                                spreadRadius: 10
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Combo Effects ──
              IgnorePointer(
                child: Stack(
                  children: [
                    ..._comboEffects.map((e) => Center(
                      child: Opacity(
                        opacity: e.opacity,
                        child: Transform.scale(
                          scale: e.scale,
                          child: Text(
                            e.text,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(color: AppColors.neonBlue, blurRadius: 20),
                                Shadow(color: AppColors.neonPurple, blurRadius: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),

              if (_gameState == GameState.paused)
                FadeIn(child: PauseMenu(onResume: _togglePause, onRestart: _restartGame, onExit: _exitToMenu)),
              if (_gameState == GameState.gameOver)
                FadeIn(child: GameOverScreen(score: _engine.score, onRetry: _restartGame, onExit: _exitToMenu)),
              if (_gameState == GameState.victory)
                VictoryOverlay(
                  level: _engine.level,
                  score: _engine.score,
                  stars: LevelService.getLevelStars(_engine.level),
                  onNextLevel: _nextLevel,
                  onExit: _exitToMenu,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerLine(Size size) {
    double verticalSpacing = GameEngine.bubbleDiameter * 0.866;
    double lineY = GameEngine.gridTopOffset + GameEngine.bubbleRadius +
        (GameEngine.dangerRow * verticalSpacing);
    return Positioned(
      top: lineY,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _warningFlashController,
        builder: (_, __) => Container(
          height: 2,
          color: Colors.red.withOpacity(0.4 + 0.6 * _warningFlashController.value),
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                'DANGER ZONE',
                style: GoogleFonts.outfit(
                  color: Colors.red.withOpacity(0.9),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarningBanner(Size size) {
    return Positioned(
      top: 155,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _warningFlashController,
          builder: (_, __) => Opacity(
            opacity: 0.5 + 0.5 * _warningFlashController.value,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.6)),
                ),
                child: Text(
                  _engine.isInCritical ? '⚠ BUBBLES APPROACHING! ⚠' : '⚠ WARNING!',
                  style: GoogleFonts.outfit(
                    color: Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    int secs = _engine.countdownTimer.ceil();
    bool urgent = secs <= 3;
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _warningFlashController,
          builder: (_, __) => Center(
            child: Column(
              children: [
                Text(
                  'LAST CHANCE!',
                  style: GoogleFonts.outfit(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                Text(
                  '$secs',
                  style: GoogleFonts.outfit(
                    color: urgent
                      ? Color.lerp(Colors.red, Colors.white, _warningFlashController.value)!
                      : Colors.orange,
                    fontSize: urgent ? 52 : 40,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(color: Colors.red, blurRadius: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double pct) {
    int filled = _engine.getFilledBubbleCount();
    bool nearEnd = filled <= 10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SECTOR ${_engine.level}',
              style: GoogleFonts.outfit(color: Colors.grey, fontSize: 9, letterSpacing: 2),
            ),
            Text(
              nearEnd ? '✦ FINAL WAVE ✦' : '${(pct * 100).toInt()}% CLEARED',
              style: GoogleFonts.outfit(
                color: nearEnd ? Colors.amber : Colors.grey,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct.clamp(0.0, 1.0),
            minHeight: 4,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation(
              nearEnd ? Colors.amber : AppColors.neonBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAimPrediction(Size size) {
    return RepaintBoundary(
      child: CustomPaint(
        size: size,
        painter: AimPainter(_aimAngle, GameEngine.bubbleRadius, _engine),
      ),
    );
  }
}

class VictoryOverlay extends StatelessWidget {
  final int level;
  final int score;
  final VoidCallback onNextLevel;
  final VoidCallback onExit;
  final int stars;

  const VictoryOverlay({
    super.key,
    required this.level,
    required this.score,
    required this.onNextLevel,
    required this.onExit,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    String rank = stars == 3 ? 'LEGENDARY' : (stars == 2 ? 'EXCELLENT' : 'SUCCESS');
    
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInDown(
                  child: Column(
                    children: [
                      Text(rank, style: GoogleFonts.outfit(color: AppColors.neonBlue, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 10)),
                      Text('MISSION COMPLETE', textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildStarsDisplay(),
                const SizedBox(height: 30),
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppColors.neonBlue.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text('SECTOR $level DATA', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        const SizedBox(height: 8),
                        Text('$score', style: GoogleFonts.outfit(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeInUp(
                  delay: const Duration(milliseconds: 900),
                  child: Column(
                    children: [
                      if (level < 100)
                        CustomButton(text: 'NEXT SECTOR', icon: Icons.navigate_next_rounded, onPressed: onNextLevel),
                      const SizedBox(height: 12),
                      CustomButton(text: 'RETURN TO BASE', icon: Icons.home_rounded, isSecondary: true, onPressed: onExit),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarsDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool active = index < stars;
        return ZoomIn(
          delay: Duration(milliseconds: 400 + (index * 200)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              Icons.star_rounded,
              color: active ? Colors.amber : Colors.white.withOpacity(0.1),
              size: index == 1 ? 70 : 50,
              shadows: active ? [
                Shadow(color: Colors.amber.withOpacity(0.8), blurRadius: 20),
                Shadow(color: Colors.orange.withOpacity(0.5), blurRadius: 40),
              ] : [],
            ),
          ),
        );
      }),
    );
  }
}

class AimPainter extends CustomPainter {
  final double angle;
  final double bubbleRadius;
  final GameEngine engine;

  AimPainter(this.angle, this.bubbleRadius, this.engine);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(colors: [Colors.cyanAccent, Colors.cyanAccent.withOpacity(0)]).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Start at nose of the ship
    double curX = size.width / 2 + 45 * cos(angle);
    double curY = size.height - 55 + 45 * sin(angle);
    
    // Use the exact same speed as physics for perfect prediction
    double speed = 18.0; 
    double vx = speed * cos(angle);
    double vy = speed * sin(angle);

    // Default iterations 40. Apply multiplier.
    int iterations = (40 * engine.aimLengthMultiplier).toInt();

    for (int i = 0; i < iterations; i++) { 
      curX += vx;
      curY += vy;

      // Exact wall bounce logic from GameEngine
      if (curX - bubbleRadius <= 0 || curX + bubbleRadius >= size.width) {
        vx = -vx;
        curX = curX.clamp(bubbleRadius, size.width - bubbleRadius);
      }
      
      // Only draw a dot every 3 iterations to keep it dotted
      if (i % 3 == 0) {
        if (engine.level <= 25 || i < (15 * engine.aimLengthMultiplier)) { // In hard levels, only show short aim line scaled
          canvas.drawCircle(Offset(curX, curY), 2, paint);
        }
      }

      bool hit = false;
      for (var b in engine.grid) {
        if (b != null) {
          final pos = engine.getBubblePosition(b.row, b.col, size.width);
          if (sqrt(pow(curX - pos.dx, 2) + pow(curY - pos.dy, 2)) < GameEngine.bubbleDiameter * 0.85) {
            hit = true; break;
          }
        }
      }
      if (hit || curY <= GameEngine.gridTopOffset + bubbleRadius) break;
    }
  }

  @override
  bool shouldRepaint(covariant AimPainter oldDelegate) => oldDelegate.angle != angle;
}

class ComboTextEffect {
  final String text;
  double opacity = 1.0;
  double scale = 0.5;
  int life = 60;
  bool isFinished = false;
  ComboTextEffect({required this.text});
  void update() {
    life--;
    if (life <= 0) isFinished = true;
    if (life < 20) opacity = life / 20;
    scale = min(1.5, scale + 0.05);
  }
}

class ParticleEffect {
  double x, y, vx, vy, size, opacity = 1.0;
  int life = 40;
  bool isFinished = false;
  final Color color;
  final bool isExplosion;

  ParticleEffect({required this.x, required this.y, Color? color, this.isExplosion = false})
      : vx = (Random().nextDouble() - 0.5) * (isExplosion ? 25 : 12),
        vy = (Random().nextDouble() - 0.5) * (isExplosion ? 25 : 12),
        size = Random().nextDouble() * (isExplosion ? 8 : 4) + 2,
        color = color ?? (Random().nextBool() ? AppColors.neonBlue : AppColors.neonPurple);

  void update() {
    life--;
    if (life <= 0) isFinished = true;
    x += vx; 
    y += vy; 
    vy += isExplosion ? 0.5 : 0.3; 
    opacity = (life / 40.0).clamp(0.0, 1.0);
  }

  Widget build() {
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: 0.5 + opacity * 1.5,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            color: color, 
            shape: BoxShape.circle, 
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: isExplosion ? 10 : 4, spreadRadius: isExplosion ? 2 : 0)
            ]
          ),
        ),
      ),
    );
  }
}
