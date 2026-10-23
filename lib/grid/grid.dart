import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:calc_tetris/block/math/scoring/score_keeper.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/math/seed/spawn_origin.dart';
import 'package:calc_tetris/block/single_block_component_factory.dart';
import 'package:calc_tetris/block/solution_strategy.dart';
import 'package:calc_tetris/grid/grid_controller.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/grid/queries/grid_content_holder.dart';
import 'package:calc_tetris/grid/visuals/grid_frame.dart';
import 'package:calc_tetris/grid/visuals/grid_line.dart';
import 'package:calc_tetris/layout/board/block_board.dart';
import 'package:calc_tetris/screens/gameover/game_over_listener.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:flame/components.dart';

class Grid extends PositionComponent {
  final IntVector2 _blockCount;
  double _cellSize = 0;
  late final GridModel _gridModel;
  late final GridController _gridController;

  Grid({
    required this._blockCount,
    required SolutionStrategy solutionStrategy,
    required NextBlockPlanner nextBlockPlanner,
    required SingleBlockComponentFactory singleBlockComponentFactory,
    GridContentHolder? gridContentHolder,
    SpawnOrigin? spawnOrigin,
    ScoreRecorder? scoreRecorder,
    GameOverListener? gameOverListener,
  }) {
    _gridModel = GridModel(
      size: _blockCount,
      gridComponent: this,
    );
    gridContentHolder?.attach(_gridModel);
    _gridController = GridController(
      gridModel: _gridModel,
      grid: this,
      solutionStrategy: solutionStrategy,
      nextBlockPlanner: nextBlockPlanner,
      singleBlockComponentFactory: singleBlockComponentFactory,
      spawnOrigin: spawnOrigin,
      scoreRecorder: scoreRecorder,
      gameOverListener: gameOverListener,
    );
  }

  @override
  FutureOr<void> onLoad() {
    var boardSize = findParent<BlockBoard>()!.size;

    final double calcCellSizeBasedOnY = boardSize.y / _blockCount.y;
    final double calcCellSizeBasedOnX = boardSize.x / _blockCount.x;
    _cellSize = min(calcCellSizeBasedOnX, calcCellSizeBasedOnY);
    _gridModel.cellSize = _cellSize;

    position.x = (boardSize.x - (_cellSize * _blockCount.x)) / 2;
    position.y = (boardSize.y - (_cellSize * _blockCount.y)) / 2;

    dev.log('Cell based on x: $calcCellSizeBasedOnX');
    dev.log('Cell based on y: $calcCellSizeBasedOnY');
    dev.log('Cell size used: $_cellSize');
    dev.log('BoardSize: $boardSize');
    dev.log('Position of Grid: $position');

    addGridVisualization();

    _gridController.spawnNextBlock();

    return super.onLoad();
  }

  void addGridVisualization() {
    add(
      GridFrame(
        size: Vector2(_blockCount.x * _cellSize, _blockCount.y * _cellSize),
      ),
    );
    for (var i = 0; i <= _blockCount.x; i++) {
      add(
        GridLine(
          Vector2(
            i * _cellSize,
            0,
          ),
          Vector2(
            i * _cellSize,
            _blockCount.y * _cellSize,
          ),
        ),
      );
    }
    for (var i = 0; i <= _blockCount.y; i++) {
      add(
        GridLine(
          Vector2(
            0,
            i * _cellSize,
          ),
          Vector2(_blockCount.x * _cellSize, i * _cellSize),
        ),
      );
    }
  }

  double get cellSize => _cellSize;

  IntVector2 get gridSize =>
      IntVector2(_gridModel.model.length, _gridModel.model[0].length);

  GridController get controller => _gridController;
}
