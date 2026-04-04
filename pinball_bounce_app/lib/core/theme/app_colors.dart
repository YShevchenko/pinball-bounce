import 'package:flutter/material.dart';

/// Neon Pulse color palette — Pinball Bounce variant.
abstract final class AppColors {
  // Core surfaces
  static const background = Color(0xFF0E0E13);
  static const surface = Color(0xFF0E0E13);
  static const surfaceContainer = Color(0xFF19191F);
  static const surfaceContainerLow = Color(0xFF131318);
  static const surfaceContainerHigh = Color(0xFF1F1F25);
  static const surfaceContainerHighest = Color(0xFF25252C);
  static const surfaceContainerLowest = Color(0xFF000000);
  static const surfaceBright = Color(0xFF2C2B35);

  // Primary (neon cyan)
  static const primary = Color(0xFF8FF5FF);
  static const primaryContainer = Color(0xFF00EEFC);
  static const primaryDim = Color(0xFF00D4E0);
  static const onPrimary = Color(0xFF003840);
  static const onPrimaryFixed = Color(0xFF002830);
  static const neonCyan = Color(0xFF8FF5FF);

  // Secondary (hot pink)
  static const secondary = Color(0xFFFF59E3);
  static const secondaryContainer = Color(0xFFAD009B);
  static const onSecondary = Color(0xFF42003A);

  // Tertiary (NEON GREEN — unique to Pinball Bounce!)
  static const tertiary = Color(0xFFA1FFC2);
  static const tertiaryContainer = Color(0xFF00FC9A);
  static const tertiaryDim = Color(0xFF00CC7E);

  // Error
  static const error = Color(0xFFFF716C);
  static const errorContainer = Color(0xFF9F0519);
  static const onErrorContainer = Color(0xFFFFA8A3);

  // Text / surface
  static const onSurface = Color(0xFFF9F5FD);
  static const onSurfaceVariant = Color(0xFFACAAB1);
  static const onBackground = Color(0xFFF9F5FD);
  static const outline = Color(0xFF76747B);
  static const outlineVariant = Color(0xFF48474D);

  // Glow presets (for BoxShadow / TextShadow)
  static const primaryGlow = Color(0x668FF5FF);
  static const primaryGlowStrong = Color(0x9900EEFC);
  static const secondaryGlow = Color(0x44FF59E3);
  static const tertiaryGlow = Color(0x44A1FFC2);

  // Game-specific
  static const ballColor = Color(0xFF8FF5FF);
  static const bumperColor = Color(0xFFFF59E3);
  static const targetColor = Color(0xFFA1FFC2);
  static const targetClearedColor = Color(0xFF00FC9A);
  static const flipperColor = Color(0xFFE0E0E8);
  static const wallColor = Color(0xFF48474D);
  static const gridColor = Color(0xFF1A1A22);
  static const scoreGlow = Color(0xFF8FF5FF);
}
