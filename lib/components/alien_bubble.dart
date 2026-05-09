import 'package:flutter/material.dart';
import 'dart:math' as math;

class AlienBubble extends StatelessWidget {
  final Color color;
  final double size;
  final bool isShooting;

  const AlienBubble({
    super.key,
    required this.color,
    this.size = 40,
    this.isShooting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: AlienOrbPainter(color: color),
      ),
    );
  }
}

class AlienOrbPainter extends CustomPainter {
  final Color color;

  AlienOrbPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer glow
    final outerPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withOpacity(0.8), color.withOpacity(0.2), Colors.transparent],
        stops: const [0.5, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, outerPaint);

    // Inner core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, color],
        stops: const [0.1, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.6));
    canvas.drawCircle(center, radius * 0.6, corePaint);

    // Alien "Eyes" or patterns
    final detailPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(center.dx - radius * 0.2, center.dy - radius * 0.1), radius * 0.1, detailPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.2, center.dy - radius * 0.1), radius * 0.1, detailPaint);
    
    // Glowing pulse effect (Static for now, but looks premium)
    final pulsePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(Offset(center.dx - radius * 0.3, center.dy - radius * 0.3), radius * 0.1, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
