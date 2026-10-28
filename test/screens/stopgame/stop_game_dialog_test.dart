import 'package:calc_tetris/screens/stopgame/stop_game_dialog.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:test/test.dart';

StopGameDialog _dialog({
  void Function()? onConfirm,
  void Function()? onCancel,
}) => StopGameDialog(
  size: Vector2(400, 800),
  onConfirm: onConfirm ?? () {},
  onCancel: onCancel ?? () {},
);

void main() {
  test('asks in german whether the game should really end', () {
    expect(_dialog().messageText.text, 'Spiel wirklich beenden?');
  });

  test('offers Ja and Nein', () {
    final dialog = _dialog();

    expect(dialog.yesButton.label, 'Ja');
    expect(dialog.noButton.label, 'Nein');
  });

  test('places the buttons side by side below the message', () {
    final dialog = _dialog();

    expect(dialog.yesButton.y, dialog.noButton.y);
    expect(dialog.yesButton.x, lessThan(dialog.noButton.x));
    expect(dialog.yesButton.y, greaterThan(dialog.messageText.y));
  });

  test('keeps the buttons inside the dialog size', () {
    final dialog = _dialog();

    for (final button in [dialog.yesButton, dialog.noButton]) {
      expect(button.x, greaterThanOrEqualTo(0));
      expect(button.x + button.width, lessThanOrEqualTo(400));
      expect(button.y + button.height, lessThanOrEqualTo(800));
    }
  });

  test('confirms when Ja is pressed', () {
    var confirmed = 0;
    var cancelled = 0;
    final dialog = _dialog(
      onConfirm: () => confirmed++,
      onCancel: () => cancelled++,
    );

    dialog.yesButton.press();

    expect(confirmed, 1);
    expect(cancelled, 0);
  });

  test('cancels when Nein is pressed', () {
    var confirmed = 0;
    var cancelled = 0;
    final dialog = _dialog(
      onConfirm: () => confirmed++,
      onCancel: () => cancelled++,
    );

    dialog.noButton.press();

    expect(cancelled, 1);
    expect(confirmed, 0);
  });

  test('covers the whole game and is drawn above it', () {
    final dialog = _dialog();

    expect(dialog.size, Vector2(400, 800));
    expect(dialog.priority, greaterThanOrEqualTo(1000));
  });

  test('swallows taps and drags so the game below stays untouched', () {
    final dialog = _dialog();

    expect(dialog, isA<TapCallbacks>());
    expect(dialog, isA<DragCallbacks>());
  });
}
