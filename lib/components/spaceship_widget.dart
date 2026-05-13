import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/save_service.dart';

class SpaceshipWidget extends StatefulWidget {
  final double angle;
  final Color engineColor;
  final int? shipId;

  final double recoilOffset;
  final bool isMuzzleFlashing;

  const SpaceshipWidget({
    super.key,
    required this.angle,
    this.engineColor = Colors.cyanAccent,
    this.shipId,
    this.recoilOffset = 0,
    this.isMuzzleFlashing = false,
  });

  @override
  State<SpaceshipWidget> createState() => _SpaceshipWidgetState();
}

class _SpaceshipWidgetState extends State<SpaceshipWidget> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int activeShipId = widget.shipId ?? SaveService.getSelectedShip();

    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        // Idle hover animation
        double hoverY = math.sin(_hoverController.value * 2 * math.pi) * 8;
        double flicker = 0.8 + (math.sin(_hoverController.value * 10 * math.pi) * 0.2);
        
        return Transform.translate(
          offset: Offset(0, hoverY),
          child: Transform.rotate(
            angle: widget.angle + (math.pi / 2),
            child: CustomPaint(
              size: const Size(70, 90),
              painter: SpaceshipPainter(
                engineIntensity: flicker,
                engineColor: widget.engineColor,
                hoverValue: _hoverController.value,
                shipId: activeShipId,
                recoilOffset: widget.recoilOffset,
                isMuzzleFlashing: widget.isMuzzleFlashing,
              ),
            ),
          ),
        );
      },
    );
  }
}

class SpaceshipPainter extends CustomPainter {
  final double engineIntensity;
  final Color engineColor;
  final double hoverValue;
  final int shipId;
  final double recoilOffset;
  final bool isMuzzleFlashing;

  SpaceshipPainter({
    required this.engineIntensity, 
    required this.engineColor,
    required this.hoverValue,
    required this.shipId,
    required this.recoilOffset,
    required this.isMuzzleFlashing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Apply recoil translation
    canvas.save();
    canvas.translate(0, recoilOffset);

    switch(shipId) {
      case 1: _paintFalcon(canvas, size); break;
      case 2: _paintNeonBlade(canvas, size); break;
      case 3: _paintTitanX(canvas, size); break;
      case 4: _paintGalaxyHunter(canvas, size); break;
      case 0:
      default: _paintDefault(canvas, size); break;
    }

    if (isMuzzleFlashing) {
      _drawMuzzleFlash(canvas, size);
    }
    
    canvas.restore();
  }

  void _drawMuzzleFlash(Canvas canvas, Size size) {
    final w = size.width;
    final flashPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.cyanAccent.withOpacity(0.8), Colors.transparent],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.5, 0), radius: 30));
    
    canvas.drawCircle(Offset(w * 0.5, 0), 25, flashPaint);
    
    // Tiny sparks
    final sparkPaint = Paint()..color = Colors.white;
    final rand = math.Random(123); // Consistent random for muzzle flash
    for (int i = 0; i < 5; i++) {
      double angle = rand.nextDouble() * 2 * math.pi;
      double dist = rand.nextDouble() * 20;
      canvas.drawCircle(Offset(w * 0.5 + math.cos(angle) * dist, math.sin(angle) * dist), 1.5, sparkPaint);
    }
  }

  void _fillAndOutline(Canvas canvas, double w, double h, ui.Path bodyPath) {
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(bodyPath, bodyPaint);

    final outlinePaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(bodyPath, outlinePaint);
  }

  void _drawCockpit(Canvas canvas, double w, double h, ui.Path cockpitPath) {
    final cockpitPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.cyanAccent, Colors.blue.withOpacity(0.3)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.3, h * 0.1, w * 0.4, h * 0.4));
    
    canvas.drawPath(cockpitPath, cockpitPaint);
    
    canvas.drawPath(cockpitPath, Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5);
  }

  void _drawNeonTip(Canvas canvas, Offset pos) {
    final lightPaint = Paint()
      ..color = Colors.blueAccent
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(pos, 3, lightPaint);
    canvas.drawCircle(pos, 1.5, Paint()..color = Colors.white);
  }

  void _drawEngineFire(Canvas canvas, Size size, List<Offset> engines) {
    final firePaint = Paint();
    for (var pos in engines) {
      firePaint.shader = RadialGradient(
        colors: [engineColor.withOpacity(0.8 * engineIntensity), Colors.transparent],
      ).createShader(Rect.fromCircle(center: pos, radius: 35 * engineIntensity));
      canvas.drawCircle(pos, 35 * engineIntensity, firePaint);

      final firePath = ui.Path();
      firePath.moveTo(pos.dx - 10, pos.dy);
      firePath.lineTo(pos.dx + 10, pos.dy);
      firePath.lineTo(pos.dx, pos.dy + 50 * engineIntensity);
      firePath.close();

      firePaint.shader = LinearGradient(
        colors: [Colors.white, engineColor, Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(pos.dx - 10, pos.dy, 20, 50 * engineIntensity));
      
      canvas.drawPath(firePath, firePaint);
      
      final innerCorePath = ui.Path();
      innerCorePath.moveTo(pos.dx - 4, pos.dy);
      innerCorePath.lineTo(pos.dx + 4, pos.dy);
      innerCorePath.lineTo(pos.dx, pos.dy + 25 * engineIntensity);
      innerCorePath.close();
      
      canvas.drawPath(innerCorePath, Paint()..color = Colors.white);
    }
  }

  // 0. Default Ship
  void _paintDefault(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    _drawEngineFire(canvas, size, [Offset(w * 0.3, h * 0.75), Offset(w * 0.7, h * 0.75)]);

    final bodyPath = ui.Path();
    bodyPath.moveTo(w * 0.5, 0); // Nose
    bodyPath.lineTo(w, h * 0.7); // Right Wing Tip
    bodyPath.lineTo(w * 0.8, h * 0.8); // Right Fin
    bodyPath.lineTo(w * 0.2, h * 0.8); // Left Fin
    bodyPath.lineTo(0, h * 0.7); // Left Wing Tip
    bodyPath.close();

    _fillAndOutline(canvas, w, h, bodyPath);

    final cockpitPath = ui.Path()
      ..moveTo(w * 0.4, h * 0.2)
      ..conicTo(w * 0.5, h * 0.1, w * 0.6, h * 0.2, 1.0)
      ..lineTo(w * 0.65, h * 0.5)
      ..lineTo(w * 0.35, h * 0.5)
      ..close();
      
    _drawCockpit(canvas, w, h, cockpitPath);

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    canvas.drawLine(Offset(w * 0.2, h * 0.5), Offset(w * 0.35, h * 0.6), paint);
    canvas.drawLine(Offset(w * 0.8, h * 0.5), Offset(w * 0.65, h * 0.6), paint);
    canvas.drawRect(Rect.fromLTWH(w * 0.45, h * 0.55, w * 0.1, h * 0.1), paint);
    
    _drawNeonTip(canvas, Offset(w * 0.1, h * 0.65));
    _drawNeonTip(canvas, Offset(w * 0.9, h * 0.65));
  }

  // 1. Falcon Ship (Sleek, swept back)
  void _paintFalcon(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    _drawEngineFire(canvas, size, [Offset(w * 0.4, h * 0.8), Offset(w * 0.6, h * 0.8)]);

    final bodyPath = ui.Path();
    bodyPath.moveTo(w * 0.5, h * 0.05); // Nose
    bodyPath.lineTo(w * 0.6, h * 0.3);  
    bodyPath.lineTo(w * 0.95, h * 0.9); // Deep swept wing
    bodyPath.lineTo(w * 0.7, h * 0.85); 
    bodyPath.lineTo(w * 0.5, h * 0.95); // Center tail
    bodyPath.lineTo(w * 0.3, h * 0.85); 
    bodyPath.lineTo(w * 0.05, h * 0.9); // Left swept wing
    bodyPath.lineTo(w * 0.4, h * 0.3);
    bodyPath.close();

    _fillAndOutline(canvas, w, h, bodyPath);

    final cockpitPath = ui.Path()
      ..moveTo(w * 0.45, h * 0.25)
      ..lineTo(w * 0.55, h * 0.25)
      ..lineTo(w * 0.6, h * 0.5)
      ..lineTo(w * 0.4, h * 0.5)
      ..close();
      
    _drawCockpit(canvas, w, h, cockpitPath);

    _drawNeonTip(canvas, Offset(w * 0.95, h * 0.9));
    _drawNeonTip(canvas, Offset(w * 0.05, h * 0.9));
  }

  // 2. Neon Blade (Sword-like, sharp forward)
  void _paintNeonBlade(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    _drawEngineFire(canvas, size, [Offset(w * 0.5, h * 0.9)]);

    final bodyPath = ui.Path();
    bodyPath.moveTo(w * 0.5, 0); // Extremely sharp nose
    bodyPath.lineTo(w * 0.7, h * 0.5); // Wide middle
    bodyPath.lineTo(w * 0.85, h * 0.4); // Forward swept small wing
    bodyPath.lineTo(w * 0.65, h * 0.8);
    bodyPath.lineTo(w * 0.35, h * 0.8);
    bodyPath.lineTo(w * 0.15, h * 0.4); // Forward swept left wing
    bodyPath.lineTo(w * 0.3, h * 0.5);
    bodyPath.close();

    _fillAndOutline(canvas, w, h, bodyPath);

    final cockpitPath = ui.Path()
      ..moveTo(w * 0.5, h * 0.15)
      ..lineTo(w * 0.6, h * 0.6)
      ..lineTo(w * 0.4, h * 0.6)
      ..close();
      
    _drawCockpit(canvas, w, h, cockpitPath);

    _drawNeonTip(canvas, Offset(w * 0.85, h * 0.4));
    _drawNeonTip(canvas, Offset(w * 0.15, h * 0.4));
  }

  // 3. Titan X (Bulky, wide, 4 engines)
  void _paintTitanX(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    _drawEngineFire(canvas, size, [
      Offset(w * 0.25, h * 0.8), 
      Offset(w * 0.4, h * 0.85),
      Offset(w * 0.6, h * 0.85),
      Offset(w * 0.75, h * 0.8)
    ]);

    final bodyPath = ui.Path();
    bodyPath.moveTo(w * 0.3, h * 0.1); 
    bodyPath.lineTo(w * 0.7, h * 0.1); // Flat nose
    bodyPath.lineTo(w * 0.9, h * 0.4); // Bulky shoulders
    bodyPath.lineTo(w * 0.95, h * 0.7); 
    bodyPath.lineTo(w * 0.8, h * 0.9);
    bodyPath.lineTo(w * 0.2, h * 0.9);
    bodyPath.lineTo(w * 0.05, h * 0.7);
    bodyPath.lineTo(w * 0.1, h * 0.4);
    bodyPath.close();

    _fillAndOutline(canvas, w, h, bodyPath);

    final cockpitPath = ui.Path()
      ..moveTo(w * 0.35, h * 0.2)
      ..lineTo(w * 0.65, h * 0.2)
      ..lineTo(w * 0.7, h * 0.4)
      ..lineTo(w * 0.3, h * 0.4)
      ..close();
      
    _drawCockpit(canvas, w, h, cockpitPath);

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(w * 0.5, h * 0.4), Offset(w * 0.5, h * 0.9), paint);
    canvas.drawLine(Offset(w * 0.2, h * 0.6), Offset(w * 0.8, h * 0.6), paint);
    
    _drawNeonTip(canvas, Offset(w * 0.95, h * 0.7));
    _drawNeonTip(canvas, Offset(w * 0.05, h * 0.7));
  }

  // 4. Galaxy Hunter (V-shape, alien)
  void _paintGalaxyHunter(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    _drawEngineFire(canvas, size, [Offset(w * 0.5, h * 0.6)]);

    final bodyPath = ui.Path();
    bodyPath.moveTo(w * 0.5, h * 0.3); // Deep V inner
    bodyPath.lineTo(w * 0.8, h * 0.1); // High top right
    bodyPath.lineTo(w, h * 0.8); // Long sharp right bottom
    bodyPath.lineTo(w * 0.6, h * 0.9); // Inner angle
    bodyPath.lineTo(w * 0.5, h * 0.7); // Connects to engine area
    bodyPath.lineTo(w * 0.4, h * 0.9); 
    bodyPath.lineTo(0, h * 0.8); // Long sharp left bottom
    bodyPath.lineTo(w * 0.2, h * 0.1); // High top left
    bodyPath.close();

    _fillAndOutline(canvas, w, h, bodyPath);

    final cockpitPath = ui.Path()
      ..moveTo(w * 0.45, h * 0.4)
      ..lineTo(w * 0.55, h * 0.4)
      ..lineTo(w * 0.5, h * 0.6)
      ..close();
      
    _drawCockpit(canvas, w, h, cockpitPath);
    
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), 8, Paint()..color = engineColor.withOpacity(0.8));
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), 4, Paint()..color = Colors.white);

    _drawNeonTip(canvas, Offset(w, h * 0.8));
    _drawNeonTip(canvas, Offset(0, h * 0.8));
    _drawNeonTip(canvas, Offset(w * 0.8, h * 0.1));
    _drawNeonTip(canvas, Offset(w * 0.2, h * 0.1));
  }

  @override
  bool shouldRepaint(covariant SpaceshipPainter oldDelegate) {
    return oldDelegate.engineIntensity != engineIntensity || 
           oldDelegate.hoverValue != hoverValue ||
           oldDelegate.shipId != shipId ||
           oldDelegate.recoilOffset != recoilOffset ||
           oldDelegate.isMuzzleFlashing != isMuzzleFlashing;
  }
}

