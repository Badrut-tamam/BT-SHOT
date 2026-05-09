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
  late AnimationController _nebulaController;
  late List<Star> _stars;
  late List<Meteor> _meteors;
  late List<Planet> _planets;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _nebulaController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _stars = List.generate(PerformanceService.starCount, (index) => Star(_random));
    _meteors = [];
    _planets = List.generate(PerformanceService.isBatterySaver ? 2 : 5, (index) => Planet(_random));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nebulaController.dispose();
    super.dispose();
  }

  void _updateMeteors() {
    if (PerformanceService.shouldReduceAnimations) return;
    if (_random.nextDouble() < (widget.isMenu ? 0.005 : 0.002)) {
      _meteors.add(Meteor(_random));
    }
    _meteors.removeWhere((m) => m.isDead);
    for (var m in _meteors) { m.update(); }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_scrollController, _nebulaController]),
        builder: (context, child) {
          _updateMeteors();
          
          double speedMult = PerformanceService.scrollSpeedMultiplier;
          
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000428), Color(0xFF000000), Color(0xFF050010)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                // Deep Space Nebula Layer 1
                if (!PerformanceService.isBatterySaver)
                  _buildNebulaLayer(size, _nebulaController.value, Colors.purple.withOpacity(0.05), 1.0),
                
                // Deep Space Nebula Layer 2
                if (!PerformanceService.isBatterySaver)
                  _buildNebulaLayer(size, (_nebulaController.value + 0.5) % 1.0, Colors.blue.withOpacity(0.05), 0.7),

                // Far Stars (Parallax Layer 1)
                ..._stars.take((_stars.length * 0.4).toInt()).map((star) {
                  double top = (star.y + _scrollController.value * 200 * star.speed * speedMult) % size.height;
                  return _buildStar(star, top, size.width);
                }),

                // Mid Planets (Parallax Layer 2)
                ..._planets.map((planet) {
                  double top = (planet.y + _scrollController.value * 150 * planet.speed * speedMult) % size.height;
                  return Positioned(
                    left: planet.x * size.width,
                    top: top,
                    child: Opacity(
                      opacity: planet.opacity,
                      child: Container(
                        width: planet.size,
                        height: planet.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [planet.color, Colors.transparent],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Near Stars (Parallax Layer 3)
                ..._stars.skip((_stars.length * 0.4).toInt()).map((star) {
                  double top = (star.y + _scrollController.value * 600 * star.speed * speedMult) % size.height;
                  return _buildStar(star, top, size.width);
                }),
  
                // Meteors
                ..._meteors.map((m) => Positioned(
                  left: m.x,
                  top: m.y,
                  child: Transform.rotate(
                    angle: m.angle,
                    child: Container(
                      width: 2,
                      height: m.length,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [m.color.withOpacity(0.8), Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(color: m.color.withOpacity(0.4), blurRadius: 4)
                        ]
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

  Widget _buildNebulaLayer(Size size, double animValue, Color color, double scale) {
    return Positioned(
      left: -size.width * 0.5 + (math.sin(animValue * 2 * math.pi) * 100),
      top: -size.height * 0.5 + (math.cos(animValue * 2 * math.pi) * 100),
      child: Container(
        width: size.width * 2 * scale,
        height: size.height * 2 * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }

  Widget _buildStar(Star star, double top, double width) {
    return Positioned(
      left: star.x * width,
      top: top,
      child: Opacity(
        opacity: (star.opacity * (0.4 + 0.6 * math.sin(_scrollController.value * 20 + star.x * 100))).clamp(0.0, 1.0),
        child: Container(
          width: star.size,
          height: star.size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: star.size > 2 ? [
              BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 4)
            ] : null,
          ),
        ),
      ),
    );
  }
}

class Star {
  double x, y, size, speed, opacity;
  Star(math.Random rand)
      : x = rand.nextDouble(),
        y = rand.nextDouble() * 2000,
        size = rand.nextDouble() * 2.5 + 0.5,
        speed = rand.nextDouble() * 0.6 + 0.1,
        opacity = rand.nextDouble() * 0.7 + 0.3;
}

class Meteor {
  double x, y, length, speed, angle;
  Color color;
  bool isDead = false;
  Meteor(math.Random rand)
      : x = rand.nextDouble() * 1200 - 200,
        y = -100,
        length = rand.nextDouble() * 80 + 40,
        speed = rand.nextDouble() * 15 + 10,
        angle = (rand.nextDouble() * 0.2 + 0.6) * math.pi, // Diagonal downward
        color = rand.nextBool() ? Colors.white : (rand.nextBool() ? Colors.cyanAccent : Colors.orangeAccent);
  
  void update() {
    x += speed * math.cos(angle - math.pi / 2);
    y += speed * math.sin(angle - math.pi / 2);
    if (y > 1500 || x < -500 || x > 1500) isDead = true;
  }
}

class Planet {
  double x, y, size, speed, opacity;
  Color color;
  Planet(math.Random rand)
      : x = rand.nextDouble(),
        y = rand.nextDouble() * 1000,
        size = rand.nextDouble() * 60 + 20,
        speed = rand.nextDouble() * 0.15 + 0.05,
        opacity = rand.nextDouble() * 0.15 + 0.05,
        color = [Colors.red, Colors.blue, Colors.purple, Colors.orange, Colors.teal][rand.nextInt(5)].withOpacity(0.3);
}
