// to suit your point format, run search/replace for '.x' and '.y';
// for 3D version, see 3d branch (configurability would draw significant performance overhead)

// square distance between 2 points
import 'dart:math';

// square distance from a point to a segment
num getSqSegDist(Point p, Point p1, Point p2) {
  var x = p1.x, y = p1.y, dx = p2.x - x, dy = p2.y - y;

  if (dx != 0 || dy != 0) {
    var t = ((p.x - x) * dx + (p.y - y) * dy) / (dx * dx + dy * dy);

    if (t > 1) {
      x = p2.x;
      y = p2.y;
    } else if (t > 0) {
      x += dx * t;
      y += dy * t;
    }
  }

  dx = p.x - x;
  dy = p.y - y;

  return dx * dx + dy * dy;
}
// rest of the code doesn't care about point format

// basic distance-based simplification
List<Point> simplifyRadialDist(List<Point> points, num sqTolerance) {
  var prevPoint = points[0];
  var newPoints = [prevPoint];

  Point? point;
  for (var i = 1, len = points.length; i < len; i++) {
    point = points[i];

    if (point.squaredDistanceTo(prevPoint) > sqTolerance) {
      newPoints.add(point);
      prevPoint = point;
    }
  }

  if (prevPoint != point) newPoints.add(point!);

  return newPoints;
}

void simplifyDPStep(List<Point> points, int first, int last, num sqTolerance,
    List<Point> simplified) {
  var maxSqDist = sqTolerance;
  var index = 0;

  for (var i = first + 1; i < last; i++) {
    var sqDist = getSqSegDist(points[i], points[first], points[last]);

    if (sqDist > maxSqDist) {
      index = i;
      maxSqDist = sqDist;
    }
  }

  if (maxSqDist > sqTolerance) {
    if (index - first > 1) {
      simplifyDPStep(points, first, index, sqTolerance, simplified);
    }
    simplified.add(points[index]);
    if (last - index > 1) {
      simplifyDPStep(points, index, last, sqTolerance, simplified);
    }
  }
}

// simplification using Ramer-Douglas-Peucker algorithm
List<Point> simplifyDouglasPeucker(List<Point> points, num sqTolerance) {
  final last = points.length - 1;

  final simplified = [points[0]];
  simplifyDPStep(points, 0, last, sqTolerance, simplified);
  simplified.add(points[last]);

  return simplified;
}

// both algorithms combined for awesome performance
List<Point> simplify(List<Point> points,
    {num? tolerance, bool highestQuality = false}) {
  if (points.length <= 2) return points;

  final sqTolerance = tolerance != null ? tolerance * tolerance : 1;

  points = highestQuality ? points : simplifyRadialDist(points, sqTolerance);
  points = simplifyDouglasPeucker(points, sqTolerance);

  return points;
}
