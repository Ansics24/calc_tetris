import 'dart:ui';

import 'package:flame/components.dart';
import 'package:magic_blocks/block/block_contour.dart';
import 'package:magic_blocks/block/compound_block_component.dart';
import 'package:magic_blocks/block/outline_dashes.dart';
import 'package:magic_blocks/grid/grid.dart';
import 'package:magic_blocks/theme/light_theme.dart';

/// A subtle border around the visible blocks of its [CompoundBlockComponent],
/// with dashes slowly running clockwise. Marks the block the player controls
/// and is not shown while that block is locked.
class ActiveBlockOutline extends Component
    with ParentIsA<CompoundBlockComponent> {
  static const double cellsPerSecond = 0.4;
  static const double dashSpacingInCells = 0.5;

  static const double _widthInCells = 0.07;

  double _phase = 0;
  double _cellSize = 0;

  ActiveBlockOutline() : super(priority: 10);

  /// How far the dashes have moved towards the next one, from 0 to 1.
  double get phase => _phase;

  bool get isShown => !parent.isLocked;

  /// The contours around the visible blocks in cells of the block.
  List<List<Corner>> get contours => blockContours(
    parent.getLocalSingleBlockPositions().map((cell) => (cell.x, cell.y)),
  );

  @override
  void onMount() {
    super.onMount();
    _cellSize = parent.findParent<Grid>()!.cellSize;
  }

  @override
  void update(double dt) {
    _phase = (_phase + dt * cellsPerSecond / dashSpacingInCells) % 1;
  }

  @override
  void render(Canvas canvas) {
    if (!isShown) {
      return;
    }
    final width = _cellSize * _widthInCells;
    // dark dashes in a light seam stand out on the board and on the tiles
    final seam = _stroke(width * 1.8, colorScheme.surface);
    final track = _stroke(width, colorScheme.onSurface.withValues(alpha: 0.35));
    final dash = _stroke(width, colorScheme.onSurface);

    for (final corners in contours) {
      final path = Path()
        ..addPolygon([
          for (final (x, y) in corners) Offset(x * _cellSize, y * _cellSize),
        ], true);
      canvas.drawPath(path, seam);
      canvas.drawPath(path, track);

      for (final metric in path.computeMetrics()) {
        for (final (start, end) in outlineDashes(
          length: metric.length,
          spacing: _cellSize * dashSpacingInCells,
          phase: _phase,
        )) {
          canvas.drawPath(metric.extractPath(start, end), dash);
        }
      }
    }
  }

  Paint _stroke(double width, Color color) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color;
}
