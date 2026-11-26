import 'package:magic_blocks/theme/light_theme.dart';
import 'package:magic_blocks/theme/text_theme.dart';
import 'package:flutter/widgets.dart';

/// Small rounded button inside a game mode card. Handles its taps itself, so
/// the card below does not react to them.
class CardButton extends StatefulWidget {
  static const Key surfaceKey = Key('card-button-surface');
  static const double height = 38;

  final String label;
  final void Function()? onPressed;

  const CardButton({super.key, required this.label, this.onPressed});

  @override
  State<CardButton> createState() => _CardButtonState();
}

class _CardButtonState extends State<CardButton> {
  bool _pressed = false;

  void _setPressed(bool pressed) => setState(() => _pressed = pressed);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      // always claims the tap, even without a callback
      onTap: () => widget.onPressed?.call(),
      child: DecoratedBox(
        key: CardButton.surfaceKey,
        decoration: BoxDecoration(
          color: _pressed ? colorScheme.primary : colorScheme.primaryContainer,
          border: Border.all(color: colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(CardButton.height / 2),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: CardButton.height),
          child: Center(
            heightFactor: 1,
            child: Text(
              widget.label,
              style: textTheme.labelLarge!.copyWith(
                inherit: false,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
