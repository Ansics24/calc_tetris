import 'package:calc_tetris/global/tetris_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: TetrisGame(),
      backgroundBuilder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
      ),
    ),
  );
}
