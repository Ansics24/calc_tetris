import 'package:calc_tetris/global/game_dimensions.dart';
import 'package:calc_tetris/global/grid.dart';
import 'package:flame/game.dart';

class TetrisGame extends FlameGame {
  final GameDimensions _gameDimensions = GameDimensions();

  @override
  void onMount() {
    add(
      Grid(),
    );
    super.onMount();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _gameDimensions.availableSize = size;
  }

  GameDimensions get gameDimensions => _gameDimensions;
}
