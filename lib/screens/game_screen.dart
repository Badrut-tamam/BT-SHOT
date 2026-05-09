import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
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
  double _aimAngle = -pi / 2;
  late PowerUpService _powerUpService;
  int _initialBubbleCount = 0;
  bool _showLaserEffect = false;
  
  // Effects
  final List<ComboTextEffect> _comboEffects = [];
  final List<ParticleEffect> _particles = [];
  double _shakeIntensity = 0.0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _engine = GameEngine(targetLevel: widget.initialLevel);
    _powerUpService = PowerUpService();
    _initialBubbleCount = _engine.getFilledBubbleCount();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_gameLoop);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _gameLoop() {
    if (_gameState == GameState.playing) {
      setState(() {
        int oldScore = _engine.score;
        int oldCombo = _engine.rewardService.comboCount;
        
        _engine.update(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
          _triggerGameOver,
        );

        // Update Laser Progress
        _powerUpService.updateProgress(_engine.getFilledBubbleCount(), _initialBubbleCount);
        
        // Check for Win
        if (_engine.checkWin()) {
          _triggerVictory();
        }
        
        // Check for Lose
        if (_engine.checkLose()) {
          _triggerGameOver();
        }
        
        // Show combo effect if combo increased
        if (_engine.rewardService.comboCount > oldCombo && _engine.rewardService.comboCount >= 2) {
          _addComboEffect(_engine.rewardService.getComboText());
          _shakeIntensity = 10.0; // Shake on combo
        }
        
        // Add particles if score increased
        if (_engine.score > oldScore) {
          _addParticles(MediaQuery.of(context).size.width / 2, 200);
          _shakeIntensity = 5.0; // Slight shake on pop
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
    if (!_powerUpService.isLaserReady) return;
    
    setState(() {
      _showLaserEffect = true;
      _shakeIntensity = 25.0; // Big shake for laser
    });
    
    _powerUpService.activateLaser();
    _engine.fireLaser(MediaQuery.of(context).size.width);
    
    Future.delayed(const Duration(milliseconds: 800), () {
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

  void _addParticles(double x, double y) {
    for (int i = 0; i < 20; i++) {
      _particles.add(ParticleEffect(x: x, y: y));
    }
  }

  void _togglePause() {
    setState(() {
      if (_gameState == GameState.playing) {
        _gameState = GameState.paused;
      } else {
        _gameState = GameState.playing;
      }
    });
  }

  void _triggerGameOver() {
    if (_gameState == GameState.gameOver || _gameState == GameState.victory) return;
    
    int earnedCoins = _engine.rewardService.calculateCoins(_engine.score);
    SaveService.addCoins(earnedCoins);
    
    setState(() {
      _gameState = GameState.gameOver;
      _shakeIntensity = 15.0;
    });
    AudioService.playLose();
  }

  void _triggerVictory() {
    if (_gameState == GameState.victory) return;
    
    LevelService.unlockNextLevel(_engine.level);
    int earnedCoins = _engine.rewardService.calculateCoins(_engine.score) + 50;
    SaveService.addCoins(earnedCoins);
    
    setState(() {
      _gameState = GameState.victory;
      _shakeIntensity = 10.0;
    });
    AudioService.playWin();
  }

  void _nextLevel() {
    setState(() {
      _engine.startLevel(_engine.level + 1);
      _gameState = GameState.playing;
      _comboEffects.clear();
      _particles.clear();
      _initialBubbleCount = _engine.getFilledBubbleCount();
      _powerUpService.reset();
    });
  }

  void _restartGame() {
    setState(() {
      _engine.restart();
      _gameState = GameState.playing;
      _comboEffects.clear();
      _particles.clear();
      _initialBubbleCount = _engine.getFilledBubbleCount();
      _powerUpService.reset();
    });
  }

  void _exitToMenu() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _handlePointerUpdate(PointerEvent event) {
    if (_gameState != GameState.playing) return;
    double dx = event.position.dx - MediaQuery.of(context).size.width / 2;
    double dy = event.position.dy - (MediaQuery.of(context).size.height - 140);
    setState(() {
      _aimAngle = atan2(dy, dx);
      if (_aimAngle > 0) _aimAngle = dx > 0 ? 0 : pi;
    });
  }

  void _handlePointerUp(PointerEvent event) {
    if (_gameState != GameState.playing) return;
    _engine.shoot(_aimAngle, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    // Calculate Shake Offset
    Offset shakeOffset = Offset(
      (_random.nextDouble() - 0.5) * _shakeIntensity,
      (_random.nextDouble() - 0.5) * _shakeIntensity,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_gameState == GameState.playing) _togglePause();
        else _exitToMenu();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Transform.translate(
          offset: shakeOffset,
          child: Stack(
            children: [
              // Premium Background
              const RepaintBoundary(child: SpaceBackground()),
              
              // Game Layer
              Listener(
                onPointerMove: _handlePointerUpdate,
                onPointerDown: _handlePointerUpdate,
                onPointerUp: _handlePointerUp,
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      ScoreHeader(
                        score: _engine.score,
                        level: _engine.level,
                        bubbles: _engine.remainingBubbles,
                        laserProgress: _powerUpService.laserProgress,
                        onBack: _togglePause,
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            if (_gameState == GameState.playing && _engine.activeBubble == null)
                              _buildAimPrediction(size),
                            
                            RepaintBoundary(
                              child: BubbleGrid(engine: _engine, screenWidth: size.width),
                            ),
                            
                            // Particles
                            ..._particles.map((p) => Positioned(
                              left: p.x,
                              top: p.y,
                              child: p.build(),
                            )),
                          ],
                        ),
                      ),
                      ShooterUI(
                        shooterColor: _engine.shooterColor,
                        nextColor: _engine.nextColor,
                        angle: _aimAngle,
                        laserReady: _powerUpService.isLaserReady,
                        laserProgress: _powerUpService.laserProgress,
                        onLaserTap: _activateLaser,
                      ),
                    ],
                  ),
                ),
              ),
    
              // Laser Effect
              if (_showLaserEffect)
                FadeIn(
                  duration: const Duration(milliseconds: 100),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: size.height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.neonBlue.withOpacity(0.8),
                            Colors.white,
                            AppColors.neonBlue.withOpacity(0.8),
                            Colors.transparent,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(color: AppColors.neonBlue.withOpacity(0.8), blurRadius: 40, spreadRadius: 20)
                        ]
                      ),
                    ),
                  ),
                ),
              
              // Effects Layer
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
    
              // Overlays
              if (_gameState == GameState.paused)
                FadeIn(child: PauseMenu(onResume: _togglePause, onRestart: _restartGame, onExit: _exitToMenu)),
              if (_gameState == GameState.gameOver)
                FadeIn(child: GameOverScreen(score: _engine.score, onRetry: _restartGame, onExit: _exitToMenu)),
              if (_gameState == GameState.victory)
                VictoryOverlay(
                  level: _engine.level,
                  score: _engine.score,
                  onNextLevel: _nextLevel,
                  onExit: _exitToMenu,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAimPrediction(Size size) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(size.width, size.height - 140),
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

  const VictoryOverlay({
    super.key,
    required this.level,
    required this.score,
    required this.onNextLevel,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
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
                      Text('MISSION', style: GoogleFonts.outfit(color: AppColors.neonBlue, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 10)),
                      Text('SUCCESS', style: GoogleFonts.outfit(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ZoomIn(
                  delay: const Duration(milliseconds: 300),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.neonPurple.withOpacity(0.5), blurRadius: 40)]),
                      ),
                      const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 80),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Container(
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
                const SizedBox(height: 60),
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

    double curX = size.width / 2;
    double curY = size.height - 100;
    double vx = cos(angle);
    double vy = sin(angle);

    for (int i = 0; i < 15; i++) {
      double nextX = curX + vx * 40;
      double nextY = curY + vy * 40;

      if (nextX <= bubbleRadius || nextX >= size.width - bubbleRadius) vx = -vx;
      
      canvas.drawCircle(Offset(nextX, nextY), 2, paint);
      curX = nextX;
      curY = nextY;

      bool hit = false;
      for (var b in engine.grid) {
        if (b != null) {
          final pos = engine.getBubblePosition(b.row, b.col, size.width);
          if (sqrt(pow(curX - pos.dx, 2) + pow(curY - pos.dy, 2)) < GameEngine.bubbleDiameter * 0.8) {
            hit = true; break;
          }
        }
      }
      if (hit || curY <= bubbleRadius) break;
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

  ParticleEffect({required this.x, required this.y})
      : vx = (Random().nextDouble() - 0.5) * 12,
        vy = (Random().nextDouble() - 0.5) * 12,
        size = Random().nextDouble() * 4 + 2,
        color = Random().nextBool() ? AppColors.neonBlue : AppColors.neonPurple;

  void update() {
    life--;
    if (life <= 0) isFinished = true;
    x += vx; y += vy; vy += 0.3; opacity = life / 40;
  }

  Widget build() {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)]),
      ),
    );
  }
}
