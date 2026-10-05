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
import 'package:calc_tetris/core/grid/queries/grid_model_aware.dart';
import 'package:calc_tetris/core/grid/queries/position_in_grid_aware.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/image_composition.dart';
import 'package:uuid/uuid.dart';

class MathCompoundBlockComponent extends MathBlockComponent with TapCallbacks {
  late List<List<MathSingleBlock>> _model;
  final Map<Uuid, MathSingleBlockComponent> _components = {};
  final GridModelAware _gridModelAware;
  final PositionInGridAware _positionInGridAware;
  late double _cellSize;

  MathCompoundBlockComponent(
    this._model, {
    required this._gridModelAware,
    required this._positionInGridAware,
  });

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
    rotate();
  }

  void rotate() {
    var newModel = List.generate(
      _model[0].length,
      (i) => List.generate(
        _model.length,
        (j) => _model[j][_model[0].length - 1 - i],
      ),
    );
    if (_isAnyPositionBlocked(newModel)) {
      developer.log("Cant rotate. There is some cell blocked");
      return;
    }

    _model = newModel;
    updateSingleBlockPositions();
  }

  bool _isAnyPositionBlocked(List<List<MathSingleBlock>> blocks) {
    final positionInGrid = _positionInGridAware.positionInGrid(this)!;
    for (var x = 0; x < blocks.length; x++) {
      for (var y = 0; y < blocks[x].length; y++) {
        final posToCheck = positionInGrid.add(x, y);
        if (_gridModelAware.anyPositionBlocked(List.filled(1, posToCheck))) {
          return true;
        }
      }
    }
    return false;
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
            EffectController(duration: withAnimation ? 0.1 : 0),
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
    return result;
  }

  List<List<MathSingleBlock>> get model => _model;

  int get modelWidth => _model.length;
}
