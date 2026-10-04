import 'dart:math';

import 'package:test/test.dart';
import 'package:vector_tile_renderer/src/features/symbol_line_renderer.dart';

void main() {
  const deg = pi / 180;

  group('north-up map', () {
    test('keeps a label that already reads left to right', () {
      expect(rightSideUpAngle(30 * deg, 0), closeTo(30 * deg, 1e-9));
      expect(rightSideUpAngle(-80 * deg, 0), closeTo(-80 * deg, 1e-9));
    });

    test('flips a label that would read upside down', () {
      expect(rightSideUpAngle(150 * deg, 0), closeTo(330 * deg, 1e-9));
      expect(rightSideUpAngle(-120 * deg, 0), closeTo(60 * deg, 1e-9));
    });

    test('tolerates a small overshoot past vertical', () {
      expect(rightSideUpAngle(92 * deg, 0), closeTo(92 * deg, 1e-9));
      expect(rightSideUpAngle(94 * deg, 0), closeTo(274 * deg, 1e-9));
    });
  });

  group('rotated map', () {
    test('flips a label that the rotation turns upside down', () {
      // Upright on a north-up tile, but the map turns it 180°.
      expect(rightSideUpAngle(10 * deg, pi), closeTo(190 * deg, 1e-9));
      // 60° + 45° = 105° on screen.
      expect(rightSideUpAngle(60 * deg, 45 * deg), closeTo(240 * deg, 1e-9));
    });

    test('keeps a label that the rotation turns right side up', () {
      // Upside down on the tile, upright once the map turns it.
      expect(rightSideUpAngle(150 * deg, -90 * deg), closeTo(150 * deg, 1e-9));
      expect(rightSideUpAngle(170 * deg, pi), closeTo(170 * deg, 1e-9));
    });

    test('wraps the summed angle across a full turn', () {
      expect(rightSideUpAngle(10 * deg, 2 * pi), closeTo(10 * deg, 1e-9));
      expect(rightSideUpAngle(10 * deg, -315 * deg), closeTo(10 * deg, 1e-9));
    });
  });
}
