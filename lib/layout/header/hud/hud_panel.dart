import 'package:calc_tetris/theme/light_theme.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Decoration of a panel framed in the primary color, used by all HUD cards.
final BoxDecoration hudPanelDecoration = BoxDecoration(
  color: colorScheme.primaryContainer,
  borderRadius: const BorderRadius.all(Radius.circular(14)),
  border: Border.fromBorderSide(
    BorderSide(color: colorScheme.primary, width: 2),
  ),
  boxShadow: [
    BoxShadow(color: colorScheme.shadow.withAlpha(0x55), blurRadius: 8),
  ],
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
