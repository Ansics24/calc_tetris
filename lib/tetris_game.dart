import 'dart:async';

import 'package:calc_tetris/persistence/database_service.dart';
import 'package:calc_tetris/persistence/in_memory_database_service.dart';
import 'package:calc_tetris/screens/endless/endless_game.dart';
import 'package:calc_tetris/screens/welcome/welcome_screen.dart';
import 'package:calc_tetris/theme/welcome_palette.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class TetrisGame extends FlameGame {
  static const String welcomeRoute = 'welcome';
  static const String endlessRoute = 'endless';

  static const List<Color> _welcomeSurround = [
    WelcomePalette.skyTop,
    WelcomePalette.skyBottom,
  ];
  static const List<Color> _endlessSurround = _welcomeSurround;

  /// Colors (top to bottom) for the area around the game, e.g. behind camera
  /// cutouts and system bars. Follows the current route.
  final ValueNotifier<List<Color>> surroundColors = ValueNotifier(
    _welcomeSurround,
  );

  final DatabaseService _databaseService;

  TetrisGame({DatabaseService? databaseService})
    : _databaseService = databaseService ?? InMemoryDatabaseService();

  late final RouterComponent router = RouterComponent(
    initialRoute: welcomeRoute,
    routes: {
      welcomeRoute: Route(
        () => WelcomeScreen(
          databaseService: _databaseService,
          onStartEndless: () {
            surroundColors.value = _endlessSurround;
            router.pushReplacementNamed(endlessRoute);
          },
        ),
        maintainState: false,
      ),
      endlessRoute: Route(
        () => EndlessGame(
          databaseService: _databaseService,
          onQuit: () {
            surroundColors.value = _welcomeSurround;
            router.pushReplacementNamed(welcomeRoute);
          },
        ),
        maintainState: false,
      ),
    },
  );

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    await add(router);
  }
}
