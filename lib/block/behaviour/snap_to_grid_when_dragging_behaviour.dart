import 'dart:developer';

import 'package:magic_blocks/block/behaviour/compound_block_behaviour.dart';
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
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    dragPosition = Vector2.zero();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) async {
    event.continuePropagation = true;
    final localDelta = event.localDelta;
    dragPosition.add(localDelta);
    while (dragPosition.x > cellSize) {
      log("Draged to right on dragPosition: $dragPosition");
      gridController.onBlockDraggedRight();
      dragPosition.add(Vector2(-cellSize, 0));
    }
    while (dragPosition.x < -cellSize) {
      log("Draged to left on dragPosition: $dragPosition");
      gridController.onBlockDraggedLeft();
      dragPosition.add(Vector2(cellSize, 0));
    }
    while (dragPosition.y > cellSize) {
      log("Draged down on dragPosition: $dragPosition");
      gridController.onBlockDraggedDown();
      dragPosition.add(Vector2(0, -cellSize));
    }
    while (dragPosition.y < -cellSize) {
      log("Draged up on dragPosition: $dragPosition");
      gridController.onBlockDraggedUp();
      dragPosition.add(Vector2(0, cellSize));
    }
  }
}
