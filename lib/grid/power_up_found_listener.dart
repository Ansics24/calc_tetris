import 'package:flame/components.dart';

/// The power-ups a player can find.
enum PowerUpType { cannon }

/// Gets told when the player found a power-up by solving an equation.
abstract interface class PowerUpFoundListener {
  /// [foundPositionAbsoluteCenter] is the on-screen center of the solved
  /// blocks, where the power-up was found.
  void onPowerUpFound(PowerUpType type, Vector2 foundPositionAbsoluteCenter);
}
