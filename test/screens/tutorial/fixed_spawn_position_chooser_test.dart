import 'package:magic_blocks/block/math/seed/spawn_position_chooser.dart';
import 'package:magic_blocks/screens/tutorial/fixed_spawn_position_chooser.dart';
import 'package:magic_blocks/util/int_vector_2.dart';
import 'package:test/test.dart';

void main() {
  test('is a spawn position chooser', () {
    expect(
      FixedSpawnPositionChooser(IntVector2(7, 2)),
      isA<SpawnPositionChooser>(),
    );
  });

  test('always chooses its position when it is a candidate', () {
    final chooser = FixedSpawnPositionChooser(IntVector2(7, 2));

    final chosen = chooser.choose([IntVector2(0, 0), IntVector2(7, 2)]);

    expect(chosen.x, 7);
    expect(chosen.y, 2);
  });

  test('throws when its position is not free', () {
    final chooser = FixedSpawnPositionChooser(IntVector2(7, 2));

    expect(() => chooser.choose([IntVector2(0, 0)]), throwsStateError);
  });
}
