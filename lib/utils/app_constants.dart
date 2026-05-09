import 'dart:core';
import 'package:flutter/material.dart';

class AppConstants {
  static final ThemeData themeData = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
  );
  static final int primary = 0xFF32645E;
  static final int secondary = 0xFF8EACC1;
  static String formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;

    if(minutes == 0) return "${seconds}s";
    if (hours == 0) return "${minutes}m";
    return "${hours}h ${minutes}m";
  }
  static double findPercentage(int goal, int totalUsage) {
    return totalUsage/goal;
  }
}
