import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// HUD scanline overlay.
class ScanlineOverlay extends StatelessWidget {
  final double opacity;

  const ScanlineOverlay({super.key, this.opacity = 0.3});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _ScanlinePainter(),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.02)
      ..style = PaintingStyle.fill;

    const lineHeight = 2.0;
    const gap = 4.0;

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, lineHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Atmospheric background with floating colored blurs.
class AtmosphericBackground extends StatelessWidget {
  const AtmosphericBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -40,
            left: -60,
            child: _BlurCircle(
              color: AppColors.primary,
              size: 200,
              opacity: 0.05,
            ),
          ),
          Positioned(
            bottom: -40,
            right: -60,
            child: _BlurCircle(
              color: AppColors.secondary,
              size: 250,
              opacity: 0.05,
            ),
          ),
          Positioned(
            top: 200,
            right: 40,
            child: _BlurCircle(
              color: AppColors.tertiary,
              size: 120,
              opacity: 0.03,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _BlurCircle({
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: size * 0.6,
            spreadRadius: size * 0.2,
          ),
        ],
      ),
    );
  }
}
