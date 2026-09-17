import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Header extends PositionComponent {
  Header({super.size, super.position});

  @override
  FutureOr<void> onLoad() {
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color.fromARGB(255, 38, 32, 32),
      ),
    );
    return super.onLoad();
  }
}
