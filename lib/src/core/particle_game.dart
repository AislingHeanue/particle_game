import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/material.dart';

import './config.dart';
import '../components/components.dart';

enum TapMode { create, destroy, attract }

// TODO: colour palettes

// TODO: way later ideas:
//       maps with walls and stuff
//       allow user to draw and remove walls freehand
//       accelerometer events to shake the screen to make the walls give an impulse or just
//         to randomise speeds of all particles proportional to gravity.

class ParticleGame extends FlameGame with HasCollisionDetection, DragCallbacks {
  ParticleGame() : super(children: [ScreenHitbox()]);

  double get width => size.x;
  double get height => size.y;
  final random = Random();

  double baseGravity = initialGravity.toDouble();
  Vector2 currentGravity = Vector2(0, 0);

  final Controller _controller = Controller();
  Controller get controller => _controller;

  int particleCount = 0;
  double particleSize = initialParticleSize.toDouble();
  double particleScanningExtraRadius = 0;

  Map<int, Vector2> pointerPositions = {};

  TapMode tapMode = TapMode.create;

  List<Vector2> sinks = [];

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    camera = CameraComponent.withFixedResolution(width: size.x, height: size.y);
    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(Gyroscope());

    world.add(_controller);

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
            if (world.componentsAtPoint(p).whereType<Particle>().isEmpty) {
              controller.addParticle(
                Particle(
                  position: p,
                  radius: particleSize,
                  colour: Colors.accents.random(),
                ),
              );
            }

          case TapMode.destroy:
            particleScanningExtraRadius = eraserToolSize.toDouble();
            for (var p in world.componentsAtPoint(p).whereType<Particle>()) {
              controller.destroyParticle(p);
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
