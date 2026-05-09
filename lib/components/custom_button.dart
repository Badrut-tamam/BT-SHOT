import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final bool isFullWidth;
  final bool isSecondary;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.white,
    this.isFullWidth = true,
    this.isSecondary = false,
    this.icon,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPrimary = !widget.isSecondary;
    Color neonColor = isPrimary ? AppColors.neonBlue : Colors.white.withOpacity(0.3);
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.isFullWidth ? double.infinity : null,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: neonColor.withOpacity(isPrimary ? 0.4 : 0.1),
                  blurRadius: _isHovering ? 25 : 15,
                  spreadRadius: _isHovering ? 4 : 1,
                  offset: const Offset(0, 4),
                ),
                if (isPrimary)
                  BoxShadow(
                    color: AppColors.neonPurple.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: -5,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 20, 
                    horizontal: widget.isFullWidth ? 32 : 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPrimary 
                        ? [AppColors.neonBlue, AppColors.neonPurple]
                        : [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.12)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isPrimary 
                        ? Colors.white.withOpacity(0.8)
                        : Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: isPrimary ? Colors.white : Colors.cyanAccent, size: 20),
                        const SizedBox(width: 12),
                      ],
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.text.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 2)),
                                if (isPrimary)
                                  const Shadow(color: Colors.white, blurRadius: 2),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
