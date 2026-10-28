import 'package:calc_tetris/screens/welcome/game_mode_card.dart';
import 'package:flame/components.dart';
import 'package:test/test.dart';

GameModeCard _card({int highScore = 0, void Function()? onTap}) => GameModeCard(
  title: 'Endlosspiel',
  description: 'Lorem ipsum dolor sit amet',
  highScore: highScore,
  size: Vector2(360, 120),
  onTap: onTap,
);

void main() {
  _verticalLayoutTests();

  test('shows title and description', () {
    final card = _card();

    expect(card.titleText.text, 'Endlosspiel');
    expect(card.descriptionText.text, 'Lorem ipsum dolor sit amet');
  });

  test('has an image placeholder on the left of the texts', () {
    final card = _card();

    expect(card.imagePlaceholder.x, lessThan(card.titleText.x));
  });

  test('shows the high score with german thousands separator', () {
    final card = _card(highScore: 12540);

    expect(card.highScoreLabel.text, 'Höchstpunktzahl');
    expect(card.highScoreValue.text, '12.540');
  });

  test('shows the high score on the right of the title', () {
    final card = _card(highScore: 7);

    expect(card.highScoreValue.x, greaterThan(card.titleText.x));
  });

  test('calls onTap when pressed', () {
    var taps = 0;
    final card = _card(onTap: () => taps++);

    card.press();

    expect(taps, 1);
  });

  test('can be pressed without a tap callback', () {
    expect(() => _card().press(), returnsNormally);
  });
}

void _verticalLayoutTests() {
  group('vertical layout', () {
    test('centers the image placeholder vertically', () {
      final card = _card();
      final image = card.imagePlaceholder;

      expect(image.y + image.height / 2, card.height / 2);
    });

    test('aligns the high score label at the top of the card', () {
      final card = _card(highScore: 12540);

      expect(card.highScoreLabel.y, card.titleText.y);
    });

    test('places the high score value below its label', () {
      final card = _card(highScore: 12540);

      expect(
        card.highScoreValue.y,
        greaterThanOrEqualTo(
          card.highScoreLabel.y + card.highScoreLabel.height,
        ),
      );
    });

    test('centers the high score value horizontally below its label', () {
      final card = _card(highScore: 12540);
      final labelCenter = card.highScoreLabel.x - card.highScoreLabel.width / 2;

      expect(card.highScoreValue.anchor, Anchor.topCenter);
      expect(card.highScoreValue.x, closeTo(labelCenter, 0.5));
    });

    test('shows the high score value larger than before', () {
      final style = (_card().highScoreValue.textRenderer as TextPaint).style;

      expect(style.fontSize, greaterThan(22));
    });
  });
}
