import 'package:flutter/material.dart';
import '../services/game_engine.dart';
import '../models/bubble_model.dart';

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
    return Expanded(
      child: Stack(
        children: [
          // Render static bubbles in grid
          ...engine.grid.where((b) => b != null).map((bubble) {
            Offset pos = engine.getBubblePosition(bubble!.row, bubble.col, screenWidth);
            return Positioned(
              left: pos.dx - GameEngine.bubbleRadius,
              top: pos.dy - GameEngine.bubbleRadius,
              child: _buildBubble(bubble.color),
            );
          }),
          
          // Render active shooting bubble
          if (engine.activeBubble != null)
            Positioned(
              left: engine.activeX - GameEngine.bubbleRadius,
              top: engine.activeY - GameEngine.bubbleRadius,
              child: _buildBubble(engine.activeBubble!.color),
            ),
        ],
      ),
    );
  }

  Widget _buildBubble(Color color) {
    return Container(
      width: GameEngine.bubbleDiameter,
      height: GameEngine.bubbleDiameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.transparent,
          ],
          center: const Alignment(-0.3, -0.3),
        ),
      ),
    );
  }
}
