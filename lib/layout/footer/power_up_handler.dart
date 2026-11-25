import 'package:calc_tetris/audio/sound_effect_player.dart';
import 'package:calc_tetris/audio/sound_files.dart';
import 'package:calc_tetris/grid/play_mode.dart';
import 'package:calc_tetris/grid/power_up_found_listener.dart';
import 'package:calc_tetris/grid/power_up_selected_listener.dart';
import 'package:calc_tetris/grid/power_up_used_listener.dart';
import 'package:calc_tetris/layout/footer/footer.dart';

/// Lets the player use the power-ups of the footer: takes one when selected,
/// counts its uses and switches between the modes. The game mode is told about
/// every switch and applies it to its grid.
class PowerUpHandler implements PowerUpSelectedListener, PowerUpUsedListener {
  final Footer _footer;
  final void Function(PlayMode mode) _onPlayModeChanged;
  final SoundEffectPlayer _soundEffectPlayer;
  PlayMode _playMode = const PlayMode.defaultMode();

  /// How often the power-up in use can still be used.
  int _usesLeft = 0;

  PowerUpHandler({
    required this._footer,
    required this._onPlayModeChanged,
    SoundEffectPlayer? soundEffectPlayer,
  }) : _soundEffectPlayer = soundEffectPlayer ?? SilentSoundEffectPlayer();

  PlayMode get playMode => _playMode;

  /// Takes one of the power-ups and starts using it. Only possible in the
  /// default mode and when there is one left.
  @override
  void onPowerUpSelected(PowerUpType type) {
    final button = _footer.buttonFor(type);
    if (_playMode.isPowerUpInUse || button.count == 0) {
      return;
    }
    button.count -= 1;
    _usesLeft = type.uses;
    button.activeUses = _usesLeft;
    _setPlayMode(PlayMode.powerUpInUse(type));
  }

  /// Counts the uses of the power-up in use and goes back to the default mode
  /// after the last one.
  @override
  void onPowerUpUsed(PowerUpType type) {
    if (_playMode.powerUpType != type) {
      return;
    }
    _soundEffectPlayer.playSafely(_soundOfUsing(type));
    _usesLeft--;
    if (_usesLeft > 0) {
      _footer.buttonFor(type).activeUses = _usesLeft;
      return;
    }
    reset();
  }

  /// Ends the use of a power-up and goes back to the default mode.
  void reset() {
    final type = _playMode.powerUpType;
    if (type == null) {
      return;
    }
    _footer.buttonFor(type).activeUses = null;
    _setPlayMode(const PlayMode.defaultMode());
  }

  static String _soundOfUsing(PowerUpType type) => switch (type) {
    PowerUpType.cannon => SoundFiles.cannonShot,
  };

  void _setPlayMode(PlayMode mode) {
    _playMode = mode;
    _footer.isLocked = mode.isPowerUpInUse;
    _onPlayModeChanged(mode);
  }
}
