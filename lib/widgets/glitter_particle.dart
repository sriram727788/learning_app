import 'dart:ui';

class GlitterParticle {
  Offset position;
  double size;
  double opacity;
  double angle;

  GlitterParticle({
    required this.position,
    this.size = 3.0,
    this.opacity = 1.0,
    this.angle = 0.0,
  });
}
