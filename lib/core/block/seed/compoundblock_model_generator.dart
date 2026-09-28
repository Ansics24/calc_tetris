import 'dart:math';

import 'package:calc_tetris/core/block/math_number_block_component.dart';
import 'package:calc_tetris/core/block/math_single_block_component.dart';

class CompoundblockModelGenerator {
  List<List<MathSingleBlockComponent>> generate() {
    final compoundBlockModel = List.generate(
      3,
      (_) => List.generate(
        2,
        (i) => MathNumberBlockComponent(
          number: Random().nextInt(9),
        ),
      ),
    );
    return compoundBlockModel;
  }
}
