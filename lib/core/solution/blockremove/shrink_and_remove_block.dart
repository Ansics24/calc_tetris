import 'dart:async';

import 'package:calc_tetris/core/solution/remove_block_animation.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class ShrinkAndRemoveBlock extends Component implements RemoveBlockAnimation {
  @override
  Future<void> execute() {
    Completer completer = Completer<void>();

    parent?.add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: 1),
        onComplete: () {
          completer.complete();
          parent?.removeFromParent();
        },
      ),
    );

    return completer.future;
  }
}
