import 'package:flutter/material.dart';

enum BubbleType { normal, bomb, stone, ice, rainbow }
enum FaceType { alien, skull, monster, ultraman }

class BubbleModel {
  final int row;
  final int col;
  final Color color;
  final BubbleType type;
  final FaceType faceType;
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
    this.faceType = FaceType.alien,
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
    FaceType? faceType,
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
      faceType: faceType ?? this.faceType,
      isPopping: isPopping ?? this.isPopping,
      health: health ?? this.health,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}
