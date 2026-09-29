import 'package:calc_tetris/core/block/math_single_block_component.dart';
import 'package:calc_tetris/core/block/model/math_number_block.dart';
import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/painting.dart';

class MathNumberBlockComponent
    extends MathSingleBlockComponent<MathNumberBlock> {
  MathNumberBlock model;
  MathNumberBlockComponent({
    required this.model,
  });

  @override
  void onLoad() async {
    super.onLoad();
    final backgroundSvg = await Svg.load("images/block_blue.svg");
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
        text: model.number.toString(),
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
      ),
    );
  }

  @override
  MathNumberBlock get blockModel => model;
}
