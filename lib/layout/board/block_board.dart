import 'dart:async';

import 'package:calc_tetris/block/math/scoring/score_keeper.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/math/seed/spawn_origin.dart';
import 'package:calc_tetris/block/single_block_component_factory.dart';
import 'package:calc_tetris/block/solution_strategy.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/queries/grid_content_holder.dart';
import 'package:calc_tetris/layout/game_dimensions.dart';
import 'package:calc_tetris/screens/gameover/game_over_listener.dart';
import 'package:flame/components.dart';

class BlockBoard extends PositionComponent {
  final ScoreRecorder? _scoreRecorder;
  final SolutionStrategy _solutionStrategy;
  final NextBlockPlanner _nextBlockPlanner;
  final SingleBlockComponentFactory _singleBlockComponentFactory;
  final SpawnOrigin? _spawnOrigin;
  final GridContentHolder? _gridContentHolder;
  final GameOverListener? _gameOverListener;
  late final Grid _grid;

  BlockBoard({
    this._scoreRecorder,
    required this._solutionStrategy,
    required this._nextBlockPlanner,
    required this._singleBlockComponentFactory,
    this._spawnOrigin,
    this._gridContentHolder,
    this._gameOverListener,
    super.size,
    super.position,
  });

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    _grid = Grid(
      blockCount: GameDimensions.gridBlockCount,
      solutionStrategy: _solutionStrategy,
      nextBlockPlanner: _nextBlockPlanner,
      singleBlockComponentFactory: _singleBlockComponentFactory,
      gridContentHolder: _gridContentHolder,
      spawnOrigin: _spawnOrigin,
      scoreRecorder: _scoreRecorder,
      gameOverListener: _gameOverListener,
    );
    add(_grid);
  }

  /// Lets the block currently controlled by the player fall down.
  void dropCurrentBlock() => _grid.controller.fallBlockDown();
}
