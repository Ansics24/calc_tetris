import 'dart:math';
import 'dart:ui';

import 'package:calc_tetris/layout/footer/powerup_button.dart';
import 'package:calc_tetris/theme/light_theme.dart';

/// Button of the cannon power-up. The cannon can shoot blocks that already
/// landed in the grid.
class CannonButton extends PowerUpButton {
  CannonButton({
    super.count,
    super.showBadge,
    super.size,
    super.position,
  });

  /// Everything is drawn in a square of this edge length and scaled to the
  /// area.
  static const double _unit = 100;

  @override
  void paintIcon(Canvas canvas, Rect area) {
    canvas.save();
    canvas.translate(area.left, area.top);
    canvas.scale(area.width / _unit);
    final body = Paint()..color = colorScheme.tertiary;

    // barrel, pointing to the upper right
    canvas.save();
    canvas.translate(36, 52);
    canvas.rotate(-0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-12, -17, 60, 34),
        const Radius.circular(10),
      ),
      body,
    );
    // reinforcing ring around the muzzle and knob at the rear
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(38, -22, 14, 44),
        const Radius.circular(5),
      ),
      body,
    );
    canvas.drawCircle(const Offset(-14, 0), 10, body);
    canvas.restore();

    // wheel with hub and spokes
    const wheelCenter = Offset(40, 72);
    canvas.drawCircle(wheelCenter, 24, body);
    final spoke = Paint()
      ..color = colorScheme.primaryContainer
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final angle = i * 0.7854;
      final dx = 16 * cos(angle);
      final dy = 16 * sin(angle);
      canvas.drawLine(
        wheelCenter.translate(-dx, -dy),
        wheelCenter.translate(dx, dy),
        spoke,
      );
    }
    canvas.drawCircle(wheelCenter, 6, spoke);
    canvas.restore();
  }
}
