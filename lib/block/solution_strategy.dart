import 'package:calc_tetris/block/solution_strategy_singlerun_result.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

abstract interface class SolutionStrategy {
  SolutionStrategySinglerunResult execute(
    GridModel gridModel, {
    required List<IntVector2> triggeringPositions,
  });
}
