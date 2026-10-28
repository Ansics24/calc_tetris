import 'dart:async';

import 'package:calc_tetris/screens/endless_game.dart';
import 'package:calc_tetris/screens/welcome/welcome_screen.dart';
import 'package:flame/game.dart';

class TetrisGame extends FlameGame {
  static const String welcomeRoute = 'welcome';
  static const String endlessRoute = 'endless';

  late final RouterComponent router = RouterComponent(
    initialRoute: welcomeRoute,
    routes: {
      welcomeRoute: Route(
        () => WelcomeScreen(
          onStartEndless: () => router.pushReplacementNamed(endlessRoute),
        ),
      ),
      endlessRoute: Route(EndlessGame.new),
    },
  );

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    await add(router);
  }
}
