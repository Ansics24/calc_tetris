import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';

/// Gives access to the blocks of a grid that does not exist yet when the
/// holder is created. Until a grid is attached the content is empty.
class GridContentHolder {
  List<List<SingleBlock?>> Function() _source = () => [];

  /// The blocks of the grid, indexed `[x][y]`.
  List<List<SingleBlock?>> call() => _source();

  void attach(GridModel gridModel) {
    _source = () => [
      for (final column in gridModel.model)
        [for (final block in column) block?.component.model],
    ];
  }
}
