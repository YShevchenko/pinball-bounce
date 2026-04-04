import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Wraps a child with a neon glow effect.
class NeonGlow extends StatelessWidget {
  final Widget child;
  final Color color;
  final double blurRadius;
  final double spreadRadius;
  final BorderRadius borderRadius;

  const NeonGlow({
    super.key,
    required this.child,
    this.color = AppColors.primaryGlow,
    this.blurRadius = 20,
    this.spreadRadius = 0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Applies a neon text shadow.
class NeonText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color glowColor;
  final double blurRadius;

  const NeonText(
    this.text, {
    super.key,
    this.style,
    this.glowColor = AppColors.primaryGlow,
    this.blurRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.headlineLarge!;
    return Text(
      text,
      style: baseStyle.copyWith(
        shadows: [
          Shadow(color: glowColor, blurRadius: blurRadius),
          Shadow(
            color: glowColor.withValues(alpha: 0.5),
            blurRadius: blurRadius * 2,
          ),
        ],
      ),
    );
  }
}
