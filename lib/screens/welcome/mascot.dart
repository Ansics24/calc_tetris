import 'package:flutter/widgets.dart';

/// Mascot of the game. Its image is transparent; the low opacity
/// keeps it a subtle decoration.
class Mascot extends StatelessWidget {
  static const String imageName = 'mascot.png';
  static const double _opacity = 0.45;

  /// Width and height of the mascot.
  final double? size;

  const Mascot({super.key, this.size});

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/$imageName',
    width: size,
    height: size,
    fit: BoxFit.fill,
    opacity: const AlwaysStoppedAnimation(_opacity),
  );
}
