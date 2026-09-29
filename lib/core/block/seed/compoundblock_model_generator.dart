import 'dart:math';

import 'package:calc_tetris/core/block/model/math_number_block.dart';
import 'package:calc_tetris/core/block/model/math_single_block.dart';

class CompoundblockModelGenerator {
  List<List<MathSingleBlock>> generate() {
    final compoundBlockModel = List.generate(
      3,
      (_) => List.generate(
        2,
        (i) => MathNumberBlock(number: Random().nextInt(9)),
      ),
    );
    return compoundBlockModel;
  }
}
