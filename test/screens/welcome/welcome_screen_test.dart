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
  _friendlyLookTests();

  test('takes over the size of the game when it is resized', () {
    expect(_screen().size, Vector2(400, 800));
  });

  group('mascot', () {
    test('is drawn above the sky but behind the cards', () {
      final screen = _screen();

      expect(screen.mascot.priority, greaterThan(screen.background.priority));
      expect(screen.mascot.priority, lessThan(screen.cards.first.priority));
    });

    test('reaches behind the first card', () {
      final screen = _screen();

      expect(
        screen.mascot.toRect().overlaps(screen.cards.first.toRect()),
        isTrue,
      );
    });

    test('sits behind the title', () {
      final screen = _screen();

      expect(
        screen.mascot.toRect().contains(screen.title.position.toOffset()),
        isTrue,
      );
      expect(screen.mascot.priority, lessThan(screen.title.priority + 1));
    });

    test('stays inside the screen horizontally', () {
      final screen = _screen();

      expect(screen.mascot.x, greaterThanOrEqualTo(0));
      expect(screen.mascot.x + screen.mascot.width, lessThanOrEqualTo(400));
    });

    test('stays inside the screen vertically', () {
      final screen = _screen();

      expect(screen.mascot.y, greaterThanOrEqualTo(0));
      expect(screen.mascot.y + screen.mascot.height, lessThanOrEqualTo(800));
    });
  });

  test('shows the game name above the cards', () {
    final screen = _screen();

    expect(screen.title.text, 'Magic Blocks');
    expect(screen.title.y, lessThan(screen.cards.first.y));
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

void _friendlyLookTests() {
  group('friendly look', () {
    test('has a sky background covering the whole screen', () {
      final screen = _screen();

      expect(screen.background.size, Vector2(400, 800));
      expect(screen.background.position, Vector2.zero());
    });

    test('draws the sky behind everything else', () {
      expect(_screen().background.priority, lessThan(0));
    });

    test('gives the cards enough height for the bigger texts', () {
      expect(_screen().cards.first.height, greaterThanOrEqualTo(150));
    });
  });
}
