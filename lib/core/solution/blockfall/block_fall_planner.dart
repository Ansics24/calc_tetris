import 'package:calc_tetris/core/grid/block_move.dart';
import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/grid_single_block_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';

/// Calculates how blocks fall down column-wise after blocks were removed.
///
/// Falling blocks are:
/// * all blocks above a removed block in the same column
/// * all blocks sharing a placementId with a removed block
///
/// Each falling block drops independently, so formerly connected blocks
/// may be broken apart. The planner does not change the grid.
class BlockFallPlanner {
  List<BlockMove> plan(
    GridModel grid,
    Iterable<GridSingleBlockModel> removedBlocks,
  ) {
    final removed = removedBlocks.toSet();
    final removedPlacementIds = removed.map((b) => b.placementId).toSet();
    final model = grid.model;
    final columnCount = model.length;
    final rowCount = columnCount == 0 ? 0 : model[0].length;

    // Lowest removed row per column (null = nothing removed in the column).
    final lowestRemovedY = List<int?>.filled(columnCount, null);
    for (var x = 0; x < columnCount; x++) {
      for (var y = 0; y < rowCount; y++) {
        if (removed.contains(model[x][y])) {
          lowestRemovedY[x] = y;
        }
      }
    }

    final occupied = List.generate(
      columnCount,
      (_) => List<bool>.filled(rowCount, false),
    );
    final fallingByColumn = List.generate(
      columnCount,
      (_) => <_Falling>[],
    );

    for (var x = 0; x < columnCount; x++) {
      for (var y = 0; y < rowCount; y++) {
        final block = model[x][y];
        if (block == null || removed.contains(block)) {
          continue;
        }
        final removedY = lowestRemovedY[x];
        final isAboveRemoved = removedY != null && y < removedY;
        final isConnectedToRemoved = removedPlacementIds.contains(
          block.placementId,
        );
        if (isAboveRemoved || isConnectedToRemoved) {
          fallingByColumn[x].add(_Falling(block, y));
        } else {
          occupied[x][y] = true;
        }
      }
    }

    final moves = <BlockMove>[];
    for (var x = 0; x < columnCount; x++) {
      // Bottom-most blocks first, so blocks above can rest on them.
      for (final falling in fallingByColumn[x].reversed) {
        var targetY = falling.y;
        while (targetY + 1 < rowCount && !occupied[x][targetY + 1]) {
          targetY++;
        }
        occupied[x][targetY] = true;
        if (targetY != falling.y) {
          moves.add(
            BlockMove(
              block: falling.block,
              from: IntVector2(x, falling.y),
              to: IntVector2(x, targetY),
            ),
          );
        }
      }
    }
    return moves;
  }
}

class _Falling {
  final GridSingleBlockModel block;
  final int y;

  _Falling(this.block, this.y);
}
