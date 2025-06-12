import 'dart:math';

import 'package:flame/components.dart';

import '../core/config.dart';
import '../core/particle_game.dart';
import './overlap.dart';

mixin CollidableCircleMixin on CircleComponent {
  late final ParticleGame game;
  Set<CollidableCircleMixin> contacts = {};

  double get mass;

  Vector2 get velocity;
  set velocity(Vector2 velocity);

  bool alive = true;

  List<Overlap> get overlaps {
    List<Overlap> overlaps = [];
    for (var p in [...contacts]) {
      final overlap = (radius + p.radius) - distance(p);
      final normal = (p.position - position).normalized();
      final relativeVelocity = p.velocity - velocity;
      // this particle is not on this plane of existence any more.
      if (!p.alive) {
        contacts.remove(p);
        continue;
      }
      // these particles are miles apart, stop considering them for contacts
      if (overlap < -min(radius, p.radius)) {
        contacts.remove(p);
        continue;
      }
      if (overlap > overlapTolerancePerRadius * (radius + p.radius)) {
        overlaps.add(
          Overlap(
            normal: normal,
            amount: overlap,
            relativeVelocity: relativeVelocity,
          ),
        );
      }
    }
    var wallEffectiveRadius = radius;
    if (position.y + wallEffectiveRadius > game.height) {
      overlaps.add(
        Overlap(
          normal: Vector2(0, 1),
          amount: position.y + radius - game.height,
          // relativeVelocity: -velocity,
        ),
      );
    }
    if (position.y - wallEffectiveRadius < 0) {
      overlaps.add(
        Overlap(
          normal: Vector2(0, -1),
          amount: -(position.y - radius),
          // relativeVelocity: -velocity,
        ),
      );
    }
    if (position.x + wallEffectiveRadius > game.width) {
      overlaps.add(
        Overlap(
          normal: Vector2(1, 0),
          amount: position.x + radius - game.width,
          // relativeVelocity: -velocity,
        ),
      );
    }
    if (position.x - wallEffectiveRadius < 0) {
      overlaps.add(
        Overlap(
          normal: Vector2(-1, 0),
          amount: -(position.x - radius),
          // relativeVelocity: -velocity,
        ),
      );
    }
    return overlaps;
  }

  void applyCorrection() {
    final positionBeforeCorrection = position;
    // preform a couple iterations of a method to make sure that particles
    // are never intersecting and never moving towards one another if they
    // are currently colliding.
    for (var i = 0; i < resolvePenetrationIterations; i++) {
      for (var o in overlaps) {
        // move this particle away from any particle it is intersecting
        position -= o.normal * o.amount * unconfinedPositionDamping.toDouble();
        // if AND ONLY IF the particles are moving towards each other,
        // then set this particle's velocity so that it doesn't do that
        // any more. This does not cover the resolution of the Actual
        // collision, just any steps after that, such as particles
        // resting on top of each other.
        if (o.relativeVelocity != null &&
            o.relativeVelocity!.dot(o.normal) <= 0) {
          velocity +=
              o.normal *
              o.relativeVelocity!.dot(o.normal) *
              unconfinedVelocityDamping.toDouble();
        }
      }
      // if the particle is not overlapping with anything, move on
      if (overlaps.isEmpty) {
        break;
      }
    }
    // particle is still overlapping, position correction has failed, do nothing
    // this is a fallback case, and will cause 'waves' of frozen particles to
    // propagate through the system.
    if (overlaps.isNotEmpty) {
      position = positionBeforeCorrection;
      velocity *= confinedVelocityDamping.toDouble();
    }
    velocity *= overallVelocityDamping.toDouble();
  }

  void mixinOnCollision(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    final averageIntersectionPoint =
        intersectionPoints.reduce((a, b) => a + b) /
        intersectionPoints.length.toDouble();

    final normal = (averageIntersectionPoint - position).normalized();
    final v1Normal = velocity.dot(normal);
    final v1Tangent = velocity - (normal * v1Normal);
    final m1 = mass;

    double epsilon = epsilonWall;
    double v2Normal = 0;
    Vector2 v2Tangent = Vector2(0, 0);
    double? m2;
    if (other is CollidableCircleMixin) {
      contacts.add(other);

      epsilon = epsilonParticle;
      v2Normal = other.velocity.dot(normal);
      v2Tangent = other.velocity - (normal * v2Normal);
      m2 = other.mass;
    }

    if (v1Normal - v2Normal <= 0) {
      return;
    }

    // https://www.phys.ufl.edu/~kevin/teaching/2060/08spring/two-body_collisions.pdf
    late final double newV1Normal;
    if (m2 != null) {
      newV1Normal =
          ((m1 - epsilon * m2) * v1Normal + m2 * (1 + epsilon) * v2Normal) /
          (m1 + m2);
    } else {
      newV1Normal = -epsilon * v1Normal;
      // print('$v1Normal to $newV1Normal');
    }

    velocity = v1Tangent + (normal * newV1Normal);

    if (other is CollidableCircleMixin) {
      final newV2Normal =
          ((m2! - epsilon * m1) * v2Normal + m1 * (1 + epsilon) * v1Normal) /
          (m1 + m2);
      other.velocity = v2Tangent + (normal * newV2Normal);
    }
  }
}
