import 'package:calc_tetris/block/model/null_block.dart';
import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

/// Returns the leftmost columns in which the block can enter the grid at the
/// top without overlapping an already blocked cell. [block] is indexed
/// `[x][y]`, like the grid.
List<int> freeStartColumns({
  required List<List<MathSingleBlock>> block,
  required int gridWidth,
  required bool Function(IntVector2 position) isBlocked,
}) {
  final blockWidth = block.length;
  return [
    for (var column = 0; column + blockWidth <= gridWidth; column++)
      if (_fitsAt(block, column, isBlocked)) column,
  ];
}

bool _fitsAt(
  List<List<MathSingleBlock>> block,
  int column,
  bool Function(IntVector2 position) isBlocked,
) {
  for (var x = 0; x < block.length; x++) {
    for (var y = 0; y < block[x].length; y++) {
      if (block[x][y] is NullBlock) {
        continue;
      }
      if (isBlocked(IntVector2(column + x, y))) {
        return false;
      }
    }
  }
  return true;
}
