import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:particle_game/src/components/particle.dart';

import '../core/config.dart';
import '../core/particle_game.dart';

class Controller extends Component with HasGameReference<ParticleGame> {
  void reset() {
    // briefly unpause the game to allow all the particles to be destroyed
    bool mustPause = false;
    if (game.paused) {
      mustPause = true;
      game.paused = false;
    }

    game.world.removeWhere((c) {
      return c is Particle;
    });
    game.particleCount = 0;

    if (mustPause) {
      // leave the game running for a few ms to allow particles to be deleted
      Future.delayed(Duration(milliseconds: 2), () {
        game.paused = true;
      });
    }
  }

  void spawnParticles() {
    // briefly unpause the game to allow all the particles to be destroyed
    bool mustPause = false;
    if (game.paused) {
      mustPause = true;
      game.paused = false;
    }

    int balls = (150 / game.particleSize).floor();
    for (var i = 0; i < balls; i++) {
      for (var j = 0; j < balls; j++) {
        Color colour;
        // if (j < -4 || j > 4) {
        //   colour = Colors.lightBlue;
        // } else if (j > -2 && j < 2) {
        //   colour = Colors.white;
        // } else {
        //   colour = Colors.pink;
        // }
        colour = Colors.accents.random();
        addParticle(
          Particle(
            colour: colour,
            radius: game.particleSize, // [7.0, 8.0, 10.0, 20.0].random(),
            position: Vector2(
              game.width / 2 +
                  (2 * game.particleSize * (i.toDouble() - (balls - 1) / 2)),
              game.height / 2 +
                  (2 * game.particleSize * (j.toDouble() - (balls - 1) / 2)),
            ),
          ),
        );
      }
    }

    if (mustPause) {
      // leave the game running for a few ms to allow particles to be deleted
      Future.delayed(Duration(milliseconds: 2), () {
        game.paused = true;
      });
    }
  }

  void changeGravity(double gravityIn) {
    game.baseGravity = initialGravity * gravityIn;
  }

  void changeParticleSize(double particleSizeIn) {
    game.particleSize =
        smallestParticleSize * (1 - particleSizeIn) +
        largestParticleSize * (particleSizeIn);
  }

  void addParticle(Particle p) {
    if (game.particleCount < maxParticles) {
      game.world.add(p);
      game.particleCount++;
    }
  }

  void destroyParticle(Particle p) {
    p.alive = false;
    game.world.remove(p);
    game.particleCount--;
  }

  void pause() {
    game.paused = true;
  }

  void play() {
    game.paused = false;
  }

  void freezeParticles() {
    var particles = game.world.children.whereType<Particle>();
    for (var p in particles) {
      p.velocity = Vector2(0, 0);
    }
  }

  void setTapMode(TapMode tapMode) {
    game.tapMode = tapMode;
  }
}
