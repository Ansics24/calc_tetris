import 'package:magic_blocks/screens/welcome/card_button.dart';
import 'package:magic_blocks/theme/text_theme.dart';
import 'package:magic_blocks/theme/welcome_palette.dart';
import 'package:magic_blocks/util/german_number_format.dart';
import 'package:flutter/widgets.dart';

/// Card presenting one game mode with its image, description and high score.
/// It is as high as its content needs, but at least [minHeight].
class GameModeCard extends StatelessWidget {
  static const Key surfaceKey = Key('game-mode-card-surface');
  static const Key imageKey = Key('game-mode-card-image');
  static const double cornerRadius = 24;
  static const double minHeight = 170;
  static const double _borderWidth = 3;
  static const double _padding = 14;
  static const double _imageSize = 72;
  static const double _scoreColumnWidth = 110;
  static const double _titleHeight = 44;
  static const double _descriptionMargin = 8;
  static const double _scoreGap = 2;

  final String title;
  final String description;

  /// Name of the image in the image assets, e.g. `trophy.png`.
  final String? imageName;
  final int highScore;
  final void Function()? onTap;

  /// Label of an optional button inside the card, e.g. to start a tutorial.
  final String? secondaryLabel;
  final void Function()? onSecondaryTap;

  const GameModeCard({
    super.key,
    required this.title,
    required this.description,
    required this.highScore,
    this.imageName,
    this.onTap,
    this.secondaryLabel,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        key: surfaceKey,
        decoration: BoxDecoration(
          color: WelcomePalette.cardFill,
          border: Border.all(
            color: WelcomePalette.cardBorder,
            width: _borderWidth,
          ),
          borderRadius: BorderRadius.circular(cornerRadius),
          boxShadow: const [
            BoxShadow(color: WelcomePalette.cardShadow, offset: Offset(0, 4)),
          ],
        ),
        // lets the columns share the height of the highest one
        child: IntrinsicHeight(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: const EdgeInsets.all(_padding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: _image()),
                  const SizedBox(width: _padding),
                  Expanded(child: _texts()),
                  SizedBox(width: _scoreColumnWidth, child: _scoreColumn()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _image() {
    final name = imageName;
    return SizedBox.square(
      key: imageKey,
      dimension: _imageSize,
      child: name == null
          ? null
          : Image.asset('assets/images/$name', fit: BoxFit.fill),
    );
  }

  Widget _texts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _titleHeight),
          // shrinks the title instead of wrapping it on narrow screens
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: _text(
              title,
              textTheme.headlineMedium!,
              WelcomePalette.cardTitle,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(_descriptionMargin),
          child: _text(
            description,
            textTheme.bodyMedium!,
            WelcomePalette.cardText,
          ),
        ),
      ],
    );
  }

  /// High score at the top, the secondary button at the bottom.
  Widget _scoreColumn() {
    final label = secondaryLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _text(
              'Höchstpunktzahl',
              textTheme.labelMedium!,
              WelcomePalette.cardTextMuted,
            ),
            const SizedBox(height: _scoreGap),
            _text(
              formatGermanNumber(highScore),
              textTheme.displaySmall!,
              WelcomePalette.scoreValue,
            ),
          ],
        ),
        if (label != null)
          SizedBox(
            width: _scoreColumnWidth - _padding / 2,
            child: CardButton(label: label, onPressed: onSecondaryTap),
          ),
      ],
    );
  }

  /// Text without the spacing the surrounding material theme would add.
  Widget _text(String text, TextStyle style, Color color) =>
      Text(text, style: style.copyWith(inherit: false, color: color));
}
