import 'package:calc_tetris/screens/welcome/welcome_screen.dart';
import 'package:calc_tetris/tetris_game.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';

Future<TetrisGame> _pumpGame(WidgetTester tester) async {
  final game = TetrisGame();
  await tester.pumpWidget(GameWidget(game: game));
  await tester.pump();
  await tester.pump();
  // Text boxes redraw delayed; let those timers run out.
  await tester.pump(const Duration(seconds: 1));
  return game;
}

WelcomeScreen _welcomeScreen(TetrisGame game) =>
    game.descendants().whereType<WelcomeScreen>().first;

void main() {
  testWidgets('starts on the welcome route', (tester) async {
    final game = await _pumpGame(tester);

    expect(game.router.currentRoute.name, TetrisGame.welcomeRoute);
    expect(game.descendants().whereType<WelcomeScreen>(), hasLength(1));
  });

  testWidgets('replaces the welcome route by the endless game route', (
    tester,
  ) async {
    final game = await _pumpGame(tester);

    _welcomeScreen(game).cards.first.press();
    await tester.pump();

    expect(game.router.currentRoute.name, TetrisGame.endlessRoute);
    expect(game.descendants().whereType<WelcomeScreen>(), isEmpty);
  });
}
