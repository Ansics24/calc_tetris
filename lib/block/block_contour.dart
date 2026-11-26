/// A corner of a cell in grid units, y points downwards.
typedef Corner = (int, int);

/// The directions of an edge, in clockwise order.
const _directions = [(1, 0), (0, 1), (-1, 0), (0, -1)];

/// The outlines around the given cells: every contour lists the corners where
/// it turns, clockwise on screen, starting at its topmost and then leftmost
/// corner. Neighbouring cells share one contour, cells touching only at a
/// corner have their own.
List<List<Corner>> blockContours(Iterable<Corner> cells) {
  final occupied = cells.toSet();
  // the borders between a cell and no cell, as (start corner, direction)
  final edges = <(Corner, int)>{
    for (final (x, y) in occupied) ...[
      if (!occupied.contains((x, y - 1))) ((x, y), 0),
      if (!occupied.contains((x + 1, y))) ((x + 1, y), 1),
      if (!occupied.contains((x, y + 1))) ((x + 1, y + 1), 2),
      if (!occupied.contains((x - 1, y))) ((x, y + 1), 3),
    ],
  };

  final contours = <List<Corner>>[];
  while (edges.isNotEmpty) {
    contours.add(_takeContour(edges));
  }
  return contours;
}

/// Follows the edges once around, removing them from [edges].
List<Corner> _takeContour(Set<(Corner, int)> edges) {
  final first = edges.reduce((a, b) => _isBefore(b.$1, a.$1) ? b : a);
  final corners = <Corner>[];
  var edge = first;
  int? previousDirection;
  while (edges.remove(edge)) {
    final ((x, y), direction) = edge;
    if (direction != previousDirection) {
      corners.add((x, y));
    }
    previousDirection = direction;

    final (dx, dy) = _directions[direction];
    final end = (x + dx, y + dy);
    // turning right first keeps cells apart which only touch at a corner
    for (final turn in const [1, 0, 3]) {
      edge = (end, (direction + turn) % 4);
      if (edges.contains(edge)) {
        break;
      }
    }
  }
  return corners;
}

bool _isBefore(Corner a, Corner b) =>
    a.$2 < b.$2 || (a.$2 == b.$2 && a.$1 < b.$1);
