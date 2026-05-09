import 'package:flutter/material.dart';
import 'save_service.dart';

class PerformanceService {
  static bool get isBatterySaver => SaveService.isBatterySaver();
  static int get fpsLimit => SaveService.getFpsMode();

  // Optimization hints
  static bool get shouldReduceAnimations => isBatterySaver;
  static int get starCount => isBatterySaver ? 40 : 100;
  static double get scrollSpeedMultiplier => isBatterySaver ? 0.5 : 1.0;
}
