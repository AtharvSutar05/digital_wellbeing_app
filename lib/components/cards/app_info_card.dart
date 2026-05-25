import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage_event.dart';
import 'package:wellbeing_app/models/custom_app_info.dart';
import 'package:wellbeing_app/services/app_info_service.dart';
import 'package:wellbeing_app/utils/app_constants.dart';
import '../dialogs/set_app_daily_limit_dialog.dart';

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
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(0xFFEDEEED),
          titlePadding: const EdgeInsets.only(left: 24, right: 24, top: 16),
          contentPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
              Text(
                appInfo.name,
                style: const TextStyle(
                  color: Color(0xFF191C1C),
                  fontFamily: "Manrope",
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.28,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.white,
                      content: Text(
                        "This feature is coming soon!!!",
                        style: TextStyle(
                          color: Color(0xFF191C1C),
                          fontFamily: "Manrope",
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          letterSpacing: 0.28,
                        ),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                leading: const Icon(Icons.folder),
                title: const Text(
                  "Move to Category",
                  style: TextStyle(
                    color: Color(0xFF191C1C),
                    fontFamily: "Manrope",
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.28,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  final bloc = context.read<AppUsageBloc>();
                  final messenger = ScaffoldMessenger.of(context);
                  bloc.add(
                    UpdateTracking(
                      packageName: appInfo.packageName,
                      isTracking: false,
                    ),
                  );
                  Navigator.pop(context);
                  messenger.showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.white,
                      content: Text(
                        "${appInfo.name} removed from tracking",
                        style: TextStyle(
                          color: Color(0xFF191C1C),
                          fontFamily: "Manrope",
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          letterSpacing: 0.28,
                        ),
                      ),
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: Colors.blue,
                        onPressed: () {
                          bloc.add(
                            UpdateTracking(
                              packageName: appInfo.packageName,
                              isTracking: true,
                            ),
                          );
                        },
                      ),
                      showCloseIcon: true,
                      closeIconColor: const Color(0xFF191C1C),
                      duration: const Duration(seconds: 5),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                leading: const Icon(Icons.visibility_off),
                title: const Text(
                  "Hide from Tracking",
                  style: TextStyle(
                    color: Color(0xFF191C1C),
                    fontFamily: "Manrope",
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                      letterSpacing: 0.28,
                    ),
                  ),
                  if (appInfo.dailyLimit != null) const SizedBox(height: 4),
                  if (appInfo.dailyLimit != null)
                    LinearProgressIndicator(
                      value: appInfo.usage.inMinutes / appInfo.dailyLimit! > 1
                          ? 1
                          : appInfo.usage.inMinutes / appInfo.dailyLimit!,
                      color: appInfo.usage.inMinutes / appInfo.dailyLimit! > 1
                          ? const Color(0xFFC61F2B)
                          : const Color(AppConstants.primary),
                      backgroundColor: const Color(AppConstants.tertiary),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  if (appInfo.dailyLimit != null) const SizedBox(height: 2),
                  RichText(
                    textDirection: TextDirection.rtl,
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style.copyWith(
                        color: const Color(0xFF191C1C),
                        fontFamily: "Manrope",
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.28,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: AppConstants.formatDuration(
                            usage: appInfo.usage,
                            showSeconds: false,
                          ),
                        ),
                        if (appInfo.dailyLimit != null)
                          TextSpan(
                            text:
                                " / ${AppConstants.formatDuration(usage: Duration(minutes: appInfo.dailyLimit!))}",
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: () {
                showSetAppTimerDialog(
                  context: context,
                  appName: appInfo.name,
                  initialHours: 0,
                  initialMinutes: 30,
                  dailyLimit: appInfo.dailyLimit,
                  onConfirm: (totalMinutes) {
                    context.read<AppUsageBloc>().add(
                      UpdateDailyLimit(
                        packageName: appInfo.packageName,
                        dailyLimit: totalMinutes,
                      ),
                    );
                  },
                  onDeleteTimer: () {
                    context.read<AppUsageBloc>().add(
                      UpdateDailyLimit(
                        packageName: appInfo.packageName,
                        dailyLimit: null,
                      ),
                    );
                  },
                );
              },
              child: Icon(
                appInfo.dailyLimit == null
                    ? Icons.hourglass_empty_rounded
                    : appInfo.usage.inMinutes < appInfo.dailyLimit!
                    ? Icons.hourglass_top_rounded
                    : Icons.hourglass_bottom_rounded,
                size: 20,
                color: Color(0xFF191C1C),
              ),
            ),
          ],
        ),
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
