import 'dart:async';

import 'package:calc_tetris/core/grid/grid.dart';
import 'package:calc_tetris/core/grid/int_vector_2.dart';
import 'package:flame/components.dart';

class BlockBoard extends PositionComponent {
  BlockBoard({super.size, super.position});

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    // final background = await Sprite.load("background_mittelalter.png");
    // TODO does overlap grid lines
    //await add(
    //  SpriteComponent(
    //    sprite: background,
    //    scale: Vector2.all(0.5),
    //  ),
    //);
    add(Grid(blockCount: IntVector2(9, 14)));
  }
}
