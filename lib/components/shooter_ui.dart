import 'package:flutter/material.dart';

class ShooterUI extends StatelessWidget {
  final Color shooterColor;
  final Color nextColor;
  final double angle;

  const ShooterUI({
    super.key,
    required this.shooterColor,
    required this.nextColor,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Next Ball Preview
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 80,
            child: Column(
              children: [
                const Text('NEXT', style: TextStyle(color: Colors.grey, fontSize: 8)),
                const SizedBox(height: 4),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: nextColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ],
            ),
          ),
          
          // Main Shooter Cannon/Arrow
          Positioned(
            bottom: 30,
            child: Transform.rotate(
              angle: angle + 1.5708, // Adjusting for icon orientation (90 degrees)
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: shooterColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: shooterColor.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_upward,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    var max = size.height;
    var dashWidth = 5.0;
    var dashSpace = 5.0;
    double startY = 0;
    while (startY < max) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
