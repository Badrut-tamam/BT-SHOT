import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/performance_service.dart';

class SpaceBackground extends StatefulWidget {
  final bool isMenu;
  const SpaceBackground({super.key, this.isMenu = false});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground> with TickerProviderStateMixin {
  late AnimationController _scrollController;
  late List<Star> _stars;
  late List<FallingStar> _fallingStars;
  late List<Planet> _planets;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _stars = List.generate(PerformanceService.starCount, (index) => Star(_random));
    _fallingStars = [];
    _planets = List.generate(PerformanceService.isBatterySaver ? 1 : 3, (index) => Planet(_random));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFallingStars() {
    if (PerformanceService.shouldReduceAnimations) return;
    if (_random.nextDouble() < 0.01) {
      _fallingStars.add(FallingStar(_random));
    }
    _fallingStars.removeWhere((fs) => fs.isDead);
    for (var fs in _fallingStars) { fs.update(); }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _scrollController,
        builder: (context, child) {
          if (widget.isMenu) _updateFallingStars();
          
          double speedMult = PerformanceService.scrollSpeedMultiplier;
          
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000428), Color(0xFF000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                // Nebula glow
                if (!PerformanceService.isBatterySaver)
                  ...List.generate(2, (index) {
                    return Positioned(
                      left: index * 200 - 100,
                      top: index * 300,
                      child: Opacity(
                        opacity: 0.1,
                        child: Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                index == 0 ? Colors.purple : Colors.blue,
                                Colors.transparent
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                
                // Parallax Stars
                ..._stars.map((star) {
                  double top = (star.y + _scrollController.value * 1000 * star.speed * speedMult) % MediaQuery.of(context).size.height;
                  return Positioned(
                    left: star.x * MediaQuery.of(context).size.width,
                    top: top,
                    child: Opacity(
                      opacity: star.opacity * (0.5 + 0.5 * math.sin(_scrollController.value * 10 + star.x)),
                      child: Container(
                        width: star.size,
                        height: star.size,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      ),
                    ),
                  );
                }),
  
                // Planets
                ..._planets.map((planet) {
                  double top = (planet.y + _scrollController.value * 200 * planet.speed * speedMult) % MediaQuery.of(context).size.height;
                  return Positioned(
                    left: planet.x * MediaQuery.of(context).size.width,
                    top: top,
                    child: Opacity(
                      opacity: 0.2,
                      child: Icon(planet.icon, size: planet.size, color: planet.color),
                    ),
                  );
                }),
  
                // Falling Stars (Menu only)
                if (widget.isMenu && !PerformanceService.isBatterySaver)
                  ..._fallingStars.map((fs) => Positioned(
                    left: fs.x,
                    top: fs.y,
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 2,
                        height: fs.length,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.transparent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Star {
  double x, y, size, speed, opacity;
  Star(math.Random rand)
      : x = rand.nextDouble(),
        y = rand.nextDouble() * 2000,
        size = rand.nextDouble() * 2 + 1,
        speed = rand.nextDouble() * 0.5 + 0.1,
        opacity = rand.nextDouble() * 0.7 + 0.3;
}

class FallingStar {
  double x, y, length, speed;
  bool isDead = false;
  FallingStar(math.Random rand)
      : x = rand.nextDouble() * 1000,
        y = -100,
        length = rand.nextDouble() * 50 + 20,
        speed = rand.nextDouble() * 10 + 10;
  
  void update() {
    x -= speed;
    y += speed;
    if (y > 1000) isDead = true;
  }
}

class Planet {
  double x, y, size, speed;
  IconData icon;
  Color color;
  Planet(math.Random rand)
      : x = rand.nextDouble(),
        y = rand.nextDouble() * 1000,
        size = rand.nextDouble() * 100 + 50,
        speed = rand.nextDouble() * 0.2 + 0.05,
        icon = Icons.circle,
        color = Colors.white.withOpacity(0.1);
}
