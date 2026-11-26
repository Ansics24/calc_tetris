import 'package:magic_blocks/screens/tutorial/tutorial_message_overlay.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:test/test.dart';

TutorialMessageOverlay _overlay({
  String text = 'Ziehe den Stein.',
  String buttonLabel = 'Weiter',
  void Function()? onContinue,
}) => TutorialMessageOverlay(
  text: text,
  buttonLabel: buttonLabel,
  size: Vector2(400, 800),
  onContinue: onContinue ?? () {},
);

void main() {
  test('shows the text and the label of the button', () {
    final overlay = _overlay(text: 'Hallo', buttonLabel: 'Los');

    expect(overlay.messageText.text, 'Hallo');
    expect(overlay.continueButton.label, 'Los');
  });

  test('continues when the button is pressed', () {
    var continued = 0;
    final overlay = _overlay(onContinue: () => continued++);

    overlay.continueButton.press();

    expect(continued, 1);
  });

  test('covers the whole game and is drawn above it', () {
    final overlay = _overlay();

    expect(overlay.size, Vector2(400, 800));
    expect(overlay.priority, greaterThanOrEqualTo(1000));
  });

  test('swallows taps and drags so the board below stays untouched', () {
    final overlay = _overlay();

    expect(overlay, isA<TapCallbacks>());
    expect(overlay, isA<DragCallbacks>());
  });

  group('panel', () {
    test('sits at the bottom and leaves the upper half of the board free', () {
      final panel = _overlay().panelRect;

      expect(panel.bottom, lessThanOrEqualTo(800));
      expect(panel.top, greaterThanOrEqualTo(400));
    });

    test('contains the text and the button', () {
      final overlay = _overlay();
      final panel = overlay.panelRect;

      expect(
        panel.contains(overlay.messageText.toRect().topLeft),
        isTrue,
      );
      expect(
        panel.contains(overlay.continueButton.toRect().bottomRight),
        isTrue,
      );
    });

    test('wraps the text inside the panel width', () {
      final overlay = _overlay(text: 'Wort ' * 80);

      expect(overlay.messageText.toRect().right, lessThanOrEqualTo(400));
      expect(overlay.messageText.toRect().left, greaterThanOrEqualTo(0));
    });
  });
}
