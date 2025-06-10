import 'package:flame/components.dart';

class Overlap {
  Overlap({required this.normal, required this.amount, this.relativeVelocity});
  Vector2 normal;
  double amount;
  Vector2? relativeVelocity;
}
