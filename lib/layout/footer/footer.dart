import 'dart:math';

import 'package:calc_tetris/grid/power_up_found_listener.dart';
import 'package:calc_tetris/layout/footer/cannon_button.dart';
import 'package:calc_tetris/layout/footer/powerup_button.dart';
import 'package:flame/components.dart';

/// Space below the grid. Shows the power-ups the player can use.
class Footer extends PositionComponent {
  /// Share of the footer height the power-up buttons use.
  static const double _buttonHeightFactor = 0.8;

  final CannonButton cannonButton = CannonButton();

  bool _locked = false;

  /// [onPowerUpSelected] is told which power-up the player pressed.
  Footer({
    super.size,
    super.position,
    void Function(PowerUpType type)? onPowerUpSelected,
  }) {
    _layout();
    add(cannonButton);
    for (final type in PowerUpType.values) {
      buttonFor(type).onPressed = () => onPowerUpSelected?.call(type);
    }
  }

  bool get isLocked => _locked;

  /// Locks or unlocks all power-up buttons.
  set isLocked(bool locked) {
    _locked = locked;
    for (final type in PowerUpType.values) {
      buttonFor(type).isLocked = locked;
    }
  }

  /// The button that shows the power-ups of the given kind.
  PowerUpButton buttonFor(PowerUpType type) => switch (type) {
    PowerUpType.cannon => cannonButton,
  };

  /// Centers the power-up buttons.
  void _layout() {
    final diameter = min(height * _buttonHeightFactor, width);
    cannonButton
      ..size = Vector2.all(diameter)
      ..position = Vector2((width - diameter) / 2, (height - diameter) / 2);
  }
}
