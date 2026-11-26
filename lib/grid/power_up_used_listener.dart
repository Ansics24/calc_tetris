import 'package:magic_blocks/grid/power_up_found_listener.dart';

/// Gets told about every use of the power-up in use, e.g. a shot of the
/// cannon.
abstract interface class PowerUpUsedListener {
  void onPowerUpUsed(PowerUpType type);
}
