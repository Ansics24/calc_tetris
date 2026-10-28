import 'package:calc_tetris/screens/welcome/welcome_screen.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

WelcomeScreen _screen({int endlessHighScore = 0, void Function()? onStart}) {
  return WelcomeScreen(
    endlessHighScore: endlessHighScore,
    onStartEndless: onStart,
  )..onGameResize(Vector2(400, 800));
}

void main() {
  test('takes over the size of the game when it is resized', () {
    expect(_screen().size, Vector2(400, 800));
  });

  test('places the logo placeholder above the cards', () {
    final screen = _screen();

    expect(
      screen.logoPlaceholder.y + screen.logoPlaceholder.height,
      lessThanOrEqualTo(screen.cards.first.y),
    );
  });

  test('lets the cards fill the width apart from a margin', () {
    final card = _screen().cards.first;

    expect(card.width, lessThan(400));
    expect(card.x * 2 + card.width, 400);
  });

  test('shows the endless game card with lorem ipsum description', () {
    final screen = _screen();

    expect(screen.cards, hasLength(1));
    expect(screen.cards.first.titleText.text, 'Endlosspiel');
    expect(screen.cards.first.descriptionText.text, startsWith('Lorem ipsum'));
  });

  test('shows the high score of the endless game', () {
    final screen = _screen(endlessHighScore: 4711);

    expect(screen.cards.first.highScoreValue.text, '4.711');
  });

  test('reports a press on the endless game card', () {
    var started = 0;
    final screen = _screen(onStart: () => started++);

    screen.cards.first.press();

    expect(started, 1);
  });
}
