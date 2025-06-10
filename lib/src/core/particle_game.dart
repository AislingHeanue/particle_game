import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import './config.dart';
import '../components/components.dart';

enum Screen { playing, settings }

// TODO: tap modes: add particles, remove particles, attract particles
//       slider to adjust ball size as they are added (must be clicked to open slider)
//       selection of continuous color palettes or constant colour.
//       pause/play button
//       freeze all velocities button
//       help button to replace the IconButtons with LabelButtons or whatever they're called
//       (I really hope I can do this in MenuEntryButton)
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

  double baseGravity = initialGravity.toDouble();
  Vector2 currentGravity = Vector2(0, 0);

  final Controller _controller = Controller();
  Controller get controller => _controller;

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    camera = CameraComponent.withFixedResolution(width: size.x, height: size.y);
    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(Gyroscope());

    world.add(_controller);

    _controller.spawnParticles();
  }
}
