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
        }
        
        // Add particles if score increased
        if (_engine.score > oldScore) {
          _addParticles(MediaQuery.of(context).size.width / 2, 200);
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
    });
    
    _powerUpService.activateLaser();
    _engine.fireLaser(MediaQuery.of(context).size.width);
    
    // Screen shake or something could go here
    
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
    for (int i = 0; i < 15; i++) {
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
    });
    AudioService.playLose();
  }

  void _triggerVictory() {
    if (_gameState == GameState.victory) return;
    
    // Unlock next level
    LevelService.unlockNextLevel(_engine.level);
    
    int earnedCoins = _engine.rewardService.calculateCoins(_engine.score) + 50; // Bonus for victory
    SaveService.addCoins(earnedCoins);
    
    setState(() {
      _gameState = GameState.victory;
    });
    AudioService.playWin();
  }

  void _nextLevel() {
    setState(() {
      _engine.startLevel(_engine.level + 1);
      _gameState = GameState.playing;
      _comboEffects.clear();
      _particles.clear();
    });
  }

  void _restartGame() {
    setState(() {
      _engine.restart();
      _gameState = GameState.playing;
      _comboEffects.clear();
      _particles.clear();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Space Background
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
                    child: RepaintBoundary(
                      child: BubbleGrid(engine: _engine, screenWidth: size.width),
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
              duration: const Duration(milliseconds: 200),
              child: Center(
                child: Container(
                  width: 60,
                  height: size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.blueAccent.withOpacity(0.8),
                        Colors.cyanAccent,
                        Colors.blueAccent.withOpacity(0.8),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 30, spreadRadius: 10)
                    ]
                  ),
                ),
              ),
            ),
          
          // Effects Layer (Particles & Combo Text)
          IgnorePointer(
            child: Stack(
              children: [
                ..._particles.map((p) => Positioned(
                  left: p.x,
                  top: p.y,
                  child: Opacity(
                    opacity: p.opacity,
                    child: Container(
                      width: p.size,
                      height: p.size,
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.neonBlue.withOpacity(0.5), blurRadius: 4)
                        ]
                      ),
                    ),
                  ),
                )),
                ..._comboEffects.map((e) => Center(
                  child: Opacity(
                    opacity: e.opacity,
                    child: Transform.scale(
                      scale: e.scale,
                      child: Text(
                        e.text,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
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
            PauseMenu(onResume: _togglePause, onRestart: _restartGame, onExit: _exitToMenu),
          if (_gameState == GameState.gameOver)
            GameOverScreen(score: _engine.score, onRetry: _restartGame, onExit: _exitToMenu),
          if (_gameState == GameState.victory)
            VictoryOverlay(
              level: _engine.level,
              score: _engine.score,
              onNextLevel: _nextLevel,
              onExit: _exitToMenu,
            ),
        ],
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
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: AppColors.background.withOpacity(0.8),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInDown(
                  child: ShaderMask(
                    shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                    child: const Icon(Icons.stars_rounded, color: Colors.white, size: 100),
                  ),
                ),
                const SizedBox(height: 20),
                FadeIn(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'LEVEL COMPLETE!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'LEVEL $level PASSED',
                  style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 40),
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TOTAL SCORE', 
                          style: GoogleFonts.outfit(
                            color: Colors.grey[400], 
                            fontSize: 12, 
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          )
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$score',
                          style: GoogleFonts.outfit(
                            color: Colors.white, 
                            fontSize: 54, 
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(color: AppColors.neonBlue.withOpacity(0.5), blurRadius: 20)
                            ]
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                FadeInUp(
                  delay: const Duration(milliseconds: 900),
                  child: Column(
                    children: [
                      if (level < 10)
                        CustomButton(
                          text: 'NEXT LEVEL',
                          onPressed: onNextLevel,
                        ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'MAIN MENU',
                        isSecondary: true,
                        onPressed: onExit,
                      ),
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
  int life = 30;
  bool isFinished = false;

  ParticleEffect({required this.x, required this.y})
      : vx = (Random().nextDouble() - 0.5) * 10,
        vy = (Random().nextDouble() - 0.5) * 10,
        size = Random().nextDouble() * 5 + 2;

  void update() {
    life--;
    if (life <= 0) isFinished = true;
    x += vx;
    y += vy;
    vy += 0.2; // Gravity
    opacity = life / 30;
  }
}
