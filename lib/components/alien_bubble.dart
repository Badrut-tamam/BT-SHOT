import 'package:flutter/material.dart';
import 'dart:math' as math;

class AlienBubble extends StatefulWidget {
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

  AlienOrbPainter({required this.color, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer shell gradient
    final shellPaint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withOpacity(0.3), Colors.transparent],
        stops: const [0.4, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, shellPaint);

    // Inner glowing core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, color],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.6));
    canvas.drawCircle(center, radius * 0.6, corePaint);

    // Alien Eyes (Glowy)
    final eyePaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    final eyeSocketPaint = Paint()
      ..color = Colors.black.withOpacity(0.5);

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
