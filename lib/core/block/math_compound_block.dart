import 'dart:async';
import 'dart:developer';

import 'package:calc_tetris/core/block/math_block_component.dart';
import 'package:calc_tetris/core/block/math_block_model.dart';
import 'package:calc_tetris/core/block/math_number_block_component.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:flame/image_composition.dart';

class MathCompoundBlock extends MathBlockComponent {
  late List<List<MathBlockModel?>> _model;

  MathCompoundBlock() {
    _model = List.generate(
      3,
      (_) => List.generate(
        2,
        (i) => MathBlockModel(component: MathNumberBlockComponent(number: i)),
      ),
    );
  }

  @override
  void onLoad() async {
    await super.onLoad();
    var cellSize = findParent<Grid>()!.cellSize;
    size = Vector2(
      _model.length * cellSize,
      _model[0].length * cellSize,
    );

    log('Size of compound block: ${size.x} / ${size.y}');

    for (var i = 0; i < _model.length; i++) {
      for (var j = 0; j < _model[i].length; j++) {
        final blockModel = _model[i][j];
        if (blockModel != null) {
          var component = blockModel.component;
          component.position = Vector2(
            cellSize * i,
            cellSize * j,
          );
          add(component);
        }
      }
    }
  }
}
