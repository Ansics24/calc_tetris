import 'package:calc_tetris/persistence/database_service.dart';
import 'package:calc_tetris/persistence/model/game_mode.dart';
import 'package:calc_tetris/persistence/model/game_mode_name.dart';
import 'package:calc_tetris/persistence/sql/game_mode.sql.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart'
    show
        Database,
        DatabaseExecutor,
        DatabaseFactory,
        OpenDatabaseOptions,
        ConflictAlgorithm,
        databaseFactorySqflitePlugin;

/// Keeps the data in a SQLite database. It is opened on first use.
class SqliteDatabaseService implements DatabaseService {
  static const String _fileName = 'calc_tetris.db';
  static const int _version = 1;

  final DatabaseFactory _factory;
  final String? _path;
  Future<Database>? _database;

  SqliteDatabaseService({DatabaseFactory? databaseFactory, this._path})
    : _factory = databaseFactory ?? databaseFactorySqflitePlugin;

  Future<Database> _open() async {
    final path = _path ?? p.join(await _factory.getDatabasesPath(), _fileName);
    return _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _version,
        // Creates the table of a new file; does nothing for existing tables.
        onOpen: (db) async {
          await db.execute(GameModeSql.createTable);
          for (final update in GameModeSql.updates) {
            await db.execute(update);
          }
        },
      ),
    );
  }

  Future<Database> get _db => _database ??= _open();

  Future<void> close() async {
    final database = _database;
    _database = null;
    await (await database)?.close();
  }

  @override
  Future<GameMode?> loadGameMode(GameModeName name) async {
    final db = await _db;
    return _read(db, name);
  }

  @override
  Future<bool> saveHighscoreIfHigher(GameModeName name, int score) async {
    if (score < 0) {
      throw ArgumentError.value(score, 'score', 'must not be negative');
    }
    if (score == 0) {
      return false;
    }
    final db = await _db;
    return db.transaction((txn) async {
      final stored = await _read(txn, name);
      if (stored != null && score <= stored.highscore) {
        return false;
      }
      await txn.insert(GameModeSql.tableName, {
        'name': name.value,
        'highscore': score,
        'achieved_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    });
  }

  Future<GameMode?> _read(DatabaseExecutor executor, GameModeName name) async {
    final rows = await executor.query(
      GameModeSql.tableName,
      where: 'name = ?',
      whereArgs: [name.value],
    );
    if (rows.isEmpty) {
      return null;
    }
    final row = rows.single;
    return GameMode(
      name: row['name'] as String,
      highscore: row['highscore'] as int,
      achievedAt: DateTime.parse(row['achieved_at'] as String),
    );
  }
}
