import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';

/// Gives access to the blocks of a grid that does not exist yet when the
/// holder is created. Until a grid is attached the content is empty.
class GridContentHolder {
  List<List<MathSingleBlock?>> Function() _source = () => [];

  /// The blocks of the grid, indexed `[x][y]`.
  List<List<MathSingleBlock?>> call() => _source();

  void attach(GridModel gridModel) {
    _source = () => [
      for (final column in gridModel.model)
        [for (final block in column) block?.component.model],
    ];
  }
}
