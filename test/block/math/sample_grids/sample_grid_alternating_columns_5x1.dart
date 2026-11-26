import 'package:magic_blocks/grid/model/grid_model.dart';
import 'package:magic_blocks/util/int_vector_2.dart';

import 'sample_grid_support.dart';

/// Gridmodel looks like this. No two free cells are adjacent.
///
/// +---+---+---+---+---+
/// |   | 1 |   | 2 |   |
/// +---+---+---+---+---+
GridModel getAlternatingColumns5x1SampleModel() {
  final gridModel = newEmptyGridModel(IntVector2(5, 1));
  addNumber(IntVector2(1, 0), 1, gridModel);
  addNumber(IntVector2(3, 0), 2, gridModel);
  return gridModel;
}
