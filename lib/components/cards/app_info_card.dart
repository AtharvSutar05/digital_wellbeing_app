import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:wellbeing_app/models/app_info.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AppIconWidget(
              packageName: appInfo.packageName,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appInfo.name,
                      style: const TextStyle(
                        color: Color(0xFF191C1C),
                        fontFamily: "Manrope",
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 0,
                        letterSpacing: 0.28,
                      ),
                    ),
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
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: AppConstants.findPercentage(
                    totalUsage.inSeconds,
                    appInfo.usage.inSeconds,
                  ),
                  minHeight: 6,
                  color: Color(AppConstants.primary),
                  borderRadius: BorderRadius.circular(6),
                  backgroundColor: const Color(0xFFE1E3E2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppIconWidget extends StatelessWidget {
  final String packageName;

  const AppIconWidget({
    super.key,
    required this.packageName,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: AppInfoService().getAppIcon(packageName),

      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            ),
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
