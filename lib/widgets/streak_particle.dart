import 'dart:math';
import 'package:flutter/material.dart';

class StreakParticleBurst extends StatefulWidget {
  final int streakCount;

  const StreakParticleBurst({super.key, required this.streakCount});

  @override
  State<StreakParticleBurst> createState() => _StreakParticleBurstState();
}

class _StreakParticleBurstState extends State<StreakParticleBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  static const int _particleCount = 18;
  static const List<int> _milestones = [7, 21, 30, 60, 100];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    if (_milestones.contains(widget.streakCount)) {
      _generateParticles();
      _controller.forward();
    }
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < _particleCount; i++) {
      final angle = (2 * pi * i) / _particleCount;
      final speed = 40.0 + _random.nextDouble() * 60;
      _particles.add(_Particle(
        angle: angle,
        speed: speed,
        size: 2.0 + _random.nextDouble() * 4,
        delay: _random.nextDouble() * 0.3,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_milestones.contains(widget.streakCount)) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              progress: _controller.value,
            ),
          ),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final double delay;

  const _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.delay,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  const _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..color = Colors.black;

    for (final particle in particles) {
      final t = (progress - particle.delay).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final curve = Curves.easeOut.transform(t);
      final alpha = (1.0 - t).clamp(0.0, 1.0);

      paint.color = Colors.black.withValues(alpha: alpha);

      final dx = cos(particle.angle) * particle.speed * curve;
      final dy = sin(particle.angle) * particle.speed * curve;

      canvas.drawCircle(
        center + Offset(dx, dy),
        particle.size * (1 - t * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) {
    return old.progress != progress;
  }
}
