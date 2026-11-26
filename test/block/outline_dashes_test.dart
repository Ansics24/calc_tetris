import 'package:magic_blocks/block/outline_dashes.dart';
import 'package:test/test.dart';

/// Dashes are `(start, end)` distances along a closed contour.
void main() {
  test('spreads dashes and gaps of the same length over the contour', () {
    expect(outlineDashes(length: 40, spacing: 10, phase: 0), [
      (0, 5),
      (10, 15),
      (20, 25),
      (30, 35),
    ]);
  });

  test('moves the dashes forward along the contour with the phase', () {
    expect(outlineDashes(length: 20, spacing: 10, phase: 0.2), [
      (2, 7),
      (12, 17),
    ]);
  });

  test('continues a dash at the start when it passes the end', () {
    expect(outlineDashes(length: 20, spacing: 10, phase: 0.7), [
      (7, 12),
      (17, 20),
      (0, 2),
    ]);
  });

  test('stretches the spacing so that the contour has no seam', () {
    expect(outlineDashes(length: 22, spacing: 10, phase: 0), [
      (0, 5.5),
      (11, 16.5),
    ]);
  });
}
