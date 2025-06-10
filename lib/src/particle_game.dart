import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import './config.dart';
import 'components/components.dart';

enum Screen { playing, settings }

// TODO: tap modes: add particles, remove particles, attract particles
//       slider to adjust ball size as they are added (must be clicked to open slider)
//       gravity slider
//       selection of continuous color palettes or constant colour.
//       settings button opens a set of overlaid menus such as theses
//       clear button
//       random button
//       pause/play button
//
// TODO: way later ideas:
//       maps with walls and stuff
//       allow user to draw and remove walls freehand
//       accelerometer events to shake the screen to make the walls give an impulse or just
//         to randomise speeds of all particles proportional to gravity.

class ParticleGame extends FlameGame with HasCollisionDetection {
  ParticleGame() : super(children: [ScreenHitbox()]);

  double get width => size.x;
  double get height => size.y;
  final random = Random();

  Vector2 gravity = Vector2(-80, 80);

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    camera = CameraComponent.withFixedResolution(width: size.x, height: size.y);
    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(Gyroscope());

    for (var i = -balls; i <= balls; i++) {
      for (var j = -balls; j <= balls; j++) {
        Color colour;
        // if (j < -4 || j > 4) {
        //   colour = Colors.lightBlue;
        // } else if (j > -2 && j < 2) {
        //   colour = Colors.white;
        // } else {
        //   colour = Colors.pink;
        // }
        colour = Colors.accents.random();
        world.add(
          Particle(
            colour: colour,
            radius: r.toDouble(), // [7.0, 8.0, 10.0, 20.0].random(),
            position: Vector2(
              size.x / 2 + (2 * r + 1) * i.toDouble(),
              size.y / 2 + (2 * r + 1) * j.toDouble(),
            ),
          ),
        );
      }
    }
  }
}
