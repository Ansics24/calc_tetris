import 'package:calc_tetris/block/model/null_block.dart';
import 'package:calc_tetris/block/model/single_block.dart';

List<List<SingleBlock?>> generateI3x1() {
  return List.generate(
    3,
    (_) => List.generate(3, (y) => y == 1 ? null : NullBlock()),
  );
}

List<List<SingleBlock?>> generateS3x2Right() {
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

List<List<SingleBlock?>> generateS3x2Left() {
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

List<List<SingleBlock?>> generatel2x2Left() {
  return List.generate(
    2,
    (x) => List.generate(2, (y) {
      return y == 0 ? null : (x == 1 ? NullBlock() : null);
    }),
  );
}

List<List<SingleBlock?>> generatel2x2Right() {
  return List.generate(
    2,
    (x) => List.generate(2, (y) {
      return y == 0 ? null : (x == 1 ? null : NullBlock());
    }),
  );
}

List<List<SingleBlock?>> generateI2x1() {
  return List.generate(2, (_) => List.filled(1, null));
}

List<List<SingleBlock?>> generate1x1() {
  return List.generate(1, (_) => List.filled(1, null));
}

enum CompoundBlockShape {
  i3x1(generateEmptyFunction: generateI3x1),
  l2x2l(generateEmptyFunction: generatel2x2Left),
  l2x2r(generateEmptyFunction: generatel2x2Right),
  i2x1(generateEmptyFunction: generateI2x1),
  i1x1(generateEmptyFunction: generate1x1),
  ;

  final List<List<SingleBlock?>> Function() _generateEmptyFunction;
  final bool enabled;

  const CompoundBlockShape({
    required this._generateEmptyFunction,
    this.enabled = true,
  });

  List<List<SingleBlock?>> get maskedModel => _generateEmptyFunction();
}
