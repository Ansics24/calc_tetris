import 'package:magic_blocks/block/solution_strategy_singlerun_result.dart';
import 'package:magic_blocks/grid/model/grid_model.dart';
import 'package:magic_blocks/util/int_vector_2.dart';

abstract interface class SolutionStrategy {
  SolutionStrategySinglerunResult execute(
    GridModel gridModel, {
    required List<IntVector2> triggeringPositions,
  });
}
