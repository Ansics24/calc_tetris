import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:calc_tetris/core/solution/solution_strategy_singlerun_result.dart';

abstract interface class SolutionStrategy {
  SolutionStrategySinglerunResult execute(
    GridModel gridModel, {
    required List<IntVector2> triggeringPositions,
  });
}
