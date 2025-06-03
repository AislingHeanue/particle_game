import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'components/components.dart';

enum Screen { playing, settings }

class ParticleGame extends FlameGame with HasCollisionDetection {
  ParticleGame()
    : super(
        // camera: CameraComponent.withFixedResolution(width: 900, height: 1600)
      );

  double get width => size.x;
  double get height => size.y;
  final random = Random();

  Vector2 gravity = Vector2(-40, 80);

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    camera = CameraComponent.withFixedResolution(width: size.x, height: size.y);
    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(PlayArea());

    // debugMode = true;

    for (var i = -5; i <= 5; i++) {
      for (var j = 5; j < 17; j++) {
        world.add(
          Particle(
            radius: 15,
            position: Vector2(
              size.x / 2 + 31 * i.toDouble(),
              31 * j.toDouble(),
            ),
          ),
        );
      }
    }
  }
}
