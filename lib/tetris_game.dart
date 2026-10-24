import 'dart:async';

import 'package:calc_tetris/screens/endless_game.dart';
import 'package:flame/game.dart';

class TetrisGame extends FlameGame {
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    await add(EndlessGame());
  }
}
