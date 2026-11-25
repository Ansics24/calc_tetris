import 'dart:developer' as dev;
import 'dart:math';

import 'package:calc_tetris/block/block_component.dart';
import 'package:calc_tetris/block/compound_block_component.dart';
import 'package:calc_tetris/block/math/scoring/score_keeper.dart';
import 'package:calc_tetris/block/math/seed/free_spawn_positions.dart';
import 'package:calc_tetris/block/math/seed/next_block_planner.dart';
import 'package:calc_tetris/block/math/seed/spawn_origin.dart';
import 'package:calc_tetris/block/math/seed/spawn_position_chooser.dart';
import 'package:calc_tetris/block/single_block_component_factory.dart';
import 'package:calc_tetris/block/solution_strategy.dart';
import 'package:calc_tetris/block/solution_strategy_executor.dart';
import 'package:calc_tetris/block/solution_strategy_singlerun_result.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/grid_behaviour_settings.dart';
import 'package:calc_tetris/grid/grid_controller.dart';
import 'package:calc_tetris/grid/grid_round_listener.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/grid/play_mode.dart';
import 'package:calc_tetris/grid/power_up_found_listener.dart';
import 'package:calc_tetris/grid/queries/position_in_grid_aware.dart';
import 'package:calc_tetris/screens/gameover/game_over_listener.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class EndlessGameGridController implements GridController, PositionInGridAware {
  /// How likely the player finds a power-up whenever a block solved
  /// equations.
  static const Map<PowerUpType, double> defaultPowerUpFindChances = {
    PowerUpType.cannon: 0.2,
  };

  final GridModel _gridModel;
  final Grid _grid;
  final SolutionStrategy _solutionStrategy;
  final SingleBlockComponentFactory _singleBlockComponentFactory;
  final ScoreRecorder? _scoreRecorder;

  final NextBlockPlanner _nextBlockPlanner;
  final SpawnPositionChooser _spawnPositionChooser;
  SpawnOrigin? _spawnOrigin;
  CompoundBlockComponent? currentBlock;
  IntVector2? currentBlockGridPosition;

  /// True while the new block flies from the preview into the grid. It can
  /// not be controlled until it has arrived.
  bool _spawning = false;

  /// True from the moment the block starts to land until it is in the grid.
  bool _landing = false;

  /// True once the upcoming block found no room. The controller does nothing
  /// from then on.
  bool _gameOver = false;
  final GameOverListener? _gameOverListener;
  final GridRoundListener? _roundListener;
  final bool _spawnNextBlockAfterRound;
  final PowerUpFoundListener? _powerUpFoundListener;
  final Map<PowerUpType, double> _powerUpFindChances;
  final Random _random;

  /// Points earned since the last block landed.
  int _roundPoints = 0;

  bool get isGameOver => _gameOver;

  PlayMode _playMode = const PlayMode.defaultMode();

  PlayMode get playMode => _playMode;

  /// While a power-up is in use the current block stands still: it can not be
  /// moved, rotated or placed, and it is drawn half transparent.
  set playMode(PlayMode mode) {
    _playMode = mode;
    _applyPlayMode();
  }

  void _applyPlayMode() {
    final inUse = _playMode.isPowerUpInUse;
    currentBlock
      ?..isLocked = inUse
      ..opacity = inUse ? 0.2 : 1;
  }

  /// Where new blocks fly in from. Can be set once the origin exists, which
  /// may be later than the controller.
  set spawnOrigin(SpawnOrigin? origin) => _spawnOrigin = origin;

  EndlessGameGridController({
    required this._gridModel,
    required this._grid,
    required this._solutionStrategy,
    required this._nextBlockPlanner,
    required this._singleBlockComponentFactory,
    SpawnPositionChooser? spawnPositionChooser,
    this._spawnOrigin,
    this._scoreRecorder,
    this._gameOverListener,
    this._roundListener,
    this._spawnNextBlockAfterRound = true,
    this._powerUpFoundListener,
    Map<PowerUpType, double>? powerUpFindChances,
    Random? random,
  }) : _spawnPositionChooser =
           spawnPositionChooser ?? RandomSpawnPositionChooser(),
       _powerUpFindChances = _checkedChances(
         powerUpFindChances ?? defaultPowerUpFindChances,
       ),
       _random = random ?? Random();

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

  /// Starts the landing. Returns false if the block is landing already.
  bool landCurrentBlockOnGrid() {
    if (_landing) {
      return false;
    }
    _landing = true;
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
    return true;
  }

  void onBlockLanded() {
    var newPositions = _gridModel.addCompoundBlock(
      blockComponent: currentBlock!,
      position: currentBlockGridPosition!,
    );
    currentBlock!.removeFromParent();
    currentBlock = null;
    currentBlockGridPosition = null;
    _landing = false;

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
    _roundPoints += result.pointsEarned;
    _scoreRecorder?.add(result.pointsEarned);
    if (result.pointsEarned > 0) {
      _findPowerUps(result);
    }
  }

  /// Rolls the dice for every kind of power-up and reports the ones found.
  void _findPowerUps(SolutionStrategySinglerunResult result) {
    final listener = _powerUpFoundListener;
    if (listener == null) {
      return;
    }
    final foundPosition = _absoluteCenterOf(result);
    for (final entry in _powerUpFindChances.entries) {
      if (_random.nextDouble() < entry.value) {
        listener.onPowerUpFound(entry.key, foundPosition);
      }
    }
  }

  /// The on-screen center of the solved blocks. The blocks are already
  /// shrunk away at this point, so it is worked out from their positions in
  /// the grid. Without blocks it is the center of the grid.
  Vector2 _absoluteCenterOf(SolutionStrategySinglerunResult result) {
    final blocks = result.solvedBlocks.toList();
    if (blocks.isEmpty) {
      return _grid.absoluteCenter;
    }
    final sum = blocks.fold(
      Vector2.zero(),
      (sum, block) => sum + block.component.position,
    );
    final center = sum / blocks.length.toDouble();
    return _grid.absolutePositionOf(center + Vector2.all(_grid.cellSize / 2));
  }

  static Map<PowerUpType, double> _checkedChances(
    Map<PowerUpType, double> chances,
  ) {
    for (final entry in chances.entries) {
      if (entry.value < 0 || entry.value > 1) {
        throw ArgumentError.value(
          entry.value,
          'powerUpFindChances[${entry.key.name}]',
          'must be between 0 and 1',
        );
      }
    }
    return chances;
  }

  void onStrategyDone() {
    dev.log("Solution strategy executor done");
    final points = _roundPoints;
    _roundPoints = 0;
    _roundListener?.onRoundFinished(points);
    if (_spawnNextBlockAfterRound) {
      spawnNextBlock();
    }
  }

  void startNewBlock(
    CompoundBlockComponent block,
    IntVector2 startPosition,
  ) {
    currentBlock = block;
    currentBlockGridPosition = startPosition;
    _applyPlayMode();

    final targetPosition = _gridModel.gridPositionToAbsolutePosition(
      startPosition,
    );
    final spawnOrigin = _spawnOrigin;
    if (spawnOrigin == null) {
      block.position = targetPosition;
      _grid.add(block);
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
        onComplete: () => _spawning = false,
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

  /// Takes the planned block, puts it at a free position (preferably at a
  /// border of the grid) and plans the next one. The game is over when the
  /// block fits nowhere.
  @override
  void spawnNextBlock() {
    if (_gameOver) {
      return;
    }
    final freePositions = freeSpawnPositions(
      block: _nextBlockPlanner.upcoming,
      gridModel: _gridModel,
    );
    if (freePositions.isEmpty) {
      _gameOver = true;
      _gameOverListener?.onGameOver();
      return;
    }

    final blockModel = _nextBlockPlanner.take();
    final startPosition = _spawnPositionChooser.choose(freePositions);

    startNewBlock(
      CompoundBlockComponent(
        blockModel,
        gridModelAware: _gridModel,
        positionInGridAware: this,
        singleBlockComponentFactory: _singleBlockComponentFactory,
      ),
      startPosition,
    );
  }

  @override
  void onBlockDraggedRight() => _moveBlockHorizontally(1);

  @override
  void onBlockDraggedLeft() => _moveBlockHorizontally(-1);

  void _moveBlockHorizontally(int deltaX) {
    if (_spawning || currentBlock == null || _playMode.isPowerUpInUse) {
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

  /// Moves the block one cell down on player request. A blocked
  /// block does not land.
  @override
  void onBlockDraggedDown() => _moveBlockVertically(1);

  @override
  void onBlockDraggedUp() => _moveBlockVertically(-1);

  void _moveBlockVertically(int deltaY) {
    if (_spawning || currentBlock == null || _playMode.isPowerUpInUse) {
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

  /// Puts the block into the grid exactly where it stands now. Returns true if
  /// the block starts to land, false if there is nothing to place right now
  /// (no block, still flying in, or already landing).
  @override
  bool placeCurrentBlock() {
    if (_spawning || currentBlock == null || _playMode.isPowerUpInUse) {
      return false;
    }
    return landCurrentBlockOnGrid();
  }

  @override
  IntVector2? positionInGrid(BlockComponent component) {
    if (component != currentBlock) {
      return null;
    }
    return currentBlockGridPosition;
  }
}
