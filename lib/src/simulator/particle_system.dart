import 'package:flame/components.dart';
import 'package:flutter/material.dart';
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
      p.positionBeforeCorrection = p.position;
    }

    for (Particle p in particles) {}
    // COLLISIONS!
    for (int i = 0; i < impulseLoops; i++) {
      particles.shuffle();
      for (Particle p in particles) {
        p.overlaps = [];
        updateOverlaps(p);
        for (Overlap o in p.overlaps) {
          if (!o.colliding()) {
            continue;
          }
          final impulse = o.impulse();
          p.velocity += o.normal.scaled(impulse / p.mass);
          o.other!.velocity -= o.normal.scaled(impulse / o.other!.mass);
        }
        p.wallOverlaps = [];
        updateWallOverlaps(p);
        for (Overlap o in p.wallOverlaps) {
          if (!o.colliding()) {
            continue;
          }
          p.velocity += o.normal.scaled(o.impulse() / p.mass);
        }
      }
    }

    // GET REMAINING OVERLAPS AND APPLY SPATIAL CORRECTION
    for (int i = 0; i < correctionLoops; i++) {
      particles.shuffle();
      for (Particle p in particles) {
        applyCorrection(p);
        applyFallbackCorrections(p);
      }
    }
    for (Particle p in particles) {
      p.velocity *= overallVelocityDamping.toDouble();
    }
    for (Particle p in particles) {
      p.colour = Color.fromRGBO(
        p.velocity[0].toInt() + 128,
        p.velocity[1].toInt() + 128,
        255,
        1,
      );
    }
  }

  void updateWallOverlaps(Particle p) {
    var wallEffectiveRadius = p.radius;
    if (p.y + wallEffectiveRadius > game.height) {
      p.wallOverlaps.add(
        Overlap(
          // this hack ensures particles are pulled out of the wall on the first correction iteration, because otherwise
          // they have a tendency to slowly sink into the wall.
          p: p,
          normal: Vector2(0, -1),
          amount: -(p.y + p.radius - game.height),
          isWall: true,
        ),
      );
    }
    if (p.y - wallEffectiveRadius < 0) {
      p.wallOverlaps.add(
        Overlap(
          p: p,
          normal: Vector2(0, 1),
          amount: (p.y - p.radius),
          isWall: true,
        ),
      );
    }
    if (p.x + wallEffectiveRadius > game.width) {
      p.wallOverlaps.add(
        Overlap(
          p: p,
          normal: Vector2(-1, 0),
          amount: -(p.x + wallEffectiveRadius - game.width),
          isWall: true,
        ),
      );
    }
    if (p.x - wallEffectiveRadius < 0) {
      p.wallOverlaps.add(
        Overlap(
          p: p,
          normal: Vector2(1, 0),
          amount: (p.x - p.radius),
          isWall: true,
        ),
      );
    }
  }

  void updateOverlaps(Particle p) {
    for (var j = 0; j < particles.length; j++) {
      Particle p2 = particles[j];
      double d = distance(p.position, p2.position);
      if (p == p2 || d > p.radius + p2.radius + 0.01) {
        // not colliding
        continue;
      }
      p.overlaps.add(
        Overlap(
          p: p,
          normal: (p.position - p2.position).normalized(),
          amount: d - (p.radius + p2.radius),
          other: p2,
          isWall: false,
        ),
      );
    }
  }

  void applyCorrection(Particle p) {
    // preform a couple iterations of a method to make sure that particles
    // are never intersecting and never moving towards one another if they
    // are currently colliding.
    for (var i = 0; i < resolvePenetrationIterations; i++) {
      if (p.overlaps.isEmpty && p.wallOverlaps.isEmpty) {
        break;
      }
      unclip(p, false);
    }
  }

  void applyFallbackCorrections(Particle p) {
    p.wallOverlaps = [];
    updateWallOverlaps(p);
    // particle is still overlapping, position correction has failed, only guarantee
    // it hasn't fallen through a wall. This fallback case should produce a 'wave' effect.
    if (p.wallOverlaps.isNotEmpty) {
      p.position = p.positionBeforeCorrection;
      p.velocity *= confinedVelocityDamping.toDouble();
      unclip(p, true);
    }
  }

  void unclip(Particle p, bool onlyWalls) {
    p.overlaps = [];
    if (!onlyWalls) {
      updateOverlaps(p);
    }
    // if the particle is not overlapping with anything, move on
    for (var o in p.overlaps) {
      if (o.amount > -0.1) continue;
      // double totalInverseMass = 1.0 / p.mass + 1.0 / o.other!.mass;
      Vector2 correction =
          o.normal * o.amount * unconfinedPositionDamping.toDouble();
      if (correction.dot(game.currentGravity) < 0) {
        o.other!.position += correction;
      } else {
        p.position -= correction;
      }
      // move this particle away from any particle it is intersecting
      // // if AND ONLY IF the particles are moving towards each other,
      // // then set this particle's velocity so that it doesn't do that
      // // any more. This does not cover the resolution of the Actual
      // // collision, just any steps after that, such as particles
      // // resting on top of each other.
      if (o.colliding()) {
        final rv = o.relativeVelocity()!.dot(o.normal);
        if (correction.dot(game.currentGravity) < 0) {
          o.other!.velocity +=
              o.normal * rv * unconfinedVelocityDamping.toDouble();
        } else {
          p.velocity -= o.normal * rv * unconfinedVelocityDamping.toDouble();
        }
      }
    }
    p.wallOverlaps = [];
    updateWallOverlaps(p);
    for (var o in p.wallOverlaps) {
      if (o.amount > 0) continue;
      // move this particle away from any particle it is intersecting
      p.position -= o.normal * o.amount;
      // if (o.colliding()) {
      //   final rv = p.velocity.dot(o.normal);
      //   p.velocity -= o.normal * rv * unconfinedVelocityDamping.toDouble();
      // }
    }
  }
}
