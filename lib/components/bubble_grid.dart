import 'package:flutter/material.dart';

class BubbleGrid extends StatelessWidget {
  const BubbleGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy grid layout
    int rows = 6;
    int cols = 8;
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: List.generate(rows, (rowIndex) {
            bool isOffset = rowIndex % 2 != 0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(isOffset ? cols - 1 : cols, (colIndex) {
                return Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[600]!, width: 1),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
