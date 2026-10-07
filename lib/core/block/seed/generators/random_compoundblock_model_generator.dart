import 'dart:math';
import 'dart:developer' as dev;

import 'package:calc_tetris/core/block/model/math_equals_block.dart';
import 'package:calc_tetris/core/block/model/math_number_block.dart';
import 'package:calc_tetris/core/block/model/math_operant_block.dart';
import 'package:calc_tetris/core/block/model/math_operant_type.dart';
import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/core/block/seed/compoundblock_model_generator.dart';
import 'package:calc_tetris/core/block/seed/shape_chooser.dart';

class RandomCompoundblockModelGenerator implements CompoundblockModelGenerator {
  final ShapeChooser _shapeChooser = ShapeChooser();

  @override
  List<List<MathSingleBlock>> generate() {
    var nextShape = _shapeChooser.next();
    dev.log("Next shape is  $nextShape");

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
      return MathNumberBlock(number: random.nextInt(9));
    }
    if (randomInt < 80) {
      return MathOperantBlock(
        type: random.nextBool() ? MathOperandType.plus : MathOperandType.minus,
      );
    }
    return MathEqualsBlock();
  }
}
