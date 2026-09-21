import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:calc_tetris/core/grid/queries/position_in_grid.dart';
import 'package:flame/components.dart';

class PositionInGridFinder {
  final GridModel _gridModel;

  PositionInGridFinder({required this._gridModel});

  PositionInGrid? findPosition(ComponentKey key) {
    final model = _gridModel.model;
    for (var i = 0; i < model.length; i++) {
      for (var j = 0; j < model[i].length; j++) {
        final blockModel = model[i][j];
        if (blockModel == null) {
          continue;
        }
        if (blockModel.component.key == key) {
          return PositionInGrid(blockModel.component, IntVector2(i, j));
        }
      }
    }
    return null;
  }
}
