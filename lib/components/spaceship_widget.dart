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
      duration: const Duration(seconds: 2),
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
        // Idle hover animation (up and down slightly)
        double hoverY = math.sin(_hoverController.value * 2 * math.pi) * 5;
        
        return Transform.translate(
          offset: Offset(0, hoverY),
          child: Transform.rotate(
            angle: widget.angle + (math.pi / 2), // Adjusting so ship points to target
            child: CustomPaint(
              size: const Size(60, 80),
              painter: SpaceshipPainter(
                engineIntensity: 0.5 + (_hoverController.value * 0.5),
                engineColor: widget.engineColor,
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

  SpaceshipPainter({required this.engineIntensity, required this.engineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Body of the spaceship (Futuristic Deltwing/Jet shape)
    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.5, 0); // Nose
    bodyPath.lineTo(size.width, size.height * 0.8); // Right Wing
    bodyPath.lineTo(size.width * 0.7, size.height * 0.7); // Right back indent
    bodyPath.lineTo(size.width * 0.3, size.height * 0.7); // Left back indent
    bodyPath.lineTo(0, size.height * 0.8); // Left Wing
    bodyPath.close();

    // Body Gradient
    const bodyGradient = LinearGradient(
      colors: [Color(0xFF2C3E50), Color(0xFF000000), Color(0xFF2C3E50)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    paint.shader = bodyGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(bodyPath, paint);

    // Detail lines (Metallic look)
    final detailPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(bodyPath, detailPaint);

    // Cockpit
    final cockpitPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.cyanAccent, Colors.cyanAccent.withOpacity(0.1)],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.5, size.height * 0.3), radius: 10));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.3), width: 12, height: 20),
      cockpitPaint,
    );

    // Engine Glow
    final enginePaint = Paint()
      ..color = engineColor.withOpacity(0.8 * engineIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    // Left engine
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.75), 8 * engineIntensity, enginePaint);
    // Right engine
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.75), 8 * engineIntensity, enginePaint);

    // Engine Fire Trails
    final firePaint = Paint()
      ..shader = LinearGradient(
        colors: [engineColor, Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3));
    
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.7, 8, 20 * engineIntensity),
      firePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.7, 8, 20 * engineIntensity),
      firePaint,
    );
  }

  @override
  bool shouldRepaint(covariant SpaceshipPainter oldDelegate) {
    return oldDelegate.engineIntensity != engineIntensity;
  }
}
