import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:particle_game/src/components/particle.dart';

import '../core/config.dart';
import '../core/particle_game.dart';

enum ColourSelectionMode { list, single, random }

class Controller extends Component with HasGameReference<ParticleGame> {
  Color particleColour = initialColour;
  int particleCount = 0;
  ColourSelectionMode colourSelectionMode = ColourSelectionMode.random;
  late List<Color> particleColourList;

  void doUnpaused(Function f) {
    // briefly unpause the game to allow all the particles to be destroyed
    bool mustPause = false;
    if (game.paused) {
      mustPause = true;
      game.paused = false;
    }
    f();
    if (mustPause) {
      // leave the game running for a few ms to allow particles to be deleted
      Future.delayed(Duration(milliseconds: 2), () {
        game.paused = true;
      });
    }
  }

  void reset() {
    doUnpaused(() {
      game.world.removeWhere((c) {
        return c is Particle;
      });
    });
    particleCount = 0;
  }

  void spawnParticles() {
    int balls = (150 / game.particleSize).floor();
    for (var i = 0; i < balls; i++) {
      for (var j = 0; j < balls; j++) {
        addParticle(
          game.particleSize, // [7.0, 8.0, 10.0, 20.0].random(),
          Vector2(
            game.width / 2 +
                (2 * game.particleSize * (i.toDouble() - (balls - 1) / 2)),
            game.height / 2 +
                (2 * game.particleSize * (j.toDouble() - (balls - 1) / 2)),
          ),
        );
      }
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

  void addParticle(double radius, Vector2 position) {
    if (particleCount < maxParticles) {
      Color colour = switch (colourSelectionMode) {
        ColourSelectionMode.random => Colors.accents.random(),
        ColourSelectionMode.list => particleColourList.random(),
        ColourSelectionMode.single => particleColour,
      };
      doUnpaused(() {
        game.world.add(
          Particle(position: position, radius: radius, colour: colour),
        );
      });
      particleCount++;
    }
  }

  void destroyParticle(Particle p) {
    p.alive = false;
    doUnpaused(() {
      game.world.remove(p);
    });
    particleCount--;
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

  void setColour(Color colour) {
    colourSelectionMode = ColourSelectionMode.single;
    particleColour = colour;
  }

  void setRandomColours() {
    colourSelectionMode = ColourSelectionMode.random;
  }

  void setColourList(List<Color> colours) {
    colourSelectionMode = ColourSelectionMode.list;
    particleColourList = colours;
  }
}
