import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:particle_game/src/components/particle.dart';

import '../core/config.dart';
import '../core/particle_game.dart';

class Controller extends Component with HasGameReference<ParticleGame> {
  void reset() {
    game.world.removeWhere((c) {
      return c is Particle;
    });
  }

  void spawnParticles() {
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
        game.world.add(
          Particle(
            colour: colour,
            radius: r.toDouble(), // [7.0, 8.0, 10.0, 20.0].random(),
            position: Vector2(
              game.width / 2 + (2 * r + 1) * i.toDouble(),
              game.height / 2 + (2 * r + 1) * j.toDouble(),
            ),
          ),
        );
      }
    }
  }

  void changeGravity(double gravityIn) {
    game.baseGravity = initialGravity * gravityIn;
  }
}
