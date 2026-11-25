import 'package:flame/components.dart';

/// The power-ups a player can find.
enum PowerUpType {
  /// Shoots blocks that landed in the grid.
  cannon(uses: 8);

  /// How often one such power-up can be used once it is activated.
  final int uses;

  const PowerUpType({required this.uses});
}

/// Gets told when the player found a power-up by solving an equation.
abstract interface class PowerUpFoundListener {
  /// [foundPositionAbsoluteCenter] is the on-screen center of the solved
  /// blocks, where the power-up was found.
  void onPowerUpFound(PowerUpType type, Vector2 foundPositionAbsoluteCenter);
}
