import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

import 'sample_grid_support.dart';

/// Gridmodel looks like this
///
/// +---+---+---+---+
/// |   |   |   |   |
/// +---+---+---+---+
/// |   |   |   |   |
/// +---+---+---+---+
/// |   |   |   |   |
/// +---+---+---+---+
GridModel getEmpty4x3SampleModel() => newEmptyGridModel(IntVector2(4, 3));
