import 'dart:math';
import 'dart:developer' as dev;

import 'package:calc_tetris/core/block/math_compound_block.dart';
import 'package:calc_tetris/core/block/math_number_block_component.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class GridController {
  final GridModel _gridModel;
  final Grid _grid;
  MathCompoundBlock? currentBlock;
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

  void startNewBlock(MathCompoundBlock block, IntVector2 startPosition) {
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
    final compoundBlockModel = List.generate(
      3,
      (_) => List.generate(
        2,
        (i) => MathNumberBlockComponent(
          number: Random().nextInt(9),
          gridQueryable: _gridModel,
        ),
      ),
    );

    startNewBlock(
      MathCompoundBlock(
        compoundBlockModel,
        gridQueryable: _gridModel,
      ),
      IntVector2(3, 0),
    );
  }
}
