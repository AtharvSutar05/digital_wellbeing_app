import 'dart:core';
import 'package:flutter/material.dart';

class AppConstants {
  static final ThemeData themeData = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
  );
  static const int primary = 0xFF32645E;
  static const int secondary = 0xFF8EACC1;
  static const int tertiary = 0xFFD8E2DC;
  static String formatDuration({
    required Duration usage,
    bool showSeconds = true,
  }) {
    final hours = usage.inHours;
    final minutes = usage.inMinutes % 60;
    final seconds = usage.inSeconds % 60;

    if (hours > 0) {
      return minutes == 0 ? "${hours}h" : "${hours}h ${minutes}m";
    }

    if (minutes > 0) {
      return showSeconds && seconds != 0
          ? "${minutes}m ${seconds}s"
          : "${minutes}m";
    }

    return showSeconds ? "${seconds}s" : "Less than a minute";
  }

  static double findPercentage(int goal, int totalUsage) {
    return totalUsage / goal;
  }
}
