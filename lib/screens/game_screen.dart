import 'package:flutter/material.dart';
import '../components/score_header.dart';
import '../components/bubble_grid.dart';
import '../components/shooter_ui.dart';
import 'pause_menu.dart';
import 'game_over_screen.dart';

enum GameState { playing, paused, gameOver }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameState _gameState = GameState.playing;
  int _score = 0;

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
      _score = 0;
      _gameState = GameState.playing;
    });
  }

  void _exitToMenu() {
    Navigator.popUntil(context, ModalRoute.withName('/menu'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main Game View
          Column(
            children: [
              ScoreHeader(
                score: _score,
                onBack: _togglePause,
              ),
              const BubbleGrid(),
              // Dummy gesture detector to simulate score/game over
              GestureDetector(
                onTap: () {
                  if (_gameState == GameState.playing) {
                    setState(() {
                      _score += 10;
                      if (_score >= 50) {
                        _triggerGameOver();
                      }
                    });
                  }
                },
                child: const ShooterUI(),
              ),
            ],
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
              score: _score,
              onRetry: _restartGame,
              onExit: _exitToMenu,
            ),
        ],
      ),
    );
  }
}
