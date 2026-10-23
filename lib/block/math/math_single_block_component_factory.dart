import 'package:calc_tetris/block/math/exceptions/no_matching_block_component_exception.dart';
import 'package:calc_tetris/block/math/math_equals_block_component.dart';
import 'package:calc_tetris/block/math/math_number_block_component.dart';
import 'package:calc_tetris/block/math/math_operant_block_component.dart';
import 'package:calc_tetris/block/math/model/math_equals_block.dart';
import 'package:calc_tetris/block/math/model/math_number_block.dart';
import 'package:calc_tetris/block/math/model/math_operant_block.dart';
import 'package:calc_tetris/block/model/null_block.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/block/single_block_component.dart';

/// Creates the component for a single block model, or null if the model
/// stands for an empty cell. Without a [cellSize] the component takes the
/// cell size of its [Grid] parent.
SingleBlockComponent? newComponentFromBlockModel(
  SingleBlock model, {
  double? cellSize,
}) {
  if (model is MathNumberBlock) {
    return MathNumberBlockComponent(model: model, cellSize: cellSize);
  }
  if (model is MathOperantBlock) {
    return MathOperantBlockComponent(model: model, cellSize: cellSize);
  }
  if (model is MathEqualsBlock) {
    return MathEqualsBlockComponent(model: model, cellSize: cellSize);
  }
  if (model is NullBlock) {
    return null;
  }
  throw NoMatchingBlockComponentException();
}
