import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Footer extends PositionComponent {
  Footer({super.size, super.position});

  @override
  FutureOr<void> onLoad() {
    add(RectangleComponent(size: size, paint: Paint()..color = Colors.grey));
    return super.onLoad();
  }
}
