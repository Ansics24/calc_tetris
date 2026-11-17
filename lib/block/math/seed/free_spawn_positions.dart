import 'package:calc_tetris/block/model/null_block.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

/// Returns the top left positions at which the block can enter the grid
/// without overlapping an already blocked cell. [block] is indexed `[x][y]`,
/// like the grid.
///
/// Positions touching a border of the grid are preferred. Only if none of them
/// is free, all other free positions inside the grid are returned. The result
/// is empty when the block fits nowhere.
List<IntVector2> freeSpawnPositions({
  required List<List<SingleBlock>> block,
  required GridModel gridModel,
}) {
  final gridWidth = gridModel.model.length;
  final gridHeight = gridWidth == 0 ? 0 : gridModel.model[0].length;
  final blockWidth = block.length;
  final blockHeight = blockWidth == 0 ? 0 : block[0].length;

  final atBorder = <IntVector2>[];
  final inside = <IntVector2>[];
  for (var x = 0; x + blockWidth <= gridWidth; x++) {
    for (var y = 0; y + blockHeight <= gridHeight; y++) {
      final position = IntVector2(x, y);
      if (!_fitsAt(block, position, gridModel)) {
        continue;
      }
      final touchesBorder =
          x == 0 ||
          y == 0 ||
          x + blockWidth == gridWidth ||
          y + blockHeight == gridHeight;
      (touchesBorder ? atBorder : inside).add(position);
    }
  }
  return atBorder.isNotEmpty ? atBorder : inside;
}

bool _fitsAt(
  List<List<SingleBlock>> block,
  IntVector2 position,
  GridModel gridModel,
) {
  for (var x = 0; x < block.length; x++) {
    for (var y = 0; y < block[x].length; y++) {
      if (block[x][y] is NullBlock) {
        continue;
      }
      if (gridModel.isPositionBlocked(position.add(x, y))) {
        return false;
      }
    }
  }
  return true;
}
