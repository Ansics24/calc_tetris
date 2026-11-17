import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

import 'sample_grid_support.dart';

/// Gridmodel looks like this
///
/// +---+---+---+---+
/// | 1 | 1 | 1 | 1 |
/// +---+---+---+---+
/// | 1 |   |   | 1 |
/// +---+---+---+---+
/// | 1 |   |   | 1 |
/// +---+---+---+---+
/// | 1 | 1 | 1 | 1 |
/// +---+---+---+---+
GridModel getBorderBlocked4x4SampleModel() {
  final gridModel = newEmptyGridModel(IntVector2(4, 4));
  for (var x = 0; x < 4; x++) {
    for (var y = 0; y < 4; y++) {
      if (x == 0 || y == 0 || x == 3 || y == 3) {
        addNumber(IntVector2(x, y), 1, gridModel);
      }
    }
  }
  return gridModel;
}
