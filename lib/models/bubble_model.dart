import 'package:flutter/material.dart';

enum BubbleType { normal, bomb, stone, ice, rainbow }

class BubbleModel {
  final int row;
  final int col;
  final Color color;
  final BubbleType type;
  bool isPopping;
  int health;
  
  // Position for animation
  double? x;
  double? y;

  BubbleModel({
    required this.row,
    required this.col,
    required this.color,
    this.type = BubbleType.normal,
    this.isPopping = false,
    this.health = 1,
    this.x,
    this.y,
  });

  // Copy with for updates
  BubbleModel copyWith({
    int? row,
    int? col,
    Color? color,
    BubbleType? type,
    bool? isPopping,
    int? health,
    double? x,
    double? y,
  }) {
    return BubbleModel(
      row: row ?? this.row,
      col: col ?? this.col,
      color: color ?? this.color,
      type: type ?? this.type,
      isPopping: isPopping ?? this.isPopping,
      health: health ?? this.health,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}
