import 'package:magic_blocks/grid/power_up_found_listener.dart';

/// Gets told when the player wants to use a power-up.
abstract interface class PowerUpSelectedListener {
  void onPowerUpSelected(PowerUpType type);
}
