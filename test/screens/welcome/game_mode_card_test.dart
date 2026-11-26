import 'package:magic_blocks/screens/welcome/card_button.dart';
import 'package:magic_blocks/screens/welcome/game_mode_card.dart';
import 'package:magic_blocks/theme/light_theme.dart';
import 'package:magic_blocks/theme/welcome_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/load_game_font.dart';

const _description = 'Lorem ipsum dolor sit amet';

Future<void> _pumpCard(
  WidgetTester tester, {
  String description = _description,
  int highScore = 0,
  double width = 360,
  void Function()? onTap,
  String? secondaryLabel,
  void Function()? onSecondaryTap,
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: GameModeCard(
            title: 'Endlosspiel',
            description: description,
            highScore: highScore,
            onTap: onTap,
            secondaryLabel: secondaryLabel,
            onSecondaryTap: onSecondaryTap,
          ),
        ),
      ),
    ),
  ),
);

Rect _card(WidgetTester tester) => tester.getRect(find.byType(GameModeCard));

Rect _text(WidgetTester tester, String text) => tester.getRect(find.text(text));

Rect _image(WidgetTester tester) =>
    tester.getRect(find.byKey(GameModeCard.imageKey));

/// The style a text is really drawn with, including everything it inherits.
TextStyle _styleOf(WidgetTester tester, String text) => tester
    .widget<RichText>(
      find.descendant(of: find.text(text), matching: find.byType(RichText)),
    )
    .text
    .style!;

BoxDecoration _decoration(WidgetTester tester, Key key) =>
    tester.widget<DecoratedBox>(find.byKey(key)).decoration as BoxDecoration;

void main() {
  setUpAll(loadGameFont);

  _contentTests();
  _heightTests();
  _layoutTests();
  _secondaryButtonTests();
  _friendlyLookTests();
}

void _contentTests() {
  testWidgets('shows title and description', (tester) async {
    await _pumpCard(tester);

    expect(find.text('Endlosspiel'), findsOneWidget);
    expect(find.text(_description), findsOneWidget);
  });

  testWidgets('shows the high score with german thousands separator', (
    tester,
  ) async {
    await _pumpCard(tester, highScore: 12540);

    expect(find.text('Höchstpunktzahl'), findsOneWidget);
    expect(find.text('12.540'), findsOneWidget);
  });

  testWidgets('calls onTap when pressed', (tester) async {
    var taps = 0;
    await _pumpCard(tester, onTap: () => taps++);

    await tester.tap(find.text(_description));

    expect(taps, 1);
  });

  testWidgets('can be pressed without a tap callback', (tester) async {
    await _pumpCard(tester);

    await tester.tap(find.byType(GameModeCard));

    expect(tester.takeException(), isNull);
  });
}

void _heightTests() {
  group('height', () {
    final longDescription = List.filled(12, 'Löse Gleichungen.').join(' ');

    testWidgets('has a minimum for a short description', (tester) async {
      await _pumpCard(tester, description: 'Kurz.');

      expect(_card(tester).height, GameModeCard.minHeight);
    });

    testWidgets('grows with a long description', (tester) async {
      await _pumpCard(tester, description: longDescription);

      expect(_card(tester).height, greaterThan(GameModeCard.minHeight));
      expect(
        _text(tester, longDescription).bottom,
        lessThanOrEqualTo(_card(tester).bottom),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the button at the bottom when it grows', (
      tester,
    ) async {
      await _pumpCard(
        tester,
        description: longDescription,
        secondaryLabel: 'Tutorial',
      );

      final button = tester.getRect(find.byType(CardButton));
      expect(_card(tester).bottom - button.bottom, lessThanOrEqualTo(24));
    });
  });
}

void _layoutTests() {
  group('layout', () {
    testWidgets('keeps the title on one line on a narrow phone', (
      tester,
    ) async {
      // card width on a 360 wide screen
      await _pumpCard(tester, width: 328);
      final title = _text(tester, 'Endlosspiel');

      expect(title.height, lessThan(40));
      expect(
        title.right,
        lessThanOrEqualTo(_text(tester, 'Höchstpunktzahl').left),
      );
    });

    testWidgets('has the image on the left of the texts', (tester) async {
      await _pumpCard(tester);

      expect(
        _image(tester).right,
        lessThanOrEqualTo(_text(tester, 'Endlosspiel').left),
      );
    });

    testWidgets('centers the image vertically', (tester) async {
      await _pumpCard(tester);

      expect(
        _image(tester).center.dy,
        closeTo(_card(tester).center.dy, 0.5),
      );
    });

    testWidgets('shows the high score on the right of the title', (
      tester,
    ) async {
      await _pumpCard(tester);

      expect(
        _text(tester, '0').left,
        greaterThan(_text(tester, 'Endlosspiel').left),
      );
    });

    testWidgets('puts the high score below its label, both centered', (
      tester,
    ) async {
      await _pumpCard(tester, highScore: 12540);
      final label = _text(tester, 'Höchstpunktzahl');
      final value = _text(tester, '12.540');

      expect(value.top, greaterThanOrEqualTo(label.bottom));
      expect(value.center.dx, closeTo(label.center.dx, 0.5));
    });
  });
}

void _secondaryButtonTests() {
  group('secondary button', () {
    testWidgets('is missing without a label', (tester) async {
      await _pumpCard(tester);

      expect(find.byType(CardButton), findsNothing);
    });

    testWidgets('shows the label', (tester) async {
      await _pumpCard(tester, secondaryLabel: 'Tutorial');

      expect(
        find.descendant(
          of: find.byType(CardButton),
          matching: find.text('Tutorial'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('calls its own callback and not the one of the card', (
      tester,
    ) async {
      var card = 0;
      var button = 0;
      await _pumpCard(
        tester,
        secondaryLabel: 'Tutorial',
        onTap: () => card++,
        onSecondaryTap: () => button++,
      );

      await tester.tap(find.byType(CardButton));

      expect(button, 1);
      expect(card, 0);
    });

    testWidgets('does not start the card without its own callback', (
      tester,
    ) async {
      var card = 0;
      await _pumpCard(
        tester,
        secondaryLabel: 'Tutorial',
        onTap: () => card++,
      );

      await tester.tap(find.byType(CardButton));

      expect(card, 0);
    });

    testWidgets('sits below the high score, inside the card', (tester) async {
      await _pumpCard(tester, highScore: 12540, secondaryLabel: 'Tutorial');
      final button = tester.getRect(find.byType(CardButton));

      expect(
        button.top,
        greaterThanOrEqualTo(_text(tester, '12.540').bottom),
      );
      expect(button.right, lessThanOrEqualTo(_card(tester).right));
      expect(button.bottom, lessThanOrEqualTo(_card(tester).bottom));
    });

    testWidgets('does not overlap the description', (tester) async {
      await _pumpCard(tester, width: 300, secondaryLabel: 'Tutorial');

      expect(
        _text(tester, _description).right,
        lessThanOrEqualTo(tester.getRect(find.byType(CardButton)).left),
      );
    });

    testWidgets('is a big button that is easy to hit', (tester) async {
      await _pumpCard(tester, secondaryLabel: 'Tutorial');

      expect(
        tester.getSize(find.byType(CardButton)).height,
        greaterThanOrEqualTo(36),
      );
    });

    testWidgets('changes its color while it is held down', (tester) async {
      await _pumpCard(tester, secondaryLabel: 'Tutorial');
      Color? color() => _decoration(tester, CardButton.surfaceKey).color;
      expect(color(), colorScheme.primaryContainer);

      final gesture = await tester.press(find.byType(CardButton));
      await tester.pump(const Duration(milliseconds: 200));
      expect(color(), colorScheme.primary);

      await gesture.up();
      await tester.pump();
      expect(color(), colorScheme.primaryContainer);
    });
  });
}

void _friendlyLookTests() {
  group('friendly look', () {
    testWidgets('uses the colors of the welcome palette for the texts', (
      tester,
    ) async {
      await _pumpCard(tester, highScore: 7);

      expect(
        _styleOf(tester, 'Endlosspiel').color,
        WelcomePalette.cardTitle,
      );
      expect(_styleOf(tester, _description).color, WelcomePalette.cardText);
      expect(
        _styleOf(tester, 'Höchstpunktzahl').color,
        WelcomePalette.cardTextMuted,
      );
      expect(_styleOf(tester, '7').color, WelcomePalette.scoreValue);
    });

    testWidgets('uses big, easy to read letters', (tester) async {
      await _pumpCard(tester, highScore: 7);

      expect(_styleOf(tester, 'Endlosspiel').fontSize, 26);
      expect(_styleOf(tester, _description).fontSize, 15);
      expect(_styleOf(tester, 'Höchstpunktzahl').fontSize, 13);
      expect(_styleOf(tester, '7').fontSize, 30);
    });

    testWidgets('does not take over spacing from the material theme', (
      tester,
    ) async {
      await _pumpCard(tester);

      for (final text in ['Endlosspiel', _description, 'Höchstpunktzahl']) {
        expect(_styleOf(tester, text).letterSpacing, anyOf(isNull, 0));
        expect(_styleOf(tester, text).height, isNull);
      }
    });

    testWidgets('is a white card with an orange border and a shadow', (
      tester,
    ) async {
      await _pumpCard(tester);
      final decoration = _decoration(tester, GameModeCard.surfaceKey);

      expect(decoration.color, WelcomePalette.cardFill);
      expect(
        decoration.border,
        Border.all(color: WelcomePalette.cardBorder, width: 3),
      );
      expect(decoration.boxShadow, const [
        BoxShadow(color: WelcomePalette.cardShadow, offset: Offset(0, 4)),
      ]);
    });

    testWidgets('has strongly rounded corners', (tester) async {
      await _pumpCard(tester);

      expect(GameModeCard.cornerRadius, greaterThanOrEqualTo(20));
      expect(
        _decoration(tester, GameModeCard.surfaceKey).borderRadius,
        BorderRadius.circular(GameModeCard.cornerRadius),
      );
    });
  });
}
