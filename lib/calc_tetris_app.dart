import 'package:calc_tetris/tetris_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Root widget: hosts the game inside the safe area of the device, so camera
/// cutouts and system bars never cover the game. The area around the game
/// takes the colors the game asks for.
class CalcTetrisApp extends StatelessWidget {
  static const Key surroundKey = Key('calc-tetris-surround');

  final TetrisGame game;

  CalcTetrisApp({super.key, TetrisGame? game}) : game = game ?? TetrisGame();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ValueListenableBuilder<List<Color>>(
        valueListenable: game.surroundColors,
        builder: (context, colors, child) => DecoratedBox(
          key: surroundKey,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
          ),
          child: child,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(child: GameWidget(game: game)),
        ),
      ),
    );
  }
}
