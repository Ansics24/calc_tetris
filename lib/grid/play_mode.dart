import 'package:calc_tetris/grid/power_up_found_listener.dart';

/// The kinds of modes a game can be in.
enum PlayModeKind { defaultMode, powerUpInUse }

/// The mode a game is in. A game starts in [PlayMode.defaultMode].
class PlayMode {
  final PlayModeKind kind;

  /// The power-up that is in use, only set for [PlayModeKind.powerUpInUse].
  final PowerUpType? powerUpType;

  const PlayMode.defaultMode()
    : kind = PlayModeKind.defaultMode,
      powerUpType = null;

  const PlayMode.powerUpInUse(PowerUpType type)
    : kind = PlayModeKind.powerUpInUse,
      powerUpType = type;

  bool get isPowerUpInUse => kind == PlayModeKind.powerUpInUse;

  @override
  bool operator ==(Object other) =>
      other is PlayMode &&
      other.kind == kind &&
      other.powerUpType == powerUpType;

  @override
  int get hashCode => Object.hash(kind, powerUpType);

  @override
  String toString() => 'PlayMode(${kind.name}, ${powerUpType?.name})';
}
