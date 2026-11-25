import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

/// What the outside of a grid asks its controller to do. The game mode decides
/// which controller a grid gets, so every mode can bring its own rules.
abstract interface class GridController {
  void onBlockDraggedLeft();

  void onBlockDraggedRight();

  void onBlockDraggedUp();

  void onBlockDraggedDown();

  /// The player tapped the grid cell [cell].
  void onCellTapped(IntVector2 cell);

  /// Puts the block the player controls into the grid where it stands. Returns
  /// true if the block starts to land, false if there is nothing to place
  /// right now.
  bool placeCurrentBlock();

  /// Brings the next block into the grid. Called once when the grid is loaded
  /// to start the game.
  void spawnNextBlock();
}

/// Creates the controller of a grid. The grid hands over its model and itself,
/// because the controller works on both.
typedef GridControllerFactory =
    GridController Function(GridModel gridModel, Grid grid);
