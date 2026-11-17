import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

import 'sample_grid_support.dart';

/// Gridmodel looks like this
///
/// +---+---+---+
/// | 1 | 2 | 3 |
/// +---+---+---+
/// |   |   |   |
/// +---+---+---+
/// |   |   |   |
/// +---+---+---+
GridModel getTopRowBlocked3x3SampleModel() {
  final gridModel = newEmptyGridModel(IntVector2(3, 3));
  addNumber(IntVector2(0, 0), 1, gridModel);
  addNumber(IntVector2(1, 0), 2, gridModel);
  addNumber(IntVector2(2, 0), 3, gridModel);
  return gridModel;
}
