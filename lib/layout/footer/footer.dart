import 'dart:math';

import 'package:calc_tetris/layout/footer/cannon_button.dart';
import 'package:flame/components.dart';

/// Space below the grid. Shows the power-ups the player can use.
class Footer extends PositionComponent {
  /// Share of the footer height the power-up buttons use.
  static const double _buttonHeightFactor = 0.8;

  final CannonButton cannonButton = CannonButton();

  Footer({super.size, super.position}) {
    _layout();
    add(cannonButton);
  }

  /// Centers the power-up buttons.
  void _layout() {
    final diameter = min(height * _buttonHeightFactor, width);
    cannonButton
      ..size = Vector2.all(diameter)
      ..position = Vector2((width - diameter) / 2, (height - diameter) / 2);
  }
}
