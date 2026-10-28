import 'dart:async';

import 'package:calc_tetris/screens/endless/endless_game.dart';
import 'package:calc_tetris/screens/welcome/welcome_screen.dart';
import 'package:calc_tetris/theme/game_palette.dart';
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
  static const List<Color> _endlessSurround = [
    GamePalette.panelDeep,
    GamePalette.panelDeep,
  ];

  /// Colors (top to bottom) for the area around the game, e.g. behind camera
  /// cutouts and system bars. Follows the current route.
  final ValueNotifier<List<Color>> surroundColors = ValueNotifier(
    _welcomeSurround,
  );

  late final RouterComponent router = RouterComponent(
    initialRoute: welcomeRoute,
    routes: {
      welcomeRoute: Route(
        () => WelcomeScreen(
          onStartEndless: () {
            surroundColors.value = _endlessSurround;
            router.pushReplacementNamed(endlessRoute);
          },
        ),
      ),
      endlessRoute: Route(
        () => EndlessGame(
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
