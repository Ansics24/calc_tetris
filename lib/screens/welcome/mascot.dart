import 'dart:async';

import 'package:flame/components.dart';

/// Mascot of the game. Its image is transparent; the low opacity
/// keeps it a subtle decoration.
class Mascot extends SpriteComponent {
  static const String imageName = 'mascot.png';

  Mascot({super.size, super.position}) : super(priority: -1) {
    opacity = 0.45;
  }

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load(imageName);
  }
}
