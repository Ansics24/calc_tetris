import 'dart:developer' as developer;
import 'dart:math';

import 'package:calc_tetris/core/block/math_block_component.dart';
import 'package:calc_tetris/core/block/math_block_model.dart';
import 'package:calc_tetris/core/block/math_number_block_component.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/image_composition.dart';

class MathCompoundBlock extends MathBlockComponent
    with TapCallbacks, DragCallbacks {
  late List<List<MathBlockModel?>> _model;
  late double _cellSize;

  MathCompoundBlock({required super.gridQueryable}) {
    _model = List.generate(
      3,
      (_) => List.generate(
        2,
        (i) => MathBlockModel(
          component: MathNumberBlockComponent(
            number: Random().nextInt(9),
            gridQueryable: super.gridQueryable,
          ),
        ),
      ),
    );
    for (var element in _model) {
      for (var i = 0; i < element.length; i++) {
        add(element[i]!.component);
      }
    }
  }

  @override
  void onLoad() async {
    await super.onLoad();
    _cellSize = findParent<Grid>()!.cellSize;
    updateSingleBlockPositions();
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

  @override
  onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position.add(event.deviceDelta);
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

  void updateSingleBlockPositions() {
    for (var i = 0; i < _model.length; i++) {
      for (var j = 0; j < _model[i].length; j++) {
        final blockModel = _model[i][j];
        if (blockModel != null) {
          var component = blockModel.component;
          component.add(
            MoveToEffect(
              Vector2(
                _cellSize * i,
                _cellSize * j,
              ),
              EffectController(duration: 0.5),
            ),
          );
        }
      }
    }
    size = Vector2(
      _model.length * _cellSize,
      _model[0].length * _cellSize,
    );
    gridQueryable.hasBlocksUnder(this);
  }

  IntVector2 get modelSize => IntVector2(_model.length, _model[0].length);
}
