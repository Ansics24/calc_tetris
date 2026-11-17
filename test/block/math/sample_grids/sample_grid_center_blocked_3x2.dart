import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

import 'sample_grid_support.dart';

/// Gridmodel looks like this
///
/// +---+---+---+
/// |   |   |   |
/// +---+---+---+
/// |   | 1 |   |
/// +---+---+---+
GridModel getCenterBlocked3x2SampleModel() {
  final gridModel = newEmptyGridModel(IntVector2(3, 2));
  addNumber(IntVector2(1, 1), 1, gridModel);
  return gridModel;
}
