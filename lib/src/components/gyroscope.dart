import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:particle_game/src/core/config.dart';
import 'package:simple_sensor/simple_sensor.dart';

import '../core/particle_game.dart';

class Sensors extends Component with HasGameReference<ParticleGame> {
  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    simpleSensor.absoluteOrientation.listen(onGyro);
    simpleSensor.userAccelerometer.listen(onAccelerometer);
    simpleSensor.userAccelerometerUpdateInterval = 20000;
  }

  void onGyro(AbsoluteOrientationEvent event) {
    game.currentGravity = eventToGravity(event, game.baseGravity.toDouble());
  }

  void onAccelerometer(UserAccelerometerEvent event) {
    // print(event);
    game.currentAcceleration = eventToAcceleration(event);
  }

  // pitch goes from -pi to +pi, with 0 being the 'flat' level. +pi/2 is +y
  // roll goes from -pi to pi, with 0 = pi = -pi = 'flat'. +pi/2 is +x
  Vector2 eventToGravity(AbsoluteOrientationEvent event, double baseGravity) =>
      Vector2(baseGravity * sin(event.roll), baseGravity * sin(event.pitch));

  Vector2 eventToAcceleration(UserAccelerometerEvent event) {
    if (pow(event.x, 2) + pow(event.y, 2) > 15) {
      return Vector2(
        event.x * accelerometerSensitivity,
        -event.y * accelerometerSensitivity,
      );
    } else {
      return Vector2(0, 0);
    }
  }
}
