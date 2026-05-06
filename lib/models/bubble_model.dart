import 'package:flutter/material.dart';

class BubbleModel {
  final int row;
  final int col;
  final Color color;
  bool isPopping;
  
  // Position for animation
  double? x;
  double? y;

  BubbleModel({
    required this.row,
    required this.col,
    required this.color,
    this.isPopping = false,
    this.x,
    this.y,
  });

  // Copy with for updates
  BubbleModel copyWith({
    int? row,
    int? col,
    Color? color,
    bool? isPopping,
    double? x,
    double? y,
  }) {
    return BubbleModel(
      row: row ?? this.row,
      col: col ?? this.col,
      color: color ?? this.color,
      isPopping: isPopping ?? this.isPopping,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}
