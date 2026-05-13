import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/bubble_model.dart';

class AlienBubble extends StatefulWidget {
  final Color color;
  final double size;
  final bool isShooting;
  final BubbleType type;
  final FaceType faceType;

  const AlienBubble({
    super.key,
    required this.color,
    this.size = 40,
    this.isShooting = false,
    this.type = BubbleType.normal,
    this.faceType = FaceType.alien,
  });

  @override
  State<AlienBubble> createState() => _AlienBubbleState();
}

class _AlienBubbleState extends State<AlienBubble> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        double pulse = 0.95 + (_pulseController.value * 0.1);
        return Container(
          width: widget.size * pulse,
          height: widget.size * pulse,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4 + (_pulseController.value * 0.3)),
                blurRadius: 15 + (_pulseController.value * 10),
                spreadRadius: 2 + (_pulseController.value * 2),
              ),
            ],
          ),
          child: CustomPaint(
            painter: AlienOrbPainter(
              color: widget.color,
              pulseValue: _pulseController.value,
              type: widget.type,
              faceType: widget.faceType,
            ),
          ),
        );
      },
    );
  }
}

class AlienOrbPainter extends CustomPainter {
  final Color color;
  final double pulseValue;
  final BubbleType type;
  final FaceType faceType;

  AlienOrbPainter({
    required this.color, 
    required this.pulseValue, 
    this.type = BubbleType.normal,
    this.faceType = FaceType.alien,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer shell glow gradient
    final shellPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withOpacity(0.8), color.withOpacity(0.5), Colors.transparent],
        stops: const [0.5, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, shellPaint);

    // Inner glowing bright core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, color.withOpacity(0.9), color.withOpacity(0.0)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.8));
    canvas.drawCircle(center, radius * 0.8, corePaint);

    // Alien Eyes (Glowy)
    final eyePaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    
    final eyeSocketPaint = Paint()
      ..color = Colors.black.withOpacity(0.8);


    if (type == BubbleType.stone) {
      // Stone texture
      final stonePaint = Paint()
        ..color = Colors.grey.shade700;
      canvas.drawCircle(center, radius, stonePaint);
      final crackPaint = Paint()
        ..color = Colors.black54
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(center.dx - radius * 0.5, center.dy - radius * 0.5), Offset(center.dx + radius * 0.2, center.dy + radius * 0.1), crackPaint);
      canvas.drawLine(Offset(center.dx + radius * 0.2, center.dy + radius * 0.1), Offset(center.dx - radius * 0.1, center.dy + radius * 0.6), crackPaint);
    } else if (type == BubbleType.bomb) {
      // Bomb icon
      final bombPaint = Paint()
        ..color = Colors.black87;
      canvas.drawCircle(center, radius * 0.8, bombPaint);
      final fusePaint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(center.dx, center.dy - radius * 0.8), Offset(center.dx + radius * 0.4, center.dy - radius * 1.1), fusePaint);
      final sparkPaint = Paint()..color = Colors.redAccent;
      canvas.drawCircle(Offset(center.dx + radius * 0.4, center.dy - radius * 1.1), radius * 0.2 * pulseValue, sparkPaint);
    } else if (type == BubbleType.ice) {
      // Ice crystal
      final icePaint = Paint()
        ..color = Colors.cyan.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromCenter(center: center, width: radius * 1.2, height: radius * 1.2), icePaint);
    } else {
      // Draw based on FaceType
      switch (faceType) {
        case FaceType.skull:
          _drawSkull(canvas, center, radius);
          break;
        case FaceType.monster:
          _drawMonster(canvas, center, radius);
          break;
        case FaceType.ultraman:
          _drawUltraman(canvas, center, radius);
          break;
        case FaceType.alien:
        default:
          _drawAlien(canvas, center, radius, eyeSocketPaint, eyePaint);
          break;
      }
    }

    // Highlight sheen
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withOpacity(0.6), Colors.transparent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius * 0.8, Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.2), Colors.transparent],
        center: const Alignment(-0.4, -0.4),
        radius: 0.3,
      ).createShader(Rect.fromCircle(center: center, radius: radius)));
  }

  void _drawAlien(Canvas canvas, Offset center, double radius, Paint eyeSocketPaint, Paint eyePaint) {
    // Left eye
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx - radius * 0.25, center.dy - radius * 0.1), width: radius * 0.2, height: radius * 0.3),
      eyeSocketPaint,
    );
    canvas.drawCircle(Offset(center.dx - radius * 0.25, center.dy - radius * 0.1), radius * 0.05, eyePaint);

    // Right eye
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx + radius * 0.25, center.dy - radius * 0.1), width: radius * 0.2, height: radius * 0.3),
      eyeSocketPaint,
    );
    canvas.drawCircle(Offset(center.dx + radius * 0.25, center.dy - radius * 0.1), radius * 0.05, eyePaint);
  }

  void _drawSkull(Canvas canvas, Offset center, double radius) {
    final paint = Paint()..color = Colors.white.withOpacity(0.9);
    final holePaint = Paint()..color = Colors.black87;

    // Main skull shape
    canvas.drawCircle(Offset(center.dx, center.dy - radius * 0.1), radius * 0.45, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + radius * 0.3), width: radius * 0.4, height: radius * 0.3),
        Radius.circular(radius * 0.1),
      ),
      paint,
    );

    // Eyes
    canvas.drawCircle(Offset(center.dx - radius * 0.15, center.dy), radius * 0.1, holePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.15, center.dy), radius * 0.1, holePaint);

    // Nose
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy + radius * 0.1)
        ..lineTo(center.dx - radius * 0.05, center.dy + radius * 0.2)
        ..lineTo(center.dx + radius * 0.05, center.dy + radius * 0.2)
        ..close(),
      holePaint,
    );

    // Teeth lines
    final linePaint = Paint()..color = Colors.black54..strokeWidth = 1;
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(center.dx + i * radius * 0.1, center.dy + radius * 0.25),
        Offset(center.dx + i * radius * 0.1, center.dy + radius * 0.4),
        linePaint,
      );
    }
  }

  void _drawMonster(Canvas canvas, Offset center, double radius) {
    final eyePaint = Paint()..color = Colors.yellowAccent;
    final pupilPaint = Paint()..color = Colors.black;
    final mouthPaint = Paint()..color = Colors.black87;

    // Angled angry eyes
    Path leftEye = Path()
      ..moveTo(center.dx - radius * 0.4, center.dy - radius * 0.3)
      ..lineTo(center.dx - radius * 0.1, center.dy - radius * 0.1)
      ..lineTo(center.dx - radius * 0.4, center.dy)
      ..close();
    canvas.drawPath(leftEye, eyePaint);
    canvas.drawCircle(Offset(center.dx - radius * 0.3, center.dy - radius * 0.15), 2, pupilPaint);

    Path rightEye = Path()
      ..moveTo(center.dx + radius * 0.4, center.dy - radius * 0.3)
      ..lineTo(center.dx + radius * 0.1, center.dy - radius * 0.1)
      ..lineTo(center.dx + radius * 0.4, center.dy)
      ..close();
    canvas.drawPath(rightEye, eyePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.3, center.dy - radius * 0.15), 2, pupilPaint);

    // Wide mouth with fangs
    canvas.drawArc(
      Rect.fromCenter(center: Offset(center.dx, center.dy + radius * 0.2), width: radius * 0.6, height: radius * 0.3),
      0, 3.14, true, mouthPaint,
    );

    // Fangs
    final fangPaint = Paint()..color = Colors.white;
    Path fang1 = Path()
      ..moveTo(center.dx - radius * 0.2, center.dy + radius * 0.2)
      ..lineTo(center.dx - radius * 0.15, center.dy + radius * 0.35)
      ..lineTo(center.dx - radius * 0.1, center.dy + radius * 0.2)
      ..close();
    canvas.drawPath(fang1, fangPaint);
    
    Path fang2 = Path()
      ..moveTo(center.dx + radius * 0.2, center.dy + radius * 0.2)
      ..lineTo(center.dx + radius * 0.15, center.dy + radius * 0.35)
      ..lineTo(center.dx + radius * 0.1, center.dy + radius * 0.2)
      ..close();
    canvas.drawPath(fang2, fangPaint);
  }

  void _drawUltraman(Canvas canvas, Offset center, double radius) {
    final headPaint = Paint()..color = Colors.white.withOpacity(0.9);
    final eyePaint = Paint()..shader = RadialGradient(
      colors: [Colors.yellow.shade200, Colors.orange.shade400],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Ultraman head crest
    Path crest = Path()
      ..moveTo(center.dx, center.dy - radius * 0.8)
      ..lineTo(center.dx - radius * 0.1, center.dy - radius * 0.3)
      ..lineTo(center.dx + radius * 0.1, center.dy - radius * 0.3)
      ..close();
    canvas.drawPath(crest, headPaint);

    // Large oval eyes
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx - radius * 0.3, center.dy - radius * 0.1), width: radius * 0.4, height: radius * 0.5),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx + radius * 0.3, center.dy - radius * 0.1), width: radius * 0.4, height: radius * 0.5),
      eyePaint,
    );

    // Energy core (color timer)
    final timerPaint = Paint()..color = Colors.cyanAccent..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(center.dx, center.dy + radius * 0.4), radius * 0.1, timerPaint);
  }

  @override
  bool shouldRepaint(covariant AlienOrbPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.color != color || oldDelegate.faceType != faceType;
  }
}
