import 'package:calc_tetris/core/block/model/math_single_block.dart';
import 'package:calc_tetris/core/block/model/null_block.dart';

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

List<List<MathSingleBlock?>> generateS3x2() {
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

enum CompoundBlockShape {
  b2x2(generateEmptyFunction: generateB2x2),
  t3x2(generateEmptyFunction: generateT3x2),
  lLeft3x2(
    generateEmptyFunction: generateLLeft3x2,
  ),
  lRight3x2(
    generateEmptyFunction: generateLRight3x2,
  ),
  i4x1(generateEmptyFunction: generateI4x1),
  s3x2(generateEmptyFunction: generateS3x2);

  final List<List<MathSingleBlock?>> Function() _generateEmptyFunction;

  const CompoundBlockShape({
    required this._generateEmptyFunction,
  });

  List<List<MathSingleBlock?>> get maskedModel => _generateEmptyFunction();
}
