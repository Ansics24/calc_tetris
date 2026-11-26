import 'package:magic_blocks/grid/model/grid_model.dart';
import 'package:magic_blocks/util/int_vector_2.dart';

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
