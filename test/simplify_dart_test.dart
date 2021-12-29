import 'dart:math';

import 'package:simplify_dart/simplify_dart.dart';
import 'package:test/test.dart';

import 'fixtures/test_points.dart' as test_points;

Point deserializePoint(Map<String, num> serialized) =>
    Point(serialized['x']!, serialized['y']!);

void main() {
  final points = test_points.points.map(deserializePoint).toList();
  final simplified = test_points.simplified.map(deserializePoint).toList();

  group('simplify', () {
    test('simplifies points correctly with the given tolerance', () {
      final result = simplify(points, tolerance: 5);

      expect(result, containsAllInOrder(simplified));
    });

    test('just return the points if it has only one point', () {
      final result = simplify([Point(1, 2)]);

      expect(result, containsAllInOrder([Point(1, 2)]));
    });

    test('just return the points if it has no points', () {
      final result = simplify([]);

      expect(result, isEmpty);
    });
  });
}
