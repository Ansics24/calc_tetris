import 'dart:developer' as dev;

import 'package:calc_tetris/block/block_component.dart';
import 'package:calc_tetris/block/compound_block_component.dart';
import 'package:calc_tetris/block/math/scoring/score_keeper.dart';
import 'package:calc_tetris/block/math/seed/free_start_columns.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/math/seed/spawn_origin.dart';
import 'package:calc_tetris/block/math/seed/start_column_chooser.dart';
import 'package:calc_tetris/block/single_block_component_factory.dart';
import 'package:calc_tetris/block/solution_strategy.dart';
import 'package:calc_tetris/block/solution_strategy_executor.dart';
import 'package:calc_tetris/block/solution_strategy_singlerun_result.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/grid_behaviour_settings.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/grid/queries/position_in_grid_aware.dart';
import 'package:calc_tetris/grid/queries/position_in_grid_finder.dart';
import 'package:calc_tetris/screens/gameover/game_over_listener.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class GridController implements PositionInGridAware {
  final GridModel _gridModel;
  final PositionInGridFinder _positionInGridFinder;
  final Grid _grid;
  final SolutionStrategy _solutionStrategy;
  final SingleBlockComponentFactory _singleBlockComponentFactory;
  final ScoreRecorder? _scoreRecorder;

  final NextBlockPlanner _nextBlockPlanner;
  final StartColumnChooser _startColumnChooser;
  final SpawnOrigin? _spawnOrigin;
  CompoundBlockComponent? currentBlock;
  IntVector2? currentBlockGridPosition;

  /// True while the new block flies from the preview into the grid. It can
  /// not be controlled and does not fall until it has arrived.
  bool _spawning = false;

  /// True once the upcoming block found no room. The controller does nothing
  /// from then on.
  bool _gameOver = false;
  final GameOverListener? _gameOverListener;

  bool get isGameOver => _gameOver;

  GridController({
    required this._gridModel,
    required this._grid,
    required this._solutionStrategy,
    required this._nextBlockPlanner,
    required this._singleBlockComponentFactory,
    StartColumnChooser? startColumnChooser,
    this._spawnOrigin,
    this._scoreRecorder,
    this._gameOverListener,
  }) : _startColumnChooser = startColumnChooser ?? RandomStartColumnChooser(),
       _positionInGridFinder = PositionInGridFinder(gridModel: _gridModel);

  void moveBlockDownByOne() {
    if (currentBlock == null) {
      return;
    }

    final anyTargetBlocked = anyTargetPositionBlockedFromCurrentLocation(
      (vector) => vector.addY(1),
    );

    if (anyTargetBlocked) {
      dev.log('Cant move block down. Its blocked');
      landCurrentBlockOnGrid();
      return;
    }

    currentBlockGridPosition = currentBlockGridPosition!.addY(1);
    onPositionUpdated();
  }

  bool anyTargetPositionBlockedFromCurrentLocation(
    IntVector2 Function(IntVector2) posMapper,
  ) {
    return _gridModel.anyPositionBlocked(
      currentBlock!
          .getLocalSingleBlockPositions()
          .map(
            (vector) => vector.add(
              currentBlockGridPosition!.x,
              currentBlockGridPosition!.y,
            ),
          )
          .map(posMapper),
    );
  }

  void onPositionUpdated({bool withAnimation = true}) {
    final targetPosition = _gridModel.gridPositionToAbsolutePosition(
      currentBlockGridPosition!,
    );

    // A running effect targets an outdated column and would pull the block
    // back, so it must never overlap with a newer position update.
    currentBlock!.children.whereType<MoveToEffect>().toList().forEach(
      (effect) => effect.removeFromParent(),
    );

    if (withAnimation) {
      currentBlock!.add(
        MoveToEffect(targetPosition, EffectController(duration: 0.2)),
      );
    } else {
      currentBlock!.position = targetPosition;
    }
  }

  void landCurrentBlockOnGrid() {
    currentBlock!.add(
      ScaleEffect.by(
        Vector2.all(1.3),
        EffectController(duration: 0.2),
        onComplete: () => currentBlock!.add(
          ScaleEffect.to(
            Vector2.all(1),
            EffectController(duration: 0.2),
            onComplete: onBlockLanded,
          ),
        ),
      ),
    );
  }

  void onBlockLanded() {
    var newPositions = _gridModel.addCompoundBlock(
      blockComponent: currentBlock!,
      position: currentBlockGridPosition!,
    );
    currentBlock!.removeFromParent();
    currentBlock = null;
    currentBlockGridPosition = null;

    final executor = SolutionStrategyExecutor(
      solutionStrategy: _solutionStrategy,
      gridModel: _gridModel,
    );
    executor.streamOfResults().listen(
      onStrategyResult,
      onError: (error) => dev.log("Solution strategy executor error: $error"),
      onDone: onStrategyDone,
    );
    executor.runWithTriggeringPositions(newPositions);
  }

  void onStrategyResult(SolutionStrategySinglerunResult result) async {
    dev.log("Got result from solution strategy executor: $result");
    _scoreRecorder?.add(result.pointsEarned);
  }

  void onStrategyDone() {
    dev.log("Solution strategy executor done");
    spawnNextBlock();
  }

  void startNewBlock(
    CompoundBlockComponent block,
    IntVector2 startPosition,
  ) {
    currentBlock = block;
    currentBlockGridPosition = startPosition;

    final targetPosition = _gridModel.gridPositionToAbsolutePosition(
      startPosition,
    );
    final spawnOrigin = _spawnOrigin;
    if (spawnOrigin == null) {
      block.position = targetPosition;
      _grid.add(block);
      _startFalling(block);
      return;
    }

    block.position = _grid.absoluteToLocal(spawnOrigin.absoluteTopLeft);
    block.scale = Vector2.all(spawnOrigin.cellSize / _grid.cellSize);
    _grid.add(block);
    _spawning = true;
    final spawnController = EffectController(
      duration: spawnDurationInSeconds,
      curve: Curves.easeInOutCubic,
    );
    block.add(
      MoveToEffect(
        targetPosition,
        spawnController,
        onComplete: () {
          _spawning = false;
          _startFalling(block);
        },
      ),
    );
    block.add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(
          duration: spawnDurationInSeconds,
          curve: Curves.easeInOutCubic,
        ),
      ),
    );
  }

  void _startFalling(CompoundBlockComponent block) {
    if (!blockFallsDownAutomatically) {
      return;
    }
    block.add(
      TimerComponent(
        period: durationForBlockToMoveDownInSeconds,
        repeat: true,
        onTick: () {
          moveBlockDownByOne();
        },
      ),
    );
  }

  /// Takes the planned block, puts it into a random column at the top of the
  /// grid and plans the next one.
  void spawnNextBlock() {
    if (_gameOver) {
      return;
    }
    final freeColumns = freeStartColumns(
      block: _nextBlockPlanner.upcoming,
      gridWidth: _gridModel.model.length,
      isBlocked: _gridModel.isPositionBlocked,
    );
    if (freeColumns.isEmpty) {
      _gameOver = true;
      _gameOverListener?.onGameOver();
      return;
    }

    final blockModel = _nextBlockPlanner.take();
    final column = _startColumnChooser.choose(
      blockWidth: blockModel.length,
      gridWidth: _gridModel.model.length,
      candidates: freeColumns,
    );

    startNewBlock(
      CompoundBlockComponent(
        blockModel,
        gridModelAware: _gridModel,
        positionInGridAware: this,
        singleBlockComponentFactory: _singleBlockComponentFactory,
      ),
      IntVector2(column, 0),
    );
  }

  void moveBlockRight() => _moveBlockHorizontally(1);

  void moveBlockLeft() => _moveBlockHorizontally(-1);

  void _moveBlockHorizontally(int deltaX) {
    if (_spawning || currentBlock == null) {
      return;
    }
    if (anyTargetPositionBlockedFromCurrentLocation(
      (vector) => vector.addX(deltaX),
    )) {
      dev.log("Dont move block horizontally by $deltaX, it's blocked");
      return;
    }
    currentBlockGridPosition = currentBlockGridPosition!.addX(deltaX);
    onPositionUpdated(withAnimation: false);
  }

  /// Moves the block one cell down on player request. Unlike
  /// [moveBlockDownByOne] a blocked block does not land.
  void moveBlockDown() => _moveBlockVertically(1);

  void moveBlockUp() => _moveBlockVertically(-1);

  void _moveBlockVertically(int deltaY) {
    if (_spawning || currentBlock == null) {
      return;
    }
    if (anyTargetPositionBlockedFromCurrentLocation(
      (vector) => vector.addY(deltaY),
    )) {
      dev.log("Dont move block vertically by $deltaY, it's blocked");
      return;
    }
    currentBlockGridPosition = currentBlockGridPosition!.addY(deltaY);
    onPositionUpdated(withAnimation: false);
  }

  void fallBlockDown() {
    if (_spawning || currentBlock == null) {
      return;
    }
    var lowestPossiblePosition = _positionInGridFinder
        .findLowestPossiblePosition(
          currentBlockGridPosition!,
          currentBlock!,
        );
    if (lowestPossiblePosition == null) {
      dev.log("Block can't fall down. It's blocked");
      return;
    }
    dev.log("Block falls down to $lowestPossiblePosition");
    currentBlockGridPosition = lowestPossiblePosition;
    onPositionUpdated();
    landCurrentBlockOnGrid();
  }

  @override
  IntVector2? positionInGrid(BlockComponent component) {
    if (component != currentBlock) {
      return null;
    }
    return currentBlockGridPosition;
  }
}
