import 'dart:developer' as dev;
import 'dart:math';

import 'package:calc_tetris/core/block/math_compound_block_component.dart';
import 'package:calc_tetris/core/block/seed/generators/random_compoundblock_model_generator.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class GridController {
  final GridModel _gridModel;
  final Grid _grid;
  final RandomCompoundblockModelGenerator blockGenerator =
      RandomCompoundblockModelGenerator();
  MathCompoundBlockComponent? currentBlock;
  IntVector2? currentBlockGridPosition;

  GridController({required this._gridModel, required this._grid});

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

  void onPositionUpdated() {
    final targetPosition = _gridModel.gridPositionToAbsolutePosition(
      currentBlockGridPosition!,
    );

    currentBlock!.add(
      MoveToEffect(targetPosition, EffectController(duration: 0.2)),
    );
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
    _gridModel.addCompoundBlock(
      blockComponent: currentBlock!,
      position: currentBlockGridPosition!,
    );
    currentBlock!.removeFromParent();
    currentBlock = null;
    currentBlockGridPosition = null;

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
        period: 5.0,
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
    onPositionUpdated();
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
    onPositionUpdated();
  }
}
