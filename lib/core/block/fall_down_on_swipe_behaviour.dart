import 'package:calc_tetris/core/block/compound_block_behaviour.dart';
import 'package:flame/events.dart';

class FallDownOnSwipeBehaviour extends CompoundBlockBehaviour
    with DragCallbacks {
  double dragedDistanceDown = 0;
  DateTime? startTimestamp;
  final double minDistanceYToTriggerSwipe;
  final double maxDragTimeInMilliesToTriggerSwipe;

  FallDownOnSwipeBehaviour({
    this.minDistanceYToTriggerSwipe = 100,
    this.maxDragTimeInMilliesToTriggerSwipe = 300,
  });

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    event.continuePropagation = true;
    dragedDistanceDown = 0;
    startTimestamp = DateTime.now();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    dragedDistanceDown += event.canvasDelta.y;
    if (dragedDistanceDown < 10 ||
        DateTime.now().difference(startTimestamp!).inMilliseconds > 30) {
      event.continuePropagation = true;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    event.continuePropagation = true;
    if (dragedDistanceDown < minDistanceYToTriggerSwipe) {
      return;
    }
    if (DateTime.now().difference(startTimestamp!).inMilliseconds >
        maxDragTimeInMilliesToTriggerSwipe) {
      return;
    }
    gridController.fallBlockDown();
  }
}
