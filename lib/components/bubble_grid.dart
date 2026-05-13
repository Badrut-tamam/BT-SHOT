import 'package:flutter/material.dart';
import '../services/game_engine.dart';
import '../models/bubble_model.dart';
import 'alien_bubble.dart';

class BubbleGrid extends StatelessWidget {
  final GameEngine engine;
  final double screenWidth;

  const BubbleGrid({
    super.key,
    required this.engine,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Render static bubbles in grid
        ...engine.grid.where((b) => b != null).map((bubble) {
          Offset pos = engine.getBubblePosition(bubble!.row, bubble.col, screenWidth);
          return Positioned(
            left: pos.dx - GameEngine.bubbleRadius,
            top: pos.dy - GameEngine.bubbleRadius,
            child: AlienBubble(
              color: bubble.color,
              size: GameEngine.bubbleDiameter,
              type: bubble.type,
            ),
          );
        }),
        
        // Render active shooting bubble
        if (engine.activeBubble != null)
          Positioned(
            left: engine.activeX - GameEngine.bubbleRadius,
            top: engine.activeY - GameEngine.bubbleRadius,
            child: AlienBubble(
              color: engine.activeBubble!.color,
              size: GameEngine.bubbleDiameter,
              type: engine.activeBubble!.type,
            ),
          ),
      ],
    );
  }
}
