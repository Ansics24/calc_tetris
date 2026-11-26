import 'package:magic_blocks/audio/flame_music_player.dart';
import 'package:magic_blocks/audio/flame_sound_effect_player.dart';
import 'package:magic_blocks/magic_blocks_app.dart';
import 'package:magic_blocks/persistence/sqlite_database_service.dart';
import 'package:magic_blocks/magic_blocks_game.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MagicBlocksApp(
      game: MagicBlocksGame(
        databaseService: SqliteDatabaseService(),
        musicPlayer: FlameMusicPlayer(),
        soundEffectPlayer: FlameSoundEffectPlayer(),
      ),
    ),
  );
}
