import 'dart:developer';

import 'package:calc_tetris/core/block/math_compound_block_component.dart';
import 'package:calc_tetris/core/grid/exception/grid_index_out_of_bounds_exception.dart';
import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:flame/components.dart';

class PositionInGridFinder {
  final GridModel _gridModel;

  PositionInGridFinder({required this._gridModel});

  IntVector2? findPosition(Component component) {
    final model = _gridModel.model;
    for (var i = 0; i < model.length; i++) {
      for (var j = 0; j < model[i].length; j++) {
        final singleBlockModel = model[i][j];
        if (singleBlockModel == null) {
          continue;
        }
        if (singleBlockModel.component.key == component.key) {
          return IntVector2(i, j);
        }
      }
    }
    return null;
  }

  IntVector2? findLowestPossiblePosition(
    IntVector2 compoundBlockPositionInGrid,
    MathCompoundBlockComponent compoundBlockComponent,
  ) {
    final localPositions = compoundBlockComponent
        .getLocalSingleBlockPositions();
    final gridPositions = localPositions.map(
      (pos) =>
          pos.add(compoundBlockPositionInGrid.x, compoundBlockPositionInGrid.y),
    );

    var targetY = 1000;
    for (var posToCheck in gridPositions) {
      final nextFreePosInColumn = nextFreePositionInColumn(posToCheck.x);
      if (nextFreePosInColumn == null) {
        return null;
      }
      var yPosForColumn =
          nextFreePosInColumn -
          compoundBlockComponent.getLowestLocalBlockYPosition(
            posToCheck.x - compoundBlockPositionInGrid.x,
          );
      if (yPosForColumn < targetY) {
        targetY = yPosForColumn;
      }
    }
    if (targetY < compoundBlockPositionInGrid.y) {
      return null;
    }

    log("Lowest possible Y-Pos is $targetY");
    return IntVector2(
      compoundBlockPositionInGrid.x,
      targetY,
    );
  }

  int? nextFreePositionInColumn(int columnIndex) {
    if (columnIndex < 0 || columnIndex >= _gridModel.model.length) {
      throw GridIndexOutOfBoundsException();
    }
    for (var y = 0; y < _gridModel.model[columnIndex].length; y++) {
      if (!_gridModel.isPositionBlocked(IntVector2(columnIndex, y))) {
        continue;
      }
      if (y == 0) {
        return null;
      }
      return y - 1;
    }
    return _gridModel.model[columnIndex].length - 1;
  }
}
