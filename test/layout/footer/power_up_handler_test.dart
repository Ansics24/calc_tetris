import 'package:calc_tetris/audio/sound_files.dart';
import 'package:calc_tetris/grid/play_mode.dart';
import 'package:calc_tetris/grid/power_up_found_listener.dart';
import 'package:calc_tetris/grid/power_up_selected_listener.dart';
import 'package:calc_tetris/grid/power_up_used_listener.dart';
import 'package:calc_tetris/layout/footer/footer.dart';
import 'package:calc_tetris/layout/footer/power_up_handler.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

import '../../support/recording_sound_effect_player.dart';

const _cannon = PowerUpType.cannon;
const _inUse = PlayMode.powerUpInUse(_cannon);
const _normal = PlayMode.defaultMode();

class _Setup {
  final Footer footer = Footer(size: Vector2(400, 80));
  final List<PlayMode> modes = [];
  final RecordingSoundEffectPlayer sounds = RecordingSoundEffectPlayer();
  late final PowerUpHandler handler = PowerUpHandler(
    footer: footer,
    onPlayModeChanged: modes.add,
    soundEffectPlayer: sounds,
  );

  _Setup({int cannons = 1}) {
    footer.cannonButton.count = cannons;
  }
}

void main() {
  test('listens for selected and used power-ups', () {
    final handler = _Setup().handler;

    expect(handler, isA<PowerUpSelectedListener>());
    expect(handler, isA<PowerUpUsedListener>());
  });

  test('starts in the default mode', () {
    expect(_Setup().handler.playMode, _normal);
  });

  test('takes a power-up and switches the mode when selected', () {
    final setup = _Setup(cannons: 2);

    setup.handler.onPowerUpSelected(_cannon);

    expect(setup.footer.cannonButton.count, 1);
    expect(setup.footer.cannonButton.activeUses, 8);
    expect(setup.footer.isLocked, isTrue);
    expect(setup.handler.playMode, _inUse);
    expect(setup.modes, [_inUse]);
  });

  test('does nothing without a power-up left', () {
    final setup = _Setup(cannons: 0);

    setup.handler.onPowerUpSelected(_cannon);

    expect(setup.modes, isEmpty);
  });

  test('counts the uses, plays the shot and ends after the last one', () {
    final setup = _Setup()..handler.onPowerUpSelected(_cannon);

    for (var i = 0; i < 7; i++) {
      setup.handler.onPowerUpUsed(_cannon);
    }
    expect(setup.footer.cannonButton.activeUses, 1);

    setup.handler.onPowerUpUsed(_cannon);

    expect(setup.footer.cannonButton.activeUses, isNull);
    expect(setup.footer.isLocked, isFalse);
    expect(setup.modes, [_inUse, _normal]);
    expect(setup.sounds.played, List.filled(8, SoundFiles.cannonShot));
  });

  test('ignores uses in the default mode', () {
    final setup = _Setup();

    setup.handler.onPowerUpUsed(_cannon);

    expect(setup.sounds.played, isEmpty);
  });

  test('can be reset to the default mode', () {
    final setup = _Setup()..handler.onPowerUpSelected(_cannon);

    setup.handler.reset();

    expect(setup.handler.playMode, _normal);
    expect(setup.footer.cannonButton.activeUses, isNull);
    expect(setup.footer.isLocked, isFalse);
  });
}
