// import 'package:flame/collisions.dart';
// import 'package:flame/components.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:particle_game/src/simulator/overlap.dart';
// import 'package:particle_game/src/core/config.dart';
// import 'package:flutter/painting.dart';

// import '../core/particle_game.dart';
// import '../util/collidable.dart';

class Particle {
  Particle({
    required this.position,
    required this.radius,
    required this.colour,
    Vector2? velocity,
  }) : velocity = velocity ?? Vector2(0, 0),
       mass = radius * radius,
       positionBeforeCorrection = position;

  Vector2 position;
  Vector2 positionBeforeCorrection;
  Vector2 velocity;
  double mass;
  double radius;
  Color colour;
  List<Overlap> overlaps = [];
  List<Overlap> wallOverlaps = [];
  Set<(int, int)> gridTiles = {};

  get x => radius + position[0];
  get y => radius + position[1];
}
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
  // override this function to prevent particles being spawned to close to existing particles

//   @override
//   bool containsLocalPoint(Vector2 point) {
//     final radius = size.x / 2;
//     final dx = point.x - radius;
//     final dy = point.y - radius;
//     return dx * dx + dy * dy <=
//         (radius + game.particleScanningExtraRadius) *
//             (radius + game.particleScanningExtraRadius);
//   }
//
//   @override
//   void update(double dt) {
//     super.update(dt);
//     // update velocity and position according to gravity and any other external forces (not collisions).
//     doGravity(dt);
//     // apply corrections to make sure particles do not intersect
//     doMove(dt);
//     final sunk = doSinks(dt);
//     if (!sunk) {
//       applyCorrection();
//     }
//   }
//
//   void doGravity(double dt) {
//     velocity += game.currentGravity * dt;
//   }
//
//   bool doSinks(double dt) {
//     var sunk = false;
//     for (var sink in game.sinks) {
//       var distance = position.distanceTo(sink);
//       if (distance < attractorRadius) {
//         final normal = (sink - position).normalized();
//         velocity += normal * attractorStrength.toDouble() * dt;
//         sunk = true;
//       }
//     }
//     return sunk;
//   }
//
//   void doMove(double dt) {
//     position += velocity * dt;
//   }
//
//   @override
//   void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
//     super.onCollision(intersectionPoints, other);
//     mixinOnCollision(intersectionPoints, other);
//   }
// }
