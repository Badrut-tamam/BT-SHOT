import 'package:flutter/material.dart';
import 'dart:math';
import '../components/score_header.dart';
import '../components/bubble_grid.dart';
import '../components/shooter_ui.dart';
import '../services/game_engine.dart';
import '../services/save_service.dart';
import '../services/audio_service.dart';
import 'pause_menu.dart';
import 'game_over_screen.dart';

enum GameState { playing, paused, gameOver }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

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
    _engine = GameEngine();
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
        
        // Show combo effect if combo increased
        if (_engine.rewardService.comboCount > oldCombo && _engine.rewardService.comboCount >= 2) {
          _addComboEffect(_engine.rewardService.getComboText());
        }
        
        // Add particles if score increased (bubbles popped)
        if (_engine.score > oldScore) {
          // In a real implementation, we'd pass the exact coordinates of the popped bubbles
          // For now, we'll spawn some at the top area
          _addParticles(MediaQuery.of(context).size.width / 2, 200);
        }

        // Update effects
        _comboEffects.removeWhere((e) => e.isFinished);
        _particles.removeWhere((p) => p.isFinished);
        for (var e in _comboEffects) { e.update(); }
        for (var p in _particles) { p.update(); }

        if (_engine.remainingBubbles <= 0 && _engine.activeBubble == null) {
          _triggerGameOver();
        }
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
    if (_gameState == GameState.gameOver) return;
    
    // Save coins earned
    int earnedCoins = _engine.rewardService.calculateCoins(_engine.score);
    SaveService.addCoins(earnedCoins);
    
    setState(() {
      _gameState = GameState.gameOver;
    });
    AudioService.playLose();
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
                  BubbleGrid(engine: _engine, screenWidth: size.width),
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
        ],
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
