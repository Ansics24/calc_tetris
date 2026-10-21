import 'dart:developer' as dev;
import 'dart:math';

import 'package:calc_tetris/core/block/math_block_component.dart';
import 'package:calc_tetris/core/block/math_compound_block_component.dart';
import 'package:calc_tetris/core/block/seed/generators/random_compoundblock_model_generator.dart';
import 'package:calc_tetris/core/game_settings.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:calc_tetris/core/grid/queries/position_in_grid_aware.dart';
import 'package:calc_tetris/core/grid/queries/position_in_grid_finder.dart';
import 'package:calc_tetris/core/scoring/score_keeper.dart';
import 'package:calc_tetris/core/solution/solution_strategy.dart';
import 'package:calc_tetris/core/solution/solution_strategy_executor.dart';
import 'package:calc_tetris/core/solution/solution_strategy_singlerun_result.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class GridController implements PositionInGridAware {
  final GridModel _gridModel;
  final PositionInGridFinder _positionInGridFinder;
  final Grid _grid;
  final SolutionStrategy _solutionStrategy;
  final ScoreRecorder? _scoreRecorder;

  final RandomCompoundblockModelGenerator blockGenerator =
      RandomCompoundblockModelGenerator();
  MathCompoundBlockComponent? currentBlock;
  IntVector2? currentBlockGridPosition;

  GridController({
    required this._gridModel,
    required this._grid,
    required this._solutionStrategy,
    this._scoreRecorder,
  }) : _positionInGridFinder = PositionInGridFinder(gridModel: _gridModel);

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
    addExperimentalStuff();
  }

  void startNewBlock(
    MathCompoundBlockComponent block,
    IntVector2 startPosition,
  ) {
    currentBlock = block;
    currentBlockGridPosition = startPosition;

    currentBlock!.position = _gridModel.gridPositionToAbsolutePosition(
      startPosition,
    );
    _grid.add(currentBlock!);

    currentBlock!.add(
      TimerComponent(
        period: durationForBlockToMoveDownInSeconds,
        repeat: true,
        onTick: () {
          moveBlockDownByOne();
        },
      ),
    );
  }

  void addExperimentalStuff() {
    final newBlockModel = blockGenerator.generate();

    final random = Random();

    startNewBlock(
      MathCompoundBlockComponent(
        newBlockModel,
        gridModelAware: _gridModel,
        positionInGridAware: this,
      ),
      IntVector2(
        random.nextInt(
          max(_gridModel.model.length - 1 - newBlockModel.length, 0),
        ),
        5,
      ),
    );
  }

  void moveBlockRight() {
    var targetPosition = currentBlockGridPosition!.addX(1);
    if (anyTargetPositionBlockedFromCurrentLocation(
      (vector) => vector.addX(1),
    )) {
      dev.log("Dont move block right, it's blocked");
      return;
    }
    currentBlockGridPosition = targetPosition;
    onPositionUpdated(withAnimation: false);
  }

  void moveBlockLeft() {
    var targetPosition = currentBlockGridPosition!.addX(-1);
    if (anyTargetPositionBlockedFromCurrentLocation(
      (vector) => vector.addX(-1),
    )) {
      dev.log("Dont move block left, it's blocked");
      return;
    }
    currentBlockGridPosition = targetPosition;
    onPositionUpdated(withAnimation: false);
  }

  void fallBlockDown() {
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
  IntVector2? positionInGrid(MathBlockComponent component) {
    if (component != currentBlock) {
      return null;
    }
    return currentBlockGridPosition;
  }
}
