import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// Neon-styled button matching the Neon Pulse design.
class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isLarge;
  final Color? color;
  final bool hapticEnabled;

  const NeonButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isLarge = false,
    this.color,
    this.hapticEnabled = true,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? AppColors.primary;
    final height = widget.isLarge ? 64.0 : 52.0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          if (widget.hapticEnabled) HapticFeedback.lightImpact();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [buttonColor, buttonColor.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: buttonColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: AppColors.onPrimaryFixed, size: 24),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.onPrimaryFixed,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary outlined button for less prominent actions.
class NeonOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  final bool hapticEnabled;

  const NeonOutlinedButton({
    super.key,
    required this.label,
    required this.onTap,
    this.leadingIcon,
    this.hapticEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (hapticEnabled) HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurface,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
