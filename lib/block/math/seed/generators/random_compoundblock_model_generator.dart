import 'dart:math';

import 'package:calc_tetris/block/math/model/math_equals_block.dart';
import 'package:calc_tetris/block/math/model/math_number_block.dart';
import 'package:calc_tetris/block/math/model/math_operant_block.dart';
import 'package:calc_tetris/block/math/model/math_operant_type.dart';
import 'package:calc_tetris/block/math/model/math_single_block.dart';
import 'package:calc_tetris/block/math/seed/compoundblock_model_generator.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/block/shapes/shape_chooser.dart';

class RandomCompoundblockModelGenerator implements CompoundblockModelGenerator {
  final ShapeChooser _shapeChooser = ShapeChooser();

  @override
  List<List<SingleBlock>> generate() {
    var nextShape = _shapeChooser.next();

    final maskedModel = nextShape.maskedModel;
    final compoundBlockModel = List.generate(
      maskedModel.length,
      (x) => List.generate(
        maskedModel[x].length,
        (y) => maskedModel[x][y] ?? generateRandomBlock(),
      ),
    );
    return compoundBlockModel;
  }

  MathSingleBlock generateRandomBlock() {
    var random = Random();
    var randomInt = random.nextInt(100);
    if (randomInt < 60) {
      return MathNumberBlock(number: random.nextInt(3));
    }
    if (randomInt < 80) {
      return MathOperantBlock(
        type: random.nextBool() ? MathOperandType.plus : MathOperandType.minus,
      );
    }
    return MathEqualsBlock();
  }
}
