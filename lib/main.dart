import 'package:calc_tetris/calc_tetris_app.dart';
import 'package:calc_tetris/persistence/sqlite_database_service.dart';
import 'package:calc_tetris/tetris_game.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    CalcTetrisApp(
      game: TetrisGame(databaseService: SqliteDatabaseService()),
    ),
  );
}
