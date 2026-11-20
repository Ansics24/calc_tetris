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
