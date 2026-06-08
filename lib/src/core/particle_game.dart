import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:particle_game/src/simulator/particle.dart';
import 'package:particle_game/src/simulator/particle_system.dart';

import './config.dart';
import '../components/components.dart';

enum TapMode { create, destroy, attract }

// TODO: way later ideas:
//       maps with walls and stuff
//       allow user to draw and remove walls freehand
//       accelerometer events to shake the screen to make the walls give an impulse or just
//         to randomise speeds of all particles proportional to gravity.
//       sounds? /meme

double distance(Vector2 p1, Vector2 p2) {
  return sqrt(pow(p1[0] - p2[0], 2) + pow(p1[1] - p2[1], 2));
}

class ParticleGame extends FlameGame with DragCallbacks {
  ParticleGame() : super(children: [ScreenHitbox()]);

  double get width => size.x;
  double get height => size.y;
  final random = Random();

  double baseGravity = initialGravity.toDouble();
  Vector2 currentGravity = Vector2(0, 0);
  Vector2 currentAcceleration = Vector2(0, 0);

  final Controller _controller = Controller();
  Controller get controller => _controller;

  final ParticleSystem _system = ParticleSystem();
  ParticleSystem get system => _system;

  double particleSize = initialParticleSize.toDouble();
  double particleScanningExtraRadius = 0;

  Map<int, Vector2> pointerPositions = {};

  TapMode tapMode = TapMode.create;

  List<Vector2> sinks = [];

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(Sensors());

    world.add(_controller);

    world.add(ParticleRenderer());

    world.add(_system);

    _controller.spawnParticles();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (tapMode == TapMode.attract) {
      sinks = pointerPositions.values.toList();
    } else {
      for (var p in pointerPositions.values) {
        switch (tapMode) {
          case TapMode.create:
            particleScanningExtraRadius = particleSize;
            if (!system.particles.any((particle) {
              return distance(Vector2(particle.x, particle.y), p) <
                  2 * particleScanningExtraRadius;
            })) {
              controller.addParticle(particleSize, p);
            }

          case TapMode.destroy:
            particleScanningExtraRadius = eraserToolSize.toDouble();
            for (Particle particle in system.particles.where((particle) {
              return distance(Vector2(particle.x, particle.y), p) <
                  particleScanningExtraRadius;
            })) {
              controller.destroyParticle(particle);
            }
          default:
            break;
        }
      }
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    pointerPositions[event.pointerId] = event.canvasPosition;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    pointerPositions[event.pointerId] = event.canvasEndPosition;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    pointerPositions.remove(event.pointerId);
  }
}
