import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:calc_tetris/core/block/single_block_component.dart';
import 'package:calc_tetris/core/grid_line.dart';
import 'package:calc_tetris/global/block_board.dart';
import 'package:flame/components.dart';

class Grid extends PositionComponent {
  final Vector2 _blockCount;
  double _cellSize = 0;

  Grid({required this._blockCount});

  @override
  FutureOr<void> onLoad() {
    var boardSize = findParent<BlockBoard>()!.size;

    final double calcCellSizeBasedOnY = boardSize.y / _blockCount.y;
    final double calcCellSizeBasedOnX = boardSize.x / _blockCount.x;
    _cellSize = min(calcCellSizeBasedOnX, calcCellSizeBasedOnY);

    position.x = (boardSize.x - (_cellSize * _blockCount.x)) / 2;
    position.y = (boardSize.y - (_cellSize * _blockCount.y)) / 2;

    dev.log('Cell based on x: $calcCellSizeBasedOnX');
    dev.log('Cell based on y: $calcCellSizeBasedOnY');
    dev.log('Cell size used: $_cellSize');
    dev.log('BoardSize: $boardSize');
    dev.log('Position of Grid: $position');

    addGridVisualization();

    // Only for test
    // addExperimentalStuff();

    return super.onLoad();
  }

  void addExperimentalStuff() {
    Vector2 blockSize = Vector2.all(_cellSize);
    add(
      SingleBlockComponent(
        number: 5,
        position: Vector2(100, 400),
        size: blockSize,
      ),
    );
    add(
      SingleBlockComponent(
        number: 2,
        position: Vector2(80, 30),
        size: blockSize,
      ),
    );
  }

  void addGridVisualization() {
    for (var i = 0; i <= _blockCount.x; i++) {
      add(
        GridLine(
          Vector2(
            i * _cellSize,
            0,
          ),
          Vector2(
            i * _cellSize,
            _blockCount.y * _cellSize,
          ),
        ),
      );
    }
    for (var i = 0; i <= _blockCount.y; i++) {
      add(
        GridLine(
          Vector2(
            0,
            i * _cellSize,
          ),
          Vector2(_blockCount.x * _cellSize, i * _cellSize),
        ),
      );
    }
  }
}
