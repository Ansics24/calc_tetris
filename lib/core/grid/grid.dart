import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:calc_tetris/core/block/math_block_model.dart';
import 'package:calc_tetris/core/block/math_block_type.dart';
import 'package:calc_tetris/core/block/math_number_block_component.dart';
import 'package:calc_tetris/core/grid/grid_line.dart';
import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/grid_position.dart';
import 'package:calc_tetris/global/block_board.dart';
import 'package:flame/components.dart';

class Grid extends PositionComponent {
  final GridPosition _blockCount;
  double _cellSize = 0;
  late final GridModel _gridModel;

  Grid({required this._blockCount}) {
    _gridModel = GridModel(size: _blockCount, gridComponent: this);
  }

  @override
  FutureOr<void> onLoad() {
    var boardSize = findParent<BlockBoard>()!.size;

    final double calcCellSizeBasedOnY = boardSize.y / _blockCount.y;
    final double calcCellSizeBasedOnX = boardSize.x / _blockCount.x;
    _cellSize = min(calcCellSizeBasedOnX, calcCellSizeBasedOnY);
    _gridModel.cellSize = _cellSize;

    position.x = (boardSize.x - (_cellSize * _blockCount.x)) / 2;
    position.y = (boardSize.y - (_cellSize * _blockCount.y)) / 2;

    dev.log('Cell based on x: $calcCellSizeBasedOnX');
    dev.log('Cell based on y: $calcCellSizeBasedOnY');
    dev.log('Cell size used: $_cellSize');
    dev.log('BoardSize: $boardSize');
    dev.log('Position of Grid: $position');

    addGridVisualization();

    // Only for test
    addExperimentalStuff();

    return super.onLoad();
  }

  void addExperimentalStuff() {
    _gridModel
        .addBlock(
          blockModel: MathBlockModel(
            component: MathNumberBlockComponent(
              number: 5,
            ),
          ),
          position: GridPosition(0, 0),
        )
        .addBlock(
          blockModel: MathBlockModel(
            component: MathNumberBlockComponent(number: 8),
          ),
          position: GridPosition(1, 0),
        )
        .addBlock(
          blockModel: MathBlockModel(
            component: MathNumberBlockComponent(number: 0),
          ),
          position: GridPosition(4, 5),
        );
    /*
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
    */
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
