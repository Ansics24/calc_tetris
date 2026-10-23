import 'package:flutter/painting.dart';

/// Base color of a block tile plus the lighter and darker shades used for its
/// glossy gradient.
class TileColor {
  final Color base;

  const TileColor(this.base);

  Color get light => _withLightness(0.18);

  Color get dark => _withLightness(-0.18);

  Color _withLightness(double delta) {
    final hsl = HSLColor.fromColor(base);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool operator ==(Object other) => other is TileColor && other.base == base;

  @override
  int get hashCode => base.hashCode;
}

/// Colors of the block tiles: every digit has its own, the operators share
/// one color per kind.
abstract final class TileColors {
  static const List<TileColor> _digits = [
    TileColor(Color(0xFF3B5BDB)),
    TileColor(Color(0xFF4C6EF5)),
    TileColor(Color(0xFF339AF0)),
    TileColor(Color(0xFF1C7ED6)),
    TileColor(Color(0xFF22B8CF)),
    TileColor(Color(0xFF1971C2)),
    TileColor(Color(0xFF5C7CFA)),
    TileColor(Color(0xFF4DABF7)),
    TileColor(Color(0xFF3A86C8)),
    TileColor(Color(0xFF2B6CB0)),
  ];

  static const TileColor plus = TileColor(Color(0xFFF0B323));
  static const TileColor minus = TileColor(Color(0xFFE3C04A));
  static const TileColor equals = TileColor(Color(0xFF3FA34D));

  static TileColor forDigit(int digit) => _digits[digit % 10];
}
