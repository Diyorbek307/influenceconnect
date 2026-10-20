import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Живой анимированный градиентный фон с плавающими светящимися «орбами».
/// Создаёт «вау»-эффект на экранах до входа (заставка, онбординг, выбор роли).
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 12))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value * 2 * math.pi;
        return Stack(
          fit: StackFit.expand,
          children: [
            // Движущийся базовый градиент
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(math.sin(t), math.cos(t)),
                  end: Alignment(-math.sin(t), -math.cos(t)),
                  colors: const [
                    Color(0xFFFF2D74),
                    Color(0xFFFF6A4D),
                    Color(0xFF8B3DFF),
                  ],
                ),
              ),
            ),
            // Плавающие орбы
            _orb(context, const Color(0xFFFF8A3D), 260,
                0.2 + 0.25 * math.sin(t), 0.15 + 0.2 * math.cos(t * 0.8)),
            _orb(context, const Color(0xFFB02DFF), 320,
                0.8 + 0.2 * math.cos(t * 1.2), 0.75 + 0.2 * math.sin(t)),
            _orb(context, const Color(0xFFFF2D74), 220,
                0.75 + 0.2 * math.sin(t * 1.5), 0.2 + 0.2 * math.cos(t)),
            widget.child,
          ],
        );
      },
    );
  }

  Widget _orb(BuildContext context, Color color, double size, double fx,
      double fy) {
    final s = MediaQuery.of(context).size;
    return Positioned(
      left: fx * s.width - size / 2,
      top: fy * s.height - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
