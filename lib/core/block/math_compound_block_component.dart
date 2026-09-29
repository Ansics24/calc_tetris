import 'dart:developer' as developer;

import 'package:calc_tetris/core/block/exceptions/no_matching_block_component_exception.dart';
import 'package:calc_tetris/core/block/math_block_component.dart';
import 'package:calc_tetris/core/block/math_number_block_component.dart';
import 'package:calc_tetris/core/block/math_operant_block_component.dart';
import 'package:calc_tetris/core/block/math_single_block_component.dart';
import 'package:calc_tetris/core/block/model/math_number_block.dart';
import 'package:calc_tetris/core/block/model/math_operant_block.dart';
import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/image_composition.dart';
import 'package:uuid/uuid.dart';

class MathCompoundBlockComponent extends MathBlockComponent
    with TapCallbacks, DragCallbacks {
  late List<List<MathSingleBlock>> _model;
  final Map<Uuid, MathSingleBlockComponent> _components = {};
  late double _cellSize;

  MathCompoundBlockComponent(this._model);

  @override
  void onLoad() async {
    await super.onLoad();
    _cellSize = findParent<Grid>()!.cellSize;
    for (var i = 0; i < _model.length; i++) {
      for (var j = 0; j < _model[i].length; j++) {
        var blockModel = _model[i][j];
        final component = newComponentFromBlockModel(blockModel);
        _components.addAll({blockModel.id: component});
        add(component);
      }
    }
    updateSingleBlockPositions(withAnimation: false);
  }

  MathSingleBlockComponent newComponentFromBlockModel(
    MathSingleBlock blockModel,
  ) {
    if (blockModel is MathNumberBlock) {
      return MathNumberBlockComponent(model: blockModel);
    }
    if (blockModel is MathOperantBlock) {
      return MathOperantBlockComponent(model: blockModel);
    }
    throw NoMatchingBlockComponentException();
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    developer.log('Local position of tap: ${event.localPosition}');
    if (event.localPosition.x < size.x / 2) {
      rotateCounterClockwise();
      developer.log('Rotated counter clockwise');
    } else {
      rotateClockwise();
      developer.log('Rotated clockwise');
    }
  }

  void rotateCounterClockwise() {
    final numberOfRows = _model.length;
    final numberOfCols = _model[0].length;
    _model = List.generate(
      numberOfCols,
      (i) => List.generate(
        numberOfRows,
        (j) => _model[numberOfRows - 1 - j][i],
      ),
    );
    updateSingleBlockPositions();
  }

  void rotateClockwise() {
    _model = List.generate(
      _model[0].length,
      (i) => List.generate(
        _model.length,
        (j) => _model[j][_model[0].length - 1 - i],
      ),
    );
    updateSingleBlockPositions();
  }

  void updateSingleBlockPositions({bool withAnimation = true}) {
    for (var i = 0; i < _model.length; i++) {
      for (var j = 0; j < _model[i].length; j++) {
        final blockModel = _model[i][j];
        var component = componentForSingleBlockModel(blockModel);
        component?.add(
          MoveToEffect(
            Vector2(
              _cellSize * i,
              _cellSize * j,
            ),
            EffectController(duration: withAnimation ? 0.3 : 0),
          ),
        );
      }
    }
    size = Vector2(
      _model.length * _cellSize,
      _model[0].length * _cellSize,
    );
  }

  MathSingleBlockComponent? componentForSingleBlockModel(
    MathSingleBlock model,
  ) => _components[model.id];

  List<IntVector2> get lowestLocalSingleBlockPositions =>
      List.generate(_model.length, (x) => IntVector2(x, _model[x].length));

  List<List<MathSingleBlock>> get model => _model;
}
