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
}
