import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:wellbeing_app/utils/app_constants.dart';

class CircularProgressIndicatorWidget extends StatelessWidget {
  final double percent;
  final Duration totalUsage;
  final int progress; // + / -
  const CircularProgressIndicatorWidget({
    super.key,
    required this.percent,
    required this.totalUsage,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 110.0,
      lineWidth: 12,
      percent: percent,
      circularStrokeCap: CircularStrokeCap.round,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Today",
            style: TextStyle(
              color: Color(0xFF404847),
              fontFamily: "Manrope",
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          ),
          Text(
            AppConstants.formatDuration(usage: totalUsage),
            style: const TextStyle(
              color: Color(0xFF191C1C),
              fontFamily: "Manrope",
              fontWeight: FontWeight.w300,
              fontSize: 48,
              letterSpacing: -0.96,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_downward_rounded,
                size: 14,
                color: Color(0xFF32645E),
              ),
              Text(
                "$progress% less", // + -> more , - -> less
                style: const TextStyle(
                  color: Color(0xFF32645E),
                  fontFamily: "Manrope",
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.28,
                ),
              ),
            ],
          ),
          const Text(
            "than yesterday",
            style: TextStyle(
              color: Color(0xFF32645E),
              fontFamily: "Manrope",
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.28,
            ),
          ),
        ],
      ),
      progressColor: Color(AppConstants.primary),
    );
  }
}
