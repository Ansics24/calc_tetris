import 'dart:async';

import 'package:calc_tetris/core/block/seed/next_block_planner.dart';
import 'package:calc_tetris/core/block/seed/spawn_origin.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/queries/grid_content_holder.dart';
import 'package:calc_tetris/core/scoring/score_keeper.dart';
import 'package:calc_tetris/global/game_dimensions.dart';
import 'package:flame/components.dart';

class BlockBoard extends PositionComponent {
  final ScoreRecorder? _scoreRecorder;
  final NextBlockPlanner _nextBlockPlanner;
  final SpawnOrigin? _spawnOrigin;
  final GridContentHolder? _gridContentHolder;

  BlockBoard({
    this._scoreRecorder,
    required this._nextBlockPlanner,
    this._spawnOrigin,
    this._gridContentHolder,
    super.size,
    super.position,
  });

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    add(
      Grid(
        blockCount: GameDimensions.gridBlockCount,
        nextBlockPlanner: _nextBlockPlanner,
        gridContentHolder: _gridContentHolder,
        spawnOrigin: _spawnOrigin,
        scoreRecorder: _scoreRecorder,
      ),
    );
  }
}
