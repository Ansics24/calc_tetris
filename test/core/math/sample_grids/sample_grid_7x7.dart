import 'package:calc_tetris/core/block/math_equals_block_component.dart';
import 'package:calc_tetris/core/block/math_number_block_component.dart';
import 'package:calc_tetris/core/block/math_operant_block_component.dart';
import 'package:calc_tetris/core/block/model/math_equals_block.dart';
import 'package:calc_tetris/core/block/model/math_number_block.dart';
import 'package:calc_tetris/core/block/model/math_operant_block.dart';
import 'package:calc_tetris/core/block/model/math_operant_type.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/grid_model.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';

/// Gridmodel looks like this
///
///+---+---+---+---+---+---+---+
///   |   |   |   |   |   | 7 |
///---+---+---+---+---+---+---+
///   | 2 |   |   |   |   | + |
///---+---+---+---+---+---+---+
/// 5 | + | 3 | = | 8 |   | 1 |
///---+---+---+---+---+---+---+
/// = | 4 | - |   |   |   | = |
///---+---+---+---+---+---+---+
///   | = |   |   |   |   | 9 |
///---+---+---+---+---+---+---+
///   | 6 | + |   |   |   | = |
///---+---+---+---+---+---+---+
///   |   | 9 | - | 4 | = | 6 |
///---+---+---+---+---+---+---+
GridModel get7x7SampleModel() {
  final GridModel gridModel = GridModel(
    size: IntVector2(7, 7),
    gridComponent: Grid(blockCount: IntVector2(0, 6)),
  );
  gridModel.cellSize = 0;
  _addNumber(IntVector2(6, 0), 7, gridModel);
  _addNumber(IntVector2(1, 1), 2, gridModel);
  _addNumber(IntVector2(0, 2), 5, gridModel);
  _addNumber(IntVector2(2, 2), 3, gridModel);
  _addNumber(IntVector2(4, 2), 8, gridModel);
  _addNumber(IntVector2(6, 2), 1, gridModel);
  _addNumber(IntVector2(1, 3), 4, gridModel);
  _addNumber(IntVector2(6, 4), 9, gridModel);
  _addNumber(IntVector2(1, 5), 6, gridModel);
  _addNumber(IntVector2(2, 6), 9, gridModel);
  _addNumber(IntVector2(4, 6), 4, gridModel);
  _addNumber(IntVector2(6, 6), 6, gridModel);

  _addPlus(IntVector2(6, 1), gridModel);
  _addPlus(IntVector2(1, 2), gridModel);
  _addPlus(IntVector2(2, 5), gridModel);

  _addMinus(IntVector2(3, 6), gridModel);
  _addMinus(IntVector2(2, 3), gridModel);

  _addEquals(IntVector2(0, 3), gridModel);
  _addEquals(IntVector2(3, 2), gridModel);
  _addEquals(IntVector2(6, 3), gridModel);
  _addEquals(IntVector2(1, 4), gridModel);
  _addEquals(IntVector2(5, 6), gridModel);
  _addEquals(IntVector2(6, 5), gridModel);

  return gridModel;
}

void _addNumber(IntVector2 position, int number, GridModel gridModel) {
  gridModel.addSingleBlock(
    "pid${position.x}_${position.y}",
    MathNumberBlockComponent(model: MathNumberBlock(number: number)),
    position,
  );
}

void _addPlus(IntVector2 position, GridModel gridModel) {
  gridModel.addSingleBlock(
    "pid${position.x}_${position.y}",
    MathOperantBlockComponent(
      model: MathOperantBlock(type: MathOperandType.plus),
    ),
    position,
  );
}

void _addMinus(IntVector2 position, GridModel gridModel) {
  gridModel.addSingleBlock(
    "pid${position.x}_${position.y}",
    MathOperantBlockComponent(
      model: MathOperantBlock(type: MathOperandType.minus),
    ),
    position,
  );
}

void _addEquals(IntVector2 position, GridModel gridModel) {
  gridModel.addSingleBlock(
    "pid${position.x}_${position.y}",
    MathEqualsBlockComponent(
      model: MathEqualsBlock(),
    ),
    position,
  );
}
