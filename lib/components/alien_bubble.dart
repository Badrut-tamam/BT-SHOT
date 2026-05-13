import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/bubble_model.dart';

class AlienBubble extends StatefulWidget {
  final Color color;
  final double size;
  final bool isShooting;
  final BubbleType type;

  const AlienBubble({
    super.key,
    required this.color,
    this.size = 40,
    this.isShooting = false,
    this.type = BubbleType.normal,
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

  AlienOrbPainter({required this.color, required this.pulseValue, this.type = BubbleType.normal});

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
      // Normal alien face
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

  @override
  bool shouldRepaint(covariant AlienOrbPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.color != color;
  }
}
