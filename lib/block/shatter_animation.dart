import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/painting.dart';

/// A block breaking apart: many small particles fly away from where it was in
/// random directions. Removes itself when they are gone.
class ShatterAnimation extends PositionComponent {
  static const int particleCount = 36;
  static const double _lifespan = 0.8;

  /// Speed of the particles in block widths per second.
  static const double _minSpeed = 1;
  static const double _maxSpeed = 4;

  /// Pull towards the bottom, in block widths per second squared.
  static const double _gravity = 6;

  final Color color;
  final Random _random;

  ShatterAnimation({
    required this.color,
    required Vector2 size,
    required Vector2 position,
    Random? random,
  }) : _random = random ?? Random(),
       super(size: size, position: position, priority: 400);

  @override
  void onLoad() {
    final paint = Paint()..color = color;
    add(
      ParticleSystemComponent(
        position: size / 2,
        particle: Particle.generate(
          count: particleCount,
          lifespan: _lifespan,
          generator: (_) => AcceleratedParticle(
            speed: _randomSpeed(),
            acceleration: Vector2(0, _gravity * size.x),
            child: CircleParticle(
              radius: size.x * (0.04 + 0.06 * _random.nextDouble()),
              paint: paint,
            ),
          ),
        ),
      ),
    );
    add(RemoveEffect(delay: _lifespan));
  }

  Vector2 _randomSpeed() {
    final angle = _random.nextDouble() * 2 * pi;
    final speed =
        size.x * (_minSpeed + (_maxSpeed - _minSpeed) * _random.nextDouble());
    return Vector2(cos(angle), sin(angle)) * speed;
  }
}
