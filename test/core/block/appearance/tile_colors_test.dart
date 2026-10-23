import 'package:calc_tetris/core/block/appearance/tile_colors.dart';
import 'package:flutter/painting.dart';
import 'package:test/test.dart';

void main() {
  blockFamilyTests();
  test('every digit has its own tile color', () {
    final colors = List.generate(10, TileColors.forDigit).toSet();
    expect(colors.length, 10);
  });

  test('digits outside 0-9 wrap around, so multi-digit numbers never fail', () {
    expect(TileColors.forDigit(12), TileColors.forDigit(2));
    expect(TileColors.forDigit(-3), TileColors.forDigit(7));
  });

  test('plus, minus and equals are distinguishable from each other', () {
    final colors = {
      TileColors.plus,
      TileColors.minus,
      TileColors.equals,
    };
    expect(colors.length, 3);
  });

  test('a tile color derives a lighter top and a darker bottom shade', () {
    final color = TileColors.forDigit(4);
    expect(
      color.light.computeLuminance(),
      greaterThan(color.base.computeLuminance()),
    );
    expect(
      color.dark.computeLuminance(),
      lessThan(color.base.computeLuminance()),
    );
  });
}

void _expectHue(TileColor color, double min, double max) {
  final hue = HSLColor.fromColor(color.base).hue;
  expect(hue, inInclusiveRange(min, max));
}

void blockFamilyTests() {
  test('all digits are blue tones', () {
    for (var digit = 0; digit < 10; digit++) {
      _expectHue(TileColors.forDigit(digit), 180, 240);
    }
  });

  test('operators are yellowish', () {
    _expectHue(TileColors.plus, 35, 55);
    _expectHue(TileColors.minus, 35, 55);
  });

  test('equals is green', () {
    _expectHue(TileColors.equals, 100, 150);
  });
}
