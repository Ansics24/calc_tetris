import 'dart:developer' as dev;

/// Plays short sound effects.
abstract interface class SoundEffectPlayer {
  /// Plays the sound once. [fileName] is relative to the sound assets.
  Future<void> play(String fileName);
}

/// Makes no sound. Used where no sound is wanted, e.g. in tests.
class SilentSoundEffectPlayer implements SoundEffectPlayer {
  @override
  Future<void> play(String fileName) async {}
}

extension SafeSoundEffectPlayer on SoundEffectPlayer {
  /// Plays the sound. Broken audio must not disturb the game, so a failure is
  /// only logged.
  Future<void> playSafely(String fileName) async {
    try {
      await play(fileName);
    } catch (error) {
      dev.log('Could not play the sound $fileName: $error');
    }
  }
}
