import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/game_screen.dart';
import 'screens/settings_screen.dart';

import 'services/save_service.dart';

import 'screens/level_select_screen.dart';

import 'screens/shop_screen.dart';
import 'screens/achievement_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SaveService.init();
  runApp(const BubbleShooterApp());
}

class BubbleShooterApp extends StatelessWidget {
  const BubbleShooterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Shooter Premium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.cyan,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
        if (settings.name == '/menu') {
          return MaterialPageRoute(builder: (_) => const MainMenuScreen());
        }
        if (settings.name == '/game') {
          final level = settings.arguments as int?;
          return MaterialPageRoute(builder: (_) => GameScreen(initialLevel: level));
        }
        if (settings.name == '/levels') {
          return MaterialPageRoute(builder: (_) => const LevelSelectScreen());
        }
        if (settings.name == '/settings') {
          return MaterialPageRoute(builder: (_) => const SettingsScreen());
        }
        if (settings.name == '/shop') {
          return MaterialPageRoute(builder: (_) => const ShopScreen());
        }
        if (settings.name == '/achievements') {
          return MaterialPageRoute(builder: (_) => const AchievementScreen());
        }
        return null;
      },
    );
  }
}
