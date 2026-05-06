import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/menu');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ZoomIn(
                  duration: const Duration(seconds: 1),
                  child: const Icon(
                    Icons.bubble_chart_rounded,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Text(
                    'BUBBLE SHOOTER',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeIn(
                  delay: const Duration(seconds: 2),
                  child: const Text(
                    'LOADING EXPERIENCE...',
                    style: TextStyle(
                      color: Colors.grey,
                      letterSpacing: 2,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                FadeIn(
                  delay: const Duration(seconds: 1),
                  child: const SizedBox(
                    width: 40,
                    height: 2,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
