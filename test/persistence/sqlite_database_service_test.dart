import 'dart:io';

import 'package:calc_tetris/persistence/database_service.dart';
import 'package:calc_tetris/persistence/model/game_mode_name.dart';
import 'package:calc_tetris/persistence/sql/game_mode.sql.dart';
import 'package:calc_tetris/persistence/sqlite_database_service.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import 'database_service_contract.dart';

void main() {
  sqfliteFfiInit();

  group('on a fresh database', () {
    final opened = <SqliteDatabaseService>[];

    tearDown(() async {
      for (final service in opened) {
        await service.close();
      }
      opened.clear();
    });

    databaseServiceContract(() async {
      final service = SqliteDatabaseService(
        databaseFactory: databaseFactoryFfi,
        path: inMemoryDatabasePath,
      );
      opened.add(service);
      return service;
    });
  });

  test('can be used as DatabaseService', () {
    final DatabaseService service = SqliteDatabaseService(
      databaseFactory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );

    expect(service, isA<DatabaseService>());
  });

  group('with a database file', () {
    late Directory directory;
    late String path;

    setUp(() {
      directory = Directory.systemTemp.createTempSync('calc_tetris_db');
      path = p.join(directory.path, 'test.db');
    });

    tearDown(() => directory.deleteSync(recursive: true));

    SqliteDatabaseService open() =>
        SqliteDatabaseService(databaseFactory: databaseFactoryFfi, path: path);

    test('keeps the highscore after the database was closed', () async {
      final first = open();
      await first.saveHighscoreIfHigher(GameModeName.endless, 75);
      await first.close();

      final second = open();
      final mode = await second.loadGameMode(GameModeName.endless);
      await second.close();

      expect(mode!.highscore, 75);
    });

    test('creates the table only when it does not exist yet', () async {
      final first = open();
      await first.saveHighscoreIfHigher(GameModeName.endless, 75);
      await first.close();

      // opening again executes the create statement again
      final second = open();
      final saved = await second.saveHighscoreIfHigher(
        GameModeName.endless,
        20,
      );
      await second.close();

      expect(saved, isFalse);
    });

    test('stores one row per game mode with the defined columns', () async {
      final service = open();
      await service.saveHighscoreIfHigher(GameModeName.endless, 75);
      await service.close();

      final db = await databaseFactoryFfi.openDatabase(path);
      final rows = await db.query(GameModeSql.tableName);
      await db.close();

      expect(rows, hasLength(1));
      expect(
        rows.single.keys,
        containsAll(['name', 'highscore', 'achieved_at']),
      );
      expect(rows.single['name'], 'endless');
      expect(rows.single['highscore'], 75);
    });
  });
}
