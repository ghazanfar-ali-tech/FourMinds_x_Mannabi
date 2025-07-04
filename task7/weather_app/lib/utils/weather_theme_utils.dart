import 'package:flutter/material.dart';

BoxDecoration getWeatherBackground(String condition) {
  condition = condition.toLowerCase();

  if (condition.contains('rain') || condition.contains('drizzle') || condition.contains('shower')) {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF1e3c72), // Deep navy blue
          Color(0xFF2a5298), // Rich blue
          Color(0xFF4a90a4), // Soft teal
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
      ),
    );
  } else if (condition.contains('clear') || condition.contains('sunny')) {
    return const BoxDecoration(
        gradient: LinearGradient(
        colors: [Color(0xFFFFE000), Color(0xFFFFA500), Color(0xFFFF4500)], // Bright golden to orange
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  } else if (condition.contains('cloud')) {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF74b9ff), // Sky blue
          Color(0xFFa29bfe), // Lavender
          Color(0xFF6c5ce7), // Purple
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.7, 1.0],
      ),
    );
  } else if (condition.contains('snow') || condition.contains('ice')) {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFFddd6fe), // Soft lavender
          Color(0xFF93c5fd), // Light blue
          Color(0xFF60a5fa), // Bright blue
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
      ),
    );
  } else if (condition.contains('thunder') || condition.contains('storm')) {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF1a1a2e), // Dark navy
          Color(0xFF16213e), // Deep blue
          Color(0xFF0f3460), // Electric blue
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.6, 1.0],
      ),
    );
  } else if (condition.contains('fog') || condition.contains('mist') || condition.contains('haze')) {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF667eea), // Soft purple-blue
          Color(0xFF764ba2), // Muted purple
          Color(0xFF8e44ad), // Rich purple
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.5, 1.0],
      ),
    );
  } else {
    // Modern dark theme with subtle accent
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF2c3e50), // Dark blue-gray
          Color(0xFF34495e), // Medium blue-gray
          Color(0xFF4a6741), // Dark green accent
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.7, 1.0],
      ),
    );
  }
}

// Enhanced version with additional weather conditions and animations support
BoxDecoration getWeatherBackgroundEnhanced(String condition, {bool isNight = false}) {
  condition = condition.toLowerCase();

  // Night mode variations
  if (isNight) {
    if (condition.contains('rain') || condition.contains('drizzle') || condition.contains('shower')) {
      return const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0c0c0c), // Deep black
            Color(0xFF1a1a2e), // Dark navy
            Color(0xFF16213e), // Midnight blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
      );
    } else if (condition.contains('clear')) {
      return const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0f0f23), // Deep night
            Color(0xFF1a1a2e), // Dark navy
            Color(0xFF16213e), // Midnight blue
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.6, 1.0],
        ),
      );
    }
  }

  // Day mode (same as above but with additional conditions)
  if (condition.contains('rain') || condition.contains('drizzle') || condition.contains('shower')) {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF1e3c72),
          Color(0xFF2a5298),
          Color(0xFF4a90a4),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
      ),
    );
  } else if (condition.contains('clear') || condition.contains('sunny')) {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFFffeaa7),
          Color(0xFFfab1a0),
          Color(0xFFfd79a8),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.6, 1.0],
      ),
    );
  } else if (condition.contains('cloud')) {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF74b9ff),
          Color(0xFFa29bfe),
          Color(0xFF6c5ce7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.7, 1.0],
      ),
    );
  } else if (condition.contains('snow') || condition.contains('ice')) {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFFddd6fe),
          Color(0xFF93c5fd),
          Color(0xFF60a5fa),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
      ),
    );
  } else if (condition.contains('thunder') || condition.contains('storm')) {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF1a1a2e),
          Color(0xFF16213e),
          Color(0xFF0f3460),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.6, 1.0],
      ),
    );
  } else if (condition.contains('fog') || condition.contains('mist') || condition.contains('haze')) {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF667eea),
          Color(0xFF764ba2),
          Color(0xFF8e44ad),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.5, 1.0],
      ),
    );
  } else if (condition.contains('wind')) {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF00c6fb), // Cyan
          Color(0xFF005bea), // Deep blue
          Color(0xFF4834d4), // Purple
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
      ),
    );
  } else {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF2c3e50),
          Color(0xFF34495e),
          Color(0xFF4a6741),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.7, 1.0],
      ),
    );
  }
}