import 'package:calc_tetris/grid/model/grid_single_block_model.dart';

class SolutionStrategySinglerunResult {
  final Iterable<GridSingleBlockModel> solvedBlocks;
  final int pointsEarned;

  SolutionStrategySinglerunResult.empty()
    : solvedBlocks = List.empty(),
      pointsEarned = 0;

  SolutionStrategySinglerunResult({
    required this.solvedBlocks,
    required this.pointsEarned,
  });

  bool get hasSolvedBlocks => solvedBlocks.isNotEmpty;

  @override
  toString() {
    return "solvedBlocks: $solvedBlocks, pointsEarned: $pointsEarned)";
  }
}
