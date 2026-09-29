import 'dart:math';
import 'dart:developer' as dev;

import 'package:calc_tetris/core/block/model/math_number_block.dart';
import 'package:calc_tetris/core/block/model/math_operant_block.dart';
import 'package:calc_tetris/core/block/model/math_operant_type.dart';
import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/core/block/seed/shape_chooser.dart';

class CompoundblockModelGenerator {
  final ShapeChooser _shapeChooser = ShapeChooser();

  List<List<MathSingleBlock>> generate() {
    var nextShape = _shapeChooser.next();
    dev.log("Next shape is  $nextShape");

    final compoundBlockModel = List.generate(
      nextShape.outerSizeX,
      (_) => List.generate(
        nextShape.outerSizeY,
        (i) => (i % 2) == 0
            ? MathNumberBlock(number: Random().nextInt(9))
            : MathOperantBlock(type: MathOperandType.plus),
      ),
    );
    return compoundBlockModel;
  }
}
