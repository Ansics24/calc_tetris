import 'dart:developer' as developer;

import 'package:calc_tetris/core/block/math_block_component.dart';
import 'package:calc_tetris/core/block/math_single_block_component.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/image_composition.dart';

class MathCompoundBlock extends MathBlockComponent
    with TapCallbacks, DragCallbacks {
  late List<List<MathSingleBlockComponent?>> _model;
  late double _cellSize;

  MathCompoundBlock(this._model, {required super.gridQueryable});

  @override
  void onLoad() async {
    await super.onLoad();
    _cellSize = findParent<Grid>()!.cellSize;
    for (var component in _model) {
      for (var i = 0; i < component.length; i++) {
        add(component[i]!);
      }
    }
    updateSingleBlockPositions(withAnimation: false);
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
        final blockComponent = _model[i][j];
        if (blockComponent != null) {
          var component = blockComponent;
          component.add(
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
    }
    size = Vector2(
      _model.length * _cellSize,
      _model[0].length * _cellSize,
    );
  }

  List<IntVector2> get lowestLocalSingleBlockPositions =>
      List.generate(_model.length, (x) => IntVector2(x, _model[x].length));
}
