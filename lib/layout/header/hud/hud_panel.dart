import 'package:calc_tetris/theme/game_palette.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Decoration of a dark panel framed in gold, used by all HUD cards.
const BoxDecoration hudPanelDecoration = BoxDecoration(
  color: GamePalette.panel,
  borderRadius: BorderRadius.all(Radius.circular(14)),
  border: Border.fromBorderSide(
    BorderSide(color: GamePalette.copper, width: 2),
  ),
  boxShadow: [BoxShadow(color: Color(0x88000000), blurRadius: 8)],
);

/// A [PositionComponent] that paints [hudPanelDecoration] behind its children.
mixin HudPanelBackground on PositionComponent {
  late final BoxPainter _panelPainter = hudPanelDecoration.createBoxPainter(
    () {},
  );

  void renderPanel(Canvas canvas) {
    _panelPainter.paint(
      canvas,
      Offset.zero,
      ImageConfiguration(size: Size(size.x, size.y)),
    );
  }
}
