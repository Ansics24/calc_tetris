import 'package:calc_tetris/core/block/math_single_block_component.dart';
import 'package:calc_tetris/core/block/model/math_operant_block.dart';
import 'package:calc_tetris/core/block/model/math_operant_type.dart';
import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:flutter/material.dart';

class MathOperandBlockComponent
    extends MathSingleBlockComponent<MathOperantBlock> {
  MathOperantBlock model;

  MathOperandBlockComponent({required this.model});

  @override
  void onLoad() async {
    await super.onLoad();
    final backgroundSvg = await Svg.load("images/block_yellow.svg");
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
          style: TextStyle(
            color: Color.fromARGB(255, 50, 42, 42),
            fontSize: 20,
          ),
        ),
        text: model.type == MathOperandType.plus ? '+' : '-',
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
      ),
    );
  }

  @override
  MathOperantBlock get blockModel => model;
}
