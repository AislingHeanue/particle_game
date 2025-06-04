import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/components.dart';

enum Screen { playing, settings }

class ParticleGame extends FlameGame with HasCollisionDetection {
  ParticleGame()
    : super(
        // camera: CameraComponent.withFixedResolution(width: 900, height: 1600)
        children: [ScreenHitbox()],
      );

  double get width => size.x;
  double get height => size.y;
  final random = Random();
  double t = 0;

  Vector2 gravity = Vector2(-80, 80);

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    camera = CameraComponent.withFixedResolution(width: size.x, height: size.y);
    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(Gyroscope());

    final balls = 9;
    final r = 10;
    for (var i = -balls; i <= balls; i++) {
      for (var j = -balls; j <= balls; j++) {
        world.add(
          Particle(
            colour: Colors.accents.random(),
            radius: r.toDouble(), // [7.0, 8.0, 10.0, 20.0].random(),
            position: Vector2(
              size.x / 2 + (1 * r + 1) * i.toDouble(),
              size.y / 2 + (1 * r + 1) * j.toDouble(),
            ),
          ),
        );
      }
    }
    // world.add(
    //   Particle(
    //     colour: Colors.purple,
    //     radius: 40,
    //     position: Vector2(size.x / 2, 1500),
    //   ),
    // );
  }

  // @override
  // void update(double dt) {
  //   super.update(dt);
  //   t += dt;
  //   final force = 100;
  //   gravity = Vector2(force * sin(t / 5), 100 * cos(t / 5));
  // }
}

