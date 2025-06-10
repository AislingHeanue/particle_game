import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/painting.dart';

import '../core/particle_game.dart';
import '../util/collidable.dart';

class Particle extends CircleComponent
    with
        CollidableCircleMixin,
        CollisionCallbacks,
        HasGameReference<ParticleGame> {
  Particle({
    required super.position,
    required double super.radius,
    required Color colour,
    Vector2? velocity,
  }) : velocity = velocity ?? Vector2(0, 0),
       mass = radius * radius,
       super(
         anchor: Anchor.center,
         paint: Paint()
           ..color = colour
           ..style = PaintingStyle.fill,
         children: [CircleHitbox(isSolid: true)],
       );
  @override
  Vector2 velocity;
  @override
  double mass;
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

  @override
  void update(double dt) {
    super.update(dt);
    // update velocity and position according to gravity and any other external forces (not collisions).
    doMove(dt);
    // apply corrections to make sure particles do not intersect
    applyCorrection();
  }

  void doMove(double dt) {
    velocity += game.currentGravity * dt;
    position += velocity * dt;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    mixinOnCollision(intersectionPoints, other);
  }
}
