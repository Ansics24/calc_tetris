import 'dart:async';
import 'dart:developer';

import 'package:calc_tetris/global/game_dimensions.dart';
import 'package:calc_tetris/global/grid_line.dart';
import 'package:calc_tetris/global/tetris_game.dart';
import 'package:flame/components.dart';

class Grid extends PositionComponent {
  static Vector2 gridSize = Vector2(11, 18);

  Grid() {
    anchor = Anchor.center;
  }

  @override
  FutureOr<void> onLoad() {
    var gameDimensions = findParent<TetrisGame>()!.gameDimensions;

    final double cellSize = gameDimensions.gameAreaSize().x / gridSize.x;
    log('Cell width: $cellSize');
    final offset = gameDimensions.gameAreaStart();

    addVerticalLines(offset, cellSize, gameDimensions);
    addHorizontalLines(offset, cellSize, gameDimensions);
    return super.onLoad();
  }

  void addVerticalLines(
    Vector2 offset,
    double cellSize,
    GameDimensions gameDimensions,
  ) {
    for (var i = 0; i <= gridSize.x; i++) {
      add(
        GridLine(
          Vector2(
            offset.x + i * cellSize,
            offset.y,
          ),
          Vector2(
            offset.x + i * cellSize,
            offset.y + gridSize.y * cellSize,
          ),
        ),
      );
    }
  }

  void addHorizontalLines(
    Vector2 offset,
    double cellSize,
    GameDimensions gameDimensions,
  ) {
    for (var i = 0; i <= gridSize.y; i++) {
      add(
        GridLine(
          Vector2(
            offset.x,
            offset.y + i * cellSize,
          ),
          Vector2(
            offset.x + gameDimensions.gameAreaSize().x,
            offset.y + i * cellSize,
          ),
        ),
      );
    }
  }

  @override
  void onMount() {
    super.onMount();
    add(
      RectangleComponent(
        size: Vector2(20, 20),
        anchor: Anchor.center,
      ),
    );
  }
}
