import 'dart:developer' as developer;

import 'package:calc_tetris/core/block/math_block_component.dart';
import 'package:calc_tetris/core/block/math_number_block_component.dart';
import 'package:calc_tetris/core/block/math_operant_block_component.dart';
import 'package:calc_tetris/core/block/math_single_block_component.dart';
import 'package:calc_tetris/core/block/model/math_number_block.dart';
import 'package:calc_tetris/core/block/model/math_operant_block.dart';
import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/core/block/model/null_block.dart';
import 'package:calc_tetris/core/block/snap_to_grid_when_dragging_behaviour.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/image_composition.dart';
import 'package:uuid/uuid.dart';

class MathCompoundBlockComponent extends MathBlockComponent with TapCallbacks {
  late List<List<MathSingleBlock>> _model;
  final Map<Uuid, MathSingleBlockComponent> _components = {};
  late double _cellSize;

  MathCompoundBlockComponent(this._model);

  @override
  void onLoad() async {
    await super.onLoad();
    add(SnapToGridWhenDraggingBehaviour());
    _cellSize = findParent<Grid>()!.cellSize;
    for (var i = 0; i < _model.length; i++) {
      for (var j = 0; j < _model[i].length; j++) {
        var blockModel = _model[i][j];
        final component = newComponentFromBlockModel(blockModel);
        if (component != null) {
          _components.addAll({blockModel.id: component});
          add(component);
        }
      }
    }
    updateSingleBlockPositions(withAnimation: false);
  }

  MathSingleBlockComponent? newComponentFromBlockModel(
    MathSingleBlock blockModel,
  ) {
    if (blockModel is MathNumberBlock) {
      return MathNumberBlockComponent(model: blockModel);
    }
    if (blockModel is MathOperantBlock) {
      return MathOperantBlockComponent(model: blockModel);
    }
    return null;
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

  List<IntVector2> getLocalSingleBlockPositions() {
    final result = List<IntVector2>.empty(growable: true);
    for (var x = 0; x < _model.length; x++) {
      for (var y = _model[x].length - 1; y >= 0; y--) {
        if (_model[x][y] is NullBlock) {
          continue;
        }
        result.add(IntVector2(x, y));
      }
    }
    developer.log("Lowest local block positions: $result");
    return result;
  }

  List<List<MathSingleBlock>> get model => _model;

  int get modelWidth => _model.length;
}
