import 'dart:developer' as dev;

import 'package:calc_tetris/persistence/database_service.dart';
import 'package:calc_tetris/persistence/in_memory_database_service.dart';
import 'package:calc_tetris/persistence/model/game_mode_name.dart';
import 'package:calc_tetris/screens/welcome/game_mode_card.dart';
import 'package:calc_tetris/screens/welcome/mascot.dart';
import 'package:calc_tetris/screens/welcome/sky_background.dart';
import 'package:calc_tetris/theme/text_theme.dart';
import 'package:calc_tetris/theme/welcome_palette.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Start screen: name of the game on top (in front of the mascot), one card
/// per game mode below.
class WelcomeScreen extends PositionComponent {
  static const String gameName = 'Magic Blocks';

  static const double _margin = 16;
  static const double _titleHeight = 140;
  static const double _cardHeight = 150;
  static const double _gap = 16;

  final SkyBackground background = SkyBackground();

  final Mascot mascot = Mascot();

  final TextComponent title = TextComponent(
    text: gameName,
    anchor: Anchor.center,
    textRenderer: TextPaint(
      style: textTheme.displayLarge!.copyWith(
        fontSize: 46,
        color: WelcomePalette.cardTitle,
        shadows: const [Shadow(color: WelcomePalette.cardFill, blurRadius: 8)],
      ),
    ),
  );

  late final List<GameModeCard> cards;

  final DatabaseService _databaseService;

  WelcomeScreen({
    DatabaseService? databaseService,
    void Function()? onStartEndless,
  }) : _databaseService = databaseService ?? InMemoryDatabaseService() {
    cards = [
      GameModeCard(
        title: 'Endlosspiel',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        highScore: 0,
        size: Vector2(0, _cardHeight),
        onTap: onStartEndless,
      ),
    ];
    _layout();
  }

  @override
  Future<void> onLoad() async {
    await add(background);
    await add(mascot);
    await add(title);
    await addAll(cards);
    await loadHighScores();
  }

  /// Shows the stored high scores on the cards. A card keeps showing 0 if
  /// there is none or the database can not be read.
  Future<void> loadHighScores() async {
    try {
      final endless = await _databaseService.loadGameMode(
        GameModeName.endless,
      );
      if (endless != null) {
        cards.first.updateHighScore(endless.highscore);
      }
    } catch (error) {
      dev.log('Could not load the high scores: $error');
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _layout();
  }

  void _layout() {
    background
      ..position = Vector2.zero()
      ..size = size.clone();
    final contentWidth = width - 2 * _margin;
    title.position = Vector2(width / 2, _margin + _titleHeight / 2);
    _layoutMascot();
    var y = _margin + _titleHeight + _gap;
    for (final card in cards) {
      card
        ..resizeTo(Vector2(contentWidth, _cardHeight))
        ..position = Vector2(_margin, y);
      y += _cardHeight + _gap;
    }
  }

  /// Centers the mascot behind the title. Its feet reach behind the first
  /// card.
  void _layoutMascot() {
    final mascotSize = _titleHeight * 1.6;
    mascot
      ..size = Vector2.all(mascotSize)
      ..position = Vector2(
        (width - mascotSize) / 2,
        _margin + _titleHeight / 2 - mascotSize * 0.38,
      );
  }
}
