import 'dart:async';
import 'package:calc_tetris/core/block/math_single_block_component.dart';
import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/painting.dart';

class MathNumberBlockComponent extends MathSingleBlockComponent {
  int number;
  MathNumberBlockComponent({
    required this.number,
  });

  @override
  FutureOr<void> onLoad() async {
    final backgroundSvg = await Svg.load("images/block_background.svg");
    add(
      SvgComponent(
        svg: backgroundSvg,
        size: Vector2(size.x, size.y),
        position: Vector2(0, 0),
      ),
    );
    add(
      TextComponent(
        textRenderer: TextPaint(
          style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 20),
        ),
        text: number.toString(),
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
      ),
    );

    return super.onLoad();
  }
}
