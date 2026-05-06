import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.white,
    this.isFullWidth = true,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPrimary = widget.color == Colors.white;
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          decoration: BoxDecoration(
            color: isPrimary ? Colors.white : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPrimary ? Colors.white : Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: isPrimary 
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ]
              : null,
          ),
          child: Center(
            child: Text(
              widget.text.toUpperCase(),
              style: GoogleFonts.outfit(
                color: isPrimary ? Colors.black : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
