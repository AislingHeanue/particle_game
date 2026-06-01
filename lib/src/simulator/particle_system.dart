import 'package:flame/components.dart';
import 'package:particle_game/src/simulator/overlap.dart';
import 'package:particle_game/src/simulator/particle.dart';

import '../core/particle_game.dart';
import '../core/config.dart';

class ParticleSystem extends Component with HasGameReference<ParticleGame> {
  List<Particle> particles = [];

  @override
  void update(double dt) {
    super.update(dt);
    // GLOBAL GRAVITY APPLICATION
    for (Particle p in particles) {
      p.velocity += game.currentGravity * dt;
    }

    // SINK GRAVITY APPLICATION
    for (Particle p in particles) {
      // bool sunk = false;
      for (var sink in game.sinks) {
        var distance = p.position.distanceTo(sink);
        if (distance < attractorRadius) {
          final normal = (sink - p.position).normalized();
          p.velocity += normal * attractorStrength.toDouble() * dt;
          // sunk = true;
        }
      }
    }

    // MOVEMENT (NO COLLISIONS)
    for (Particle p in particles) {
      p.position += p.velocity * dt;
    }

    // GET REMAINING OVERLAPS AND APPLY SPATIAL CORRECTION
    for (int i = 0; i < particles.length; i++) {
      applyCorrection(i);
    }
  }

  void updateOverlaps(int index) {
    Particle p = particles[index];
    p.overlaps = [];

    var wallEffectiveRadius = p.radius;
    if (p.y + wallEffectiveRadius > game.height) {
      p.overlaps.add(
        Overlap(
          // this hack ensures particles are pulled out of the wall on the first correction iteration, because otherwise
          // they have a tendency to slowly sink into the wall.
          normal: Vector2(0, 1 / unconfinedPositionDamping),
          amount: p.y + p.radius - game.height,
          relativeVelocity: -p.velocity,
        ),
      );
    }
    if (p.y - wallEffectiveRadius < 0) {
      p.overlaps.add(
        Overlap(
          normal: Vector2(0, -1 / unconfinedPositionDamping),
          amount: -(p.y - p.radius),
          relativeVelocity: -p.velocity,
        ),
      );
    }
    if (p.x + wallEffectiveRadius > game.width) {
      p.overlaps.add(
        Overlap(
          normal: Vector2(1 / unconfinedPositionDamping, 0),
          amount: p.x + wallEffectiveRadius - game.width,
          relativeVelocity: -p.velocity,
        ),
      );
    }
    if (p.x - wallEffectiveRadius < 0) {
      p.overlaps.add(
        Overlap(
          normal: Vector2(-1 / unconfinedPositionDamping, 0),
          amount: -(p.x - p.radius),
          relativeVelocity: -p.velocity,
        ),
      );
    }

    for (var j = 0; j < particles.length; j++) {
      Particle p2 = particles[j];
      double d = distance(p.position, p2.position);
      if (j == index || d > p.radius + p2.radius) {
        // not colliding (TODO: use a grid to optimize this checking)
        continue;
      }
    }
  }

  void applyCorrection(int index) {
    Particle p = particles[index];
    final positionBeforeCorrection = p.position;
    // preform a couple iterations of a method to make sure that particles
    // are never intersecting and never moving towards one another if they
    // are currently colliding.
    for (var i = 0; i < resolvePenetrationIterations; i++) {
      updateOverlaps(index);
      // if the particle is not overlapping with anything, move on
      if (p.overlaps.isEmpty) {
        break;
      }
      for (var o in p.overlaps) {
        // move this particle away from any particle it is intersecting
        particles[index].position -=
            o.normal * o.amount * unconfinedPositionDamping.toDouble();
        // if AND ONLY IF the particles are moving towards each other,
        // then set this particle's velocity so that it doesn't do that
        // any more. This does not cover the resolution of the Actual
        // collision, just any steps after that, such as particles
        // resting on top of each other.
        if (o.relativeVelocity != null &&
            o.relativeVelocity!.dot(o.normal) <= 0) {
          particles[index].velocity +=
              o.normal *
              o.relativeVelocity!.dot(o.normal) *
              unconfinedVelocityDamping.toDouble();
        }
      }
    }
    // particle is still overlapping, position correction has failed, do nothing
    // this is a fallback case, and will cause 'waves' of frozen particles to
    // propagate through the system.
    if (p.overlaps.isNotEmpty) {
      particles[index].position = positionBeforeCorrection;
      particles[index].velocity *= confinedVelocityDamping.toDouble();
    }
    particles[index].velocity *= overallVelocityDamping.toDouble();
  }
}
