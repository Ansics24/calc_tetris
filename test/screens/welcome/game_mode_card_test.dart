import 'dart:ui';

import 'package:calc_tetris/screens/welcome/game_mode_card.dart';
import 'package:calc_tetris/theme/welcome_palette.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextStyle;
import 'package:test/test.dart';

GameModeCard _card({
  int highScore = 0,
  void Function()? onTap,
  String? secondaryLabel,
  void Function()? onSecondaryTap,
}) => GameModeCard(
  title: 'Endlosspiel',
  description: 'Lorem ipsum dolor sit amet',
  highScore: highScore,
  size: Vector2(360, 150),
  onTap: onTap,
  secondaryLabel: secondaryLabel,
  onSecondaryTap: onSecondaryTap,
);

void main() {
  _verticalLayoutTests();
  _secondaryButtonTests();
  _friendlyLookTests();

  test('shows title and description', () {
    final card = _card();

    expect(card.titleText.text, 'Endlosspiel');
    expect(card.descriptionText.text, 'Lorem ipsum dolor sit amet');
  });

  test('has an image placeholder on the left of the texts', () {
    final card = _card();

    expect(card.image.x, lessThan(card.titleText.x));
  });

  test('shows the high score with german thousands separator', () {
    final card = _card(highScore: 12540);

    expect(card.highScoreLabel.text, 'Höchstpunktzahl');
    expect(card.highScoreValue.text, '12.540');
  });

  test('shows a new high score after it was updated', () {
    final card = _card(highScore: 7);

    card.updateHighScore(12540);

    expect(card.highScoreValue.text, '12.540');
  });

  test('stays centered below its label after the high score was updated', () {
    final card = _card(highScore: 7);
    final x = card.highScoreValue.x;

    card.updateHighScore(12540);

    expect(card.highScoreValue.x, x);
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

void _secondaryButtonTests() {
  group('secondary button', () {
    test('is missing without a label', () {
      expect(_card().secondaryButton, isNull);
    });

    test('shows the label', () {
      expect(
        _card(secondaryLabel: 'Tutorial').secondaryButton!.label,
        'Tutorial',
      );
    });

    test('calls its own callback and not the one of the card', () {
      var card = 0;
      var button = 0;
      final c = _card(
        secondaryLabel: 'Tutorial',
        onTap: () => card++,
        onSecondaryTap: () => button++,
      );

      c.secondaryButton!.press();

      expect(button, 1);
      expect(card, 0);
    });

    test('can be pressed without a callback', () {
      final c = _card(secondaryLabel: 'Tutorial');

      expect(c.secondaryButton!.press, returnsNormally);
    });

    test('sits below the high score on the right side of the card', () {
      final c = _card(highScore: 12540, secondaryLabel: 'Tutorial');
      final button = c.secondaryButton!;

      expect(
        button.y,
        greaterThanOrEqualTo(c.highScoreValue.y + c.highScoreValue.height),
      );
      expect(button.x, greaterThan(c.titleText.x));
      expect(button.x + button.width, lessThanOrEqualTo(c.width));
    });

    test('does not overlap the description', () {
      final c = _card(secondaryLabel: 'Tutorial');

      // the box wraps its text at maxWidth, so it ends before the button
      expect(
        c.descriptionText.x + c.descriptionText.boxConfig.maxWidth,
        lessThanOrEqualTo(c.secondaryButton!.x),
      );
    });

    test('stays inside the card, also after a resize', () {
      final c = _card(secondaryLabel: 'Tutorial')..resizeTo(Vector2(300, 150));
      final button = c.secondaryButton!;

      expect(button.x + button.width, lessThanOrEqualTo(300));
      expect(button.y + button.height, lessThanOrEqualTo(150));
    });

    test('is a big button that is easy to hit', () {
      final button = _card(secondaryLabel: 'Tutorial').secondaryButton!;

      expect(button.height, greaterThanOrEqualTo(36));
    });
  });
}

void _verticalLayoutTests() {
  group('vertical layout', () {
    test('centers the image placeholder vertically', () {
      final card = _card();
      final image = card.image;

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

TextStyle _styleOf(TextComponent text) =>
    (text.textRenderer as TextPaint).style;

void _friendlyLookTests() {
  group('friendly look', () {
    test('uses the colors of the welcome palette for the texts', () {
      final card = _card();

      expect(_styleOf(card.titleText).color, WelcomePalette.cardTitle);
      expect(_styleOf(card.descriptionText).color, WelcomePalette.cardText);
      expect(
        _styleOf(card.highScoreLabel).color,
        WelcomePalette.cardTextMuted,
      );
      expect(_styleOf(card.highScoreValue).color, WelcomePalette.scoreValue);
    });

    test('uses big, easy to read letters', () {
      final card = _card();

      expect(_styleOf(card.titleText).fontSize, greaterThanOrEqualTo(26));
      expect(
        _styleOf(card.descriptionText).fontSize,
        greaterThanOrEqualTo(15),
      );
      expect(_styleOf(card.highScoreLabel).fontSize, greaterThanOrEqualTo(13));
    });

    test('has strongly rounded corners', () {
      expect(GameModeCard.cornerRadius, greaterThanOrEqualTo(20));
    });

    test('paints a light card', () async {
      final recorder = PictureRecorder();
      _card().render(Canvas(recorder));
      final image = await recorder.endRecording().toImage(360, 150);
      final bytes = (await image.toByteData())!;
      // pixel inside the card, left of the image placeholder
      final offset = (75 * 360 + 6) * 4;
      final pixel = Color.fromARGB(
        bytes.getUint8(offset + 3),
        bytes.getUint8(offset),
        bytes.getUint8(offset + 1),
        bytes.getUint8(offset + 2),
      );

      expect(pixel, WelcomePalette.cardFill);
    });
  });
}
