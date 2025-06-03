import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:particle_game/src/config.dart';
import 'package:particle_game/src/particle_game.dart';

import 'components.dart';

class Particle extends CircleComponent
    with CollisionCallbacks, HasGameReference<ParticleGame> {
  Particle({Vector2? velocity, required super.position, required double radius})
    : velocity = velocity ?? Vector2(0, 0),
      super(
        radius: radius,
        anchor: Anchor.center,
        paint: Paint()
          ..color = const Color(0xff1e6091)
          ..style = PaintingStyle.fill,
        children: [],
      );

  final _hitbox = CircleHitbox(isSolid: true);
  Vector2 velocity;

  @override
  Future<void> onLoad() {
    super.add(_hitbox);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // debugPrint(position.toString());
    velocity += game.gravity * dt;
    position.x = clampDouble(
      position.x + velocity.x * dt,
      radius,
      game.width - radius,
    );
    position.y = clampDouble(
      position.y + velocity.y * dt,
      radius,
      game.height - radius,
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is PlayArea) {
      double overlapY = 0;
      double overlapX = 0;
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -epsilon_wall * velocity.y;
        overlapY = intersectionPoints.first.y;
      } else if (intersectionPoints.first.y >= game.height) {
        velocity.y = -epsilon_wall * velocity.y;
        overlapY = intersectionPoints.first.y - game.height;
      } else if (intersectionPoints.first.x <= 0) {
        velocity.x = -epsilon_wall * velocity.x;
        overlapX = intersectionPoints.first.x;
      } else if (intersectionPoints.first.x >= game.width) {
        velocity.x = -epsilon_wall * velocity.x;
        overlapX = intersectionPoints.first.x - game.width;
      }
      velocity.x -= overlapX;
      velocity.y -= overlapY;
    } else if (other is Particle) {
      final normal = (other.position - position).normalized();
      final v1Normal = velocity.dot(normal);
      final v2Normal = other.velocity.dot(normal);
      if (v1Normal - v2Normal <= 0) return;

      final distance = position.distanceTo(other.position);
      final minDistance = radius + other.radius;
      double overlap = max(0, minDistance - distance);
      final overlapExtraVelocity = overlap;

      final newV1Normal =
          (v2Normal * (1 + epsilon_particle) +
              v1Normal * (1 - epsilon_particle)) /
          2;
      final newV2Normal =
          (v1Normal * (1 + epsilon_particle) +
              v2Normal * (1 - epsilon_particle)) /
          2;

      final v1Tangent = velocity - (normal * (v1Normal + overlapExtraVelocity));
      final v2Tangent =
          other.velocity - (normal * (v2Normal - overlapExtraVelocity));

      velocity = v1Tangent + (normal * newV1Normal);
      other.velocity = v2Tangent + (normal * newV2Normal);
    }
  }
}
