import 'package:calc_tetris/screens/welcome/game_mode_card.dart';
import 'package:calc_tetris/screens/welcome/sky_background.dart';
import 'package:calc_tetris/theme/welcome_palette.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Start screen: logo on top, one card per game mode below.
class WelcomeScreen extends PositionComponent {
  static const double _margin = 16;
  static const double _logoHeight = 140;
  static const double _cardHeight = 150;
  static const double _gap = 16;

  final SkyBackground background = SkyBackground();

  final RectangleComponent logoPlaceholder = _LogoPlaceholder();

  late final List<GameModeCard> cards;

  WelcomeScreen({int endlessHighScore = 0, void Function()? onStartEndless}) {
    cards = [
      GameModeCard(
        title: 'Endlosspiel',
        description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        highScore: endlessHighScore,
        size: Vector2(0, _cardHeight),
        onTap: onStartEndless,
      ),
    ];
    _layout();
  }

  @override
  Future<void> onLoad() async {
    await add(background);
    await add(logoPlaceholder);
    await addAll(cards);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _layout();
  }

  void _layout() {
    background
      ..position = Vector2.zero()
      ..size = size.clone();
    final contentWidth = width - 2 * _margin;
    logoPlaceholder
      ..position = Vector2(_margin, _margin)
      ..size = Vector2(contentWidth, _logoHeight);
    var y = _margin + _logoHeight + _gap;
    for (final card in cards) {
      card
        ..resizeTo(Vector2(contentWidth, _cardHeight))
        ..position = Vector2(_margin, y);
      y += _cardHeight + _gap;
    }
  }
}

/// Light, rounded stand-in for the logo.
class _LogoPlaceholder extends RectangleComponent {
  _LogoPlaceholder() : super(paint: Paint()..color = WelcomePalette.logoFill);

  @override
  void render(Canvas canvas) {
    final shape = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(GameModeCard.cornerRadius),
    );
    canvas.drawRRect(shape, paint);
    canvas.drawRRect(
      shape.deflate(1.5),
      Paint()
        ..color = WelcomePalette.logoBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}
