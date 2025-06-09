import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import '../config.dart';
import '../particle_game.dart';
import 'package:simple_sensor/simple_sensor.dart';

class Gyroscope extends Component with HasGameReference<ParticleGame> {
  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    simpleSensor.absoluteOrientation.listen(onData);
  }

  void onData(AbsoluteOrientationEvent event) {
    game.gravity = eventToGravity(event, baseGravity);
  }

  // pitch goes from -pi to +pi, with 0 being the 'flat' level. +pi/2 is +y
  // roll goes from -pi to pi, with 0 = pi = -pi = 'flat'. +pi/2 is +x
  Vector2 eventToGravity(AbsoluteOrientationEvent event, double baseGravity) =>
      Vector2(baseGravity * sin(event.roll), baseGravity * sin(event.pitch));

  void onError(Object error) {
    debugPrint('Gyroscope error!');
  }
}
