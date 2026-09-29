import 'dart:developer' as dev;

import 'package:calc_tetris/core/block/math_compound_block_component.dart';
import 'package:calc_tetris/core/block/seed/compoundblock_model_generator.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class GridController {
  final GridModel _gridModel;
  final Grid _grid;
  final CompoundblockModelGenerator blockGenerator =
      CompoundblockModelGenerator();
  MathCompoundBlockComponent? currentBlock;
  IntVector2? currentBlockGridPosition;

  GridController({required this._gridModel, required this._grid});

  void moveBlockDownByOne() {
    if (currentBlock == null) {
      return;
    }

    final anyTargetBlocked = currentBlock!.lowestLocalSingleBlockPositions
        .map(
          (vector) => vector.add(
            currentBlockGridPosition!.x,
            currentBlockGridPosition!.y,
          ),
        )
        .map((vector) => _gridModel.isPositionBlocked(vector))
        .any((blocked) => blocked);

    if (anyTargetBlocked) {
      dev.log('Cant move block down. Its blocked');
      landCurrentBlockOnGrid();
      return;
    }

    currentBlockGridPosition = currentBlockGridPosition!.addY(1);
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
        period: 4.0,
        repeat: true,
        onTick: () {
          moveBlockDownByOne();
        },
      ),
    );
  }

  void addExperimentalStuff() {
    final newBlockModel = blockGenerator.generate();

    startNewBlock(
      MathCompoundBlockComponent(
        newBlockModel,
      ),
      IntVector2(3, 5),
    );
  }
}
