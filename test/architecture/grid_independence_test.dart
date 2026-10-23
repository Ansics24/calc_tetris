import 'dart:io';

import 'package:test/test.dart';

/// Files below `lib/block/math` that are not math specific but still live
/// there. They are allowed until they are moved to a neutral place.
const _allowedGenericFiles = {
  'scoring/score_keeper.dart',
  'seed/next_block_planner.dart',
  'seed/compoundblock_model_generator.dart',
  'seed/spawn_origin.dart',
  'seed/free_start_columns.dart',
  'seed/start_column_chooser.dart',
};

void main() {
  test('the grid does not depend on math blocks', () {
    final offending = <String>[];
    final importPattern = RegExp(
      r"import 'package:calc_tetris/block/math/([^']+)'",
    );
    for (final file in Directory('lib/grid').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      for (final match in importPattern.allMatches(file.readAsStringSync())) {
        if (!_allowedGenericFiles.contains(match.group(1))) {
          offending.add('${file.path} imports block/math/${match.group(1)}');
        }
      }
    }

    expect(offending, isEmpty);
  });
}
