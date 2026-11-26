import 'dart:developer' as dev;

import 'package:magic_blocks/audio/music_player.dart';
import 'package:magic_blocks/persistence/database_service.dart';
import 'package:magic_blocks/persistence/in_memory_database_service.dart';
import 'package:magic_blocks/persistence/model/game_mode_name.dart';
import 'package:magic_blocks/screens/welcome/game_mode_card.dart';
import 'package:magic_blocks/screens/welcome/mascot.dart';
import 'package:magic_blocks/theme/text_theme.dart';
import 'package:magic_blocks/theme/welcome_palette.dart';
import 'package:flutter/widgets.dart';

/// Start screen: name of the game on top (in front of the mascot), one card
/// per game mode below, all in front of a light sky.
class WelcomeScreen extends StatefulWidget {
  static const Key skyKey = Key('welcome-sky');
  static const String gameName = 'Magic Blocks';
  static const String musicFile = 'welcome.m4a';
  static const String endlessDescription =
      'Löse Gleichungen, sammle Punkte und verbessere deinen persönlichen Highscore.';

  final DatabaseService? databaseService;
  final MusicPlayer? musicPlayer;
  final void Function()? onStartEndless;
  final void Function()? onStartTutorial;

  const WelcomeScreen({
    super.key,
    this.databaseService,
    this.musicPlayer,
    this.onStartEndless,
    this.onStartTutorial,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const double _margin = 16;
  static const double _titleHeight = 140;
  static const double _gap = 16;
  static const double _mascotSize = _titleHeight * 1.6;

  /// Centers the mascot behind the title. Its feet reach behind the first
  /// card.
  static const double _mascotTop =
      _margin + _titleHeight / 2 - _mascotSize * 0.38;

  late final DatabaseService _databaseService =
      widget.databaseService ?? InMemoryDatabaseService();
  late final MusicPlayer _musicPlayer =
      widget.musicPlayer ?? SilentMusicPlayer();

  int _endlessHighScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScores();
    _playMusic();
  }

  @override
  void dispose() {
    _stopMusic();
    super.dispose();
  }

  /// Shows the stored high scores on the cards. A card keeps showing 0 if
  /// there is none or the database can not be read.
  Future<void> _loadHighScores() async {
    try {
      final endless = await _databaseService.loadGameMode(
        GameModeName.endless,
      );
      if (endless != null && mounted) {
        setState(() => _endlessHighScore = endless.highscore);
      }
    } catch (error) {
      dev.log('Could not load the high scores: $error');
    }
  }

  /// Starts the endless music. Broken audio must not disturb the game.
  Future<void> _playMusic() async {
    try {
      await _musicPlayer.playLoop(WelcomeScreen.musicFile);
    } catch (error) {
      dev.log('Could not play the welcome music: $error');
    }
  }

  Future<void> _stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (error) {
      dev.log('Could not stop the welcome music: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: WelcomeScreen.skyKey,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [WelcomePalette.skyTop, WelcomePalette.skyBottom],
        ),
      ),
      child: SizedBox.expand(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              const Positioned(
                top: _mascotTop,
                left: 0,
                right: 0,
                child: Center(child: Mascot(size: _mascotSize)),
              ),
              _content(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content() {
    return Padding(
      padding: const EdgeInsets.all(_margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _titleHeight),
            child: Center(heightFactor: 1, child: _title()),
          ),
          const SizedBox(height: _gap),
          GameModeCard(
            title: 'Endlosspiel',
            description: WelcomeScreen.endlessDescription,
            highScore: _endlessHighScore,
            imageName: 'trophy.png',
            onTap: widget.onStartEndless,
            secondaryLabel: 'Tutorial',
            onSecondaryTap: widget.onStartTutorial,
          ),
        ],
      ),
    );
  }

  Widget _title() => Text(
    WelcomeScreen.gameName,
    textAlign: TextAlign.center,
    style: textTheme.displayLarge!.copyWith(
      inherit: false,
      fontSize: 46,
      color: WelcomePalette.cardTitle,
      shadows: const [Shadow(color: WelcomePalette.cardFill, blurRadius: 8)],
    ),
  );
}
