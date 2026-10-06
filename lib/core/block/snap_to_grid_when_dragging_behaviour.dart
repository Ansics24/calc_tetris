import 'dart:developer';

import 'package:calc_tetris/core/block/compound_block_behaviour.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class SnapToGridWhenDraggingBehaviour extends CompoundBlockBehaviour
    with DragCallbacks {
  Vector2 dragPosition = Vector2.zero();

  @override
  void onMount() {
    super.onMount();
    dragPosition.add(owner.position);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    event.continuePropagation = true;
    final localDelta = event.localDelta;
    dragPosition.add(localDelta);

    if (dragPosition.x > cellSize) {
      log("Draged to right");
      gridController.moveBlockRight();
      dragPosition = Vector2.zero();
    }
    if (dragPosition.x < -cellSize) {
      log("Draged to left");
      gridController.moveBlockLeft();
      dragPosition = Vector2.zero();
    }
  }
}
