import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:calc_tetris/core/grid/grid_controller.dart';
import 'package:calc_tetris/core/grid/grid_line.dart';
import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:calc_tetris/global/block_board.dart';
import 'package:flame/components.dart';

class Grid extends PositionComponent {
  final IntVector2 _blockCount;
  double _cellSize = 0;
  late final GridModel _gridModel;
  late final GridController _gridController;

  Grid({required this._blockCount}) {
    _gridModel = GridModel(size: _blockCount, gridComponent: this);
    _gridController = GridController(gridModel: _gridModel, grid: this);
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
    _gridController.addExperimentalStuff();

    return super.onLoad();
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

  double get cellSize => _cellSize;
}
