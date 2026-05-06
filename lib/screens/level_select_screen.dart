import 'package:flutter/material.dart';
import '../services/level_service.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int unlockedLevel = LevelService.getUnlockedLevel();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'SELECT LEVEL',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            int levelNumber = index + 1;
            bool isUnlocked = levelNumber <= unlockedLevel;
            
            return GestureDetector(
              onTap: isUnlocked 
                ? () {
                    // Navigate to game with selected level
                    Navigator.pushNamed(context, '/game', arguments: levelNumber);
                  }
                : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.grey[900] : Colors.black,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isUnlocked ? Colors.white : Colors.grey[800]!,
                    width: 2,
                  ),
                  boxShadow: isUnlocked 
                    ? [BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 10)]
                    : [],
                ),
                child: Center(
                  child: isUnlocked 
                    ? Text(
                        '$levelNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Icon(Icons.lock, color: Colors.grey[800], size: 30),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
