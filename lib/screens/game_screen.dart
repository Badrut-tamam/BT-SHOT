import 'package:flutter/material.dart';
import 'dart:math';
import '../components/score_header.dart';
import '../components/bubble_grid.dart';
import '../components/shooter_ui.dart';
import '../services/game_engine.dart';
import 'pause_menu.dart';
import 'game_over_screen.dart';

enum GameState { playing, paused, gameOver }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late GameEngine _engine;
  GameState _gameState = GameState.playing;
  late AnimationController _controller;
  double _aimAngle = -pi / 2; // Default aim: straight up

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
        _engine.update(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
          _triggerGameOver,
        );
        
        // Check win/lose condition
        if (_engine.remainingBubbles <= 0 && _engine.activeBubble == null) {
          _triggerGameOver();
        }
      });
    }
  }

  void _togglePause() {
    setState(() {
      if (_gameState == GameState.playing) {
        _gameState = GameState.paused;
      } else if (_gameState == GameState.paused) {
        _gameState = GameState.playing;
      }
    });
  }

  void _triggerGameOver() {
    setState(() {
      _gameState = GameState.gameOver;
    });
  }

  void _restartGame() {
    setState(() {
      _engine.restart();
      _gameState = GameState.playing;
    });
  }

  void _exitToMenu() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _handlePointerUpdate(PointerEvent event) {
    if (_gameState != GameState.playing) return;
    
    // Calculate angle from center bottom
    double dx = event.position.dx - MediaQuery.of(context).size.width / 2;
    double dy = event.position.dy - (MediaQuery.of(context).size.height - 100);
    
    setState(() {
      _aimAngle = atan2(dy, dx);
      // Clamp angle to avoid shooting downwards
      if (_aimAngle > 0) {
        _aimAngle = dx > 0 ? 0 : pi;
      }
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
          // Background/Game Area Listener
          Listener(
            onPointerMove: _handlePointerUpdate,
            onPointerDown: _handlePointerUpdate,
            onPointerUp: _handlePointerUp,
            child: Container(
              color: Colors.transparent, // Capture all pointer events
              child: Column(
                children: [
                  ScoreHeader(
                    score: _engine.score,
                    level: _engine.level,
                    bubbles: _engine.remainingBubbles,
                    onBack: _togglePause,
                  ),
                  BubbleGrid(
                    engine: _engine,
                    screenWidth: size.width,
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
          
          // Overlays
          if (_gameState == GameState.paused)
            PauseMenu(
              onResume: _togglePause,
              onRestart: _restartGame,
              onExit: _exitToMenu,
            ),
            
          if (_gameState == GameState.gameOver)
            GameOverScreen(
              score: _engine.score,
              onRetry: _restartGame,
              onExit: _exitToMenu,
            ),
        ],
      ),
    );
  }
}
