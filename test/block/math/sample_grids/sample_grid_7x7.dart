import 'package:magic_blocks/grid/model/grid_model.dart';
import 'package:magic_blocks/util/int_vector_2.dart';

import '../../../support/test_grid.dart';
import 'sample_grid_support.dart';

/// Gridmodel looks like this
///
///+---+---+---+---+---+---+---+
///   |   |   |   |   |   | 7 |
///---+---+---+---+---+---+---+
///   | 2 |   |   |   |   | + |
///---+---+---+---+---+---+---+
/// 5 | + | 3 | = | 8 |   | 1 |
///---+---+---+---+---+---+---+
/// = | 4 | - |   |   |   | = |
///---+---+---+---+---+---+---+
///   | = |   |   |   |   | 9 |
///---+---+---+---+---+---+---+
///   | 6 | + |   |   |   | = |
///---+---+---+---+---+---+---+
///   |   | 9 | - | 4 | = | 6 |
///---+---+---+---+---+---+---+
GridModel get7x7SampleModel() {
  final GridModel gridModel = GridModel(
    size: IntVector2(7, 7),
    gridComponent: newTestGrid(IntVector2(0, 6)),
  );
  gridModel.cellSize = 0;
  addNumber(IntVector2(6, 0), 7, gridModel);
  addNumber(IntVector2(1, 1), 2, gridModel);
  addNumber(IntVector2(0, 2), 5, gridModel);
  addNumber(IntVector2(2, 2), 3, gridModel);
  addNumber(IntVector2(4, 2), 8, gridModel);
  addNumber(IntVector2(6, 2), 1, gridModel);
  addNumber(IntVector2(1, 3), 4, gridModel);
  addNumber(IntVector2(6, 4), 9, gridModel);
  addNumber(IntVector2(1, 5), 6, gridModel);
  addNumber(IntVector2(2, 6), 9, gridModel);
  addNumber(IntVector2(4, 6), 4, gridModel);
  addNumber(IntVector2(6, 6), 6, gridModel);

  addPlus(IntVector2(6, 1), gridModel);
  addPlus(IntVector2(1, 2), gridModel);
  addPlus(IntVector2(2, 5), gridModel);

  addMinus(IntVector2(3, 6), gridModel);
  addMinus(IntVector2(2, 3), gridModel);

  addEquals(IntVector2(0, 3), gridModel);
  addEquals(IntVector2(3, 2), gridModel);
  addEquals(IntVector2(6, 3), gridModel);
  addEquals(IntVector2(1, 4), gridModel);
  addEquals(IntVector2(5, 6), gridModel);
  addEquals(IntVector2(6, 5), gridModel);

  return gridModel;
}
