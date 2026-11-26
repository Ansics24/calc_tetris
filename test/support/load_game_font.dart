import 'dart:io';

import 'package:magic_blocks/theme/text_theme.dart';
import 'package:flutter/services.dart';

/// Loads the font of the game, so that texts take the same room in widget
/// tests as on a device. Without it every letter is a wide square.
Future<void> loadGameFont() async {
  final bytes = File('assets/fonts/Fredoka.ttf').readAsBytesSync();
  final loader = FontLoader(gameFontFamily)
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}
