import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SpaceshipWidget extends StatefulWidget {
  final double angle;
  final Color engineColor;

  const SpaceshipWidget({
    super.key,
    required this.angle,
    this.engineColor = Colors.cyanAccent,
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

  SpaceshipPainter({
    required this.engineIntensity, 
    required this.engineColor,
    required this.hoverValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Engine Fire Effect (First to be behind)
    _drawEngineFire(canvas, size);

    // Ship Body Path
    final bodyPath = ui.Path();
    bodyPath.moveTo(w * 0.5, 0); // Nose
    bodyPath.lineTo(w, h * 0.7); // Right Wing Tip
    bodyPath.lineTo(w * 0.8, h * 0.8); // Right Fin
    bodyPath.lineTo(w * 0.2, h * 0.8); // Left Fin
    bodyPath.lineTo(0, h * 0.7); // Left Wing Tip
    bodyPath.close();

    // Body Gradient (Metallic)
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    
    canvas.drawPath(bodyPath, bodyPaint);

    // Glowing Outlines
    final outlinePaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(bodyPath, outlinePaint);

    final cockpitPath = ui.Path()
      ..moveTo(w * 0.4, h * 0.2)
      ..conicTo(w * 0.5, h * 0.1, w * 0.6, h * 0.2, 1.0)
      ..lineTo(w * 0.65, h * 0.5)
      ..lineTo(w * 0.35, h * 0.5)
      ..close();

    final cockpitPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.cyanAccent, Colors.blue.withOpacity(0.3)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.3, h * 0.1, w * 0.4, h * 0.4));
    
    canvas.drawPath(cockpitPath, cockpitPaint);
    
    // Add inner glow to cockpit
    canvas.drawPath(cockpitPath, Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5);

    // Detail Panels
    _drawPanels(canvas, size);
  }

  void _drawEngineFire(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final firePaint = Paint();
    
    // Engine positions
    final engines = [Offset(w * 0.3, h * 0.75), Offset(w * 0.7, h * 0.75)];
    
    for (var pos in engines) {
      // Glow
      firePaint.shader = RadialGradient(
        colors: [engineColor.withOpacity(0.8 * engineIntensity), Colors.transparent],
      ).createShader(Rect.fromCircle(center: pos, radius: 35 * engineIntensity));
      canvas.drawCircle(pos, 35 * engineIntensity, firePaint);

      // Core fire (longer and sharper)
      final firePath = ui.Path();
      firePath.moveTo(pos.dx - 10, pos.dy);
      firePath.lineTo(pos.dx + 10, pos.dy);
      firePath.lineTo(pos.dx, pos.dy + 50 * engineIntensity); // Longer tail
      firePath.close();

      firePaint.shader = LinearGradient(
        colors: [Colors.white, engineColor, Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(pos.dx - 10, pos.dy, 20, 50 * engineIntensity));
      
      canvas.drawPath(firePath, firePaint);
      
      // Inner hot core
      final innerCorePath = ui.Path();
      innerCorePath.moveTo(pos.dx - 4, pos.dy);
      innerCorePath.lineTo(pos.dx + 4, pos.dy);
      innerCorePath.lineTo(pos.dx, pos.dy + 25 * engineIntensity);
      innerCorePath.close();
      
      canvas.drawPath(innerCorePath, Paint()..color = Colors.white);
    }
  }

  void _drawPanels(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    // Wings detail
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.5), Offset(size.width * 0.35, size.height * 0.6), paint);
    canvas.drawLine(Offset(size.width * 0.8, size.height * 0.5), Offset(size.width * 0.65, size.height * 0.6), paint);
    
    // Center detail
    canvas.drawRect(Rect.fromLTWH(size.width * 0.45, size.height * 0.55, size.width * 0.1, size.height * 0.1), paint);
    
    // Wing tip neon lights
    final lightPaint = Paint()
      ..color = Colors.blueAccent
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.65), 3, lightPaint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.65), 3, lightPaint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.65), 1.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.65), 1.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant SpaceshipPainter oldDelegate) {
    return oldDelegate.engineIntensity != engineIntensity || oldDelegate.hoverValue != hoverValue;
  }
}
