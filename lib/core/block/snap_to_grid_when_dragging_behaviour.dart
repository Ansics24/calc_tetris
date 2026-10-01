import 'dart:developer';

import 'package:calc_tetris/core/block/math_compound_block_component.dart';
import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/grid_controller.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class SnapToGridWhenDraggingBehaviour extends PositionComponent
    with DragCallbacks {
  late MathCompoundBlockComponent _owner;
  late double _cellSize;
  late IntVector2 _gridSize;
  late GridController _gridController;
  Vector2 dragPosition = Vector2.zero();

  @override
  void onMount() {
    super.onMount();
    final grid = findParent<Grid>();
    _cellSize = grid!.cellSize;
    _gridSize = grid.gridSize;
    _owner = findParent<MathCompoundBlockComponent>()!;
    _gridController = grid.controller;
    size = _owner.size;
    dragPosition.add(_owner.position);
    log("Behaviours size is $size");
  }

  @override
  bool get isDragged => throw UnimplementedError();

  @override
  void onDragCancel(DragCancelEvent event) {}

  @override
  void onDragEnd(DragEndEvent event) {}

  @override
  void onDragStart(DragStartEvent event) {
    dragPosition = Vector2.zero();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final localDelta = event.localDelta;
    dragPosition.add(localDelta);

    if (dragPosition.x > _cellSize) {
      log("Draged to right");
      _gridController.moveBlockRight();
      dragPosition = Vector2.zero();
    }
    if (dragPosition.x < -_cellSize) {
      log("Draged to left");
      _gridController.moveBlockLeft();
      dragPosition = Vector2.zero();
    }
  }
}
