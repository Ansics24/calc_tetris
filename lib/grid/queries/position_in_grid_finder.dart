import 'dart:developer';

import 'package:calc_tetris/block/compound_block_component.dart';
import 'package:calc_tetris/grid/exception/grid_index_out_of_bounds_exception.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
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

  /// The position the block reaches when it falls straight down from
  /// [compoundBlockPositionInGrid]. Only cells below the block count, so
  /// blocks above it (overhangs) do not matter.
  IntVector2? findLowestPossiblePosition(
    IntVector2 compoundBlockPositionInGrid,
    CompoundBlockComponent compoundBlockComponent,
  ) {
    final columns = compoundBlockComponent
        .getLocalSingleBlockPositions()
        .map((pos) => pos.x)
        .toSet();

    int? fallDistance;
    for (final localX in columns) {
      final lowestY =
          compoundBlockPositionInGrid.y +
          compoundBlockComponent.getLowestLocalBlockYPosition(localX);
      final distance =
          lastFreePositionBelow(
            compoundBlockPositionInGrid.x + localX,
            lowestY,
          ) -
          lowestY;
      if (fallDistance == null || distance < fallDistance) {
        fallDistance = distance;
      }
    }
    if (fallDistance == null) {
      return null;
    }

    final targetY = compoundBlockPositionInGrid.y + fallDistance;
    log("Lowest possible Y-Pos is $targetY");
    return IntVector2(compoundBlockPositionInGrid.x, targetY);
  }

  /// The lowest y a block can reach in [columnIndex] when it falls from
  /// [fromY]: the cell above the first blocked one below it, or the floor.
  int lastFreePositionBelow(int columnIndex, int fromY) {
    if (columnIndex < 0 || columnIndex >= _gridModel.model.length) {
      throw GridIndexOutOfBoundsException();
    }
    final columnHeight = _gridModel.model[columnIndex].length;
    for (var y = fromY + 1; y < columnHeight; y++) {
      if (_gridModel.isPositionBlocked(IntVector2(columnIndex, y))) {
        return y - 1;
      }
    }
    return columnHeight - 1;
  }
}
