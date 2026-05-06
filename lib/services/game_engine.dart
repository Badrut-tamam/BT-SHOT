import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bubble_model.dart';

class GameEngine {
  static const int maxRows = 12;
  static const int colsEven = 8;
  static const int colsOdd = 7;
  static const double bubbleRadius = 20.0;
  static const double bubbleDiameter = bubbleRadius * 2;
  
  // Game State
  List<BubbleModel?> grid = List.filled(maxRows * colsEven, null);
  int score = 0;
  int level = 1;
  int remainingBubbles = 40;
  
  // Current shooting state
  BubbleModel? activeBubble;
  double activeX = 0;
  double activeY = 0;
  double velocityX = 0;
  double velocityY = 0;
  
  Color nextColor = Colors.red;
  Color shooterColor = Colors.blue;
  
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  final Random _random = Random();

  GameEngine() {
    _initGrid();
    _prepareNextBubble();
  }

  void _initGrid() {
    // Fill top 5 rows with random bubbles
    for (int r = 0; r < 5; r++) {
      int cols = r % 2 == 0 ? colsEven : colsOdd;
      for (int c = 0; c < cols; c++) {
        int index = _getIndex(r, c);
        grid[index] = BubbleModel(
          row: r,
          col: c,
          color: colors[_random.nextInt(colors.length)],
        );
      }
    }
  }

  int _getIndex(int r, int c) {
    return r * colsEven + c;
  }

  void _prepareNextBubble() {
    shooterColor = nextColor;
    nextColor = colors[_random.nextInt(colors.length)];
  }

  // Calculate pixel position from grid row/col
  Offset getBubblePosition(int r, int c, double screenWidth) {
    double horizontalSpacing = bubbleDiameter;
    double verticalSpacing = bubbleDiameter * 0.866; // sqrt(3)/2 for hexagonal
    
    double xOffset = (r % 2 == 0) ? 0 : bubbleRadius;
    // Center the grid on screen
    double gridWidth = colsEven * bubbleDiameter;
    double startX = (screenWidth - gridWidth) / 2 + bubbleRadius;
    
    return Offset(
      startX + xOffset + (c * horizontalSpacing),
      bubbleRadius + (r * verticalSpacing),
    );
  }

  void shoot(double angle, double screenWidth, double screenHeight) {
    if (activeBubble != null || remainingBubbles <= 0) return;
    
    remainingBubbles--;
    
    // Initial position of shot (center bottom)
    activeX = screenWidth / 2;
    activeY = screenHeight - 100; // Above shooter UI
    
    double speed = 15.0;
    velocityX = speed * cos(angle);
    velocityY = speed * sin(angle);
    
    activeBubble = BubbleModel(
      row: -1, col: -1, // Not in grid yet
      color: shooterColor,
      x: activeX,
      y: activeY,
    );
  }

  // Main update loop
  void update(double screenWidth, double screenHeight, VoidCallback onGameOver) {
    if (activeBubble == null) return;

    // Move active bubble
    activeX += velocityX;
    activeY += velocityY;
    
    // Wall bounce
    if (activeX - bubbleRadius <= 0 || activeX + bubbleRadius >= screenWidth) {
      velocityX = -velocityX;
      activeX = activeX.clamp(bubbleRadius, screenWidth - bubbleRadius);
    }
    
    // Check ceiling collision
    if (activeY - bubbleRadius <= 0) {
      _snapToGrid(activeX, 0, screenWidth);
      return;
    }

    // Check collision with other bubbles
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] != null) {
        Offset pos = getBubblePosition(grid[i]!.row, grid[i]!.col, screenWidth);
        double dist = sqrt(pow(activeX - pos.dx, 2) + pow(activeY - pos.dy, 2));
        
        if (dist < bubbleDiameter * 0.9) {
          _snapToGrid(activeX, activeY, screenWidth);
          return;
        }
      }
    }

    // Out of bounds (shouldn't happen with bounce, but just in case)
    if (activeY < -bubbleRadius || activeY > screenHeight) {
      activeBubble = null;
      _prepareNextBubble();
    }
  }

  void _snapToGrid(double x, double y, double screenWidth) {
    // Find closest row/col
    double verticalSpacing = bubbleDiameter * 0.866;
    int r = (y / verticalSpacing).round().clamp(0, maxRows - 1);
    
    double xOffset = (r % 2 == 0) ? 0 : bubbleRadius;
    double gridWidth = colsEven * bubbleDiameter;
    double startX = (screenWidth - gridWidth) / 2 + bubbleRadius;
    
    int c = ((x - startX - xOffset) / bubbleDiameter).round();
    int maxCols = (r % 2 == 0) ? colsEven : colsOdd;
    c = c.clamp(0, maxCols - 1);

    int index = _getIndex(r, c);
    
    // If slot is occupied, try adjacent slots
    if (grid[index] != null) {
      // Very basic fallback: just find first empty near it
      // In a real game, you'd do a more precise spatial check
    }

    grid[index] = BubbleModel(
      row: r,
      col: c,
      color: activeBubble!.color,
    );
    
    activeBubble = null;
    
    // Check for matches
    _checkMatches(r, c);
    _prepareNextBubble();
  }

  void _checkMatches(int r, int c) {
    List<int> matches = [];
    Set<int> visited = {};
    Color targetColor = grid[_getIndex(r, c)]!.color;
    
    void find(int currR, int currC) {
      int idx = _getIndex(currR, currC);
      if (visited.contains(idx)) return;
      visited.add(idx);
      
      if (grid[idx] == null || grid[idx]!.color != targetColor) return;
      
      matches.add(idx);
      
      // Check neighbors (hexagonal)
      List<Offset> neighbors = _getNeighbors(currR, currC);
      for (var n in neighbors) {
        if (n.dx >= 0 && n.dx < maxRows) {
          int nMaxCols = (n.dx.toInt() % 2 == 0) ? colsEven : colsOdd;
          if (n.dy >= 0 && n.dy < nMaxCols) {
            find(n.dx.toInt(), n.dy.toInt());
          }
        }
      }
    }

    find(r, c);

    if (matches.length >= 3) {
      for (int idx in matches) {
        grid[idx] = null;
        score += 10;
      }
      // Also drop floating bubbles (simplified: anything not connected to row 0)
      _dropFloating();
    }
  }

  List<Offset> _getNeighbors(int r, int c) {
    if (r % 2 == 0) {
      return [
        Offset(r.toDouble(), (c - 1).toDouble()), Offset(r.toDouble(), (c + 1).toDouble()), // Left, Right
        Offset((r - 1).toDouble(), (c - 1).toDouble()), Offset((r - 1).toDouble(), c.toDouble()), // Top Left, Top Right
        Offset((r + 1).toDouble(), (c - 1).toDouble()), Offset((r + 1).toDouble(), c.toDouble()), // Bottom Left, Bottom Right
      ];
    } else {
      return [
        Offset(r.toDouble(), (c - 1).toDouble()), Offset(r.toDouble(), (c + 1).toDouble()),
        Offset((r - 1).toDouble(), c.toDouble()), Offset((r - 1).toDouble(), (c + 1).toDouble()),
        Offset((r + 1).toDouble(), c.toDouble()), Offset((r + 1).toDouble(), (c + 1).toDouble()),
      ];
    }
  }

  void _dropFloating() {
    Set<int> connected = {};
    
    void traverse(int r, int c) {
      int idx = _getIndex(r, c);
      if (connected.contains(idx) || grid[idx] == null) return;
      connected.add(idx);
      
      List<Offset> neighbors = _getNeighbors(r, c);
      for (var n in neighbors) {
        if (n.dx >= 0 && n.dx < maxRows) {
          int nMaxCols = (n.dx.toInt() % 2 == 0) ? colsEven : colsOdd;
          if (n.dy >= 0 && n.dy < nMaxCols) {
            traverse(n.dx.toInt(), n.dy.toInt());
          }
        }
      }
    }

    // Start from all bubbles in row 0
    for (int c = 0; c < colsEven; c++) {
      if (grid[_getIndex(0, c)] != null) {
        traverse(0, c);
      }
    }

    // Any bubble not in 'connected' set should be dropped
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] != null && !connected.contains(i)) {
        grid[i] = null;
        score += 5; // Bonus for drops
      }
    }
  }

  void restart() {
    grid = List.filled(maxRows * colsEven, null);
    score = 0;
    remainingBubbles = 40;
    _initGrid();
    _prepareNextBubble();
  }
}
