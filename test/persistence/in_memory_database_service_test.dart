import 'package:calc_tetris/persistence/database_service.dart';
import 'package:calc_tetris/persistence/in_memory_database_service.dart';
import 'package:calc_tetris/persistence/model/game_mode_name.dart';
import 'package:test/test.dart';

import 'database_service_contract.dart';

void main() {
  databaseServiceContract(() async => InMemoryDatabaseService());

  test('can be used as DatabaseService', () {
    final DatabaseService service = InMemoryDatabaseService();

    expect(service, isA<DatabaseService>());
  });

  test('two instances do not share their data', () async {
    final first = InMemoryDatabaseService();
    final second = InMemoryDatabaseService();

    await first.saveHighscoreIfHigher(GameModeName.endless, 50);

    expect(await second.loadGameMode(GameModeName.endless), isNull);
  });
}
