import 'package:calc_tetris/block/math/math_equals_block_component.dart';
import 'package:calc_tetris/block/math/math_number_block_component.dart';
import 'package:calc_tetris/block/math/math_operant_block_component.dart';
import 'package:calc_tetris/block/math/model/math_equals_block.dart';
import 'package:calc_tetris/block/math/model/math_number_block.dart';
import 'package:calc_tetris/block/math/model/math_operant_block.dart';
import 'package:calc_tetris/block/math/model/math_operant_type.dart';
import 'package:calc_tetris/grid/model/grid_model.dart';
import 'package:calc_tetris/util/int_vector_2.dart';

import '../../../support/test_grid.dart';

void addNumber(IntVector2 position, int number, GridModel gridModel) {
  gridModel.addSingleBlock(
    "pid${position.x}_${position.y}",
    MathNumberBlockComponent(model: MathNumberBlock(number: number)),
    position,
  );
}

void addPlus(IntVector2 position, GridModel gridModel) {
  gridModel.addSingleBlock(
    "pid${position.x}_${position.y}",
    MathOperantBlockComponent(
      model: MathOperantBlock(type: MathOperandType.plus),
    ),
    position,
  );
}

void addMinus(IntVector2 position, GridModel gridModel) {
  gridModel.addSingleBlock(
    "pid${position.x}_${position.y}",
    MathOperantBlockComponent(
      model: MathOperantBlock(type: MathOperandType.minus),
    ),
    position,
  );
}

void addEquals(IntVector2 position, GridModel gridModel) {
  gridModel.addSingleBlock(
    "pid${position.x}_${position.y}",
    MathEqualsBlockComponent(
      model: MathEqualsBlock(),
    ),
    position,
  );
}

/// A [GridModel] of the given size without any block.
GridModel newEmptyGridModel(IntVector2 size) {
  final gridModel = GridModel(size: size, gridComponent: newTestGrid(size));
  gridModel.cellSize = 0;
  return gridModel;
}
