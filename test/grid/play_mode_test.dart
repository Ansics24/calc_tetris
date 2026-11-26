import 'package:magic_blocks/grid/play_mode.dart';
import 'package:magic_blocks/grid/power_up_found_listener.dart';
import 'package:test/test.dart';

void main() {
  group('default mode', () {
    test('is of the default kind without a power-up', () {
      const mode = PlayMode.defaultMode();

      expect(mode.kind, PlayModeKind.defaultMode);
      expect(mode.powerUpType, isNull);
      expect(mode.isPowerUpInUse, isFalse);
    });
  });

  group('power-up in use mode', () {
    test('knows the power-up that is in use', () {
      const mode = PlayMode.powerUpInUse(PowerUpType.cannon);

      expect(mode.kind, PlayModeKind.powerUpInUse);
      expect(mode.powerUpType, PowerUpType.cannon);
      expect(mode.isPowerUpInUse, isTrue);
    });
  });

  test('knows when two modes are the same', () {
    expect(const PlayMode.defaultMode(), const PlayMode.defaultMode());
    expect(
      PlayMode.powerUpInUse(PowerUpType.cannon),
      PlayMode.powerUpInUse(PowerUpType.cannon),
    );
    expect(
      PlayMode.powerUpInUse(PowerUpType.cannon),
      isNot(const PlayMode.defaultMode()),
    );
  });

  test('has exactly the two kinds so far', () {
    expect(PlayModeKind.values, [
      PlayModeKind.defaultMode,
      PlayModeKind.powerUpInUse,
    ]);
  });
}
