import 'package:flutter/material.dart';
import 'dart:math';
import '../components/score_header.dart';
import '../components/bubble_grid.dart';
import '../components/shooter_ui.dart';
import '../services/game_engine.dart';
import '../services/save_service.dart';
import '../services/audio_service.dart';
import '../components/custom_button.dart';
import '../services/level_service.dart';
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
  
  // Effects
  final List<ComboTextEffect> _comboEffects = [];
  final List<ParticleEffect> _particles = [];

  @override
  void initState() {
    super.initState();
    _engine = GameEngine(targetLevel: widget.initialLevel);
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
    double dy = event.position.dy - (MediaQuery.of(context).size.height - 100);
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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
                    coins: _engine.coins,
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
                  ),
                ],
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
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          shadows: [Shadow(color: Colors.blueAccent, blurRadius: 20)],
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
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, color: Colors.amber, size: 100),
              const SizedBox(height: 20),
              const Text(
                'LEVEL COMPLETE!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'LEVEL $level PASSED',
                style: const TextStyle(color: Colors.grey, fontSize: 18),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    const Text('LEVEL SCORE', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      '$score',
                      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              if (level < 10)
                CustomButton(
                  text: 'NEXT LEVEL',
                  onPressed: onNextLevel,
                  color: Colors.white,
                ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'EXIT TO MENU',
                onPressed: onExit,
                color: Colors.transparent,
              ),
            ],
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
