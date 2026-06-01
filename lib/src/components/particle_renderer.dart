import 'dart:ui';

import 'package:flame/components.dart';
import 'package:particle_game/src/simulator/particle.dart';

import '../core/particle_game.dart';

class ParticleRenderer extends Component with HasGameReference<ParticleGame> {
  @override
  void render(Canvas canvas) {
    for (Particle p in game.system.particles) {
      canvas.drawCircle(
        Offset(p.position[0] + p.radius, p.position[1] + p.radius),
        p.radius,
        Paint()
          ..color = p.colour
          ..style = PaintingStyle.fill,
      );
    }
  }
}
