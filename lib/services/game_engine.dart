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
  static const double gridTopOffset = 150.0;

  // ─── Danger Zone (row 9 and below = warning, row 10+ = critical)
  static const int dangerRow = 9;
  static const int criticalRow = 10;

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

  // Warning / Countdown system
  bool isInDanger = false;     // bubble approaching warning zone
  bool isInCritical = false;   // countdown active
  double countdownTimer = 0.0; // seconds remaining
  static const double countdownDuration = 10.0;
  bool countdownActive = false;

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
  bool hasSwapped = false;

  double aimLengthMultiplier = 1.0;

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

  // ─── Ship Stats (loaded from Hangar)
  double _bulletSpeed = 18.0;
  int _laserWidth = 1;

  GameEngine({int? targetLevel}) {
    _loadData();
    _loadShipStats();
    if (targetLevel != null) level = targetLevel;
    startLevel(level);
  }

  void _loadShipStats() {
    int shipId = SaveService.getSelectedShip();
    int speedUpgrade = SaveService.getShipUpgradeLevel(shipId, 0);
    int aimUpgrade   = SaveService.getShipUpgradeLevel(shipId, 1);
    int laserUpgrade = SaveService.getShipUpgradeLevel(shipId, 2);

    const List<double> baseSpeeds = [18.0, 20.0, 20.0, 18.0, 22.0];
    double base = shipId < baseSpeeds.length ? baseSpeeds[shipId] : 18.0;
    _bulletSpeed = base + ((speedUpgrade - 1) * 1.5);

    const List<double> baseAims = [1.0, 1.0, 1.2, 1.4, 1.4];
    double baseAim = shipId < baseAims.length ? baseAims[shipId] : 1.0;
    aimLengthMultiplier = baseAim + ((aimUpgrade - 1) * 0.2);

    _laserWidth = laserUpgrade;
  }

  void _loadData() {
    highScore = SaveService.getHighScore();
    coins = SaveService.getCoins();
    level = SaveService.getLastLevel();
  }

  double gridDropTimer = 0.0;
  double gridDropInterval = 10.0;

  void startLevel(int levelNum) {
    level = levelNum;
    SaveService.setLastLevel(level);

    LevelConfig config = LevelData.getLevel(level);
    maxBubbles = config.shotLimit;
    remainingBubbles = maxBubbles;
    score = 0;

    // Dynamic drop interval: Easy=12s, Medium=8s, Hard=5s, Expert/Nightmare=3s
    if (level <= 20) {
      gridDropInterval = 12.0;
    } else if (level <= 40) {
      gridDropInterval = 8.0;
    } else if (level <= 60) {
      gridDropInterval = 5.0;
    } else {
      gridDropInterval = 3.0;
    }
    gridDropTimer = gridDropInterval;

    // Reset warning state
    isInDanger = false;
    isInCritical = false;
    countdownActive = false;
    countdownTimer = countdownDuration;

    levelColors = allColors.sublist(0, min(config.colorCount, allColors.length));

    _initGrid(config);
    _prepareNextBubble();
  }

  void _dropGrid() {
    for (int r = maxRows - 1; r > 0; r--) {
      int currentCols = (r % 2 == 0) ? colsEven : colsOdd;
      for (int c = 0; c < currentCols; c++) {
        int target = _getIndex(r, c);
        int source = _getIndex(r - 1, c);
        if (grid[source] != null) {
          grid[target] = BubbleModel(
            row: r,
            col: c,
            color: grid[source]!.color,
            type: grid[source]!.type,
            health: grid[source]!.health,
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

    AudioService.playDrop();
  }

  void _initGrid(LevelConfig config) {
    grid = List.filled(maxRows * colsEven, null);
    for (int r = 0; r < config.rowsToFill; r++) {
      int cols = r % 2 == 0 ? colsEven : colsOdd;
      for (int c = 0; c < cols; c++) {
        int index = _getIndex(r, c);

        BubbleType type = BubbleType.normal;
        if (level >= 26) {
          double rand = _random.nextDouble();
          if (rand < 0.05) type = BubbleType.bomb;
          else if (rand < 0.1) type = BubbleType.stone;
          else if (level >= 50 && rand < 0.15) type = BubbleType.ice;
        }

        grid[index] = BubbleModel(
          row: r,
          col: c,
          color: type == BubbleType.stone ? Colors.grey : levelColors[_random.nextInt(levelColors.length)],
          type: type,
        );
      }
    }
  }

  int _getIndex(int r, int c) {
    return r * colsEven + c;
  }

  void _prepareNextBubble() {
    shooterColor = nextColor;

    Set<Color> activeColors = {};
    for (var bubble in grid) {
      if (bubble != null && bubble.type != BubbleType.stone) {
        activeColors.add(bubble.color);
      }
    }

    if (activeColors.isNotEmpty) {
      List<Color> availableColors = activeColors.toList();
      nextColor = availableColors[_random.nextInt(availableColors.length)];
      if (!availableColors.contains(shooterColor)) {
        shooterColor = availableColors[_random.nextInt(availableColors.length)];
      }
    } else {
      nextColor = levelColors[_random.nextInt(levelColors.length)];
    }
  }

  void swapBubble() {
    if (hasSwapped) return;
    Color temp = shooterColor;
    shooterColor = nextColor;
    nextColor = temp;
    hasSwapped = true;
  }

  Offset getBubblePosition(int r, int c, double screenWidth) {
    double horizontalSpacing = bubbleDiameter;
    double verticalSpacing = bubbleDiameter * 0.866;

    double xOffset = (r % 2 == 0) ? 0 : bubbleRadius;
    double gridWidth = colsEven * bubbleDiameter;
    double startX = (screenWidth - gridWidth) / 2 + bubbleRadius;

    return Offset(
      startX + xOffset + (c * horizontalSpacing),
      gridTopOffset + bubbleRadius + (r * verticalSpacing),
    );
  }

  void shoot(double angle, double screenWidth, double screenHeight) {
    if (activeBubble != null || remainingBubbles <= 0) return;

    remainingBubbles--;
    shotsFired++;
    AudioService.playShoot();

    activeX = screenWidth / 2 + 45 * cos(angle);
    activeY = screenHeight - 55 + 45 * sin(angle);

    velocityX = _bulletSpeed * cos(angle);
    velocityY = _bulletSpeed * sin(angle);

    activeBubble = BubbleModel(
      row: -1, col: -1,
      color: shooterColor,
      x: activeX,
      y: activeY,
    );
    hasSwapped = false;
  }

  bool checkWin() {
    return grid.every((bubble) => bubble == null);
  }

  /// Returns true only if a bubble crossed the critical game-over line
  bool checkLose() {
    // Out of bubbles, nothing moving, grid still has bubbles
    if (remainingBubbles <= 0 && activeBubble == null) {
      if (!checkWin()) return true;
    }
    return false;
  }

  /// Check if any bubble is in the danger or critical zone
  void _updateDangerState() {
    bool newDanger = false;
    bool newCritical = false;

    for (int r = 0; r < maxRows; r++) {
      int cols = r % 2 == 0 ? colsEven : colsOdd;
      for (int c = 0; c < cols; c++) {
        if (grid[_getIndex(r, c)] != null) {
          if (r >= criticalRow) {
            newCritical = true;
            newDanger = true;
          } else if (r >= dangerRow) {
            newDanger = true;
          }
        }
      }
    }

    // Trigger warning sound only when entering danger for first time
    if (newDanger && !isInDanger) {
      AudioService.playWarning();
    }

    isInDanger = newDanger;
    isInCritical = newCritical;
  }

  /// Called from game loop. Returns true if game should end via countdown expiry.
  bool updateCountdown(double dt) {
    if (!isInCritical) {
      // Reset countdown if bubbles cleared from critical zone
      if (countdownActive) {
        countdownActive = false;
        countdownTimer = countdownDuration;
      }
      return false;
    }

    // Start countdown if not already running
    if (!countdownActive) {
      countdownActive = true;
      countdownTimer = countdownDuration;
    }

    countdownTimer -= dt;
    if (countdownTimer <= 0) {
      countdownTimer = 0;
      return true; // Game over via countdown
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

    // Update danger state
    _updateDangerState();

    // Countdown logic
    if (updateCountdown(dt)) {
      onGameOver();
      return;
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
    if (activeY - bubbleRadius <= gridTopOffset) {
      _snapToGrid(activeX, gridTopOffset + bubbleRadius, screenWidth);
      return;
    }

    // Grid collision
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] != null) {
        Offset pos = getBubblePosition(grid[i]!.row, grid[i]!.col, screenWidth);
        double dist = sqrt(pow(activeX - pos.dx, 2) + pow(activeY - pos.dy, 2));

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
    int r = ((y - gridTopOffset - bubbleRadius) / verticalSpacing).round().clamp(0, maxRows - 1);

    double xOffset = (r % 2 == 0) ? 0 : bubbleRadius;
    double gridWidth = colsEven * bubbleDiameter;
    double startX = (screenWidth - gridWidth) / 2 + bubbleRadius;

    int c = ((x - startX - xOffset) / bubbleDiameter).round();
    int maxCols = (r % 2 == 0) ? colsEven : colsOdd;
    c = c.clamp(0, maxCols - 1);

    int index = _getIndex(r, c);

    // If slot is occupied, search adjacent free slot
    if (grid[index] != null) {
      bool placed = false;
      List<Offset> neighbors = _getNeighbors(r, c);
      for (var n in neighbors) {
        int nr = n.dx.toInt();
        int nc = n.dy.toInt();
        if (nr < 0 || nr >= maxRows) continue;
        int nMaxCols = (nr % 2 == 0) ? colsEven : colsOdd;
        if (nc < 0 || nc >= nMaxCols) continue;
        int nIdx = _getIndex(nr, nc);
        if (grid[nIdx] == null) {
          grid[nIdx] = BubbleModel(
            row: nr, col: nc,
            color: activeBubble!.color,
            type: activeBubble!.type,
          );
          activeBubble = null;
          _checkMatches(nr, nc);
          _prepareNextBubble();
          placed = true;
          break;
        }
      }
      if (!placed) {
        // Force place (edge case)
        grid[index] = BubbleModel(
          row: r, col: c,
          color: activeBubble!.color,
          type: activeBubble!.type,
        );
        activeBubble = null;
        _checkMatches(r, c);
        _prepareNextBubble();
      }
      return;
    }

    grid[index] = BubbleModel(
      row: r,
      col: c,
      color: activeBubble!.color,
      type: activeBubble!.type,
    );

    activeBubble = null;
    _checkMatches(r, c);
    _prepareNextBubble();
  }

  void _checkMatches(int r, int c) {
    List<int> matches = [];
    Set<int> visited = {};
    Set<int> bombsToExplode = {};
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

      if (grid[idx] == null) return;
      if (grid[idx]!.type == BubbleType.stone) return;
      if (grid[idx]!.color != targetColor && grid[idx]!.type != BubbleType.rainbow) return;

      matches.add(idx);

      List<Offset> neighbors = _getNeighbors(currR, currC);
      for (var n in neighbors) {
        find(n.dx.toInt(), n.dy.toInt());
      }
    }

    find(r, c);

    // ✅ FIX: Must have 3+ to pop
    if (matches.length >= 3) {
      AudioService.playExplosion();
      rewardService.incrementCombo();
      int multiplier = rewardService.getScoreMultiplier();

      void checkBombs(int currIdx) {
        if (grid[currIdx] == null) return;
        List<Offset> neighbors = _getNeighbors(grid[currIdx]!.row, grid[currIdx]!.col);
        for (var n in neighbors) {
          if (n.dx >= 0 && n.dx < maxRows) {
            int nMaxCols = (n.dx.toInt() % 2 == 0) ? colsEven : colsOdd;
            if (n.dy >= 0 && n.dy < nMaxCols) {
              int nIdx = _getIndex(n.dx.toInt(), n.dy.toInt());
              if (grid[nIdx] != null && grid[nIdx]!.type == BubbleType.bomb) {
                if (!bombsToExplode.contains(nIdx)) bombsToExplode.add(nIdx);
              }
            }
          }
        }
      }

      // Handle Ice bubbles
      for (int idx in matches) {
        if (grid[idx] != null && grid[idx]!.type == BubbleType.ice) {
          List<Offset> iceNeighbors = _getNeighbors(grid[idx]!.row, grid[idx]!.col);
          for (var n in iceNeighbors) {
            if (n.dx >= 0 && n.dx < maxRows) {
              int nMaxCols = (n.dx.toInt() % 2 == 0) ? colsEven : colsOdd;
              if (n.dy >= 0 && n.dy < nMaxCols) {
                int nIdx = _getIndex(n.dx.toInt(), n.dy.toInt());
                if (grid[nIdx] != null && grid[nIdx]!.type == BubbleType.normal) {
                  grid[nIdx] = grid[nIdx]!.copyWith(type: BubbleType.stone, health: 1);
                }
              }
            }
          }
        }
      }

      for (int idx in matches) {
        checkBombs(idx);
        grid[idx] = null;
        score += 10 * multiplier;
      }

      // Handle bomb explosions
      while (bombsToExplode.isNotEmpty) {
        int bIdx = bombsToExplode.first;
        bombsToExplode.remove(bIdx);

        if (grid[bIdx] == null) continue;

        int bR = grid[bIdx]!.row;
        int bC = grid[bIdx]!.col;
        grid[bIdx] = null;
        score += 50;
        AudioService.vibrate(100);

        List<Offset> bNeighbors = _getNeighbors(bR, bC);
        for (var n in bNeighbors) {
          if (n.dx >= 0 && n.dx < maxRows) {
            int nMaxCols = (n.dx.toInt() % 2 == 0) ? colsEven : colsOdd;
            if (n.dy >= 0 && n.dy < nMaxCols) {
              int nIdx = _getIndex(n.dx.toInt(), n.dy.toInt());
              if (grid[nIdx] != null) {
                if (grid[nIdx]!.type == BubbleType.bomb) {
                  bombsToExplode.add(nIdx);
                } else if (grid[nIdx]!.type == BubbleType.stone) {
                  grid[nIdx]!.health--;
                  if (grid[nIdx]!.health <= 0) grid[nIdx] = null;
                } else {
                  grid[nIdx] = null;
                  score += 10;
                }
              }
            }
          }
        }
      }

      bubblesPoppedThisMatch += matches.length;

      if (multiplier >= 3) {
        AudioService.vibrate(50);
      }

      _dropFloating();

    } else {
      // ✅ FIX: No match — play pop but bubble stays in grid
      AudioService.playPop();
      rewardService.resetCombo();
    }

    if (score > highScore) {
      highScore = score;
      SaveService.setHighScore(highScore);
    }
  }

  List<Offset> _getNeighbors(int r, int c) {
    List<Offset> results = [];
    results.add(Offset(r.toDouble(), (c - 1).toDouble()));
    results.add(Offset(r.toDouble(), (c + 1).toDouble()));

    if (r % 2 == 0) {
      results.add(Offset((r - 1).toDouble(), (c - 1).toDouble()));
      results.add(Offset((r - 1).toDouble(), c.toDouble()));
      results.add(Offset((r + 1).toDouble(), (c - 1).toDouble()));
      results.add(Offset((r + 1).toDouble(), c.toDouble()));
    } else {
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
    AudioService.playLaser();
    AudioService.vibrate(200);
    for (int r = 0; r < maxRows; r++) {
      int cols = r % 2 == 0 ? colsEven : colsOdd;
      int mid = cols ~/ 2;
      _clearGridItem(r, mid);
      for (int offset = 1; offset <= _laserWidth; offset++) {
        if (mid + offset < cols) _clearGridItem(r, mid + offset);
        if (mid - offset >= 0) _clearGridItem(r, mid - offset);
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

  /// Progress indicator: how many rows still have bubbles
  int getFilledRowCount() {
    int filled = 0;
    for (int r = 0; r < maxRows; r++) {
      int cols = r % 2 == 0 ? colsEven : colsOdd;
      for (int c = 0; c < cols; c++) {
        if (grid[_getIndex(r, c)] != null) {
          filled = r + 1;
          break;
        }
      }
    }
    return filled;
  }

  void restart() {
    startLevel(level);
  }
}
