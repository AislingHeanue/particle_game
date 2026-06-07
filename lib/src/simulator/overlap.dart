import 'package:flame/components.dart';
import 'package:particle_game/src/core/config.dart';
import 'package:particle_game/src/simulator/particle.dart';

class Overlap {
  Overlap({
    required this.p,
    required this.normal,
    required this.amount,
    required this.isWall,
    this.other,
  });
  Vector2 normal;
  double amount;
  Particle p;
  Particle? other;
  bool isWall;

  double impulse() {
    if (isWall) {
      return -(1 + epsilonWall) * p.velocity.dot(normal) * p.mass;
    } else {
      return -(1 + epsilonParticle) *
          (p.velocity - other!.velocity).dot(normal) /
          (1 / p.mass + 1 / other!.mass);
    }
  }

  bool colliding() {
    if (isWall) {
      return (p.velocity).dot(normal) < 0;
    } else {
      return (p.velocity - other!.velocity).dot(normal) < 0;
    }
  }

  Vector2? relativeVelocity() {
    return other != null ? p.velocity - other!.velocity : null;
  }
}
