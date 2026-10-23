import 'package:calc_tetris/global/hud/german_number_format.dart';
import 'package:test/test.dart';

void main() {
  test('small numbers stay as they are', () {
    expect(formatGermanNumber(0), '0');
    expect(formatGermanNumber(999), '999');
  });

  test('thousands are separated by a dot', () {
    expect(formatGermanNumber(1000), '1.000');
    expect(formatGermanNumber(12540), '12.540');
    expect(formatGermanNumber(1234567), '1.234.567');
  });
}
