import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF1E88E5); // Deep blue for primary elements
  static const Color primaryBlueDark = Color(0xFF1565C0); // Darker shade for hover/pressed
  static const Color primaryBlueLight = Color(0xFF4FC3F7); // Lighter shade for highlights

  // Accent Colors
  static const Color accentCyan = Color(0xFF00BCD4); // Cyan for buttons and highlights
  static const Color accentCyanLight = Color(0xFF4DD0E1); // Lighter cyan for gradients

  // Background Colors
  static const Color backgroundDark = Color(0xFF121212); // Dark background for camera
  static const Color glassBackground = Color(0x33FFFFFF); // Semi-transparent white for glass effect
  static const Color glassErrorBackground = Color(0x55EF5350); // Semi-transparent red for errors

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // White for primary text
  static const Color textSecondary = Color(0xFFB0BEC5); // Light gray for secondary text

  // Shadows and Borders
  static const Color shadowColor = Color(0x4D000000); // Semi-transparent black for shadows
  static const Color borderColor = Color(0x33FFFFFF); // Semi-transparent white for borders

  // Gradient for Buttons
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primaryBlue, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradient for Overlay
  static const LinearGradient overlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      backgroundDark,
      Colors.transparent,
      backgroundDark,
    ],
  );
}