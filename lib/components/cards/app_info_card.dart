import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:wellbeing_app/models/custom_app_info.dart';
import 'package:wellbeing_app/services/app_info_service.dart';
import 'package:wellbeing_app/utils/app_constants.dart';

class AppInfoCard extends StatelessWidget {
  final Duration totalUsage;
  final CustomAppInfo appInfo;
  const AppInfoCard({
    super.key,
    required this.appInfo,
    required this.totalUsage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEED),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AppIconWidget(packageName: appInfo.packageName),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appInfo.name,
                  style: const TextStyle(
                    color: Color(0xFF191C1C),
                    fontFamily: "Manrope",
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 0,
                    letterSpacing: 0.28,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppConstants.formatDuration(usage: appInfo.usage),
                  style: const TextStyle(
                    color: Color(0xFF191C1C),
                    fontFamily: "Manrope",
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 0,
                    letterSpacing: 0.28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(Icons.hourglass_top_rounded, size: 20, color: Color(0xFF191C1C),),
        ],
      ),
    );
  }
}

class AppIconWidget extends StatelessWidget {
  final String packageName;

  const AppIconWidget({super.key, required this.packageName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: AppInfoService().getAppIcon(packageName),

      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(snapshot.data!, fit: BoxFit.cover),
          );
        }

        if (snapshot.hasError) {
          return const Icon(Icons.broken_image);
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: const Color(0xFFE1E3E2),
            child: const Icon(Icons.apps),
          ),
        );
      },
    );
  }
}
