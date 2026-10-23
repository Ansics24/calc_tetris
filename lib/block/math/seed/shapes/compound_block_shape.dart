import 'package:calc_tetris/block/math/model/math_single_block.dart';
import 'package:calc_tetris/block/math/model/null_block.dart';

List<List<MathSingleBlock?>> generateB2x2() {
  return List.generate(2, (_) => List.generate(2, (_) => null));
}

List<List<MathSingleBlock?>> generateT3x2() {
  return List.generate(
    3,
    (x) => List.generate(3, (y) {
      if (y == 0) {
        return null;
      } else if (y == 2) {
        return NullBlock();
      }
      return x == 1 ? null : NullBlock();
    }),
  );
}

List<List<MathSingleBlock?>> generateLLeft3x2() {
  return List.generate(
    3,
    (x) => List.generate(3, (y) {
      if (y == 0) {
        return null;
      } else if (y == 2) {
        return NullBlock();
      }
      return x == 0 ? null : NullBlock();
    }),
  );
}

List<List<MathSingleBlock?>> generateLRight3x2() {
  return List.generate(
    3,
    (x) => List.generate(3, (y) {
      if (y == 0) {
        return null;
      } else if (y == 2) {
        return NullBlock();
      }
      return x == 2 ? null : NullBlock();
    }),
  );
}

List<List<MathSingleBlock?>> generateI4x1() {
  return List.generate(
    4,
    (_) => List.generate(4, (y) => y == 1 ? null : NullBlock()),
  );
}

List<List<MathSingleBlock?>> generateI3x1() {
  return List.generate(
    3,
    (_) => List.generate(3, (y) => y == 1 ? null : NullBlock()),
  );
}

List<List<MathSingleBlock?>> generateS3x2Right() {
  return List.generate(
    3,
    (x) => List.generate(3, (y) {
      if (y == 0) {
        return x == 0 ? NullBlock() : null;
      } else if (y == 2) {
        return NullBlock();
      }
      return x == 2 ? NullBlock() : null;
    }),
  );
}

List<List<MathSingleBlock?>> generateS3x2Left() {
  return List.generate(
    3,
    (x) => List.generate(3, (y) {
      if (y == 0) {
        return x == 2 ? NullBlock() : null;
      } else if (y == 2) {
        return NullBlock();
      }
      return x == 2 ? NullBlock() : null;
    }),
  );
}

List<List<MathSingleBlock?>> generatel2x2Left() {
  return List.generate(
    2,
    (x) => List.generate(2, (y) {
      return y == 0 ? null : (x == 1 ? NullBlock() : null);
    }),
  );
}

List<List<MathSingleBlock?>> generatel2x2Right() {
  return List.generate(
    2,
    (x) => List.generate(2, (y) {
      return y == 0 ? null : (x == 1 ? null : NullBlock());
    }),
  );
}

List<List<MathSingleBlock?>> generateI2x1() {
  return List.generate(2, (_) => List.filled(1, null));
}

List<List<MathSingleBlock?>> generate1x1() {
  return List.generate(1, (_) => List.filled(1, null));
}

enum CompoundBlockShape {
  b2x2(generateEmptyFunction: generateB2x2, enabled: false),
  t3x2(generateEmptyFunction: generateT3x2, enabled: true),
  lLeft3x2(generateEmptyFunction: generateLLeft3x2, enabled: false),
  lRight3x2(generateEmptyFunction: generateLRight3x2, enabled: false),
  i4x1(generateEmptyFunction: generateI4x1, enabled: true),
  i3x1(generateEmptyFunction: generateI3x1, enabled: true),
  s3x2r(generateEmptyFunction: generateS3x2Right, enabled: true),
  s3x2l(generateEmptyFunction: generateS3x2Left, enabled: true),
  l2x2l(generateEmptyFunction: generatel2x2Left),
  l2x2r(generateEmptyFunction: generatel2x2Right),
  i2x1(generateEmptyFunction: generateI2x1),
  i1x1(generateEmptyFunction: generate1x1),
  ;

  final List<List<MathSingleBlock?>> Function() _generateEmptyFunction;
  final bool enabled;

  const CompoundBlockShape({
    required this._generateEmptyFunction,
    this.enabled = true,
  });

  List<List<MathSingleBlock?>> get maskedModel => _generateEmptyFunction();
}
