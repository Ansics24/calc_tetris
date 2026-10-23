import 'dart:developer' as developer;

import 'package:calc_tetris/block/behaviour/fall_down_on_swipe_behaviour.dart';
import 'package:calc_tetris/block/behaviour/snap_to_grid_when_dragging_behaviour.dart';
import 'package:calc_tetris/block/block_component.dart';
import 'package:calc_tetris/block/model/null_block.dart';
import 'package:calc_tetris/block/model/single_block.dart';
import 'package:calc_tetris/block/single_block_component.dart';
import 'package:calc_tetris/block/single_block_component_factory.dart';
import 'package:calc_tetris/grid/grid.dart';
import 'package:calc_tetris/grid/queries/grid_model_aware.dart';
import 'package:calc_tetris/grid/queries/position_in_grid_aware.dart';
import 'package:calc_tetris/util/int_vector_2.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/image_composition.dart';
import 'package:uuid/uuid.dart';

class CompoundBlockComponent extends BlockComponent with TapCallbacks {
  late List<List<SingleBlock>> _model;
  final Map<Uuid, SingleBlockComponent> _components = {};
  final GridModelAware _gridModelAware;
  final PositionInGridAware _positionInGridAware;
  final SingleBlockComponentFactory _componentFactory;
  late double _cellSize;

  CompoundBlockComponent(
    this._model, {
    required this._gridModelAware,
    required this._positionInGridAware,
    required SingleBlockComponentFactory singleBlockComponentFactory,
  }) : _componentFactory = singleBlockComponentFactory;

  @override
  void onLoad() async {
    await super.onLoad();
    add(SnapToGridWhenDraggingBehaviour());
    add(FallDownOnSwipeBehaviour());
    _cellSize = findParent<Grid>()!.cellSize;
    for (var i = 0; i < _model.length; i++) {
      for (var j = 0; j < _model[i].length; j++) {
        var blockModel = _model[i][j];
        final component = _componentFactory(blockModel);
        if (component != null) {
          _components.addAll({blockModel.id: component});
          add(component);
        }
      }
    }
    updateSingleBlockPositions(withAnimation: false);
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

  bool _isAnyPositionBlocked(List<List<SingleBlock>> blocks) {
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

  SingleBlockComponent? componentForSingleBlockModel(
    SingleBlock model,
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

  List<List<SingleBlock>> get model => _model;

  int getEffectiveModelWidth() {
    var minIndexFound = 1000;
    var maxIndexFound = 0;
    for (var x = 0; x < model.length; x++) {
      for (var y = 0; y < model[x].length; y++) {
        if (model[x][y] is NullBlock) {
          continue;
        }
        if (x < minIndexFound) {
          minIndexFound = x;
        }
        if (x > maxIndexFound) {
          maxIndexFound = x;
        }
      }
    }
    return maxIndexFound - minIndexFound;
  }

  int getEffectiveModelHeight() {
    var minIndexFound = 1000;
    var maxIndexFound = 0;
    for (var x = 0; x < model.length; x++) {
      for (var y = 0; y < model[x].length; y++) {
        if (model[x][y] is NullBlock) {
          continue;
        }
        if (y < minIndexFound) {
          minIndexFound = y;
        }
        if (y > maxIndexFound) {
          maxIndexFound = y;
        }
      }
    }
    return maxIndexFound - minIndexFound + 1;
  }

  int getLowestLocalBlockYPosition(int columnIndex) {
    var maxIndexFound = 0;
    for (var y = 0; y < model[columnIndex].length; y++) {
      if (model[columnIndex][y] is NullBlock) {
        continue;
      }
      if (y > maxIndexFound) {
        maxIndexFound = y;
      }
    }
    return maxIndexFound;
  }
}
