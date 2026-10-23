import 'package:calc_tetris/core/block/appearance/tile_colors.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// A glossy, bevelled tile with a centered symbol. Fills its parent's size.
class BlockTile extends PositionComponent {
  final TileColor color;
  final String symbol;

  BlockTile({required this.color, required this.symbol, super.size});

  @override
  void render(Canvas canvas) {
    final inset = size.x * 0.04;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.x - 2 * inset,
      size.y - 2 * inset,
    );
    final radius = Radius.circular(size.x * 0.14);
    final tile = RRect.fromRectAndRadius(rect, radius);

    canvas.drawRRect(
      tile.shift(Offset(0, size.y * 0.03)),
      Paint()..color = const Color(0x66000000),
    );
    canvas.drawRRect(
      tile,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.light, color.base, color.dark],
          stops: const [0, 0.45, 1],
        ).createShader(rect),
    );
    canvas.drawRRect(
      tile.deflate(size.x * 0.03),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.x * 0.03
        ..color = const Color(0x33FFFFFF),
    );
    canvas.drawRRect(
      tile,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.x * 0.03
        ..color = color.dark,
    );
    TextPaint(
      style: TextStyle(
        color: const Color(0xFFFFFFFF),
        fontSize: size.y * 0.55,
        fontWeight: FontWeight.w800,
        shadows: const [Shadow(color: Color(0x99000000), offset: Offset(0, 2))],
      ),
    ).render(
      canvas,
      symbol,
      Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
  }
}
