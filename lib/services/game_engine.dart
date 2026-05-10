import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bubble_model.dart';
import '../data/level_data.dart';
import 'reward_service.dart';
import 'audio_service.dart';
import 'save_service.dart';

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
  int coins = 0;
  int highScore = 0;
  int remainingBubbles = 0;
  int maxBubbles = 0;
  int shotsFired = 0;
  int bubblesPoppedThisMatch = 0;
  
  // Services
  final RewardService rewardService = RewardService();
  
  // Current shooting state
  BubbleModel? activeBubble;
  double activeX = 0;
  double activeY = 0;
  double velocityX = 0;
  double velocityY = 0;
  
  Color nextColor = Colors.red;
  Color shooterColor = Colors.blue;
  
  late List<Color> levelColors;
  final List<Color> allColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  final Random _random = Random();
  
  // ─── Ship Stats (loaded from Hangar) ─────────────────────────
  double _bulletSpeed = 18.0;
  int _laserWidth = 1;       // extra columns cleared each side

  GameEngine({int? targetLevel}) {
    _loadData();
    _loadShipStats();
    if (targetLevel != null) level = targetLevel;
    startLevel(level);
  }

  void _loadShipStats() {
    int shipId = SaveService.getSelectedShip();
    int speedUpgrade  = SaveService.getShipUpgradeLevel(shipId, 0); // Fire Rate
    int laserUpgrade  = SaveService.getShipUpgradeLevel(shipId, 2); // Laser Damage

    // Ship base speed (from kShips constant – replicate here to avoid UI dependency)
    const List<double> baseSpeeds = [18.0, 20.0, 20.0, 18.0, 22.0]; // per ship id
    double base = shipId < baseSpeeds.length ? baseSpeeds[shipId] : 18.0;
    // Each fire-rate upgrade adds 1.5 speed
    _bulletSpeed = base + ((speedUpgrade - 1) * 1.5);

    // Each laser upgrade clears 1 extra column each side
    _laserWidth = laserUpgrade; // 1 = default, 2..5 = wider
  }

  void _loadData() {
    highScore = SaveService.getHighScore();
    coins = SaveService.getCoins();
    level = SaveService.getLastLevel();
  }

  double gridDropTimer = 0.0;
  double gridDropInterval = 10.0; // Seconds between drops

  void startLevel(int levelNum) {
    level = levelNum;
    SaveService.setLastLevel(level);
    
    LevelConfig config = LevelData.getLevel(level);
    maxBubbles = config.shotLimit;
    remainingBubbles = maxBubbles;
    score = 0;
    
    // Drop interval inversely proportional to speed
    gridDropInterval = (15.0 / config.dropSpeed).clamp(5.0, 30.0);
    gridDropTimer = gridDropInterval;
    
    // Select subset of colors for the level
    levelColors = allColors.sublist(0, min(config.colorCount, allColors.length));
    
    _initGrid(config);
    _prepareNextBubble();
  }

  void _dropGrid() {
    // Shift grid down
    for (int r = maxRows - 1; r > 0; r--) {
      for (int c = 0; c < colsEven; c++) {
        int target = _getIndex(r, c);
        int source = _getIndex(r - 1, c);
        if (grid[source] != null) {
          grid[target] = BubbleModel(
            row: r,
            col: c,
            color: grid[source]!.color,
          );
        } else {
          grid[target] = null;
        }
      }
    }
    
    // New top row
    for (int c = 0; c < colsEven; c++) {
      grid[_getIndex(0, c)] = BubbleModel(
        row: 0, col: c,
        color: levelColors[_random.nextInt(levelColors.length)],
      );
    }
    // Removed vibration for normal grid drops to improve performance and feel
  }

  void _initGrid(LevelConfig config) {
    grid = List.filled(maxRows * colsEven, null);
    for (int r = 0; r < config.rowsToFill; r++) {
      int cols = r % 2 == 0 ? colsEven : colsOdd;
      for (int c = 0; c < cols; c++) {
        int index = _getIndex(r, c);
        grid[index] = BubbleModel(
          row: r,
          col: c,
          color: levelColors[_random.nextInt(levelColors.length)],
        );
      }
    }
  }

  int _getIndex(int r, int c) {
    return r * colsEven + c;
  }

  void _prepareNextBubble() {
    shooterColor = nextColor;
    
    // SMART COLOR SYSTEM
    Set<Color> activeColors = {};
    for (var bubble in grid) {
      if (bubble != null) {
        activeColors.add(bubble.color);
      }
    }
    
    if (activeColors.isNotEmpty) {
      List<Color> availableColors = activeColors.toList();
      nextColor = availableColors[_random.nextInt(availableColors.length)];
    } else {
      nextColor = levelColors[_random.nextInt(levelColors.length)];
    }
  }

  // Calculate pixel position from grid row/col
  Offset getBubblePosition(int r, int c, double screenWidth) {
    double horizontalSpacing = bubbleDiameter;
    double verticalSpacing = bubbleDiameter * 0.866; 
    
    double xOffset = (r % 2 == 0) ? 0 : bubbleRadius;
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
    shotsFired++;
    AudioService.playShoot();
    
    activeX = screenWidth / 2;
    activeY = screenHeight - 55;
    
    velocityX = _bulletSpeed * cos(angle);
    velocityY = _bulletSpeed * sin(angle);
    
    activeBubble = BubbleModel(
      row: -1, col: -1,
      color: shooterColor,
      x: activeX,
      y: activeY,
    );
  }

  bool checkWin() {
    return grid.every((bubble) => bubble == null);
  }

  bool checkLose() {
    // Check if any bubble reached the bottom rows
    for (int r = maxRows - 2; r < maxRows; r++) {
      int cols = r % 2 == 0 ? colsEven : colsOdd;
      for (int c = 0; c < cols; c++) {
        if (grid[_getIndex(r, c)] != null) return true;
      }
    }
    // Check if out of bubbles and nothing is moving
    if (remainingBubbles <= 0 && activeBubble == null) {
      return !checkWin();
    }
    return false;
  }

  void update(double screenWidth, double screenHeight, double dt, VoidCallback onGameOver) {
    // Handle grid dropping
    gridDropTimer -= dt;
    if (gridDropTimer <= 0) {
      _dropGrid();
      gridDropTimer = gridDropInterval;
    }

    if (activeBubble == null) return;

    activeX += velocityX;
    activeY += velocityY;
    
    // Wall bounce with padding
    if (activeX - bubbleRadius <= 0 || activeX + bubbleRadius >= screenWidth) {
      velocityX = -velocityX;
      activeX = activeX.clamp(bubbleRadius, screenWidth - bubbleRadius);
    }
    
    // Top boundary
    if (activeY - bubbleRadius <= 0) {
      _snapToGrid(activeX, bubbleRadius, screenWidth);
      return;
    }

    // Grid collision
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] != null) {
        Offset pos = getBubblePosition(grid[i]!.row, grid[i]!.col, screenWidth);
        double dist = sqrt(pow(activeX - pos.dx, 2) + pow(activeY - pos.dy, 2));
        
        // Use a slightly smaller threshold for smoother entry between bubbles
        if (dist < bubbleDiameter * 0.85) {
          _snapToGrid(activeX, activeY, screenWidth);
          return;
        }
      }
    }
    
    // Prevent out of bounds
    if (activeY > screenHeight) {
      activeBubble = null;
      _prepareNextBubble();
    }
  }

  void _snapToGrid(double x, double y, double screenWidth) {
    double verticalSpacing = bubbleDiameter * 0.866;
    int r = (y / verticalSpacing).round().clamp(0, maxRows - 1);
    
    double xOffset = (r % 2 == 0) ? 0 : bubbleRadius;
    double gridWidth = colsEven * bubbleDiameter;
    double startX = (screenWidth - gridWidth) / 2 + bubbleRadius;
    
    int c = ((x - startX - xOffset) / bubbleDiameter).round();
    int maxCols = (r % 2 == 0) ? colsEven : colsOdd;
    c = c.clamp(0, maxCols - 1);

    int index = _getIndex(r, c);
    
    // If slot is occupied, find nearest empty slot
    if (grid[index] != null) {
       // Search spiral or simple adjacent
       // For now, just find a free neighbor if possible, or force overwrite if absolutely necessary (shouldn't happen with good thresholds)
    }

    grid[index] = BubbleModel(
      row: r,
      col: c,
      color: activeBubble!.color,
    );
    
    activeBubble = null;
    _checkMatches(r, c);
    _prepareNextBubble();
  }

  void _checkMatches(int r, int c) {
    List<int> matches = [];
    Set<int> visited = {};
    int rootIdx = _getIndex(r, c);
    if (grid[rootIdx] == null) return;
    Color targetColor = grid[rootIdx]!.color;
    
    void find(int currR, int currC) {
      if (currR < 0 || currR >= maxRows) return;
      int currMaxCols = (currR % 2 == 0) ? colsEven : colsOdd;
      if (currC < 0 || currC >= currMaxCols) return;

      int idx = _getIndex(currR, currC);
      if (visited.contains(idx)) return;
      visited.add(idx);
      
      if (grid[idx] == null || grid[idx]!.color != targetColor) return;
      
      matches.add(idx);
      
      List<Offset> neighbors = _getNeighbors(currR, currC);
      for (var n in neighbors) {
        find(n.dx.toInt(), n.dy.toInt());
      }
    }

    find(r, c);

    if (matches.length >= 3) {
      AudioService.playExplosion();
      rewardService.incrementCombo();
      int multiplier = rewardService.getScoreMultiplier();
      
      for (int idx in matches) {
        grid[idx] = null;
        score += 10 * multiplier;
      }
      bubblesPoppedThisMatch += matches.length;
      
      if (multiplier >= 3) {
        AudioService.vibrate(50); // Lighter vibration for big combos
      }
      
      _dropFloating();
    } else {
      rewardService.resetCombo();
    }
    
    if (score > highScore) {
      highScore = score;
      SaveService.setHighScore(highScore);
    }
  }

  List<Offset> _getNeighbors(int r, int c) {
    List<Offset> results = [];
    // Same row
    results.add(Offset(r.toDouble(), (c - 1).toDouble()));
    results.add(Offset(r.toDouble(), (c + 1).toDouble()));

    if (r % 2 == 0) {
      // Even row (offset 0)
      results.add(Offset((r - 1).toDouble(), (c - 1).toDouble()));
      results.add(Offset((r - 1).toDouble(), c.toDouble()));
      results.add(Offset((r + 1).toDouble(), (c - 1).toDouble()));
      results.add(Offset((r + 1).toDouble(), c.toDouble()));
    } else {
      // Odd row (offset radius)
      results.add(Offset((r - 1).toDouble(), c.toDouble()));
      results.add(Offset((r - 1).toDouble(), (c + 1).toDouble()));
      results.add(Offset((r + 1).toDouble(), c.toDouble()));
      results.add(Offset((r + 1).toDouble(), (c + 1).toDouble()));
    }
    return results;
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

    for (int c = 0; c < colsEven; c++) {
      if (grid[_getIndex(0, c)] != null) {
        traverse(0, c);
      }
    }

    int dropped = 0;
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] != null && !connected.contains(i)) {
        grid[i] = null;
        score += 5; 
        dropped++;
      }
    }
    bubblesPoppedThisMatch += dropped;
  }

  void fireLaser(double screenWidth) {
    AudioService.vibrate(200);
    for (int r = 0; r < maxRows; r++) {
      int cols = r % 2 == 0 ? colsEven : colsOdd;
      int mid = cols ~/ 2;
      // Always clear center column
      _clearGridItem(r, mid);
      // Expand based on laser upgrade level (_laserWidth)
      for (int offset = 1; offset <= _laserWidth; offset++) {
        if (mid + offset < cols) _clearGridItem(r, mid + offset);
        if (mid - offset >= 0)  _clearGridItem(r, mid - offset);
      }
    }
    _dropFloating();
  }

  void _clearGridItem(int r, int c) {
    int idx = _getIndex(r, c);
    if (grid[idx] != null) {
      grid[idx] = null;
      score += 10;
    }
  }

  int getFilledBubbleCount() {
    return grid.where((b) => b != null).length;
  }

  void restart() {
    startLevel(level);
  }
}
