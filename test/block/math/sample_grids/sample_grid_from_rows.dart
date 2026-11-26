import 'package:magic_blocks/block/math/math_single_block_component_factory.dart';
import 'package:magic_blocks/block/math/seed/block_tokens.dart';
import 'package:magic_blocks/grid/model/grid_model.dart';
import 'package:magic_blocks/util/int_vector_2.dart';

import 'sample_grid_support.dart';

/// Gridmodel built from rows of text. The rows are the human readable
/// representation of the model: a `.` is an empty cell, every other character
/// is a block token (digit, `+`, `-` or `=`). All rows need the same length.
///
/// Example for `['2+3', '...', '.=.']`:
///
/// +---+---+---+
/// | 2 | + | 3 |
/// +---+---+---+
/// |   |   |   |
/// +---+---+---+
/// |   | = |   |
/// +---+---+---+
GridModel sampleGridFromRows(List<String> rows) {
  final gridModel = newEmptyGridModel(
    IntVector2(rows.first.length, rows.length),
  );
  for (var y = 0; y < rows.length; y++) {
    for (var x = 0; x < rows[y].length; x++) {
      final token = rows[y][x];
      if (token == '.') {
        continue;
      }
      gridModel.addSingleBlock(
        'pid${x}_$y',
        newComponentFromBlockModel(BlockTokens.blockFor(token))!,
        IntVector2(x, y),
      );
    }
  }
  return gridModel;
}
