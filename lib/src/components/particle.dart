import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/painting.dart';

import './overlap.dart';
import '../config.dart';
import '../particle_game.dart';

class Particle extends CircleComponent
    with CollisionCallbacks, HasGameReference<ParticleGame> {
  Particle({
    Vector2? velocity,
    required super.position,
    required Color colour,
    required double radius,
  }) : velocity = velocity ?? Vector2(0, 0),
       super(
         radius: radius,
         anchor: Anchor.center,
         paint: Paint()
           ..color = colour
           ..style = PaintingStyle.fill,
         children: [CircleHitbox(isSolid: true)],
       );

  Vector2 velocity;
  Set<Particle> particleContacts = {};
  // String textToDisplay = '';
  // late final TextComponent textComponent;

  // @override
  // Future<void> onLoad() async {
  //   super.onLoad();
  //   textComponent =
  //       TextComponent(
  //           text: textToDisplay,
  //           size: Vector2(3, 3),
  //           textRenderer: TextPaint(style: TextStyle(fontSize: 8)),
  //         )
  //         ..anchor = Anchor.topCenter
  //         ..x = (radius * 0.4)
  //         ..y = (radius * 0.4)
  //         ..priority = 300;
  //   add(textComponent);
  // }
  //
  // void updateText(String text) {
  //   textComponent.text = text;
  // }

  List<Overlap> get overlaps {
    List<Overlap> overlaps = [];
    for (var p in particleContacts) {
      final overlap = (radius + p.radius) - distance(p);
      final normal = (p.position - position).normalized();
      final relativeVelocity = p.velocity - velocity;
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
    if (position.y + radius > game.height) {
      overlaps.add(
        Overlap(
          normal: Vector2(0, 1),
          amount: position.y + radius - game.height,
          relativeVelocity: -velocity,
        ),
      );
    }
    if (position.y - radius < 0) {
      overlaps.add(
        Overlap(
          normal: Vector2(0, -1),
          amount: -(position.y - radius),
          relativeVelocity: -velocity,
        ),
      );
    }
    if (position.x + radius > game.width) {
      overlaps.add(
        Overlap(
          normal: Vector2(1, 0),
          amount: position.x + radius - game.width,
          relativeVelocity: -velocity,
        ),
      );
    }
    if (position.x - radius < 0) {
      overlaps.add(
        Overlap(
          normal: Vector2(-1, 0),
          amount: -(position.x - radius),
          relativeVelocity: -velocity,
        ),
      );
    }
    return overlaps;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // updateText(sprintf('%.0f', [velocity.x]));

    // update velocity and position according to gravity and any other external forces (not collisions).
    velocity += game.gravity * dt;
    position += velocity * dt;

    final positionBeforeCorrection = position;

    // preform a couple iterations of a method to make sure that particles
    // are never intersecting and never moving towards one another if they
    // are currently colliding.
    for (var i = 0; i < resolvePenetrationIterations; i++) {
      for (var o in overlaps) {
        // move this particle away from any particle it is intersecting
        position -= o.normal * o.amount;
        // if AND ONLY IF the particles are moving towards each other,
        // then set this particle's velocity so that it doesn't do that
        // any more. This does not the resolution of the Actual collision,
        // just any steps after that, such as particles resting on top of
        // each other.
        if (o.relativeVelocity.dot(o.normal) <= 0) {
          velocity += o.normal * o.relativeVelocity.dot(o.normal);
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
      velocity *= confinedCircleDampening.toDouble();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    final averageIntersectionPoint =
        intersectionPoints.reduce((a, b) => a + b) /
        intersectionPoints.length.toDouble();

    final normal = (averageIntersectionPoint - position).normalized();
    final v1Normal = velocity.dot(normal);
    final v1Tangent = velocity - (normal * v1Normal);

    double epsilon = epsilonWall;
    double v2Normal = 0;
    Vector2 v2Tangent = Vector2(0, 0);
    if (other is Particle) {
      particleContacts.add(other);

      epsilon = epsilonParticle;
      v2Normal = other.velocity.dot(normal);
      v2Tangent = other.velocity - (normal * v2Normal);
    }

    if (v1Normal - v2Normal <= 0) {
      return;
    }

    final newV1Normal =
        (v2Normal * (1 + epsilon) + v1Normal * (1 - epsilon)) / 2;
    velocity = v1Tangent + (normal * newV1Normal);

    if (other is Particle) {
      final newV2Normal =
          (v1Normal * (1 + epsilon) + v2Normal * (1 - epsilon)) / 2;
      other.velocity = v2Tangent + (normal * newV2Normal);
    }
  }
}
